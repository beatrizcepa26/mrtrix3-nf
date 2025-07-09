process FOD_Estimation {

    input:
    path(converted_data)
    path(wm_response)
    path(gm_response)
    path(csf_response)
    path(bval)
    path(bvec)
    
    output:
    path("wm_fod.mif"), emit: wm_fod
    path("gm_fod.mif"), emit: gm_fod
    path("csf_fod.mif"), emit: csf_fod

    script:
    """
    dwi2fod msmt_csd $converted_data \
    $wm_response wm_fod.mif $gm_response gm_fod.mif $csf_response csf_fod.mif \
    -fslgrad $bvec $bval \
    -force
    """
}