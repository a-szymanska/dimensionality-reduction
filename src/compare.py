import numpy as np
from sklearn.metrics import pairwise_distances

from convert import read_fps_bin

'''
Function to compute the Jaccard similarity coefficient of two fingerprints:
MH - reduced with MinHash method
JL - reduced with Johnson-Lindenstrauss method
None - non-reduced binary fingerprint

For bulk calculations of pairwise similarity can be used with sklearn.metrics.pairwise_distances
'''
def jaccard_similarity(u, v, type=None):
    if type == 'MH':
        set_u = set(u)
        set_v = set(v)
        sim = len(set_u.intersection(set_v)) / len(set_u.union(set_v))
    elif type == 'JL' or type is None:
        dot_uv = np.dot(u, v)
        sim = dot_uv / (np.sum(u**2) + np.sum(v**2) - dot_uv)
    else:
        print(f"Invalid reduction method: {type} does not match 'MH', 'JL' or None")
        sim = -1
    return sim

if __name__ == '__main__':
    '''
    Example usage for fingerprints reduced with MinHash method
    Number of fps: m=10
    Length of fps: n=256
    '''
    fingerprints = read_fps_bin('../data/fingerprints_reduced.bin', 10, 256)
    jaccard_similarity_MH = lambda u, v: jaccard_similarity(u, v, 'MH')
    similarity_matrix = pairwise_distances(fingerprints, metric=jaccard_similarity_MH)
    print(f"Mean similarity: {np.mean(similarity_matrix):.3f}")