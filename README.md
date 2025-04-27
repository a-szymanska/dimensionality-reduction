# Reducing dimension of binary fingerprints
This repository contains a wrapper for the implementation of the Johnson-Lindenstrauss and MinHash methods used for reducing dimensionality of binary fingerprints while preserving pairwise Jaccard similarity.

The repository was created as a part of this [study](url).

## Getting Started
### Requirements
- C++ >= 17
- Python >= 3.8.10
- Python packages listed in `requirements.txt`

### Installation
Install the required Python packages and compile the C++ files:
```sh
chmod +x build.sh run.sh
./build.sh
```

## Usage
The `run.sh` script handles both ECFP fingerprints in binary file format, and directly the list of compounds stored as SMILES in format of a text file with newline separator.

Arguments:
- -m number of compounds or fingerprints
- -r radius of ECFP
- -N length of the original fingerprints
- -n length of the reduced fingerprints
- -t reduction method: JL (Johnson-Lindenstrauss) or MH (MinHash)
- -i input file (.txt or .bin)
- -o output file

To view detailed argument description:
```sh
./run.sh --help
```
Example of encoding and reducing fingerprints given list of SMILES:
```sh
./run.sh -m 10 -r 3 -N 1024 -n 256 -t MH -i data/smiles_sample.txt
```

## License
The project is under the MIT license.