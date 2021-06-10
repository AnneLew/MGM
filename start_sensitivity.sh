#!/bin/bash -e
#SBATCH -J Optim
#SBATCH -c 62
#SBATCH --mail-user=anne.lewerentz@uni-wuerzburg.de
#SBATCH --mail-type=ALL
#SBATCH --mem=10G
#SBATCH -p long-fat
#SBATCH -t 7-00:00:00

Rscript "./optimizer/210513_Optimizer_Liklihood_new.R"
