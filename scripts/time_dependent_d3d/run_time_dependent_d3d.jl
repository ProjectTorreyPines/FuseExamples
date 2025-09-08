#!/usr/bin/env julia

# Application entry point for time_dependent_d3d
# This script handles the distributed setup and calls the module function

using Pkg
Pkg.activate(@__DIR__)
using Distributed
using time_dependent_d3d
using time_dependent_d3d: FUSE

# Set up distributed workers and load FUSE everywhere
FUSE.parallel_environment("localhost", 1) # Get one extra worker for OMAS fetching
@everywhere using FUSE

# Run the main function
time_dependent_d3d.main()