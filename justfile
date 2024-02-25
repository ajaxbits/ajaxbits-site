default: dev

dev:
    hugo server --buildDrafts
    
get-fonts:
    nix build .#fonts
    sudo cp -r result/woff2/* static/fonts/.