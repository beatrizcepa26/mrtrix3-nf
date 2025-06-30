process Global_Tractography {

    input:
    path(data_mif)
    path(wm_response)
    path(gm_response)
    path(csf_response)

    output:
    path("tracks.tck"), emit: tracks

    script:
    """
    tckglobal $data_mif $wm_response \
    -riso $csf_response \
    -riso $gm_response \
    -niter 1e9 tracks.tck \
    -force

    """
}