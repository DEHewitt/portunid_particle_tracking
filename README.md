# portunid_particle_tracking
Code for simulation and analysis of particle tracking experiments for Giant Mud Crab (*Scylla serrata*), Blue Swimmer Crab (*Portunus armatus*) and Spanner Crab (*Ranina ranina*)

This repository contains all the files required to run particle tracking on the UNSW HPC (Katana).

Spanner Crab analysis is all located in the BRAN_2020 folder as it uses the BRAN2020 ocean model.

Particle tracking is conducted in Python using [PARCELS](https://github.com/OceanParcels/parcels), all output is then processed in R.

Jobs are submitted using the .pbs scripts in the Simulations folder, and are separate for each combination of species and direction (forwards or backwards).
