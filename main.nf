nextflow.enable.dsl=2

include {Parameter_List} from './modules/Parameter_List.nf'
include {Convert_Data} from './modules/Convert_Data.nf'
include {Response_Function_Estimation} from './modules/Response_Function_Estimation.nf'
include {MSMT_Tractography} from './modules/MSMT_Tractography.nf'
// include {DWI_Preprocessing} from './modules/DWI_Preprocessing.nf'
include {T1_Segmentation} from './modules/T1_Segmentation.nf'
include {AC_Tractography} from './modules/AC_Tractography.nf'
include {Seeding_Mask_GMWMI} from './modules/Seeding_Mask_GMWMI.nf'
include {FOD_Estimation} from './modules/FOD_Estimation.nf'
include {Streamline_Tractography} from './modules/Streamline_Tractography.nf'
include {Whole_Brain_Mask} from './modules/Whole_Brain_Mask.nf'

workflow{

    if (!params.input) {
        error "Please provide the input data using the --input parameter."
    }

    log.info "Input: ${params.input}"
    log.info "Tractography type: ${params.trck}"
    log.info "Tractography algorithm: ${params.trck_algorithm}"

    def root = file(params.input)
    def dwi = root.resolve("dwi.nii.gz")
    def bval = root.resolve("bval") // Re-check if this is needed
    def bvec = root.resolve("bvec") // Re-check if this is needed
    // def b0 = root.resolve("rev_b0.nii.gz")
    def voxel_mask = file("${root}/voxel_mask.*")
    def fivett_file = root.resolve("5tt.nii.gz")

    Parameter_List()

    converted_data = Channel.empty()

    if (!(dwi.exists() && bval.exists() && bvec.exists())) {
        error "Required files (dwi.nii.gz, bval, bvec) not found in the input directory."        
    }

    converted_data = Convert_Data(dwi)
    
    // Create dummy files in current directory if needed
    if (!voxel_mask.exists()) {
        file("NO_VOXEL_MASK").text = ""
        voxel_mask = file("NO_VOXEL_MASK")
    }
    if (!fivett_file.exists()) {
        file("NO_FIVETT_FILE").text = ""
        fivett_file = file("NO_FIVETT_FILE")
    }

    rfe_results = Response_Function_Estimation(converted_data, voxel_mask, fivett_file)

    // Extract response files
    wm_response = rfe_results.wm_response
    gm_response = rfe_results.gm_response
    csf_response = rfe_results.csf_response
    response = rfe_results.response

    // // Multi-shell Multi-tissue tractography
    // if (params.trck=='msmt') {

    //     tracks_msmt = MSMT_Tractography(converted_data, wm_response, gm_response, csf_response)

    // }

    // // Anatomically-constrained tractography
    // if (params.trck=='act'){

    //     // We assume that the DWI preprocessing step is already done
    //     // dwi_preproc = DWI_Preprocessing(data_mif, bval, bvec, b0)

    //     def t1 = root.resolve("t1.nii.gz")
        
    //     if (!t1.exists()) {
    //         error "T1 image (t1.nii.gz) not found in the input directory."
    //     }

    //     t1_segmentation = T1_Segmentation(t1)

    //     seeding_mask_gmwmi = Seeding_Mask_GMWMI(t1_segmentation)

    //     fod_results = FOD_Estimation(converted_data, wm_response, gm_response, csf_response, bval, bvec)
    //     wm_fod = fod_results.wm_fod

    //     tracks_act = AC_Tractography(wm_fod, t1_segmentation, bval, bvec, seeding_mask_gmwmi)

    // }

    // // Streamline tractography
    // if (params.trck=='streamline') {

    //     // iFOD1 e iFOD2
    //     if (params.trck_algorithm in ['iFOD2', 'iFOD1']) {

    //         //seed_image = Whole_Brain_Mask(converted_data, bval, bvec)

    //         fod_results = FOD_Estimation(converted_data, wm_response, gm_response, csf_response, bval, bvec)
    //         wm_fod = fod_results.wm_fod

    //         // tracks_str = Streamline_Tractography(wm_fod, seed_image)

    //         tracks_str = Streamline_Tractography(wm_fod)

    //     } 
        
    //     else {
    //         error "Unsupported algorithm for streamline tractography: ${params.trck_algorithm}. Choose 'iFOD2' or 'iFOD1'."
    //     }

    // }    

}

workflow.onComplete {
    println "Pipeline completed at: $workflow.complete"
    println "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
    println "Execution duration: $workflow.duration"
}