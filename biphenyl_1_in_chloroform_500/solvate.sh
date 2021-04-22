#!/bin/bash

res_solute=BIP
model_solute_gro=biphenyl_GMX.gro
model_solvent_gro=chloroform_solv_500.gro
model_solvent_top=chloroform_solv_500.top
model_solution_gro=biphenyl_1_in_chloroform_solv_500.gro
model_solution_top=biphenyl_1_in_chloroform_solv_500.top

box=`tail -n 1 ${model_solvent_gro}`
echo $box
box_x=`echo ${box} | awk '{print $1}'`
box_y=`echo ${box} | awk '{print $2}'`
box_z=`echo ${box} | awk '{print $3}'`
echo ${box_x} ${box_y} ${box_z}

cp -p ${model_solvent_top} ${model_solution_top}
gmx editconf -f ${model_solute_gro} -o solute.gro -box ${box_x} ${box_y} ${box_z}
gmx solvate -cs ${model_solvent_gro} -cp solute.gro -p ${model_solution_top} -o ${model_solution_gro}
rm solute.gro
