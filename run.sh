#!/bin/bash

usage() {
  echo "Usage:"
  echo "$0 -m <int> -r <int> -N <int> -n <int> [-t <type>] -i <file_path> [-o <file_path>]"
  echo ""
  echo "Arguments:"
  echo "  -m <int>         Required: number of compounds"
  echo "  -r <int>         Required: radius of ECFP"
  echo "  -N <int>         Required: length of original ECFP fingerprints"
  echo "  -n <int>         Required: length of reduced fingerprints. For preserving Jaccard similarity, use n > log(m)"
  echo "  -t <type>        Optional: reduction method 'JL' for Johnson-Lindenstrauss or 'MH' for MinHash, default is 'MH'"
  echo "  -i <file_path>   Required: input file path (.txt for SMILES, .bin for fingerprints)"
  echo "  -o <file_path>   Optional: output file path (.bin, .csv, .pkl, .npy), default is <input_file>_reduced.bin"
  echo ""
  echo "  --help           help message"
  exit 0
}

# Check for --help flag
for arg in "$@"; do
  if [[ "$arg" == "--help" ]]; then
    usage
  fi
done

type="MH"
ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      usage
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
done

set -- "${ARGS[@]}"

while getopts ":m:r:N:n:t:i:o:" opt; do
  case $opt in
    m) m=$OPTARG ;;
    r) r=$OPTARG ;;
    N) N=$OPTARG ;;
    n) n=$OPTARG ;;
    t) type=$OPTARG ;;
    i) input=$OPTARG ;;
    o) output=$OPTARG ;;
    \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
    :) echo "Option -$OPTARG requires an argument." >&2; usage ;;
  esac
done

if [[ -z "$m" || -z "$r" || -z "$N" || -z "$n" || -z "$input" ]]; then
  echo "Missing required arguments." >&2
  usage
fi

if [[ -z "$output" ]]; then
  filename="${input%.*}"
  output="${filename}_reduced.bin"
fi

# Define reduced file name
file_out_fps_reduced="${output%.*}_reduced.bin"
extension="${input##*.}"

if [[ "$extension" == "txt" ]]; then
  file_out_fps="${input%.*}_ecfp.bin"
  echo "Generating fingerprints"
  python3 ./src/encode.py "$r" "$N" "$input" "$file_out_fps"
  echo "Fingerprints saved in: $file_out_fps"
elif [[ "$extension" == "bin" ]]; then
  file_out_fps="$input"
else
  echo "Unknown input file extension: .$extension" >&2
  exit 2
fi

echo "Performing reduction"
./build/reduce "$m" "$r" "$N" "$n" "$type" "$file_out_fps" "$file_out_fps_reduced"
if [ $? -eq 0 ]; then
  output_extension="${output##*.}"
  if [[ "$output_extension" == "bin" ]]; then
    mv "$file_out_fps_reduced" "$output"
  else
    echo "Converting $file_out_fps_reduced to $output"
    python3 ./src/convert.py "$m" "$n" "$file_out_fps_reduced" "$output"
    if [ $? -eq 0 ]; then
      rm -f "$file_out_fps_reduced"
    else
      echo "Conversion failed." >&2
      exit 2
    fi
  fi
  echo "Fingerprints saved in: $output"
else
  echo "Reduction failed." >&2
  exit 2
fi
