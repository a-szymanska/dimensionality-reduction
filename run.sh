#!/bin/bash

usage() {
  echo "Usage:"
  echo "$0 -m <int> -r <int> -N <int> -n <int> [-t <type>] -i <file_path> [-o <file_path>]"
  echo ""
  echo "Arguments:"
  echo "  -m <int>         Required: number of compounds"
  echo "  -r <int>         Required: radius of ECFP"
  echo "  -N <int>         Required: length of original ECFP fingeprints"
  echo "  -n <int>         Required: length of reduced fingeprints. For preserving Jaccard similarity, use n > log(m)"
  echo "  -t <type>        Optional: reduction method 'JL' for Johnson-Lindenstrauss or 'MH' for MinHash, default is 'MH'"
  echo "  -i <file_path>   Required: input file path (.txt for SMILES, .bin for fingerprints)"
  echo "  -o <file_path>   Optional: output file path (.bin), default is <input_file>_reduced.bin"
  echo ""
  echo "  --help           help message"
  exit 0
}

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
./build/reduce "$m" "$r" "$N" "$n" "$type" "$file_out_fps" "$output"
if [ $? -eq 0 ]; then
  echo "Fingerprints saved in: $output"
else
  echo "Reduction failed." >&2
  exit 2
fi