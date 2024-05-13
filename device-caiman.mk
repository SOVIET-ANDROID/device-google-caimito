#
# Copyright (C) 2021 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ifdef RELEASE_GOOGLE_CAIMAN_RADIO_DIR
RELEASE_GOOGLE_PRODUCT_RADIO_DIR := $(RELEASE_GOOGLE_CAIMAN_RADIO_DIR)
endif
ifdef RELEASE_GOOGLE_CAIMAN_RADIOCFG_DIR
RELEASE_GOOGLE_PRODUCT_RADIOCFG_DIR := $(RELEASE_GOOGLE_CAIMAN_RADIOCFG_DIR)
endif
RELEASE_GOOGLE_BOOTLOADER_CAIMAN_DIR ?= 24D1# Keep this for pdk TODO: b/327119000
RELEASE_GOOGLE_PRODUCT_BOOTLOADER_DIR := bootloader/$(RELEASE_GOOGLE_BOOTLOADER_CAIMAN_DIR)
$(call soong_config_set,caimito_bootloader,prebuilt_dir,$(RELEASE_GOOGLE_BOOTLOADER_CAIMAN_DIR))

ifdef RELEASE_GOOGLE_CAIMAN_KERNEL_DIR
TARGET_KERNEL_DIR ?= $(RELEASE_GOOGLE_CAIMAN_KERNEL_DIR)
TARGET_BOARD_KERNEL_HEADERS ?= $(RELEASE_GOOGLE_CAIMAN_KERNEL_DIR)/kernel-headers
else
TARGET_KERNEL_DIR ?= device/google/caimito-kernels/6.1/24D1
TARGET_BOARD_KERNEL_HEADERS ?= device/google/caimito-kernels/6.1/24D1/kernel-headers
endif

LOCAL_PATH := device/google/caimito

ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
    USE_UWBFIELDTESTQM := true
endif
ifeq ($(filter factory_caiman, $(TARGET_PRODUCT)),)
    include device/google/caimito/caiman/uwb/uwb_calibration.mk
endif

$(call inherit-product-if-exists, vendor/google_devices/caimito/prebuilts/device-vendor-caiman.mk)
$(call inherit-product-if-exists, vendor/google_devices/zumapro/prebuilts/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/zumapro/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/caiman/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/caimito/proprietary/caiman/device-vendor-caiman.mk)
$(call inherit-product-if-exists, vendor/qorvo/uwb/qm35-hal/Device.mk)

ifeq ($(filter factory_caiman, $(TARGET_PRODUCT)),)
    $(call inherit-product-if-exists, vendor/google_devices/caimito/proprietary/WallpapersCaiman.mk)
endif

# display
DEVICE_PACKAGE_OVERLAYS += device/google/caimito/caiman/overlay

ifeq ($(RELEASE_PIXEL_AIDL_AUDIO_HAL),true)
USE_AUDIO_HAL_AIDL := true
endif

include device/google/caimito/audio/caiman/audio-tables.mk
include device/google/zumapro/device-shipping-common.mk
include hardware/google/pixel/vibrator/cs40l26/device.mk
include device/google/gs-common/bcmbt/bluetooth.mk
include device/google/gs-common/touch/gti/predump_gti.mk
include device/google/caimito/fingerprint/ultrasonic_udfps.mk
include device/google/gs-common/modem/radio_ext/radio_ext.mk
include device/google/gs-common/pixelsupport/pixelsupport.mk

# go/lyric-soong-variables
$(call soong_config_set,lyric,camera_hardware,caiman)
$(call soong_config_set,lyric,tuning_product,caiman)
$(call soong_config_set,google3a_config,target_device,caiman)

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.surface_flinger.ignore_hdr_camera_layers=true

# Init files
PRODUCT_COPY_FILES += \
	device/google/caimito/conf/init.caiman.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.caiman.rc

# Recovery files
PRODUCT_COPY_FILES += \
        device/google/caimito/conf/init.recovery.device.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.caiman.rc

# NFC
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.xml \
	frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hce.xml \
	frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hcef.xml \
	frameworks/native/data/etc/com.nxp.mifare.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/com.nxp.mifare.xml \
	frameworks/native/data/etc/android.hardware.nfc.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.ese.xml \
	device/google/caimito/nfc/libnfc-hal-st.conf:$(TARGET_COPY_OUT_VENDOR)/etc/libnfc-hal-st.conf \
	device/google/caimito/nfc/libnfc-nci.conf:$(TARGET_COPY_OUT_PRODUCT)/etc/libnfc-nci.conf

PRODUCT_PACKAGES += \
	$(RELEASE_PACKAGE_NFC_STACK) \
	Tag \
	android.hardware.nfc-service.st \
	NfcOverlayCaiman

# SecureElement
PRODUCT_PACKAGES += \
	android.hardware.secure_element-service.thales

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.se.omapi.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.ese.xml \
	frameworks/native/data/etc/android.hardware.se.omapi.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.uicc.xml \
	device/google/caimito/nfc/libse-gto-hal.conf:$(TARGET_COPY_OUT_VENDOR)/etc/libse-gto-hal.conf

# Bluetooth HAL
PRODUCT_COPY_FILES += \
	device/google/caimito/bluetooth/bt_vendor_overlay_caiman.conf:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth/bt_vendor_overlay.conf
PRODUCT_PROPERTY_OVERRIDES += \
    ro.bluetooth.a2dp_offload.supported=true \
    persist.bluetooth.a2dp_offload.disabled=false \
    persist.bluetooth.a2dp_offload.cap=sbc-aac-aptx-aptxhd-ldac-opus

# Coex Config
PRODUCT_SOONG_NAMESPACES += device/google/caimito/radio/caiman/coex
PRODUCT_PACKAGES += \
    camera_front_mipi_coex_table \
    camera_rear_main_dbr_coex_table \
    camera_rear_main_mipi_coex_table \
    camera_rear_tele_mipi_coex_table \
    camera_rear_wide_mipi_coex_table \
    display_primary_mipi_coex_table

# Bluetooth Tx power caps
PRODUCT_COPY_FILES += \
        $(LOCAL_PATH)/bluetooth/bluetooth_power_limits.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits.csv \
        $(LOCAL_PATH)/bluetooth/bluetooth_power_limits_JP.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_JP.csv

# DCK properties based on target
PRODUCT_PROPERTY_OVERRIDES += \
    ro.gms.dck.eligible_wcc=3 \
    ro.gms.dck.se_capability=1

# POF
PRODUCT_PRODUCT_PROPERTIES += \
    ro.bluetooth.finder.supported=true

# Spatial Audio
PRODUCT_PACKAGES += \
	libspatialaudio

# declare use of spatial audio
PRODUCT_PROPERTY_OVERRIDES += \
       ro.audio.spatializer_enabled=true

# declare use of stereo spatialization
PRODUCT_PROPERTY_OVERRIDES += \
    ro.audio.stereo_spatialization_enabled=true

ifneq ($(USE_AUDIO_HAL_AIDL),true)
# HIDL Sound Dose
PRODUCT_PACKAGES += \
	android.hardware.audio.sounddose-vendor-impl \
	audio_sounddose_aoc
endif

# HdMic Audio
PRODUCT_SOONG_NAMESPACES += device/google/caimito/audio/caiman/prebuilt/libspeechenhancer
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.audio.hdmic.version=1
PRODUCT_PACKAGES += \
    libspeechenhancer

# Audio CCA property
PRODUCT_PROPERTY_OVERRIDES += \
	persist.vendor.audio.cca.enabled=false

# Bluetooth hci_inject test tool
PRODUCT_PACKAGES_DEBUG += \
    hci_inject

# Bluetooth OPUS codec
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.opus.enabled=true

# Bluetooth SAR test tool
PRODUCT_PACKAGES_DEBUG += \
    sar_test

# Bluetooth EWP test tool
PRODUCT_PACKAGES_DEBUG += \
    ewp_tool

# Bluetooth AAC VBR
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.a2dp_aac.vbr_supported=true

# Bluetooth Super Wide Band
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.hfp.swb.supported=true

# Override BQR mask to enable LE Audio Choppy report, remove BTRT logging
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.bqr.event_mask=295006 \
    persist.bluetooth.bqr.vnd_quality_mask=29 \
    persist.bluetooth.bqr.vnd_trace_mask=0 \
    persist.bluetooth.vendor.btsnoop=true
else
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.bqr.event_mask=295006 \
    persist.bluetooth.bqr.vnd_quality_mask=16 \
    persist.bluetooth.bqr.vnd_trace_mask=0 \
    persist.bluetooth.vendor.btsnoop=false
endif

# default BDADDR for EVB only
PRODUCT_PROPERTY_OVERRIDES += \
	ro.vendor.bluetooth.evb_bdaddr="22:22:22:33:44:55"

# Spatial Audio
PRODUCT_PACKAGES += \
	libspatialaudio \
	librondo

# Keymaster HAL
#LOCAL_KEYMASTER_PRODUCT_PACKAGE ?= android.hardware.keymaster@4.1-service

# Gatekeeper HAL
#LOCAL_GATEKEEPER_PRODUCT_PACKAGE ?= android.hardware.gatekeeper@1.0-service.software


# Gatekeeper
# PRODUCT_PACKAGES += \
# 	android.hardware.gatekeeper@1.0-service.software

# Keymint replaces Keymaster
# PRODUCT_PACKAGES += \
# 	android.hardware.security.keymint-service

# Keymaster
#PRODUCT_PACKAGES += \
#	android.hardware.keymaster@4.0-impl \
#	android.hardware.keymaster@4.0-service

#PRODUCT_PACKAGES += android.hardware.keymaster@4.0-service.remote
#PRODUCT_PACKAGES += android.hardware.keymaster@4.1-service.remote
#LOCAL_KEYMASTER_PRODUCT_PACKAGE := android.hardware.keymaster@4.1-service
#LOCAL_KEYMASTER_PRODUCT_PACKAGE ?= android.hardware.keymaster@4.1-service

# PRODUCT_PROPERTY_OVERRIDES += \
# 	ro.hardware.keystore_desede=true \
# 	ro.hardware.keystore=software \
# 	ro.hardware.gatekeeper=software

# PowerStats HAL
PRODUCT_SOONG_NAMESPACES += \
    device/google/caimito/powerstats/caiman

# WiFi Overlay
PRODUCT_PACKAGES += \
    WifiOverlay2024

# Settings Overlay
PRODUCT_PACKAGES += \
    SettingsCaimanOverlay

# Trusty liboemcrypto.so
PRODUCT_SOONG_NAMESPACES += vendor/google_devices/caimito/prebuilts

# UWB
PRODUCT_SOONG_NAMESPACES += \
    device/google/caimito/caiman/uwb

# Location
# iGNSS
# gps.cfg
PRODUCT_SOONG_NAMESPACES += device/google/caimito/location/caiman
$(call soong_config_set, gpssdk, buildtype, $(TARGET_BUILD_VARIANT))
PRODUCT_PACKAGES += gps.cfg
# eGNSS
# SDK build system
$(call soong_config_set, include_libsitril_gps_wifi, board_without_radio, $(BOARD_WITHOUT_RADIO))
include device/google/gs-common/gps/brcm/device.mk
PRODUCT_SOONG_NAMESPACES += device/google/caimito/location/caiman
SOONG_CONFIG_NAMESPACES += gpssdk
SOONG_CONFIG_gpssdk += gpsconf
SOONG_CONFIG_gpssdk_gpsconf ?= $(TARGET_BUILD_VARIANT)
PRODUCT_PACKAGES += \
	gps.cer \
	gps.xml \
	scd.conf \
	lhd.conf

# Display LBE
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += vendor.display.lbe.supported=1

# Display ACL
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += vendor.display.0.brightness.acl.default=1

#Thermal VT estimator
PRODUCT_PACKAGES += \
    libthermal_tflite_wrapper

PRODUCT_VENDOR_PROPERTIES += \
	persist.device_config.configuration.disable_rescue_party=true

PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.udfps.als_feed_forward_supported=true \
    persist.vendor.udfps.lhbm_controlled_in_hal_supported=true

# OIS with system imu
PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.camera.ois_with_system_imu=true

# Camera Vendor property
PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.camera.front_720P_always_binning=true

# Media Performance Class 14
PRODUCT_PRODUCT_PROPERTIES += ro.odm.build.media_performance_class=34

# Display RRS default Config
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += persist.vendor.display.primary.boot_config=960x2142@120:120
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.vendor.primarydisplay.preferred_mode=960x2142@120:120

ifeq ($(filter factory_caiman, $(TARGET_PRODUCT)),)
    PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.vendor.primarydisplay.xrr.version=2.1
    PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.vendor.primarydisplay.blocking_zone.min_refresh_rate_by_nits=5:120,:1
    PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.vendor.primarydisplay.vrr.expected_present.headsup_ns=30000000
    PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.vendor.primarydisplay.vrr.expected_present.timeout_ns=500000000
endif

# Display OP HZ Config
PRODUCT_VENDOR_PROPERTIES += \
    vendor.primarydisplay.op.hs_hz=120 \
    vendor.primarydisplay.op.ns_hz=60 \
    vendor.primarydisplay.op.ns_min_dbv=440 \
    vendor.primarydisplay.op.hs_switch_min_dbv=1088 \
    vendor.primarydisplay.op.hist_delta_th=8

# Display fixed TE2
PRODUCT_VENDOR_PROPERTIES += vendor.primarydisplay.fixed_te2.default_rate_hz=120

# Vibrator HAL
ACTUATOR_MODEL := luxshare_ict_081545
ADAPTIVE_HAPTICS_FEATURE := adaptive_haptics_v1
PRODUCT_VENDOR_PROPERTIES += \
    ro.vendor.vibrator.hal.chirp.enabled=1 \
    ro.vendor.vibrator.hal.device.mass=0.222 \
    ro.vendor.vibrator.hal.loc.coeff=2.8 \
    persist.vendor.vibrator.hal.context.enable=false \
    persist.vendor.vibrator.hal.context.scale=60 \
    persist.vendor.vibrator.hal.context.fade=true \
    persist.vendor.vibrator.hal.context.cooldowntime=1600 \
    persist.vendor.vibrator.hal.context.settlingtime=5000 \
    ro.vendor.vibrator.hal.pm.activetimeout=5

# PKVM Memory Reclaim
PRODUCT_VENDOR_PROPERTIES += \
    hypervisor.memory_reclaim.supported=1

# Bluetooth LE Audio
# Unicast
PRODUCT_PRODUCT_PROPERTIES += \
	bluetooth.profile.bap.unicast.client.enabled=true \
	bluetooth.profile.csip.set_coordinator.enabled=true \
	bluetooth.profile.hap.client.enabled=true \
	bluetooth.profile.mcp.server.enabled=true \
	bluetooth.profile.ccp.server.enabled=true \
	bluetooth.profile.vcp.controller.enabled=true

# Set support one-handed mode
PRODUCT_PRODUCT_PROPERTIES += \
    ro.support_one_handed_mode=true

ifeq ($(RELEASE_PIXEL_BROADCAST_ENABLED), true)
PRODUCT_PRODUCT_PROPERTIES += \
	bluetooth.profile.bap.broadcast.assist.enabled=true \
	bluetooth.profile.bap.broadcast.source.enabled=true
endif

# LE Audio switcher in developer options
PRODUCT_PRODUCT_PROPERTIES += \
	ro.bluetooth.leaudio_switcher.supported=true \

# Enable hardware offloading
PRODUCT_PRODUCT_PROPERTIES += \
	ro.bluetooth.leaudio_offload.supported=true \
	persist.bluetooth.leaudio_offload.disabled=false

# Bluetooth LE Audio CIS handover to SCO
# Set the property only for the controller couldn't support CIS/SCO simultaneously. More detailed in b/242908683.
PRODUCT_PRODUCT_PROPERTIES += \
	persist.bluetooth.leaudio.notify.idle.during.call=true

# LE Audio Offload Capabilities setting
PRODUCT_COPY_FILES += \
    device/google/caimito/bluetooth/le_audio_codec_capabilities.xml:$(TARGET_COPY_OUT_VENDOR)/etc/le_audio_codec_capabilities.xml

# Disable LE Audio dual mic SWB call support
# This may depend on the BT controller capability or the launch strategy
# For example, P22 BT chip is not able to support 32k dual mic
# P23a disabled the 32k dual mic as it is not in the phase 2 launch plan
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.leaudio.dual_bidirection_swb.supported=true

# LE Audio Unicast Allowlist
PRODUCT_PRODUCT_PROPERTIES += \
   persist.bluetooth.leaudio.allow_list=SM-R510

# Support LE & Classic concurrent encryption (b/330704060)
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.ble.allow_enc_with_bredr=true

# Keyboard height ratio and bottom padding in dp for portrait mode
PRODUCT_PRODUCT_PROPERTIES += \
          ro.com.google.ime.kb_pad_port_b=8 \
          ro.com.google.ime.height_ratio=1.12

# Exynos RIL and telephony
# Support RIL Domain-selection
SUPPORT_RIL_DOMAIN_SELECTION := true

# ETM
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
$(call inherit-product-if-exists, device/google/common/etm/device-userdebug-modules.mk)
endif

# Enable Bluetooth AutoOn feature
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.server.automatic_turn_on=true

# Window Extensions
$(call inherit-product, $(SRC_TARGET_DIR)/product/window_extensions.mk)

# Connectivity Resources Overlay
PRODUCT_PACKAGES += \
    ConnectivityResourcesOverlayCaimitoOverride

#Component Override for Pixel Troubleshooting App
PRODUCT_COPY_FILES += \
    device/google/caimito/caiman/caiman-component-overrides.xml:$(TARGET_COPY_OUT_VENDOR)/etc/sysconfig/caiman-component-overrides.xml

PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.thread_dispatcher.enabled=true

# Thread HAL
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
PRODUCT_PACKAGES += \
   com.google.caimito.hardware.threadnetwork
endif
