process AC_Tractography {

    input:
    path(wm_fod) // Assuming this is the white matter FOD file
    path(t1_segmentation) // Assuming this is the 5TT segmentation file
    path(bval)
    path(bvec)
    path(seeding_mask_gmwmi)

    output:
    path("tracks_act.tck"), emit: tracks_act

    script:

    // Default algorithm is iFOD2

    """
    tckgen $wm_fod tracks_act.tck \
    -algorithm $params.act_algorithm \
    -act $t1_segmentation \
    -seed_gmwmi $seeding_mask_gmwmi \
    -fslgrad $bvec $bval \
    -force
    """
}