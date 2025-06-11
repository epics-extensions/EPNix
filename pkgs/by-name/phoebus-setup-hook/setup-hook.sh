# shellcheck shell=bash

installPhoebusJar() {
	local path="$1"
	local jarName="$2"
	local name="$3"
	local mainClass="$4"

	mkdir -p "$out/share/java"

	local jarDeps=("$path"/target/lib/*.jar)
	if (( ${#jarDeps[*]} )); then
		local depsPath="$out/share/java/$name/deps"
		mkdir -p "$depsPath"
		cp "${jarDeps[@]}" "$depsPath"
	fi

	echo "installing Phoebus jar into $out/share/java/$jarName"
	install -Dm644 "$path/target/$jarName" "$out/share/java"

	echo "making wrapper script bin/$name"
	# Don't call the jar, since the manifest inside the jar overrides the classpath
	makeWrapper "@jdk@/bin/java" "$out/bin/$name" \
		--add-flags "-classpath $out/share/java/$jarName:$depsPath/*" \
		--add-flags '${JAVA_OPTS}' \
		--add-flags "$mainClass"
}
