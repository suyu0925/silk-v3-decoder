#!/bin/sh

function print_usage {
  echo "Usage: [input_folder] [output_folder]"
  echo "   or: msg.amr [msg.mp3]"
}

# Replace file extension with .pcm
function with_pcm_extension() {
  echo "${1%.*}.pcm"
}

# Replace file extension with .mp3
function with_mp3_extension() {
  echo "${1%.*}.mp3"
}

function convert_file {
  input_file="$1"

  if [ -n "$2" ]; then
    output_file="$2"
  else
    output_file="$(with_mp3_extension $input_file)"
  fi

  middle_pcm_file="$(with_pcm_extension $input_file)"

  # Make sure the output directory exists
  mkdir -p "$(dirname $output_file)"

  decoder "$input_file" $middle_pcm_file > /dev/null 2>&1 
  ffmpeg -y -f s16le -ar 24000 -ac 1 -i $middle_pcm_file "$output_file" > /dev/null 2>&1 
  rm $middle_pcm_file
  # echo "Converted $input_file to $output_file"
}

# Check arguments
if [ $# -gt 2 ]; then
  print_usage
  exit 1
fi

input_arg="$1"
output_arg="$2"

if [ -z "$input_arg" ]; then
  input_arg="."
fi

if [ -f "$input_arg" ]; then
  input_file="$input_arg"
  convert_file $input_file $output_arg
else
  if [ -d "$input_arg" ]; then
    input_dir="$input_arg"
    if [ -n "$output_arg" ]; then
      output_dir=$output_arg
    else
      output_dir=$input_dir
    fi

    # Find all regular files (excluding hidden ones) with the .amr extension
    amr_files=$(find "$input_dir" -type f -name "*.amr")

    for arm_file in $amr_files; do
      relative_path="${arm_file#$input_dir}"
      output_file="$output_dir$relative_path"
      convert_file $arm_file "$(with_mp3_extension $output_file)"
    done
  else
    print_usage
    exit 1
  fi
fi
