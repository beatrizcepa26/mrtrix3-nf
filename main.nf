include {Convert_Data} from './modules/Convert_Data.nf'
include {Response_Function_Estimation} from './modules/Response_Function_Estimation.nf'
include {Global_Tractography} from './modules/Global_Tractography.nf'
// include {DWI_Preprocessing} from './modules/DWI_Preprocessing.nf'
include {T1_Segmentation} from './modules/T1_Segmentation.nf'
include {AC_Tractography} from './modules/AC_Tractography.nf'
include {Seeding_Mask_GMWMI} from './modules/Seeding_Mask_GMWMI.nf'
include {FOD_Estimation} from './modules/FOD_Estimation.nf'

workflow{

    if (!params.input) {
        error "Please provide the input data using the --input parameter."
    }

    log.info "Input: ${params.input}"

    def root = file(params.input)
    def dwi = root.resolve("dwi.nii.gz")
    def bval = root.resolve("bval")
    def bvec = root.resolve("bvec")
    // def b0 = root.resolve("rev_b0.nii.gz")

    converted_data = Channel.empty()

    if (dwi.exists() && bval.exists() && bvec.exists()) {
        converted_data = Convert_Data(dwi, bval, bvec)
    } else {
        error "Required files (dwi.nii.gz, bval, bvec) not found in the input directory."
    }

    if (params.trck=='global') {

        rfe_results = Response_Function_Estimation(converted_data)
        wm_response = rfe_results.wm_response
        gm_response = rfe_results.gm_response
        csf_response = rfe_results.csf_response

        tracks_global = Global_Tractography(converted_data, wm_response, gm_response, csf_response)

    }

    if (params.trck=='act'){

        // We assume that the DWI preprocessing step is already done
        // dwi_preproc = DWI_Preprocessing(data_mif, bval, bvec, b0)

        def t1 = root.resolve("t1.nii.gz")
        
        if (!t1.exists()) {
            error "T1 image (t1.nii.gz) not found in the input directory."
        }

        t1_segmentation = T1_Segmentation(t1)

        seeding_mask_gmwmi = Seeding_Mask_GMWMI(t1_segmentation)

        rfe_results = Response_Function_Estimation(converted_data)
        wm_response = rfe_results.wm_response
        gm_response = rfe_results.gm_response
        csf_response = rfe_results.csf_response

        fod_results = FOD_Estimation(converted_data, wm_response, gm_response, csf_response, bval, bvec)
        wm_fod = fod_results.wm_fod

        tracks_act = AC_Tractography(wm_fod, t1_segmentation, bval, bvec, seeding_mask_gmwmi)

    }


}

workflow.onComplete {
    println "Pipeline completed at: $workflow.complete"
    println "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
    println "Execution duration: $workflow.duration"
}