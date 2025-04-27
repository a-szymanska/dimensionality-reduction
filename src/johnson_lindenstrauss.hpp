#ifndef JOHNSON_LINDENSTRAUSS_HPP
#define JOHNSON_LINDENSTRAUSS_HPP

#include <vector>
#include <algorithm>
#include <functional>
#include <random>
#include <cmath>

class JohnsonLindenstrauss
{
private:
    int N;                               // original dimension
    int n;                               // reduced dimension
    std::vector<std::vector<float>> Pi;  // projection matrix

public:
    JohnsonLindenstrauss(int N, int n): N(N), n(n) {
        std::random_device rd;
        std::mt19937 gen(rd());
        std::normal_distribution<float> norm_dist(0.0, 1.0);

        Pi.resize(n, std::vector<float>(N));
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < N; j++) {
                Pi[i][j] = norm_dist(gen);
            }
        }
    }

    std::vector<float> reduce(const std::vector<unsigned char> &v) {
        std::vector<float> v_proj(n, 0.0);
        for (int i = 0; i < n; i++) {
            float dot_i = 0.0;
            for (int j = 0; j < N; j++) {
                dot_i += Pi[i][j] * static_cast<float>(v[j]);
            }
            v_proj[i] = dot_i / std::sqrt(n);
        }
        return v_proj;
    }
};

#endif // JOHNSON_LINDENSTRAUSS_HPP