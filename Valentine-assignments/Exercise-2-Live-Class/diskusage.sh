#!/bin/bash

#du -d 5 -h /etc | sort -hr | head -5
#diskusage.sh -n /etc

directory=$@
number_of_files=$(ls -l "$directory" | grep -c "^")

if [[ $1 == '-d' ]]; then
  dir_files=true
  shift 1
fi

if [[ $1 == '-n' && $2=~^[0-9]+$ ]]; then
  entries=$2
  shift 2
else
  entries=8
fi

list_disk_usage() {
  if [[ "$dir_files" == true ]]; then
  #for -d flag
  sudo du -ah $1 | sort -hr | head -$entries
  echo " "
  echo "Total number of entries displayed = ${entries[@]}"
else
  #for -n flag
  sudo du -h --max-depth=1 $1 | sort -hr | head -$entries
  echo " "
  echo "Total number of entries displayed = $entries"
fi
}




for dir in $directory; do
  echo "Disk Usage for directory: $dir"
  list_disk_usage $dir
done

echo " "
echo "The total number of files in '$directory' = $number_of_files"

# echo "$1 - $2 - $3"
