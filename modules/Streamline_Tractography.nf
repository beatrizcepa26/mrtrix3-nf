process Streamline_Tractography {

    input:
    path(wm_fod)
    // path(bval)
    // path(bvec)
    path(seed_image)

    output:
    path("tracks_str.tck"), emit: tracks_str

    script:

    // Config file options

    // Only one seeding option permitted, and only for masks calculated within the pipeline
    def seeding_mech = ""

    if (params.seed_image) {
        params.seed_image.split(',')
                    .each { image -> seeding_mech += "-seed_image $image "
        }
    }
    seeding_mech = seeding_mech.replaceAll(/\s+/, ' ').trim()

    def seeding_opt = """ 
        ${params.seeds ? "-seeds $params.seeds" : ""}
        ${params.max_attempts_per_seed ? "-max_attempts_per_seed $params.max_attempts_per_seed" : ""}
        ${params.seed_cutoff ? "-seed_cutoff $params.seed_cutoff" : ""}
        ${params.seed_direction ? "-seed_direction $params.seed_direction" : ""}
        ${params.output_seeds ? "-output_seeds $params.output_seeds" : ""}
    """.replaceAll(/\s+/, ' ').trim()

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

    def roi_opt = """ 
        ${params.include ? "-include $params.include" : ""}
        ${params.include_ordered ? "-include_ordered $params.include_ordered" : ""}
        ${params.exclude ? "-exclude $params.exclude" : ""}
        ${params.mask ? "-mask $params.mask" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    def ifod_opt = """ 
        ${params.power ? "-power $params.power" : ""}
        ${params.samples ? "-samples $params.samples" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    def dw_grad_opt = """ 
        ${params.grad ? "-grad $params.grad" : ""}
        ${params.fslgrad ? "-fslgrad $params.bvec $params.bval" : ""}
    """.replaceAll(/\s+/, ' ').trim()

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