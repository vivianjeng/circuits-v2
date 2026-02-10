#!/usr/bin/env bash

CURRENT_DIR=$(pwd)

# generate the witness with wasm
rm $CURRENT_DIR/witness.wtns
npx snarkjs wtns calculate $CURRENT_DIR/build/13x01_js/13x01.wasm $CURRENT_DIR/input.json $CURRENT_DIR/witness.wtns


# generate the proof with wtns from circom-witnesscalc
rm $CURRENT_DIR/proof.json
rm $CURRENT_DIR/public.json
npx snarkjs groth16 prove $CURRENT_DIR/zkeys/13x01.zkey $CURRENT_DIR/witness.wtns $CURRENT_DIR/proof.json $CURRENT_DIR/public.json

# generate the verification key
if [ ! -f "$CURRENT_DIR/verification_key.json" ]; then
    npx snarkjs zkey export verificationkey $CURRENT_DIR/zkeys/13x01.zkey $CURRENT_DIR/verification_key.json
fi

# verify the proof
npx snarkjs groth16 verify $CURRENT_DIR/verification_key.json $CURRENT_DIR/public.json $CURRENT_DIR/proof.json