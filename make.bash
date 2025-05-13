#!/bin/bash
set -e
aspell list --lang=en_US --personal=./ok.words < index.md
pandoc index.md --wrap=preserve --css style.css -s -o index.html
aspell list --lang=en_US --personal=./ok.words < compile-objdump.md
pandoc compile-objdump.md --wrap=preserve --css style.css -s -o compile-objdump.html
aspell list --lang=en_US --personal=./ok.words < hwbreak.md
pandoc hwbreak.md --wrap=preserve --css style.css -s -o hwbreak.html
