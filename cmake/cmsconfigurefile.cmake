# @param[in] input
# @param[in] output
# @param[in] any other defines that configure_file needs
configure_file(${input} ${output} @ONLY NEWLINE_STYLE LF)
