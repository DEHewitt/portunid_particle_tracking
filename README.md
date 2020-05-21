# portunid_particle_tracking
Code for simulation and analysis of particle tracking experiments for Giant Mud Crab (*Scylla serrata*) and Blue Swimmer Crab (*Portunus armatus*)

This repository contains all the files required to run particle tracking on the UNSW HPC (Katana)

The ``.pbs`` file submits the job to Katana and should be updated each time to reflect the run you are completing. For example, to run backwards simulations for the spawning season of 1994/95 for Giant Mud Crab you would submit the job using the code: ``qsub Back_1995.pbs``. This file (``Back_1995.pbs``) calls the corresponding ``.py`` file for that particular simulation (see below).

The ``.py`` file contains the code to actually run the particle tracking model. These files are prefixed by an abbreviation of the species common name (``bsc_`` for Blue Swimmer Crab and ``gmc_`` for Giant Mud Crab) which needs to be changed in the ``.pbs`` to ensure you are calling the right file. This is where you can alter the number and location of particles released, direction of the run, start/end dates. So, in the example above the ``.pbs`` file would call the corresponding ``.py`` file which is named ``gmc_back_995.py``.
