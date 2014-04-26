# install common files for all languages
foreach( _kdoctoolscommon_currentlang ${KDOCTOOLS_LANGUAGES_LIST})
    file( GLOB _kdoctoolscommon_lang_allfiles "${_kdoctoolscommon_currentlang}/*" )
    foreach( _kdoctoolscommon_lang_file ${_kdoctoolscommon_lang_allfiles} )
        install(FILES ${_kdoctoolscommon_lang_file} DESTINATION ${HTML_INSTALL_DIR}/${_kdoctoolscommon_currentlang}/kdoctools5-common)
    endforeach()
endforeach()
