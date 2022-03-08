# Check Forces

Sources were initially created by replicating the right hand side of
the conduit wall. Something was wrong and now sources are created on
both sides by
[pressuresToForces2DSymmetricVerticalBoundary](../pressuresToForces2DSymmetricVerticalBoundary.m). 
This folder contains scripts to perform relevant checks and resulting
figures.

+ [checkSources](checkSources.m): checks if sources (forces) are all
  equal. Example result: [FxDiff](FxDiffRight.bmp)

+ [compareDeformation](compareDeformation.m): check if deformation
  results are the same.
  
Figures and data refer to calculations performed using a two-step
(oneSide) or a one-step (twoSides) approach.
