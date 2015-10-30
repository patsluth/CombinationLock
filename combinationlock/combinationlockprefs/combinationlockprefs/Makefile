




ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest





BUNDLE_NAME = CombinationLockPrefs
CombinationLockPrefs_CFLAGS = -fobjc-arc
CombinationLockPrefs_FILES = SWCombinationLockPSListController.mm
CombinationLockPrefs_INSTALL_PATH = /Library/PreferenceBundles
CombinationLockPrefs_FRAMEWORKS = UIKit
CombinationLockPrefs_PRIVATE_FRAMEWORKS = Preferences
CombinationLockPrefs_LIBRARIES = sw

ADDITIONAL_CFLAGS = -Ipublic





include theos/makefiles/common.mk
include theos/makefiles/bundle.mk
include theos/makefiles/swcommon.mk





internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CombinationLockPrefs.plist$(ECHO_END)




