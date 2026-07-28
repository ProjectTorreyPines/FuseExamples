#!/bin/bash
# Postdictive time-dependent D3D simulation in the FUSE container (omega).
# Submit from this directory:  sbatch run_time_dependent_d3d.sbatch <shot> [extra args...]
# Requires the fuse >= v1.1.6 image (in-container ssh for the D3D data fetch).
#SBATCH -J fuse-postdictive
#SBATCH -p medium
#SBATCH -t 1:00:00
#SBATCH -c 16
#SBATCH --mem=64G

if [[ -z "${1:-}" ]]; then
    echo "usage: sbatch run_time_dependent_d3d.sbatch <shot> [extra script args...]" >&2
    exit 2
fi

# Where results and the per-shot data cache land; override before sbatch if
# desired (home-quota users: point these at project space).
export SINGULARITYENV_FUSE_RESULT_ARCHIVE="${FUSE_RESULT_ARCHIVE:-$SLURM_SUBMIT_DIR/results}"
export SINGULARITYENV_TMPDIR="${FUSE_DATA_CACHE:-$SLURM_SUBMIT_DIR/cache}"
mkdir -p "$SINGULARITYENV_FUSE_RESULT_ARCHIVE" "$SINGULARITYENV_TMPDIR"

/fusion/projects/dt/fuse_containers/fuse-container --threads="$SLURM_CPUS_PER_TASK" \
    "$SLURM_SUBMIT_DIR/run_time_dependent_d3d.jl" "$1" "${@:2}"
