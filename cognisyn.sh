#!/bin/bash
set -e

# Define variables
APP_NAME="cognisyn"
BIN_DIR=${BIN_DIR-"$HOME/.bin"}
INSTALL_DIR="$BIN_DIR/$APP_NAME"
PROFILE_FILE=""

# Detect OS and set shell-specific variables
detect_environment() {
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		PROFILE_FILE="$HOME/.zshrc" # Default to Zsh on Linux
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		PROFILE_FILE="$HOME/.zshrc" # Default to Zsh on macOS
	elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
		PROFILE_FILE="$HOME/.bashrc" # Default to Bash on Windows
	else
		echo "Unsupported OS. Please manually configure your shell."
		exit 1
	fi
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
		if [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
			echo "Rust installation on Windows is not supported. Please install Rust manually."
			exit 1
		else
			echo "Installing Rust..."
			curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
			source "$HOME/.cargo/env"
			echo "Rust installation complete."
		fi
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
	detect_environment
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
