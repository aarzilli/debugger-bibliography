#!/bin/bash
set -e
aspell list --personal=./ok.words < index.md
pandoc index.md --css style.css -s -o index.html
