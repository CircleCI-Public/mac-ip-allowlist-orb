#!/usr/bin/env bash

echo "Creating standard user..."

sudo sysadminctl -addUser "$PARAM_USERNAME" \
  -shell /bin/bash \
  -password "$(openssl rand -base64 16)"

echo "A user has been created with the username '$PARAM_USERNAME'"

echo "Installing Homebrew for '$PARAM_USERNAME'..."

sudo git clone -c core.sshCommand="ssh -o StrictHostKeyChecking=accept-new" https://github.com/Homebrew/brew.git "/Users/$PARAM_USERNAME/brew"
sudo chown -R "$PARAM_USERNAME" "/Users/$PARAM_USERNAME/brew"

# shellcheck disable=SC2016
echo 'export PATH="$HOME/brew/bin:$PATH"' | sudo tee -a "/Users/$PARAM_USERNAME/.bash_profile" > /dev/null

echo "Homebrew installed for '$PARAM_USERNAME'"

echo "Exporting shell functions to '$PARAM_USERNAME'..."
declare -f | sudo tee -a "/Users/$PARAM_USERNAME/.bash_profile" > /dev/null
echo "Shell functions exported to '$PARAM_USERNAME'"
