#! /bin/bash

# params
baseDir="/disk/science/my_science/magmaDynamics/magmaFoam/bubbles/slug"
simulationName="stromboli/slug_inlet_long_r2_mu10000_u0.1"
sampleTime=0.1    # pressure sample time, s
endTime=306.5        # pressure final time, s
radius=2          # slug radius, m

cd $baseDir/$simulationName

# extract pressure time series
mkdir postProcessing/pressure/programs
cp $baseDir/scripts/extractPressureTimeSeries.m postProcessing/pressure/programs
cd postProcessing/pressure/programs

matlab -nodisplay -r "extractPressureTimeSeries($sampleTime,$endTime); exit"

# calculate forces
cd $baseDir/$simulationName
mkdir -p signals/deformation/programs
cp $baseDir/scripts/p* signals/deformation/programs
cp $baseDir/scripts/deformation.m signals/deformation/programs
cp $baseDir/scripts/Green2D.m signals/deformation/programs
cd signals/deformation/programs

matlab -nodisplay -r "pressuresToForces2DSymmetricVerticalBoundary($radius); exit"

# calculate deformation and print figures
if [ ! $sampleTime == 0.1 ];
then echo "check dto in deformation.m"
fi
matlab -nodisplay -r "deformation; plotTimeseriesDeformation; exit"

