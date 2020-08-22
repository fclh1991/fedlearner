#!/bin/bash

# Copyright 2020 The FedLearner Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex

psi_signer_cmd=/app/deploy/scripts/rsa_psi/run_rsa_psi_signer.sh
psi_preprocessor_cmd=/app/deploy/scripts/rsa_psi/run_psi_preprocessor.sh 
data_join_worker_cmd=/app/deploy/scripts/data_join/run_data_join_worker.sh

echo "launch the leader of psi preprocessor at background"
exec ${psi_preprocessor_cmd} &

echo "launch psi signer for follower of psi preprocessor at front ground"
exec ${psi_signer_cmd}
echo "psi signer for follower of psi preprocessor finish"

TCP_MSL=`cat /proc/sys/net/ipv4/tcp_fin_timeout`
SLEEP_TM=$((TCP_MSL * 3))
echo "sleep 3msl($SLEEP_TM) to make sure tcp state at CLOSED"
sleep $SLEEP_TM

echo "launch data join worker"
export RAW_DATA_ITER=$PSI_OUTPUT_BUILDER
export COMPRESSED_TYPE=$PSI_OUTPUT_BUILDER_COMPRESSED_TYPE
exec ${data_join_worker_cmd}
echo "data join worker finish"

echo "waiting for background psi preprocessor exit"
wait
