{ pkgs ? import <nixpkgs> {} }:

pkgs.writeScriptBin "install-xcode" ''
  #!${pkgs.bash}/bin/bash
  echo "🕑 Installing xcode command line tools."
  if ! command -v xcode-select -p >/dev/null; then
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
    softwareupdate -i "$PROD" --verbose
    rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    echo "✅ Xcode command line tools installed."
  else
    echo "⏩ Xcode command line tools seems to already be installed; skipping."
  fi 

  echo "🕑 Installing rosetta."
  if $(/usr/sbin/softwareupdate --install-rosetta --agree-to-license >/dev/null 2>&1); then
    echo "✅ Rosetta installed."
  else
    echo "❌ Rosetta failed to install."
  fi
''
