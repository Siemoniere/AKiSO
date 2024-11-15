#!/bin/bash

get_chuck_norris_quote() {
    quote=$(curl -s "https://api.chucknorris.io/jokes/random" | jq -r '.value')
    echo "Cytat Chucka Norrisa:"
    echo "$quote"
}

get_cat_image() {
    cat_image_url=$(curl -s "https://api.thecatapi.com/v1/images/search" | jq -r '.[0].url')
    
    curl -s -o cat_image.jpg "$cat_image_url"
    
    if command -v catimg &> /dev/null; then
        catimg cat_image.jpg
    else
        echo "Obrazek kota pobrany, ale nie znaleziono narzędzia do wyświetlania."
    fi
}
clear
get_cat_image
get_chuck_norris_quote
