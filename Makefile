THEOS_DEVICE_IP =
include $(THEOS)/makefiles/common.mk
PACKAGE_VERSION=1.4.1
TWEAK_NAME = VolFlash
VolFlash_FILES = Tweak.xm
VolFlash_EXTRA_FRAMEWORKS += Cephei
VolFlash_FRAMEWORKS = IOKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += volflash
include $(THEOS_MAKE_PATH)/aggregate.mk
