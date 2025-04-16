PATH=$(dirname "$0")
nix flake update
darwin-rebuild switch --flake $PATH#Zumpyx
