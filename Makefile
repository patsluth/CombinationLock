THEOS_PACKAGE_DIR_NAME = debs

USEWIFI = 1 ###COMMENT OUT TO USE USB

ifdef USEWIFI
    THEOS_DEVICE_IP = 192.168.1.120
    THEOS_DEVICE_PORT = 22
else
    THEOS_DEVICE_IP = 127.0.0.1
    THEOS_DEVICE_PORT = 2222
endif

ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest:7.0

TWEAK_NAME = CombinationLock
CombinationLock_CFLAGS = -fobjc-arc
CombinationLock_FILES = SWCombinationLock.xm SWCombinationWheel/SWCombinationWheel/SWCombinationWheel.m SWCombinationWheel/SWCombinationWheel/SWCombinationItem.m
CombinationLock_FRAMEWORKS = Foundation UIKit CoreGraphics QuartzCore
CombinationLock_LIBRARIES = substrate sw

ADDITIONAL_CFLAGS = -Ipublic
ADDITIONAL_CFLAGS += -Ipublic/libsw
ADDITIONAL_CFLAGS += -Ipublic/libsw/libSluthware
ADDITIONAL_CFLAGS += -ISWCombinationWheel/SWCombinationWheel

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	@install.exec "killall -9 SpringBoard"