#!@zsh@/bin/zsh

source "@epnix_commands_lib@/libexec/epnix/commands-lib.sh"

GIT="@git@/bin/git"

toplevel="$(realpath -s .)"

if [[ ! -f "epnix.toml" ]]; then
	fatal "Could not find 'epnix.toml' file. Are you in an EPNix project?"
fi

app_names=(@app_names@)

# TODO: check .roots.inputs instead of assuming name stayed the same in lock file
jq_script='
.nodes | to_entries[] | if .value.locked.type == "github" then
	"\(.key) ssh://git@github.com/\(.value.locked.owner)/\(.value.locked.repo).git \(.value.locked.rev)"
elif .value.locked.type == "git" then
	"\(.key) \(.value.locked.url) \(.value.locked.rev)"
else
	null
end
'

git_infos="$(jq -r "$jq_script" < flake.lock)"

typeset -A local_git_urls
typeset -A local_git_revs
typeset -A local_git_refs

for git_info in "${(f)git_infos}"; do
	if [[ "$git_info" == "null" || "$git_info" == "" ]]; then
		debug "Found not-supported input"
		continue
	fi

	git_info=("${(z)git_info}")

	input_name="${git_info[1]}"
	url="${git_info[2]}"
	rev="${git_info[3]}"
	ref="${git_info[4]:-}"

	debug "Found flake input: Name: '$input_name', URL: '$url', Rev: '$rev'"

	local_git_urls[$input_name]="$url"
	local_git_revs[$input_name]="$rev"
	local_git_refs[$input_name]="$ref"
done

update_local_git_project() {
	local path="$1"
	local upstream="$2"
	local rev="$3"
	local ref="$4"

	debug "Path: '$path', Upstream: '$upstream', Ref: '$rev'"

	if [ -e "$path" ]; then
		if ! [ -e "$path/.git" ]; then
			warn "'$path' exists but is not a Git repository, doing nothing"
			return 0
		fi

		actual_rev="$($GIT -C "$path" rev-parse HEAD)"

		if [[ "$rev" != "$actual_rev" ]]; then
			warn "Project '$path' is checked-out at revision '${(r:7:)actual_rev}' but 'flake.lock' specifies '${(r:7:)rev}'.
Please either update your 'flake.lock' using 'nix flake update --update-input $path'
Or run 'git checkout ${(r:7:)rev}' to avoid having differences between 'nix build' and 'emake'"
		fi

		debug "Skipping update of '$path'"
		return 0
	fi

	info "Cloning '$upstream' into '$path'"
	$GIT clone "$upstream" "$path"
}

for app_name in "${app_names[@]}"; do
	debug "Trying to find flake input for '$app_name'"

	if ! (( ${+local_git_urls[$app_name]} )); then
		warn "Could not find app '$app_name' in 'flake.lock' inputs, not cloning"
		continue
	fi

	update_local_git_project \
		"$app_name" \
		"${local_git_urls[$app_name]}" \
		"${local_git_revs[$app_name]}" \
		"${local_git_refs[$app_name]}"
done
