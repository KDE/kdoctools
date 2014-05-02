# install common files for all languages
foreach( _kdoctoolscommon_currentlang ${KDOCTOOLS_LANGUAGES_LIST})
    file( GLOB _kdoctoolscommon_lang_allfiles "${_kdoctoolscommon_currentlang}/*" )
    install(FILES ${_kdoctoolscommon_lang_allfiles} DESTINATION ${HTML_INSTALL_DIR}/${_kdoctoolscommon_currentlang}/kdoctools5-common)
endforeach()
