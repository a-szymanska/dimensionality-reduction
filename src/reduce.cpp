#include <iostream>
#include <fstream>
#include <vector>
#include <numeric>
#include "johnson_lindenstrauss.hpp"
#include "minhash.hpp"

int read_fpgs(int m, int N, int r, std::vector<std::vector<unsigned char>> &fingerprints, const std::string &file_name)
{
    std::ifstream file(file_name, std::ios::binary);
    if (!file) {
        std::cerr << "Error opening file " << file_name << std::endl;
        return 1;
    }
    std::vector<unsigned char> bytes(m * N);
    file.read(reinterpret_cast<char*>(bytes.data()), bytes.size());
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < N; j++) {
            fingerprints[i][j] = bytes[i * N + j];
        }
    }
    return 0;
}

int write_fpgs(int m, int n, int r, std::vector<std::vector<float>> &fingerprints, const std::string &file_name)
{
    std::ofstream output_file(file_name, std::ios::binary);
    if (!output_file) {
        std::cerr << "Error opening file " << file_name << std::endl;
        return 1;
    }
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++) {
            output_file.write(reinterpret_cast<char *>(&fingerprints[i][j]), sizeof(float));
        }
    }
    return 0;
}

int main(int argc, char *argv[])
{
    if (argc < 8) {
        return 1;
    }

    int m = std::stoi(argv[1]);
    int r = std::stoi(argv[2]);
    int N = std::stoi(argv[3]);
    int n = std::stoi(argv[4]);
    std::string type = argv[5];
    std::string input_file = argv[6];
    std::string output_file = argv[7];

    std::vector<std::vector<unsigned char>> fingerprints(m, std::vector<unsigned char>(N));
    if (read_fpgs(m, N, r, fingerprints, input_file) != 0) {
        return 1;
    }

    std::vector<std::vector<float>> fingerprints_reduced(m);
    if (type == "JL") {
        JohnsonLindenstrauss JL(N, n);
        for (int i = 0; i < m; i++) {
            fingerprints_reduced[i] = JL.reduce(fingerprints[i]);
        }
    } else {
        MinHash MH(N, n);
        for (int i = 0; i < m; i++) {
            fingerprints_reduced[i] = MH.reduce(fingerprints[i]);
        }
    }
    write_fpgs(m, n, r, fingerprints_reduced, output_file);

    return 0;
}