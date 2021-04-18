#!/bin/bash -e
#SBATCH -J Likelihood sensitivity
#SBATCH -c 2
#SBATCH --mail-user=anne.lewerentz@uni-wuerzburg.de
#SBATCH --mail-type=ALL

module add R
module add julia

Rscript "210415_sensitivity_likelihood.R"
