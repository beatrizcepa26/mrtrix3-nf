process Response_Function_Estimation {

    input:
    path data_mif
    path voxel_mask
    path fivett_image

    output:
    path "wm_response.txt", emit: wm_response, optional: true
    path "gm_response.txt", emit: gm_response, optional: true
    path "csf_response.txt", emit: csf_response, optional: true
    path "response.txt", emit: response, optional: true

    script:

    // DW gradient table options
    def dw_grad_opt = """ 
        ${params.grad ? "-grad $params.grad" : ""}
        ${params.fslgrad ? "-fslgrad $params.bvec $params.bval" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    // General dwi2response options
    def dwi2response_opt = """ 
        ${params.rfe_mask ? "-mask $params.rfe_mask" : ""}
        ${params.voxels ? "-voxels $params.voxels" : ""}
        ${params.shells ? "-shells $params.shells" : ""}
        ${params.lmax ? "-lmax $params.lmax" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    // Options for Python scripts
    def python = """
        ${params.py_nocleanup ? "-nocleanup" : ""}
        ${params.py_scratch ? "-scratch $params.py_scratch" : ""}
        ${params.py_continue ? "-continue $params.py_continue_dir $params.py_continue_file" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    // Standard options
    def standard_opt = """ 
        ${params.info ? "-info" : ""}
        ${params.quiet ? "-quiet" : ""}
        ${params.debug ? "-debug" : ""}
        ${params.force ? "-force" : ""}
        ${params.nthreads ? "-nthreads $params.nthreads" : ""}
        ${params.help ? "-help" : ""}
        ${params.version ? "-version" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    if (params.config){
        def keys = params.config_key.split(',')
        def values = params.config_value.split(',')

        if (keys.size() != values.size()) {
            error "Number of keys and values must match. Found ${keys.size()} keys and ${values.size()} values."
        }

        for (int i = 0; i < keys.size(); i++) {
            standard_opt += " -config ${keys[i]} ${values[i]} "
        }
    }
    standard_opt = standard_opt.replaceAll(/\s+/, ' ').trim()

    // dhollander options
    def dhollander_opt = """
        ${params.dhollander_erode ? "-erode $params.dhollander_erode" : ""}
        ${params.dhollander_fa ? "-fa $params.dhollander_fa" : ""}
        ${params.dhollander_sfwm ? "-sfwm $params.dhollander_sfwm" : ""}
        ${params.dhollander_gm ? "-gm $params.dhollander_gm" : ""}
        ${params.dhollander_csf ? "-csf $params.dhollander_csf" : ""}
        ${params.dhollander_wm_algo ? "-wm_algo $params.dhollander_wm_algo_name" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    // fa options
    def fa_opt = """
        ${params.fa_erode ? "-erode $params.fa_erode" : ""}
        ${params.fa_number ? "-number $params.fa_number" : ""}
        ${params.fa_threshold ? "-threshold $params.fa_threshold" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    // manual options
    def manual_opt = """
        ${params.manual_dirs ? "-dirs $params.manual_dirs" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    // msmt_5tt options
    def msmt_5tt_opt = """
        ${params.msmt_5tt_dirs ? "-dirs $params.msmt_5tt_dirs" : ""}
        ${params.msmt_5tt_fa ? "-fa $params.msmt_5tt_fa" : ""}
        ${params.msmt_5tt_pvf ? "-pvf $params.msmt_5tt_pvf" : ""}
        ${params.msmt_5tt_wm_algo ? "-wm_algo $params.msmt_5tt_wm_algo_name" : ""}
        ${params.msmt_5tt_sfwm_fa_threshold ? "-sfwm_fa_threshold $params.msmt_5tt_sfwm_fa_threshold" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    // tax options
    def tax_opt = """
        ${params.tax_peak_ratio ? "-peak_ratio $params.tax_peak_ratio" : ""}
        ${params.tax_max_iters ? "-max_iters $params.tax_max_iters" : ""}
        ${params.tax_convergence ? "-convergence $params.tax_convergence" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    // tournier options
    def tournier_opt = """
        ${params.tournier_number ? "-number $params.tournier_number" : ""}
        ${params.tournier_iter_voxels ? "-iter_voxels $params.tournier_iter_voxels" : ""}
        ${params.tournier_dilate ? "-dilate $params.tournier_dilate" : ""}
        ${params.tournier_max_iters ? "-max_iters $params.tournier_max_iters" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    // Algorithm-specific parameters and output files
    def algorithm_params = ""
    def output_files = ""
    def command_line = ""

    if (params.rfe_algorithm == 'dhollander') {

        algorithm_params = dhollander_opt
        output_files = "wm_response.txt gm_response.txt csf_response.txt"
        command_line = "dwi2response dhollander $data_mif $output_files $algorithm_params $dw_grad_opt $dwi2response_opt $python $standard_opt"

    } else if (params.rfe_algorithm == 'fa') {

        algorithm_params = fa_opt
        output_files = "response.txt"
        command_line = "dwi2response fa $data_mif $output_files $algorithm_params $dw_grad_opt $dwi2response_opt $python $standard_opt"

    } else if (params.rfe_algorithm == 'manual') {

        algorithm_params = manual_opt
        output_files = "response.txt"
        command_line = "dwi2response manual $data_mif $voxel_mask $output_files $algorithm_params $dw_grad_opt $dwi2response_opt $python $standard_opt"
                
    } else if (params.rfe_algorithm == 'msmt_5tt') {

        algorithm_params = msmt_5tt_opt
        output_files = "wm_response.txt gm_response.txt csf_response.txt"
        command_line = "dwi2response msmt_5tt $data_mif $fivett_image $output_files $algorithm_params $dw_grad_opt $dwi2response_opt $python $standard_opt"
                  
    }
    // else if (params.rfe_algorithm == 'tax') {

    //     algorithm_params = """
    //         $params.rfe_algorithm $tax_opt
    //     """.replaceAll(/\s+/, ' ').trim()         
    // }
    // else if (params.rfe_algorithm == 'tournier') {

    //     algorithm_params = """
    //         $params.rfe_algorithm $tournier_opt
    //     """.replaceAll(/\s+/, ' ').trim()         
    // } 


    """    
    $command_line
    """

    
    // """
    // dwi2response dhollander $data_mif wm_response.txt gm_response.txt csf_response.txt

    // """
}