cd spawning_js
# Computation of the witness
echo "GENERATING WITNESS"
node generate_witness.js spawning.wasm ../input.json witness.wtns

cp witness.wtns ../
cd ..

snarkjs groth16 prove spawning_0001.zkey ./spawning_js/witness.wtns proof.json public.json

# Verify the proof
snarkjs groth16 verify verification_key.json public.json proof.json
snarkjs generatecall