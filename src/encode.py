import numpy as np
import sys
from rdkit import Chem
from rdkit.Chem import rdMolDescriptors as rdmd
from rdkit import RDLogger
RDLogger.DisableLog('rdApp.*')

def get_ecfp(r, N, file_in, file_out):
    smiles_list = np.genfromtxt(file_in, dtype=str, delimiter="\n", comments=None)
    fp_list = np.zeros((len(smiles_list), N), dtype=np.uint8)
    for i, smiles in enumerate(smiles_list):
        mol = Chem.MolFromSmiles(smiles)
        if mol is None:
            print(f"Invalid SMILES: {smiles}")
            continue
        fp = rdmd.GetMorganFingerprintAsBitVect(mol, radius=r, nBits=N)
        fp_list[i] = np.array([int(bit) for bit in fp.ToBitString()], dtype=np.uint8)

    flat_fp_list = fp_list.flatten()
    with open(file_out, 'wb') as file:
        flat_fp_list.tofile(file)

if __name__ == '__main__':
    r = int(sys.argv[1])
    N = int(sys.argv[2])
    file_in = str(sys.argv[3])
    file_out = str(sys.argv[4])

    get_ecfp(r, N, file_in, file_out)