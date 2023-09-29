#! /bin/bash
ROOT_PATH=$(pwd)
cd $ROOT_PATH/runtime

###### 1GPU ######
#### Model info ####
model_name=t5
model_size=770M

#### Hardware info ####
NNODES=1
GPUS_PER_NODE=1
WORLD_SIZE=$(($GPUS_PER_NODE*$NNODES))

#### Distributed info ####
## Modify this for distributed training
NODE_RANK=0
MASTER_ADDR=localhost
MASTER_PORT=7000
DISTRIBUTED_ARGS="--nproc_per_node $GPUS_PER_NODE --nnodes $NNODES --node_rank $NODE_RANK --master_addr $MASTER_ADDR --master_port $MASTER_PORT"

#### Paths ####
RESULT_PATH=$ROOT_PATH/logs-large/megatron/
LOG_PATH=${RESULT_PATH}runtime/${model_name}/${model_size}/
CONFIG_SAVE_PATH=${RESULT_PATH}configs/${model_name}/${model_size}/
mkdir -p ${LOG_PATH}csv

for file_name in $(ls $CONFIG_SAVE_PATH)
do
config_name=`basename $file_name .json`
CURRENT_TIME=$(date '+%Y-%m-%d-%H-%M-%S')
echo "[LOG][RUNTIME]($CURRENT_TIME) start executing cofnig: $config_name ." >> ${RESULT_PATH}full_log.log

python3 -m torch.distributed.launch $DISTRIBUTED_ARGS \
       pretrain_t5.py \
       --flexpipe-config $CONFIG_SAVE_PATH${file_name} \
       --train-iters 3 \
       --eval-iters 0 \
       --lr-decay-iters 320000 \
       --data-path $DATA_PATH \
       --vocab-file vocabs/t5-vocab.txt \
       --vocab-extra-ids 100 \
       --data-impl mmap \
       --split 949,50,1 \
       --distributed-backend nccl \
       --lr 0.00015 \
       --lr-decay-style linear \
       --min-lr 1.0e-5 \
       --weight-decay 1e-2 \
       --clip-grad 1.0 \
       --lr-warmup-fraction .01 \
       --log-interval 1 \
       --DDP-impl local \
       --fp16 \
       --log-path $LOG_PATH \
       2>&1 | tee ${LOG_PATH}full_log_${config_name}_rank${NODE_RANK}_${CURRENT_TIME}

echo "[LOG][RUNTIME]($CURRENT_TIME) end executing config: $config_name ." >> ${RESULT_PATH}full_log.log

done 


###### 4GPUs ######
#### Model info ####
model_name=t5
model_size=3B

#### Hardware info ####
NNODES=1
GPUS_PER_NODE=4
WORLD_SIZE=$(($GPUS_PER_NODE*$NNODES))

#### Distributed info ####
## Modify this for distributed training
NODE_RANK=0
MASTER_ADDR=localhost
MASTER_PORT=7000
DISTRIBUTED_ARGS="--nproc_per_node $GPUS_PER_NODE --nnodes $NNODES --node_rank $NODE_RANK --master_addr $MASTER_ADDR --master_port $MASTER_PORT"

#### Paths ####
RESULT_PATH=$ROOT_PATH/logs-large/megatron/
LOG_PATH=${RESULT_PATH}runtime/${model_name}/${model_size}/
CONFIG_SAVE_PATH=${RESULT_PATH}configs/${model_name}/${model_size}/
mkdir -p ${LOG_PATH}csv

for file_name in $(ls $CONFIG_SAVE_PATH)
do
config_name=`basename $file_name .json`
CURRENT_TIME=$(date '+%Y-%m-%d-%H-%M-%S')
echo "[LOG][RUNTIME]($CURRENT_TIME) start executing cofnig: $config_name ." >> ${RESULT_PATH}full_log.log

python3 -m torch.distributed.launch $DISTRIBUTED_ARGS \
       pretrain_t5.py \
       --flexpipe-config $CONFIG_SAVE_PATH${file_name} \
       --train-iters 3 \
       --eval-iters 0 \
       --lr-decay-iters 320000 \
       --data-path $DATA_PATH \
       --vocab-file vocabs/t5-vocab.txt \
       --vocab-extra-ids 100 \
       --data-impl mmap \
       --split 949,50,1 \
       --distributed-backend nccl \
       --lr 0.00015 \
       --lr-decay-style linear \
       --min-lr 1.0e-5 \
       --weight-decay 1e-2 \
       --clip-grad 1.0 \
       --lr-warmup-fraction .01 \
       --log-interval 1 \
       --DDP-impl local \
       --fp16 \
       --log-path $LOG_PATH \
       2>&1 | tee ${LOG_PATH}full_log_${config_name}_rank${NODE_RANK}_${CURRENT_TIME}

echo "[LOG][RUNTIME]($CURRENT_TIME) end executing config: $config_name ." >> ${RESULT_PATH}full_log.log

done 

###### 8GPUs ######
#### Model info ####
model_name=t5
model_size=6B

#### Hardware info ####
NNODES=1
GPUS_PER_NODE=8
WORLD_SIZE=$(($GPUS_PER_NODE*$NNODES))

#### Distributed info ####
## Modify this for distributed training
NODE_RANK=0
MASTER_ADDR=localhost
MASTER_PORT=7000
DISTRIBUTED_ARGS="--nproc_per_node $GPUS_PER_NODE --nnodes $NNODES --node_rank $NODE_RANK --master_addr $MASTER_ADDR --master_port $MASTER_PORT"

#### Paths ####
RESULT_PATH=$ROOT_PATH/logs-large/megatron/
LOG_PATH=${RESULT_PATH}runtime/${model_name}/${model_size}/
CONFIG_SAVE_PATH=${RESULT_PATH}configs/${model_name}/${model_size}/
mkdir -p ${LOG_PATH}csv

for file_name in $(ls $CONFIG_SAVE_PATH)
do
config_name=`basename $file_name .json`
CURRENT_TIME=$(date '+%Y-%m-%d-%H-%M-%S')
echo "[LOG][RUNTIME]($CURRENT_TIME) start executing cofnig: $config_name ." >> ${RESULT_PATH}full_log.log

python3 -m torch.distributed.launch $DISTRIBUTED_ARGS \
       pretrain_t5.py \
       --flexpipe-config $CONFIG_SAVE_PATH${file_name} \
       --train-iters 3 \
       --eval-iters 0 \
       --lr-decay-iters 320000 \
       --data-path $DATA_PATH \
       --vocab-file vocabs/t5-vocab.txt \
       --vocab-extra-ids 100 \
       --data-impl mmap \
       --split 949,50,1 \
       --distributed-backend nccl \
       --lr 0.00015 \
       --lr-decay-style linear \
       --min-lr 1.0e-5 \
       --weight-decay 1e-2 \
       --clip-grad 1.0 \
       --lr-warmup-fraction .01 \
       --log-interval 1 \
       --DDP-impl local \
       --fp16 \
       --log-path $LOG_PATH \
       2>&1 | tee ${LOG_PATH}full_log_${config_name}_rank${NODE_RANK}_${CURRENT_TIME}

echo "[LOG][RUNTIME]($CURRENT_TIME) end executing config: $config_name ." >> ${RESULT_PATH}full_log.log

done 