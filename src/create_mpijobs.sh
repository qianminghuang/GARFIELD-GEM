#!/bin/bash


# which study to run according to folders in ansys directory (/panfs/vol/HEP/GarfieldSim/PRO/ANSYS/), 
# i.e.  "gain"  or  "gasgapscan" or "holescan"  
# to run from terminal  (i.e  ./create_mpijobs.sh gain)

STUDY=$1  # according to the study to run and the folder names in /panfs/vol/HEP/GarfieldSim/PRO/ANSYS/
          # (i.e.  source create_mpijobs.sh gain    "or"   source create_mpijobs.sh gasgapscan "or" ......)

echo "****** Creating MPI jobs for " $1 "  analysis ***************** "

ansys_dir=($(ls -d /panfs/vol/HEP/GarfieldSim/PRO/ANSYS/${STUDY}/*))

echo " The ANSYS files considered are:  "  ${ansys_dir[@]}

nev=5000                 # number of events to simulate (default=5000)
gas="ar"                 # Noble gas to be used (usually in combination with CO2),  ar=ArCO2, arco2cf2=ArCO2CF4, ne=NeCO2
penning=0.57             # Penning Transfer efficiency, 0.57 for ArCO2/ArCO2CF4, 0.48-0.52 for NeCO2, ? for HeCO2
email="alfredo.hernandez@qatar.tamu.edu"    #replace  by your email

for i in "${ansys_dir[@]}"
do
testString=$i
IFS="/"
array=($testString)
cat  > ${array[8]}.job <<EOF
#!/bin/bash
#PBS -q workq
#PBS -N GARFIELD
#PBS -j oe
#PBS -l walltime=160:00:00
#PBS -M $email
#PBS -l select=4:ncpus=16:mpiprocs=16:mem=4gb
#PBS -m bae

set -x
module load intel/compiler/13.0.1/64bit
module load intel/mkl/11.0u1/64bit
module load intel/mpi/4.1/64bit

export GARFIELD_HOME=/panfs/vol/GEM/RESTORED/SW/garfield_mpi
export HEED_DATABASE=$GARFIELD_HOME/Heed/heed++/database/
export ROOTSYS=/panfs/vol/GEM/RESTORED/SW/ROOT/root
source $ROOTSYS/bin/thisroot.sh 

module list
which mpirun
set +x

echo
echo \$LD_LIBRARY_PATH
echo

cd \$PBS_O_WORKDIR

mpirun -n 64 -l ./gem $nev $gas $penning $i 

EOF

done 


