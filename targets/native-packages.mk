###############################################################################
## @file targets/native-packages.mk
## @author Y.M. Morgan
## @date 2016/03/05
##
## Additional generic packages for native target.
###############################################################################

$(call register-prebuilt-pkg-config-module,zlib,zlib)
$(call register-prebuilt-pkg-config-module,ncurses,ncurses)
