circom spawning.circom --r1cs --wasm --sym --c
cd spawning_js
# Computation of the witness
echo "GENERATING WITNESS"
node generate_witness.js spawning.wasm ../input.json witness.wtns

cp witness.wtns ../
cd ..

# Powers of tau Ceremony, generation of secret, and verification and proof keys
# First phase
# We could precompute this firs phase, since it's not circuit specific
echo "FIRST PHASE"
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
# add some noise
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v

# Second phase
# Phase 2 is circuit specific
echo "SECOND PHASE"
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup spawning.r1cs pot12_final.ptau spawning_0000.zkey
# add some random noise again
snarkjs zkey contribute spawning_0000.zkey spawning_0001.zkey --name="1st Contributor Name" -v
snarkjs zkey export verificationkey spawning_0001.zkey verification_key.json

# Generate a Groth16 ZK proof
snarkjs groth16 prove spawning_0001.zkey ./spawning_js/witness.wtns proof.json public.json

# Verify the proof
snarkjs groth16 verify verification_key.json public.json proof.json
