#!/bin/bash
set -e
aspell list --lang=en_US --personal=./ok.words < index.md
pandoc index.md --css style.css -s -o index.html
aspell list --lang=en_US --personal=./ok.words < compile-objdump.md
pandoc compile-objdump.md --css style.css -s -o compile-objdump.html
aspell list --lang=en_US --personal=./ok.words < hwbreak.md
pandoc hwbreak.md --css style.css -s -o hwbreak.html
