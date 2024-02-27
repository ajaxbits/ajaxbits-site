default: dev

dev-tailwind:
    tailwindcss -i assets/css/main.css -o static/css/styles.css --watch=always

dev-server:
    hugo server --buildDrafts

dev:
    #!/bin/sh
    just dev-tailwind &
    TAILWIND_PID="$!"
    just dev-server &
    SERVER_PID="$!"

    trap "kill $TAILWIND_PID $SERVER_PID" EXIT
    wait $TAILWIND_PID $SERVER_PID

get-fonts:
    nix build .#fonts
    sudo cp -r result/woff2/* static/fonts/.
    sudo chown $USER static/fonts/*

pin-npm-deps:
    bun install --yarn