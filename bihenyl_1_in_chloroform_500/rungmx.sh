#!/bin/bash

input=biphenyl_1_in_chloroform_solv_500

N_OMP=1
N_MPI=1

LANG=C

#module load gromacs/2019.6-cpu
#module load gromacs/2020.6/intel
#module load scl/devtoolset-9 intel_parallelstudio/2019update5
#source ~/bin/x86_64/gromacs/2020.6/intel/bin/GMXRC.bash

# Energy minimization

gmx grompp -f em.mdp -po em.out.mdp -c ${input}.gro -p ${input}.top -o em.tpr -maxwarn 10
gmx mdrun -ntmpi ${N_MPI} -ntomp ${N_OMP} -v -deffnm em

# Equilibration MD

gmx grompp -f eq.mdp -po eq.out.mdp -c em.gro -t em.trr -p ${input}.top -o eq.tpr -r em.gro -maxwarn 10
gmx mdrun -ntmpi ${N_MPI} -ntomp ${N_OMP} -v -deffnm eq

# Production MD

gmx grompp -f md.mdp -po md.out.mdp -c eq.gro -t eq.trr -p ${input}.top -o md.tpr -maxwarn 10
gmx mdrun -ntmpi ${N_MPI} -ntomp ${N_OMP} -v -deffnm md
