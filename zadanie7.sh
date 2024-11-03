#!/bin/bash

for plik in *; do
    if [ -f "$plik" ]; then
        zmieniony=$(echo "$plik" | tr '[:upper:]' '[:lower:]')
        mv -- "$plik" "$zmieniony"
    fi
done
