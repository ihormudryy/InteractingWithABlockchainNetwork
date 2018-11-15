#!/bin/bash

exit 1
find . -type f -print0 | xargs -0 -n 1 sed -i -e 's/${COIN_NAME_CAMELCASE}/${COIN_NAME_CAMELCASE}/g'
find . -type f -print0 | xargs -0 -n 1 sed -i -e 's/${COIN_NAME}/${COIN_NAME}/g'
#find . -type f -print0 | xargs -0 -n 1 sed -i -e 's/herecoin/${COIN_NAME}/g'

#find . -type f -print0 | xargs -0 -n 1 sed -i -e 's/COIN_NAME/COIN_NAME/g'

echo '' > "$1"
find . -name .git -prune -o -type f -print0 | xargs -0 -n 1 | grep -e '-e' >> "$1"

while IFS='' read -r line || [[ -n "$line" ]]; do
    rm -rf "$line"
done < "$1"

echo '' > $1
find . -name .git -prune -o -type f -print0 | xargs -0 -n 1 | grep -e '.!' >> "$1"

while IFS='' read -r line || [[ -n "$line" ]]; do
    rm -rf "$line"
done < "$1"
rm -rf "$1"