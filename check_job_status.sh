#!/bin/bash

na=0
nb=0
nb1=0
nc=0
nc1=0
nd=0

for j in *; do  # loop all jobs 
  #echo $j
  cd $j

    if [ ! -f 'job.log' ]; then # If job.log is absent, the job was not started
      #echo $j ' Not started'
      na=$(($na + 1))

    #elif [ ! -f 'slurm.out' ]; then
    elif [ $(ls slurm-*.out | wc -l) = 0 ]; then
      echo $j 'No slurm written'
      nb1=$(($nb1 + 1))

    else  # otherwise, it started
      match=$(grep -c "reached required accuracy" job.log)
      slurm_out=$(ls slurm-*.out)

      time_track=`more $slurm_out`

      if [ ! $match = 1 ]; then  # Job started, but not finished
        if [ -f 'CONTCAR' ]; then ## If so, we need to continue this run
          nlines=$(wc -l $slurm_out | awk '{ print $1 }')
	  if [ $nlines = 2 ]; then 
		  job_status='Stopped'
       	          nb=$(($nb + 1))

          else
		  job_status='Running'      
		  nc=$(($nc + 1))
	  fi	 
          echo $j 'Started but not finished.' $time_track $job_status
          #tail -n 5 job.log slurm-*.err

	  #grep E0 job.log | tail -5
#          tail -n $nlines geo-pos-1.xyz  > data-in.xyz  ## Update the starting XYZ
#          cp  geo-1.restart  input-geoopt-cp2k ## Update the input script
#          sbatch ../../run_cp2k.sh
        else
          echo $j 'Started but something went wrong. No CONTCAR written' # Something wrong
          nc1=$(($nc1 + 1))
	  #rm  job.log  slurm-*
	  #sbatch ../../../run_vasp.sh
        fi

        #cp OUTCAR OUTCAR-$slurm_out ; cp CONTCAR POSCAR ; rm  slurm-*.out  job.log  slurm-*.err
        #sbatch ../../../run_vasp.sh

      else ## Otherwise, the job was done properly
	nd=$(($nd + 1))
        #nlines=$(wc -l 'data-in.xyz' | awk '{ print $1 }')
	#tail -n $nlines geo-pos-1.xyz  > data-out.xyz ## Save the final xyz
	e=$(grep E0 job.log | tail -1 | awk '{ print $5 }')
	cpu_time=`grep 'Total CPU time used (sec):' OUTCAR `
	#echo $j 'Job done with CONTCAR. Energy: ' $e $time_track $cpu_time
	#python ../../../summary_energy.py
      fi
    #e=$(grep E0 job.log | tail -1 | awk '{ print $5 }')
    #echo $e $j
    fi
  cd ../
done

echo 'Not started:' $na 'No Slurm' $nb1 'Terminated:' $nb 'Running:' $nc 'No CONTCAR' $nc1 'Finished:' $nd
