#!/usr/bin/env bash

CIRCOM_WITNESSCALC_DIR="circom-witnesscalc"
CIRCOM_WITNESSCALC_URL="https://github.com/iden3/circom-witnesscalc.git"

CURRENT_DIR=$(pwd)

if [ ! -d "$CIRCOM_WITNESSCALC_DIR" ]; then
    git clone "$CIRCOM_WITNESSCALC_URL" "$CIRCOM_WITNESSCALC_DIR"
fi

cd "$CIRCOM_WITNESSCALC_DIR"

# build the witness graph
if [ ! -f "$CURRENT_DIR/build/13x01.bin" ]; then
    cargo run --package build-circuit --bin build-circuit --release $CURRENT_DIR/src/generated/13x01.circom $CURRENT_DIR/build/13x01.bin
fi

# calculate the witness
rm $CURRENT_DIR/witness.wtns
cargo run --package circom-witnesscalc --bin calc-witness $CURRENT_DIR/build/13x01.bin $CURRENT_DIR/input.json $CURRENT_DIR/witness.wtns

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