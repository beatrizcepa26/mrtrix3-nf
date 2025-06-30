process Response_Function_Estimation {

    input:
    path(data_mif)

    output:
    path("wm_response.txt"), emit: wm_response
    path("gm_response.txt"), emit: gm_response
    path("csf_response.txt"), emit: csf_response

    script:
    """
    dwi2response dhollander $data_mif wm_response.txt gm_response.txt csf_response.txt

    """
}