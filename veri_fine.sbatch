#!/bin/bash -x
#SBATCH --output=out_%A_%j.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=2
#SBATCH --time=47:00:00
#SBATCH --mem=256GB
#SBATCH --gres=gpu:2
#SBATCH --job-name=veri_fine.sbatch
#SBATCH --mail-type=BEGIN,END
#SBATCH --mail-user=ajn313@nyu.edu

module purge;

#debug flags
echo $SLURM_JOB_NAME

#env vars
export MASTER_PORT=$(shuf -i 10000-65500 -n 1)
export WORLD_SIZE=$(($SLURM_NNODES * $SLURM_NTASKS_PER_NODE))
echo "WORLD_SIZE="$WORLD_SIZE
master_addr=$(scontrol show hostnames "$SLURM_JOB_NODELIST" | head -n 1)
export MASTER_ADDR=$master_addr
export CUDA_VISIBLE_DEVICES=0,1

#run command
srun --accel-bind=v \
    /bin/bash run-singularity.bash \
    /bin/bash -c \
    'export PYTHONPATH="$PYTHONPATH:$PWD/src"; deepspeed --num_gpus 2 --num_nodes 1 run_clm.py --model_name_or_path=Salesforce/codegen-350M-multi --save_steps=100 --per_device_train_batch_size=1 --learning_rate 2e-5 --train_file verilog_dataset.json --num_train_epochs 1 --output_dir=CodeGen/codegen-350M-verilog-3-epochs --report_to 'wandb' --tokenizer_name Salesforce/codegen-16B-multi --block_size 1024 --gradient_accumulation_steps 32 --do_train --do_eval --fp16 --overwrite_output_dir --deepspeed ds_config.json'
