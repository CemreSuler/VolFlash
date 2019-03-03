include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = VolFlash
VolFlash_FILES = VFLRootListController.m
VolFlash_INSTALL_PATH = /Library/PreferenceBundles
VolFlash_FRAMEWORKS = UIKit
VolFlash_PRIVATE_FRAMEWORKS = Preferences
VolFlash_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/VolFlash.plist$(ECHO_END)
