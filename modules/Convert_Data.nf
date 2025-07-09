process Convert_Data {

    input:
    path(dwi)
    path(bval)
    path(bvec)

    output:
    path("data.mif"), emit: converted_data

    script:
    """
    mrconvert $dwi \
    -fslgrad $bvec $bval data.mif \
    -force

    """
}