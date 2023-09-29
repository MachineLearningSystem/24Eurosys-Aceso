ROOT_PATH=$(pwd)
cd $ROOT_PATH/external/Megatron-LM

###### 8GPUs * 4nodes ######
#### Model info ####
model_name=gpt
model_size=13B

#### Hardware info ####
NNODES=4
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
       pretrain_gpt.py \
       --config-file $CONFIG_SAVE_PATH${file_name} \
       --train-iters 3 \
       --eval-iters 0 \
       --lr-decay-iters 320000 \
       --vocab-file ${ROOT_PATH}/runtime/vocabs/gpt2-vocab.json \
       --merge-file ${ROOT_PATH}/runtime/vocabs/gpt2-merges.txt \
       --data-impl mmap \
       --split 949,50,1 \
       --distributed-backend nccl \
       --lr 0.00015 \
       --lr-decay-style cosine \
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

## For distributed running multiple configs:
## some config may cause OOM in some nodes, and the other nodes will not know the OOM and hang forever.
## we use a parallel-ssh command following the normal execution, when some node fails due to OOM, it will 
## kill the tasks in all the other nodes.
## To use this, prepare a pssh-2workers.host or pssh-4workers.host, which contains the host name or IP addresses of other nodes.
parallel-ssh -i -t 0 -h ${ROOT_PATH}/runtime/pssh-${NNODES}workers.host "ps -aux | grep 'pretrain' | grep -v grep | awk '{print \$2}' | xargs kill -9"
sleep 10s 

done 