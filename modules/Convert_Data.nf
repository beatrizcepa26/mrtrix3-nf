process Convert_Data {

    input:
    path dwi 
    // path(bval)
    // path(bvec)

    output:
    path "data.mif", emit: converted_data

    script:

    // Manipulating image properties
    def img_prop = """
        ${params.vox ? "-vox $params.vox" : ""}
        ${params.axes ? "-axes $params.axes" : ""}
        ${params.scaling ? "-scaling $params.scaling" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    if (params.coord){
        def axes = params.coord_axis.split(',')
        def selection = params.coord_selection.split('/')

        for (int i = 0; i < axes.size(); i++) {
            img_prop += " -coord ${axes[i]} ${selection[i]} "
        }
    }
    img_prop = img_prop.replaceAll(/\s+/, ' ').trim()

    // Handling JSON files
    def json = """
        ${params.json_import ? "-json_import $params.json_import" : ""}
        ${params.json_export ? "-json_export $params.json_export" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    // Modify generic header entries
    def header = """
       ${params.copy_properties ? "-copy_properties $params.copy_properties" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    if (params.clear_property){
        def keys = params.clear_property.split(',')

        for (int i = 0; i < keys.size(); i++) {
            header += " -clear_property ${keys[i]} "
        }
    }
    if (params.set_property){
        def keys = params.set_property_key.split(',')
        def values = params.set_property_value.split(',')

        if (keys.size() != values.size()) {
            error "Number of keys and values must match. Found ${keys.size()} keys and ${values.size()} values."
        }

        for (int i = 0; i < keys.size(); i++) {
            header += " -set_property ${keys[i]} ${values[i]} "
        }
    }
    if (params.append_property){
        def keys = params.append_property_key.split(',')
        def values = params.append_property_value.split(',')

        if (keys.size() != values.size()) {
            error "Number of keys and values must match. Found ${keys.size()} keys and ${values.size()} values."
        }

        for (int i = 0; i < keys.size(); i++) {
            header += " -append_property ${keys[i]} ${values[i]} "
        }
    }
    header = header.replaceAll(/\s+/, ' ').trim()

    // Stride options
    def stride = """${params.stride ? "-stride $params.stride" : ""}"""

    // Data type options
    def data_type = """${params.data_type ? "-datatype $params.data_type" : ""}"""

    // DW gradient table options
    def dw_grad_opt = """ 
        ${params.grad ? "-grad $params.grad" : ""}
        ${params.fslgrad ? "-fslgrad $params.bvec $params.bval" : ""}
        ${params.bvalue_scaling ? "-bvalue_scaling $params.bvalue_scaling" : ""}
        ${params.export_grad_mrtrix ? "-export_grad_mrtrix $params.export_grad_mrtrix" : ""}
        ${params.export_grad_fsl ? "-export_grad_fsl $params.bvecs_path $params.bvals_path" : ""}
    """.replaceAll(/\s+/, ' ').trim()

    // Phase-encoded tables
    def pe_tables = """ 
        ${params.import_pe_topup ? "-import_pe_topup $params.import_pe_topup" : ""}
        ${params.import_pe_eddy ? "-import_pe_eddy $params.pe_eddy_config_in $params.pe_eddy_indices_in" : ""}
        ${params.export_pe_topup ? "-export_pe_topup $params.export_pe_topup" : ""}
        ${params.export_pe_eddy ? "-export_pe_eddy $params.pe_eddy_config_out $params.pe_eddy_indices_out" : ""}
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


    """ 
    mrconvert $dwi $img_prop $json $header $stride $dw_grad_opt $pe_tables $standard_opt \
            data.mif 
    """

    // """
    // mrconvert $dwi \
    // -fslgrad $bvec $bval data.mif \
    // -force

    // """
}