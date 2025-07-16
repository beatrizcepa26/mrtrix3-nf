process Whole_Brain_Mask {

    input:
    path(dwi)
    path(bval)
    path(bvec)

    output:
    path("wb_mask.mif"), emit: wb_mask

    script:
    """
    dwi2mask $dwi wb_mask.mif \
    -fslgrad $bvec $bval \
    -force
    """
}