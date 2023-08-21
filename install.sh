#!/usr/bin/env bash
set -e

# Specify your tool name and directory name
<<<<<<< HEAD
TOOL_NAME="cognisyn"
TOOL_DIR_NAME="cognisyn"
=======
>>>>>>> 4610987b7014f8f324dbf010cdf7ffc2a66855f2

main() {
	BIN_DIR=${BIN_DIR-"$HOME/.bin"} # Change the directory name if desired
	mkdir -p "$BIN_DIR"

	case $SHELL in
	*/zsh)
		PROFILE=$HOME/.zshrc
		;;
	*/bash)
		PROFILE=$HOME/.bashrc
		;;
	*/fish)
		PROFILE=$HOME/.config/fish/config.fish
		;;
	*/ash)
		PROFILE=$HOME/.profile
		;;
	*)
		echo "could not detect shell, manually add ${BIN_DIR} to your PATH."
		exit 1
		;;
	esac

	if [[ ":$PATH:" != *":${BIN_DIR}:"* ]]; then
		echo >>"$PROFILE" && echo "export PATH=\"\$PATH:$BIN_DIR\"" >>"$PROFILE"
	fi

	PLATFORM="$(uname -s)"
	case $PLATFORM in
	Linux)
		PLATFORM="linux"
		;;
	Darwin)
		PLATFORM="darwin"
		;;
	*)
		err "unsupported platform: $PLATFORM"
		;;
	esac

	ARCHITECTURE="$(uname -m)"
	# Your custom architecture handling here if needed

	if [ "${ARCHITECTURE}" = "x86_64" ]; then
		# Redirect stderr to /dev/null to avoid printing errors if non Rosetta.
		if [ "$(sysctl -n sysctl.proc_translated 2>/dev/null)" = "1" ]; then
			ARCHITECTURE="aarch64" # Rosetta.
		else
			ARCHITECTURE="x86_64" # Intel.
		fi
	elif [ "${ARCHITECTURE}" = "arm64" ] || [ "${ARCHITECTURE}" = "aarch64" ]; then
		ARCHITECTURE="aarch64" # Arm.
	else
		ARCHITECTURE="x86_64" # Amd.
	fi

	# Construct the URL for downloading the release archive from GitHub
	BINARY_URL="https://github.com/rufevean/cognisyn/releases/latest/download/cognisyn-${PLATFORM}-${ARCHITECTURE}.tar.gz"
	echo "$BINARY_URL"

	echo "downloading latest binary"
	ensure curl -L "$BINARY_URL" -o "$BIN_DIR/cognisyn"
	chmod +x "$BIN_DIR/$TOOL_NAME"

	echo "installed - $("$BIN_DIR/$TOOL_NAME" --version)"
}

# Run a command that should never fail.
ensure() {
	if ! "$@"; then err "command failed: $*"; fi
}

main "$@" || exit 1