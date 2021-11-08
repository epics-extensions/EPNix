set -euo pipefail
IFS=$'\n\t'

tput() {
	# If tput fails, it just means less colors
	@ncurses@/bin/tput "$@" 2> /dev/null || true
}

NORMAL="$(tput sgr0)"
BOLD="$(tput bold)"

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
PURPLE="$(tput setaf 5)"
CYAN="$(tput setaf 6)"
WHITE="$(tput setaf 7)"

echoe() {
	echo "$@" >&2
}

debug() {
	if [ "${EPNIX_DEBUG:-0}" -ge 1 ]; then
		echoe "${BOLD}${GREEN}Debug: ${WHITE}${@}${NORMAL}"
	fi
}

info() {
	echoe "${BOLD}${CYAN}Info: ${WHITE}${@}${NORMAL}"
}

warn() {
	echoe "${BOLD}${YELLOW}Warning: ${WHITE}${@}${NORMAL}"
}

error() {
	echoe "${BOLD}${RED}Error: ${WHITE}${@}${NORMAL}"
}

fatal() {
	error "$@"
	exit 1
}
