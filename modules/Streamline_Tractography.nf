process Streamline_Tractography {

    input:
    path(wm_fod)
    path(bval)
    path(bvec)
    path(wb_mask)

    output:
    path("tracks_str.tck"), emit: tracks_str

    script:

    // Default algorithm is iFOD2

    """
    tckgen $wm_fod tracks_str.tck \
    -algorithm $params.trck_algorithm \
    -seed_image $wb_mask \
    -fslgrad $bvec $bval \
    -force
    """
}