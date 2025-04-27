#ifndef MINHASH_HPP
#define MINHASH_HPP

#include <vector>
#include <algorithm>
#include <functional>
#include <random>
#include <limits>

const uint32_t p = 1364310083u;
const uint32_t mod = 4294967029u;

class MinHash
{
    int N;                                          // original dimension
    int n;                                          // reduced dimension
    std::vector<std::function<float(uint32_t)>> H;  // hash functions

    static float get_hash(uint32_t x, uint32_t seed) {
        uint32_t hashValue = ((x ^ seed) * p) % mod;
        return (float)hashValue / std::numeric_limits<uint32_t>::max();
    }

public:
    MinHash(int N, int n): N(N), n(n) {
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_int_distribution<uint32_t> uni_dist(1, mod);
        for (int i = 0; i < n; i++) {
            uint32_t seed = uni_dist(gen);
            H.push_back([seed](uint32_t x) { return get_hash(x, seed); });
        }
    }

    std::vector<float> reduce(const std::vector<unsigned char> &v) {
        std::vector<int> v_nonzero;
        for (int j = 0; j < N; j++) {
            if (v[j] != 0) v_nonzero.push_back(j);
        }
        std::vector<float> v_proj(n, 1.0f);
        for (int i = 0; i < n; i++) {
            auto min_hash = H[i](v[0]);
            int min_x = 0;
            for (int j : v_nonzero) {
                auto hash_j = H[i](j);
                if (hash_j < min_hash) {
                    min_hash = hash_j;
                    min_x = j;
                }
            }
            v_proj[i] = (float) min_x / N;
        }
        return v_proj;
    }
};

#endif // MINHASH_HPP