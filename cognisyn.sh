#!/bin/bash
set -e

# Define variables
APP_NAME="cognisyn"
BIN_DIR=${BIN_DIR-"$HOME/.bin"}
INSTALL_DIR="$BIN_DIR/$APP_NAME"
PROFILE_FILE=""

# Temporary file to capture output
OUTPUT_FILE=$(mktemp)

# Redirect output and errors to the temporary file
exec &> >(tee "$OUTPUT_FILE")

# Detect the user's shell
detect_shell() {
	case "$SHELL" in
	*/zsh)
		PROFILE_FILE="$HOME/.zshrc"
		;;
	*/bash)
		PROFILE_FILE="$HOME/.bashrc"
		;;
	*/fish)
		PROFILE_FILE="$HOME/.config/fish/config.fish"
		;;
	*/ash)
		PROFILE_FILE="$HOME/.profile"
		;;
	*)
		echo "Could not detect shell. You need to manually add $INSTALL_DIR to your PATH."
		exit 1
		;;
	esac
}

# Add app installation directory to user's PATH
add_to_path() {
	if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
		echo >>"$PROFILE_FILE"
		echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >>"$PROFILE_FILE"
	fi
	source "$PROFILE_FILE"
	echo "Added $INSTALL_DIR to your PATH."
}

# Install Rust if not already installed
install_rust() {
	if ! command -v cargo &>/dev/null; then
		echo "Installing Rust..."
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
		source "$HOME/.cargo/env"
		echo "Rust installation complete."
	fi
}

# Clone and compile the Rust program
compile_app() {
	echo "Cloning and compiling the $APP_NAME application..."
	git clone https://github.com/rufevean/cognisyn.git "$APP_NAME"
	cd "$APP_NAME"
	cargo build --release
	cd ..
	echo "$APP_NAME compilation complete."
}

# Main function
main() {
	detect_shell
	mkdir -p "$BIN_DIR"
	install_rust
	compile_app
	mv "$APP_NAME/target/release/cognisyn" "$INSTALL_DIR"
	chmod +x "$INSTALL_DIR"

	add_to_path

	echo "Installed $APP_NAME CLI app."
	echo "You can now use '$APP_NAME' command in your terminal."

	# Clean up
	rm -rf "$APP_NAME"
}

main "$@"

# Display captured output
cat "$OUTPUT_FILE"

# Clean up
rm "$OUTPUT_FILE"
