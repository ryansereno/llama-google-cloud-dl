#!/bin/bash

# Copyright (c) Meta Platforms, Inc. and affiliates.
# This software may be used and distributed according to the terms of the GNU General Public License version 3.

PRESIGNED_URL="https://agi.gpt4.org/llama/LLaMA/*"

MODEL_SIZE="7B,13B,30B,65B"

# Prompt the user for the target bucket
echo "Enter the target bucket (e.g., gs://your-bucket-name/LLama):"
read TARGET_BUCKET

declare -A N_SHARD_DICT

N_SHARD_DICT["7B"]="0"
N_SHARD_DICT["13B"]="1"
N_SHARD_DICT["30B"]="3"
N_SHARD_DICT["65B"]="7"

echo "Downloading tokenizer"
curl -L "${PRESIGNED_URL/'*'/'tokenizer.model'}" | gsutil cp - "${TARGET_BUCKET}/tokenizer.model"
curl -L "${PRESIGNED_URL/'*'/'tokenizer_checklist.chk'}" | gsutil cp - "${TARGET_BUCKET}/tokenizer_checklist.chk"

for i in ${MODEL_SIZE//,/ }
do
    echo "Downloading ${i}"
    for s in $(seq -f "0%g" 0 ${N_SHARD_DICT[$i]})
    do
        curl -L "${PRESIGNED_URL/'*'/"${i}/consolidated.${s}.pth"}" | gsutil cp - "${TARGET_BUCKET}/${i}/consolidated.${s}.pth"
    done
    curl -L "${PRESIGNED_URL/'*'/"${i}/params.json"}" | gsutil cp - "${TARGET_BUCKET}/${i}/params.json"
    curl -L "${PRESIGNED_URL/'*'/"${i}/checklist.chk"}" | gsutil cp - "${TARGET_BUCKET}/${i}/checklist.chk"
done
