process Parameter_List {

    output:
    path("parameters.txt")

    script:

    def list_options = "";
    params.each { key, value ->
        list_options +="$key: $value\n"
    }


    """
    echo "MRtrix3 pipeline\n" >> parameters.txt
    echo "Start time: $workflow.start\n" >> parameters.txt
    echo "[Command line]\n$workflow.commandLine\n" >> parameters.txt
    echo "[Parameters]\n" >> parameters.txt
    echo "$list_options" >> parameters.txt
    """
}