process Streamline_Tractography {

    input:
    path(wm_fod)
    // path(bval)
    // path(bvec)
    // path(seed_image)

    output:
    path("tracks_str.tck"), emit: tracks_str

    script:

    // Config file options

    // Only one seeding option permitted, and only for masks calculated within the pipeline
    // Tractography seeding mechanisms
    def seeding_mech = ""

    // provide the seeding options separated by commas
    if (params.seed_image) {
        params.seed_image.split(',')
                    .each { image -> seeding_mech += "-seed_image $image "}
    } 
    if (params.seed_rejection) {
        params.seed_rejection.split(',')
                    .each { image -> seeding_mech += "-seed_rejection $image "}
    }
    if (params.seed_dynamic) {
        params.seed_dynamic.split(',')
                    .each { image -> seeding_mech += "-seed_dynamic $image "}
    }
    if (params.seed_sphere) {
        def spec = params.seed_sphere.split(',')

        for (int i=0; i<spec.size(); i+=4) {
            if (i + 3 < spec.size()) {
                seeding_mech += "-seed_sphere ${spec[i]},${spec[i+1]},${spec[i+2]},${spec[i+3]} "
            } else {
                error "Invalid seed_sphere specification: ${params.seed_sphere}. Must be in groups of four comma-separated values v(XYZ position and radius)"
            }
        }                
    }
    seeding_mech.replaceAll(/\s+/, ' ').trim()

    // not tested yet ------------
    if (params.seed_random_per_voxel) {
        def images = params.seed_random_per_voxel.split(',')
        def nums = params.num_per_voxel.split(',')

        if (images.size() != nums.size()) {
            error "Number of images and num_per_voxel must match. Found ${images.size()} images and ${nums.size()} num_per_voxel values."
        }

        for (int i=0; i<images.size(); i++) {
            seeding_mech += "-seed_random_per_voxel ${images[i]} ${nums[i]} "
        }               
    }
    // -------------------------------

    // Tractography seeding options and parameters
    def seeding_opt = """ 
        ${params.seeds ? "-seeds $params.seeds" : ""}
        ${params.max_attempts_per_seed ? "-max_attempts_per_seed $params.max_attempts_per_seed" : ""}
        ${params.seed_cutoff ? "-seed_cutoff $params.seed_cutoff" : ""}
        ${params.seed_direction ? "-seed_direction $params.seed_direction" : ""}
        ${params.output_seeds ? "-output_seeds $params.output_seeds" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    // Streamlines options
    def streamline_opt = """ 
        ${params.select ? "-select $params.select" : ""}
        ${params.step ? "-step $params.step" : ""}
        ${params.angle ? "-angle $params.angle" : ""}
        ${params.minlength ? "-minlength $params.minlength" : ""}
        ${params.maxlength ? "-maxlength $params.maxlength" : ""}
        ${params.cutoff ? "-cutoff $params.cutoff" : ""}
        ${params.trials ? "-trials $params.trials" : ""}
        ${params.noprecomputed ? "-noprecomputed" : ""}
        ${params.rk4 ? "-rk4" : ""}      
        ${params.stop ? "-stop" : ""}
        ${params.downsample ? "-downsample $params.downsample" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    // ROI processing options
    def roi_opt = """ 
        ${params.include ? "-include $params.include" : ""}
        ${params.include_ordered ? "-include_ordered $params.include_ordered" : ""}
        ${params.exclude ? "-exclude $params.exclude" : ""}
        ${params.mask ? "-mask $params.mask" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    // iFOD tracking options
    def ifod_opt = """ 
        ${params.power ? "-power $params.power" : ""}
        ${params.samples ? "-samples $params.samples" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    // DW gradient table options
    def dw_grad_opt = """ 
        ${params.grad ? "-grad $params.grad" : ""}
        ${params.fslgrad ? "-fslgrad $params.bvec $params.bval" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    // Standard options
    def standard_opt = """ 
        ${params.info ? "-info" : ""}
        ${params.quiet ? "-quiet" : ""}
        ${params.debug ? "-debug" : ""}
        ${params.force ? "-force" : ""}
        ${params.nthreads ? "-nthreads $params.nthreads" : ""}
        ${params.config ? "-config $params.config_key $params.config_value" : ""}
        ${params.help ? "-help" : ""}
        ${params.version ? "-version" : ""}
    """.replaceAll(/\s+/, ' ').trim()


    // Algorithm options
    def algorithm_params = ""

    if (params.trck_algorithm in ['iFOD2', 'iFOD1']) {

        algorithm_params = """
            $wm_fod tracks_str.tck -algorithm $params.trck_algorithm
        """.replaceAll(/\s+/, ' ').trim()         
    }

    """
    tckgen $algorithm_params $streamline_opt $seeding_mech $seeding_opt $roi_opt $ifod_opt $dw_grad_opt $standard_opt
    """
        

    // Default algorithm is iFOD2

    // """
    // tckgen $wm_fod tracks_str.tck \
    // -algorithm $params.trck_algorithm \
    // -seed_image $wb_mask \
    // -fslgrad $bvec $bval \
    // -force
    // """
}