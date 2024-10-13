#!/bin/bash

for DAY in {1..25}
do
  echo "Downloading input for day $DAY"
  curl --silent --cookie cookies.txt \
       "https://adventofcode.com/2023/day/$DAY/input" \
       -o "day$(printf "%02d" $DAY).txt"
done
