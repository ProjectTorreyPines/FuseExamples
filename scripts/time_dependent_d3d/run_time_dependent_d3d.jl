#!/usr/bin/env julia

# Application entry point for time_dependent_d3d
# This script handles the distributed setup and calls the module function

import FUSE
using Distributed
using ArgParse

function main()
    s = ArgParseSettings()
    @add_arg_table! s begin
        "shot"
        help = "Shot number"
        arg_type = Int
        required = true
        "--EFIT_TREE"
        help = "Source of LCFS shape"
        arg_type = String
        default = "EFIT01"
        "--PROFILES_TREE"
        help = "Source of profile data"
        arg_type = String
        default = "ZIPFIT01"
        "--CER_ANALYSIS_TYPE"
        help = "CER analysis type, either CERQUICK, CERAUTO, CERFAST"
        arg_type = String
        default = "CERAUTO"
        "--EFIT_RUN_ID"
        help = "Run ID for EFIT Tree, only last two digits"
        arg_type = String
        default = ""
        "--PROFILES_RUN_ID"
        help = "Run ID for OMFIT_PROFS Tree, only last three digits"
        arg_type = String
        default = ""
        "--RECONSTRUCTION"
        help = "Run time dependent simulation in reconstruction mode"
        arg_type = Bool
        default = true
        "--START_TIME"
        help = "Override simulation start time [s]"                                                                                                                                                 
        arg_type = Float64
        default = NaN                                                                                                                                                                        
        "--END_TIME"                                                                                                                                                                                    
        help = "Override simulation end time [s]"
        arg_type = Float64                                                                                                                                                                         
        default = NaN
        "--FIT_PROFILES"
        help = "Let FUSE fit the raw data into profiles"
        arg_type = Bool
        default = true
        "--USE_LOCAL_CACHE"
        help = "Use local data cache"
        arg_type = Bool
        default = true
        "--save_path"
        help = "Where the output should be stored"
        arg_type = String
        default = ""
    end
    args = parse_args(s)

    sty = FUSE.study_parameters(:PredictiveRT)
    sty.server = get(ENV, "FUSE_SERVER", "localhost")
    sty.n_workers = 0
    sty.release_workers_after_run = true
    sty.save_folder = get(ENV, "FUSE_RESULT_ARCHIVE", "")
    sty.device = :D3D
    sty.shots = [args["shot"]]
    sty.reconstruction = args["RECONSTRUCTION"]
    sty.redirect_output = false
    sty.verbose = false
    sty.start_time = args["START_TIME"]
    sty.end_time = args["END_TIME"]
    if !isempty(args["save_path"]) > 0
        sty.save_folder = args["save_path"]
    end
    sty.kw_case_parameters=Dict{Symbol,Any}(
        :use_local_cache=>args["USE_LOCAL_CACHE"],
        :fit_profiles=>args["FIT_PROFILES"],
        :EFIT_tree=>args["EFIT_TREE"],
        :PROFILES_tree=>args["PROFILES_TREE"],
        :CER_analysis_type=>args["CER_ANALYSIS_TYPE"],
        :EFIT_run_id=>args["EFIT_RUN_ID"],
        :PROFILES_run_id=>args["PROFILES_RUN_ID"],
        :use_local_cache=>true)

    study = FUSE.StudyPredictiveRT(sty)
    FUSE.run(study)
end

try
    @everywhere import FUSE
    @everywhere ProgressMeter = FUSE.ProgressMeter
    main()
finally
    # Remove PIDs
    Distributed.rmprocs(Distributed.workers())
end
