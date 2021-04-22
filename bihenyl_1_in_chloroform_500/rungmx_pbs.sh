#!/bin/bash

#PBS -l select=1:ncpus=12:mpiprocs=6:ompthreads=2:jobtype=core
#PBS -l walltime=00:30:00

input=biphenyl_1_in_chloroform_solv_500

N_NODES=1
N_CORES=12
N_OMP=2
N_MPI=`expr ${N_NODES} "*" ${N_CORES} / ${N_OMP}`
#echo N_NODES=${N_NODES} N_CORES=${N_CORES} N_MPI=${N_MPI} N_OMP=${N_OMP}

LANG=C

module load gromacs/2020.6/intel
#module load scl/devtoolset-9 intel_parallelstudio/2019update5
#source ~/bin/x86_64/gromacs/2020.6/intel/bin/GMXRC.bash

mpirun=mpiexec.hydra
export I_MPI_PERHOST=`expr ${N_CORES} / ${N_OMP}`
export I_MPI_FABRICS=shm:ofi
export I_MPI_PIN_DOMAIN=omp
export I_MPI_PIN_CELL=core

export I_MPI_HYDRA_BOOTSTRAP=rsh
export I_MPI_HYDRA_BOOTSTRAP_EXEC=/bin/pjrsh
export I_MPI_HYDRA_HOST_FILE=${PJM_O_NODEINF}


if [ ! -z "${PBS_O_WORKDIR}" ]; then
  cd "${PBS_O_WORKDIR}"
fi

# Energy minimization

gmx grompp -f em.mdp -po em.out.mdp -c ${input}.gro -p ${input}.top -o em.tpr -maxwarn 10
mpirun -n ${N_MPI} gmx_mpi mdrun -ntomp ${N_OMP} -v -deffnm em

# Equilibration MD

gmx grompp -f eq.mdp -po eq.out.mdp -c em.gro -t em.trr -p ${input}.top -o eq.tpr -r em.gro -maxwarn 10
mpirun -n ${N_MPI} gmx_mpi mdrun -ntomp ${N_OMP} -v -deffnm eq

# Production MD

gmx grompp -f md.mdp -po md.out.mdp -c eq.gro -t eq.trr -p ${input}.top -o md.tpr -maxwarn 10
mpirun -n ${N_MPI} gmx_mpi mdrun -ntomp ${N_OMP} -v -deffnm md
