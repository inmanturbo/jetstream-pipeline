#!/bin/bash

now=$(date +%d%H%M%S)
generalOptions="--jet --no-interaction --force"
installOptions=(
    "livewire-teams-pest    --stack=livewire --pest --teams" 
    "livewire-teams-phpunit --stack=livewire --phpunit --teams" 
    "livewire-pest          --stack=livewire --pest" 
    "livewire-phpunit       --stack=livewire --phpunit" 
    "inertia-teams-pest     --stack=inertia  --pest --teams" 
    "inertia-teams-phpunit  --stack=inertia  --phpunit --teams"
    "inertia-pest           --stack=inertia  --pest" 
    "inertia-phpunit        --stack=inertia  --phpunit" 
)
installCommand="laravel new"

mkdir -p ./tmp && cd ./tmp

for buildOptions in "${installOptions[@]}"; do

    build=${buildOptions%% *}
    options=${buildOptions#* }

    $installCommand $build $options $generalOptions

    mkdir -p ./tmp

    cp -r ../.git ./tmp

    git -C tmp fetch --all

    if git -C tmp rev-parse --verify $build >/dev/null 2>&1; then

        git -C tmp switch $build
        git -C tmp pull origin $build --ff
        git -C tmp add .
        git -C tmp commit -m "pulling changes from origin $build"

    else
  
        git -C tmp checkout -b $build
        git -C tmp pull origin $build --ff
        git -C tmp add .
        git -C tmp commit -m "pulling changes from origin $build"

    fi
    
    cp -r ./tmp/.git $build

    git -C $build checkout stubs ./

    git -C $build add .
    git -C $build commit -m "Built on now=$(date +"%Y-%m-%d-%H:%M:%S")"

    git -C $build push -u origin $build

    rm -rf ./tmp

    "$@"
done