# portunid_particle_tracking
Code for simulation and analysis of particle tracking experiments for Giant Mud Crab (*Scylla serrata*), Blue Swimmer Crab (*Portunus armatus*) and Spanner Crab (*Ranina ranina*)

This repository contains all the files required to run particle tracking on the UNSW HPC (Katana) for the publications _DOI for GMC/BSC paper_ and _DOI for spanner crab paper_.

Spanner Crab analysis is all located in the BRAN_2020 folder as it uses the BRAN2020 ocean model.

Particle tracking is conducted in `Python` using [PARCELS](https://github.com/OceanParcels/parcels), all output is then processed in `R`.

Jobs are submitted using the `.pbs` scripts in the Simulations folder, and are separate for each combination of species and direction (forwards or backwards). The workflow includes multiple job submissions (to manage computation times) and follows this order:

1. Submit the particle tracking job with the appropriate `.pbs`. These are named in a _species_direction_`.pbs` format, so to run forwards simulations for Giant Mud Crab you'd submit `gmc_forwards.pbs` to the HPC. Depending on the direction and species these jobs get split up in different ways (to manage memory/computation time), unless you intend to change the structure of the workflow this _shouldn't_ matter.
2. Once particle tracking simulations are complete we need to process the output to introduce some biology to our particles. This is achieved by running the `R` script `portunid_particle_processing.R` which uses a range of functions stored in the `R` folder. This script is set up to do different things for different species/directions, so we need to submit the appropriate `_processing.pbs` (prefixed by our _species_direction_ combination) to tell this script which species we're working on. So, to continue our forwards Giant Mud Crab analysis we'd submit `gmc_forwards_processing.pbs`
3. No we're ready to bring all of the output together (remember the splitting up in step 1). We do this by submitting the appropriate `_join.pbs`, prefixed by _species_direction_ (e.g., `gmc_forwards_join.pbs`).
4. Once steps 1-3 have been carried out we'll have our fully processed output. They're pretty big files, but just on the borderline of what you can manage to do plotting with on a laptop (depending on the type of plot). There are some functions in the `Plotting` folder that do plotting on the HPC, but not many.
