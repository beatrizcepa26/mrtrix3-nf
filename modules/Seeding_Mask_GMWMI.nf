process Seeding_Mask_GMWMI {


    input:
    path(t1_segmentation)

    output:
    path("seeding_mask_gmwmi.nii.gz"), emit: seeding_mask_gmwmi

    script:
    """
    5tt2gmwmi $t1_segmentation seeding_mask_gmwmi.nii.gz \
    -force
    """
}