pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    // Initialize an array to store merkle tree
    var hashes[2**(n+1)];
    for (var i = 0; i < 2**n; i++) {
        hashes[2**n+i] = leaves[i];
    }
    // Compute merkle root
    component poseidon[2**(n+1)];
    for (var i = 2**n - 1; i > 0; i--) {
        poseidon[i] = Poseidon(2);
        poseidon[i].inputs[0] <== hashes[2*i];
        poseidon[i].inputs[1] <== hashes[2*i + 1];
        hashes[i] = poseidon[i].out;
    }
    root <== hashes[1];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component poseidon[n];
    component isLeft[n];
    var hash = leaf;
    for (var i = 0; i < n; i++) {
        poseidon[i] = Poseidon(2);
        // Check if the current element is on the left or right
        isLeft[i] = IsZero();
        isLeft[i].in <== path_index[i];
        // Calculate the hash of the current element
        poseidon[i].inputs[0] <== isLeft[i].out * (hash - path_elements[i]) + path_elements[i];
        poseidon[i].inputs[1] <== isLeft[i].out * (path_elements[i] - hash) + hash;

        hash = poseidon[i].out;
    }
    root <== hash;
}