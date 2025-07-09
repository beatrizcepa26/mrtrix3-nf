process T1_Segmentation {

    input:
    path(t1)
    
    output:
    path("t1_segmentation.mif"), emit: t1_segmentation

    script:
    """
    5ttgen fsl $t1 t1_segmentation.mif \
    -force
    """
}