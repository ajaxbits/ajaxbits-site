+++
title = 'mkYarnModules in 2024'
date = 2024-02-27T11:17:29-06:00
draft = false
+++

As of today, the documentation for the `mkYarnModules` function in the [official `nixpkgs` docs](https://nixos.org/manual/nixpkgs/stable/#javascript-tool-specific) leaves something to be desired.

There's no introduction to the tool, an explanation of how it works, or any holistic examples/function signatures.

Through grepping the `nixos/nixpkgs` [GitHub](https://github.com/nixos/nixpkgs), I managed to create this a minimum viable usage example:

```nix
pkgs.mkYarnModules {
    pname = "myYarnProject";
    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;
    version = "0.0.0";
};
```

When you build this, you'll get a `result` like[^1]:

```
result
├── deps
│  └── myYarnProject
└── node_modules
   ├── myYarnProject -> ../deps/myYarnProject
   ├── example-dep-1
   ├── example-dep-2
   └── ... more deps ...
```

The whole function signature [here](https://github.com/NixOS/nixpkgs/blob/fc1b3a1e3e90cd2f28b2c9b48b6fe027ff64d232/pkgs/development/tools/yarn2nix-moretea/yarn2nix/default.nix#L63):

```nix
mkYarnModules = {
    name ? "${pname}-${version}", # safe name and version, e.g. testcompany-one-modules-1.0.0
    pname, # original name, e.g @testcompany/one
    version,
    packageJSON,
    yarnLock,
    yarnNix ? mkYarnNix { inherit yarnLock; },
    offlineCache ? importOfflineCache yarnNix,
    yarnFlags ? [ ],
    ignoreScripts ? true,
    nodejs ? inputs.nodejs,
    yarn ? inputs.yarn.override { inherit nodejs; },
    pkgConfig ? {},
    preBuild ? "",
    postBuild ? "",
    workspaceDependencies ? [], # List of yarn packages
    packageResolutions ? {},
}: {
    # ...
}
```

Note that you can pass in a `yarnNix` if you want to. This would be the nix expression resulting from running `yarn2nix` in the directory containing your `package.json` and `yarn.lock`. `mkYarnModules` will do this for you, but I could see this information being handy to get me out of a jam one day.

## Why this came up

I'm using this to get [`bun`](https://bun.sh) support in my project.

Bun is super fast. It's honestly hard to use `npm` now for dependency resolution.

There's not yet a native `bun2nix`, and I didn't want to spend a ton of time learning the complexities of [`dream2nix`](https://github.com/nix-community/dream2nix). Luckily, though, `bun` can output `yarn.lock` files[^2], in addition to the normal `bun.lockb`. I have this as part of my build process:

```shell
bun install --yarn
```

which generates a `yarn.lock` that is then picked up later in my derivation:

```nix
# example.nix
{pkgs, ...}:
let
nodeDeps =  pkgs.mkYarnModules {
    pname = "exampleDeps";
    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;
    version = "0.0.0";
};
in
pkgs.stdenv.mkDerivation {
    name = "example";
    src = ./.;
    buildInputs = with pkgs; [hugo git nodePackages.prettier tailwindcss];
    buildPhase = ''
    runHook preBuild

    cp -r ${nodeDeps}/node_modules ./.
    # inject deps here ☝️

    tailwindcss -i assets/css/main.css -o static/css/styles.css
    hugo
    prettier -w public '!**/*.{js,css}'

    runHook postBuild
    '';
    installPhase = "cp -r public $out";
}
```

## Future work

I think that a lot could be done to make the documentation on this better. I'll see if I can find the time to upstream what I've learned.

[^1]: I only tested this on my [blog project](https://github.com/ajaxbits/ajaxbits-site), which doesn't have any JavaScript build steps. So this output might look slightly different, depending on your project structure. However, the `node_modules` and `deps` directories will still be the same. 
[^2]: Yarn v1, to be precise.
