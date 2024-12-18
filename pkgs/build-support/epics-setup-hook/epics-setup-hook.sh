epicsConfigurePhase() {
	runHook preConfigure

	if ! [[ -v enableParallelBuilding ]]; then
		enableParallelBuilding=1
	fi

	appendToVar makeFlags "INSTALL_LOCATION=$out"

	stripDebugList+=("bin/@host_arch@" "lib/@host_arch@")

	# Ensure reproducibility when running Perl scripts that generate files,
	# during the build.
	export PERL_HASH_SEED=0

	# This variable is used as a default version revision if no VCS is found.
	#
	# Since fetchgit and related fetchers remove the .git directory for
	# reproducibility, EPICS fallsback to either the GENVERSIONDEFAULT variable
	# if set (not the default), or the current date/time, which isn't
	# reproducible.
	echo 'GENVERSIONDEFAULT="EPNix"' >configure/CONFIG_SITE.local

	# This prevents EPICS from detecting installed libraries on the host
	# system, for when Nix is compiling without sandbox (e.g.: WSL2)
	echo 'GNU_DIR="/var/empty"' >>configure/CONFIG_SITE.local

	if [[ "@build_arch@" != "@host_arch@" ]]; then
		stripDebugList+=("bin/@build_arch@" "lib/@build_arch@")

		# Tell EPICS we are compiling to the given architecture.
		# "host" as in Nix terminology (the machine which will run the generated code)
		echo 'CROSS_COMPILER_TARGET_ARCHS="@host_arch@"' >>configure/CONFIG_SITE.local
	fi

	echo "${local_config_site-}" >>configure/CONFIG_SITE.local

	# Undefine the SUPPORT variable here, since there is no single "support"
	# directory and this variable is a source of conflicts between RELEASE files
	echo "undefine SUPPORT" >configure/RELEASE.local

	echo "${local_release-}" >>configure/RELEASE.local

	# set to empty if unset
	: "''${EPICS_COMPONENTS=}"

	# For each EPICS-specific package (e.g. asyn, StreamDevice),
	# add it to the 'configure/RELEASE.local' file
	IFS=: read -ra components <<<"$EPICS_COMPONENTS"
	for component in "${components[@]}"; do
		echo "$component" >>configure/RELEASE.local
	done

	echo "=============================="
	echo "CONFIG_SITE.local"
	echo "------------------------------"
	cat "configure/CONFIG_SITE.local"
	echo "=============================="
	echo "RELEASE.local"
	echo "------------------------------"
	cat "configure/RELEASE.local"
	echo "------------------------------"

	runHook postConfigure
}

if [ -z "${dontUseEpicsConfigure-}" ] && [ -z "${configurePhase-}" ]; then
	configurePhase=epicsConfigurePhase
fi

epicsInstallPhase() {
	runHook preInstall

	# Don't do a manual `make install`, `make` already installs
	# everything into `INSTALL_LOCATION`.

	runHook postInstall
}

if [ -z "${dontUseEpicsInstall-}" ] && [ -z "${installPhase-}" ]; then
	installPhase=epicsInstallPhase
fi

# Automatically create binaries directly in `bin/` that calls the ones that
# are in `bin/linux-x86_64/`
# TODO: we should probably do the same for libraries
epicsInstallProgramsHook() {
	echo "Installing programs in 'bin/@host_arch@' to 'bin'..."
	if [[ -d "$out/bin/@host_arch@" ]]; then
		for file in "$out/bin/@host_arch@/"*; do
			[[ -x "$file" ]] || continue

			echo "Installing program '$(basename "$file")' to 'bin'"
			makeWrapper "$file" "$out/bin/$(basename "$file")"
		done
	fi
}

if [ -z "${dontInstallPrograms-}" ]; then
	postInstallHooks+=(epicsInstallProgramsHook)
fi

epicsInstallIocBootHook() {
	if [[ -d iocBoot ]]; then
		echo "Installing 'iocBoot' folder..."
		cp -rafv iocBoot -t "$out"
	else
		echo "No 'iocBoot' folder found, skipping"
	fi
}

if [ -z "${dontInstallIocBoot-}" ]; then
	postInstallHooks+=(epicsInstallIocBootHook)
fi
