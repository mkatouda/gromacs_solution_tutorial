#!/bin/bash

molname=chloroform
nmol=500
boxsize_x=40.0
boxsize_y=40.0
boxsize_z=40.0

packmol_inp=${molname}_solv_${nmol}.inp
model_pdb=${molname}_solv_${nmol}.pdb
model_gro=${molname}_solv_${nmol}.gro
model_top=${molname}_solv_${nmol}.top

box_xmax=`echo "scale=5; $boxsize_x - 2.0" | bc`
box_ymax=`echo "scale=5; $boxsize_y - 2.0" | bc`
box_zmax=`echo "scale=5; $boxsize_z - 2.0" | bc`
boxsize_x_nm=`echo "scale=5; $boxsize_x / 10.0" | bc`
boxsize_y_nm=`echo "scale=5; $boxsize_y / 10.0" | bc`
boxsize_z_nm=`echo "scale=5; $boxsize_z / 10.0" | bc`

#echo $box_xmax $box_ymax $box_zmax
#echo $boxsize_x_nm $boxsize_y_nm $boxsize_z_nm

cat <<EOF > ${packmol_inp}
output ${model_pdb}
tolerance 2.0

structure ${molname}_NEW.pdb
  number ${nmol}
  inside box 2. 2. 2. ${box_xmax} ${box_ymax} ${box_zmax}
end structure
EOF

packmol < ${packmol_inp}
gmx editconf -f ${model_pdb} -o ${model_gro} -box ${boxsize_x_nm} ${boxsize_y_nm} ${boxsize_z_nm}
cat <<EOF > input.awk
{if(\$1 == "${molname}" && \$2 == 1) {printf "SOL %10s\n", ${nmol}} else {print \$0}}
EOF
awk -f input.awk ${molname}_GMX.top > ${model_top}
rm input.awk
