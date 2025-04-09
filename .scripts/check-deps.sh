#!/usr/bin/env bash

if [[ ! $(command -v vips) ]]; then
    echo "vips is not installed and is required by jekyll_picture_tag. Please install it first. (brew install vips)";
    exit 1;
fi