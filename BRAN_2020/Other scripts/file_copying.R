# Move files

files <- list.files("/srv/scratch/z5278054/portunid_particle_tracking/spanner/",
                    recursive = T, full.names = T)

files2 <- stringr::str_replace(files, pattern = "z5278054", replacement = "z3374139")

file.copy(from = files,
          to   = files2)