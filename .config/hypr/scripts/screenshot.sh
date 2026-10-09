#!/bin/bash
region=$(slurp) || exit 0
grim -g "$region" - | satty --filename -
