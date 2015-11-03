



FINALPACKAGE = 1
PACKAGE_VERSION=1.0-3





ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest:7.0





TWEAK_NAME = CombinationLock
CombinationLock_CFLAGS = -fobjc-arc
CombinationLock_FILES = SWCombinationLock.xm SWCombinationWheel.m SWCombinationItem.m
CombinationLock_FRAMEWORKS = Foundation UIKit CoreGraphics QuartzCore
CombinationLock_LIBRARIES = substrate sw packageinfo

ADDITIONAL_CFLAGS = -Ipublic





BUNDLE_NAME = CombinationLockSupport
CombinationLockSupport_INSTALL_PATH = /Library/Application Support





SUBPROJECTS += CombinationLockPrefs





include theos/makefiles/common.mk
include theos/makefiles/bundle.mk
include theos/makefiles/tweak.mk
include theos/makefiles/aggregate.mk
include theos/makefiles/swcommon.mk





after-install::
	install.exec "killall -9 backboardd"




