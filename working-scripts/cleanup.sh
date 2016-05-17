#!/bin/bash

find . -mindepth 2 -type f -print -exec mv {} . \;
find . -empty -type d -delete

