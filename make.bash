#!/bin/bash
set -e
aspell list --personal=./ok.words < index.md
pandoc index.md --css style.css -s -o index.html
aspell list --personal=./ok.words < compile-objdump.md
pandoc compile-objdump.md --css style.css -s -o compile-objdump.html
