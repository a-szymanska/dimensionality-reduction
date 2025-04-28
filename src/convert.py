import struct
import numpy as np
import pickle
import os, sys

def read_fps_bin(input_file, m, n):
    with open(input_file, "rb") as f:
        data = f.read()
        dsize = np.dtype(np.float32).itemsize
        expected_size = m * n * dsize
        if len(data) < expected_size:
            raise ValueError(f"File size mismatch: expected {expected_size} bytes, got {len(data)} bytes")
        fingerprints = []
        for i in range(m):
            start_idx = i * n * dsize
            end_idx = start_idx + n * dsize
            fingerprint = struct.unpack(f"{n}f", data[start_idx:end_idx])
            fingerprints.append(fingerprint)
        return np.array(fingerprints, dtype=np.float32)


def read_fps_pkl(input_file):
    with open(input_file, 'rb') as file:
        return pickle.load(file)

def write_fps_pkl(fingerprints, output_file):
    with open(output_file, 'wb') as file:
        pickle.dump(fingerprints, file)


def read_fps_csv(input_file):
    return np.loadtxt(input_file, delimiter=",")

def write_fps_csv(fingerprints, output_file):
    np.savetxt(output_file, fingerprints, delimiter=",", fmt="%.6f")


def read_fps_npy(input_file):
    return np.load(input_file)

def write_fps_npy(fingerprints, output_file):
    np.save(output_file, fingerprints)


if __name__ == '__main__':
    m = int(sys.argv[1])
    n = int(sys.argv[2])
    input_file = str(sys.argv[3])
    output_file = str(sys.argv[4])
    _, fmt = os.path.splitext(output_file)
    fmt = fmt.lstrip('.')

    fingerprints = read_fps_bin(input_file, m, n)

    if fmt == 'pkl':
        write_fps_pkl(fingerprints, output_file)
    elif fmt == 'csv':
        write_fps_csv(fingerprints, output_file)
    elif fmt == 'npy':
        write_fps_npy(fingerprints, output_file)
    else:
        print(f"Invalid type of output file: {fmt} does not match any of .pkl, .csv, .npy")
        sys.exit(1)