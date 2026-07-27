# Time-dependent postdictive D3D simulation

`run_time_dependent_d3d.jl` runs a postdictive time-dependent simulation of a
DIII-D shot (`FUSE.StudyPostdictive`): it fetches the experimental data
(EFIT/profiles/CER/NBI via OMAS + OMFIT), fits profiles, and runs
`ActorDynamicPlasma`, saving `dd_sim` / `dd_exp` / `dd_benchmark`.

## Run it

With a host FUSE install:

```bash
julia run_time_dependent_d3d.jl 168830 --EFIT_TREE=EFIT02
```

On omega with the FUSE container (no install; requires the fuse >= v1.1.6
image, which ships the ssh client the D3D data fetch needs), as a batch job:

```bash
sbatch run_time_dependent_d3d.sbatch 168830 --EFIT_TREE=EFIT02
```

Data for each shot is fetched once and cached (`--USE_LOCAL_CACHE=true`, the
default); reruns skip the fetch. See `run_time_dependent_d3d.jl --help` for
all options.

## Environment knobs

| Variable | Purpose |
|----------|---------|
| `FUSE_RESULT_ARCHIVE` | Where result folders are saved (sbatch default: `./results`). |
| `FUSE_DATA_CACHE` | Shot-data cache dir for the sbatch wrapper (default: `./cache`). |
| `FUSE_SERVER` | Cluster the study runs on (default `localhost`). |
| `FUSE_OMFIT_HOST` | Host used for remote D3D data fetching (default `somega.gat.com`; needs a `user` entry in `~/.ssh/config`). |
| `FUSE_SCRATCH` | Scratch path on the fetch host. |

A full shot (~450 MB of results + ~200 MB cache) is heavy for a home
directory — on omega point `FUSE_RESULT_ARCHIVE`/`FUSE_DATA_CACHE` at project
space.
