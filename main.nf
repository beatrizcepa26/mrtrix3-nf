include {Convert_Data} from './modules/Convert_Data.nf'
include {Response_Function_Estimation} from './modules/Response_Function_Estimation.nf'
include {Global_Tractography} from './modules/Global_Tractography.nf'

workflow{

    if (!params.input) {
        error "Please provide the input data using the --input parameter."
    }

    log.info "Input: ${params.input}"

    def root = file(params.input)
    def dwi = root.resolve("dwi.nii.gz")
    def bval = root.resolve("bval")
    def bvec = root.resolve("bvec")


    converted_data = Channel.empty()
    if (dwi.exists() && bval.exists() && bvec.exists()) {
        data_mif = Convert_Data(dwi, bval, bvec)
    } else {
        error "Required files (dwi.nii.gz, bval, bvec) not found in the input directory."
    }

    if (params.trck=='global') {

        rfe_results = Response_Function_Estimation(data_mif)
        wm_response = rfe_results.wm_response
        gm_response = rfe_results.gm_response
        csf_response = rfe_results.csf_response

        tracks = Global_Tractography(data_mif, wm_response, gm_response, csf_response)

    }


}

workflow.onComplete {
    println "Pipeline completed at: $workflow.complete"
    println "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
    println "Execution duration: $workflow.duration"
}