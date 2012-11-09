
LOCAL_PATH := $(call my-dir)

###############################################################################
# Tango
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := tango-core
LOCAL_PBUILD_HOOK := 1

LOCAL_ARM_MODE := arm

LOCAL_CONFIG_FILES := \
	Build/ConfigTangoGeneral.in \
	Build/ConfigTangoDecoder.in \
	Build/ConfigTangoMMP.in \
	Build/ConfigTangoAudioInput.in \
	Build/ConfigTangoVoice.in
$(call load-config)

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Export \
	$(LOCAL_PATH)/Sources/restit

LOCAL_EXPORT_CFLAGS := \
	-DBUILD_TANGO

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/Sources \
	$(LOCAL_PATH)/Sources/tools/xml \
	$(LOCAL_PATH)/Sources/tools/fifo \
	$(LOCAL_PATH)/Sources/tools/list \
	$(LOCAL_PATH)/Sources/tools/debug \
	$(LOCAL_PATH)/Sources/tools/memory \
	$(LOCAL_PATH)/Sources/tools/talaInterface \
	$(LOCAL_PATH)/Sources/tools/thread \
	$(LOCAL_PATH)/Sources/encode \
	$(LOCAL_PATH)/Sources/fft \
	$(LOCAL_PATH)/Sources/fft/armv5 \
	$(LOCAL_PATH)/Sources/fft/armv7 \
	$(LOCAL_PATH)/Sources/fft/armv7/sp/include \
	$(LOCAL_PATH)/Sources/fft/c_float \
	$(LOCAL_PATH)/Sources/fft/c_float/sp/include \
	$(LOCAL_PATH)/Sources/fft/c_fixedpoint \
	$(LOCAL_PATH)/Sources/latm \
	$(LOCAL_PATH)/Sources/pfd \
	$(LOCAL_PATH)/Sources/restit \
	$(LOCAL_PATH)/Sources/sbc

LOCAL_CFLAGS := \
	-DMS -DIS -DTNS  -DPNS -DTEL_GCCLINUX

LOCAL_SRC_FILES := \
	Sources/tango_core.c \
	Sources/tools/list/tools_list.c \
	Sources/tools/fifo/tools_fifo.c \
	Sources/tools/fifo/tools_fifo_generique.c \
	Sources/tools/fifo/tools_fifo_delay.c \
    Sources/tools/debug/tools_RemoteInterfaceVoice.c \
    Sources/tools/debug/tools_RemoteInterfaceMMP.c \
	Sources/tools/memory/tools_mem.c \
	Sources/tools/thread/tools_thread.c \
	Sources/tools/xml/TANGO_config.c \
	Sources/tools/xml/tools_xml_genericXO.cpp \
	Sources/tools/talaInterface/tools_talaInterface.c \
	Sources/encode/encode_ogg_speex_file.c \
	Sources/encode/encode_ogg_speex_bitstream.c \
	Sources/encode/decode_ogg_speex_bitstream.c \
	Sources/encode/encode_speex_file.c \
	Sources/encode/encode_API_encode.c \
	Sources/encode/encode_API_record.c \
	Sources/encode/action_record.c \
	Sources/normalizer/normalizer.c \
    Sources/fft/armv5/FFT_ARMv5_4096.S \
    Sources/fft/armv5/P5_FFT.S \
	Sources/fft/fft_api.c \
	Sources/fft/c_fixedpoint/FFT_FIXEDPOINT.c \
	Sources/fft/c_fixedpoint/fft_api_c_fixedpoint.c \
	Sources/fft/armv5/fft_api_armv5.c \
	Sources/fft/armv5/FFT_ARMv5_4096_const.c \
	Sources/fft/armv5/P5_FFT_const.c \
	Sources/fft/c_float/fft_api_c_float.c \
	Sources/fft/c_float/sp/src/omxSP_FFTFwd_CToC_SC32_Sfs.c \
	Sources/fft/c_float/sp/src/omxSP_FFTFwd_RToCCS_S32_Sfs.c \
	Sources/fft/c_float/sp/src/omxSP_FFTInv_CCSToR_S32_Sfs.c \
	Sources/fft/c_float/sp/src/omxSP_FFTInv_CToC_SC32_Sfs.c \
	Sources/fft/c_float/sp/src/omxSP_FFTGetBufSize_C_SC32.c \
	Sources/fft/c_float/sp/src/omxSP_FFTGetBufSize_R_S32.c \
	Sources/fft/c_float/sp/src/omxSP_FFTInit_C_SC32.c \
	Sources/fft/c_float/sp/src/omxSP_FFTInit_R_S32.c \
	Sources/fft/c_float/sp/include/armfloatCOMM.c \
	Sources/restit/action_restit.c \
	Sources/restit/restit_dtmf.c \
	Sources/restit/restit_file.c \
	Sources/restit/restit_file_ogv.c \
	Sources/restit/restit_file_speex.c \
	Sources/restit/restit_generique.c \
	Sources/restit/restit_API_dtmf.c \
	Sources/restit/restit_API_file.c \
	Sources/restit/restit_API_ring.c \
	Sources/sbc/TANGO_SBC.c \
	Sources/latm/bitstream.c \
	Sources/latm/latmstream.c \
	Sources/latm/latm.c

# TODO: check other cpu as well or better a cpu feature in build system
ifeq ("$(TARGET_CPU)","omap3")
ifdef CONFIG_TANGO_ENABLE_NEON_OPTIMIZATION

LOCAL_CFLAGS += -DTANGO_ENABLE_NEON

LOCAL_SRC_FILES += \
	Sources/fft/armv7/fft_api_armv7.c \
	Sources/fft/armv7/sp/src/omxSP_FFTInit_C_SC32.c \
	Sources/fft/armv7/sp/src/omxSP_FFTInit_R_S32.c \
	Sources/fft/armv7/sp/src/armSP_FFT_S32TwiddleTable.c \
	Sources/fft/armv7/sp/src/omxSP_FFTGetBufSize_C_SC32.c \
	Sources/fft/armv7/sp/src/omxSP_FFTGetBufSize_R_S32.c \
	Sources/fft/armv7/sp/src/armSP_FFT_CToC_SC32_Radix2_fs_unsafe_s.S \
	Sources/fft/armv7/sp/src/armSP_FFT_CToC_SC32_Radix2_ls_unsafe_s.S \
	Sources/fft/armv7/sp/src/armSP_FFT_CToC_SC32_Radix2_unsafe_s.S \
	Sources/fft/armv7/sp/src/armSP_FFT_CToC_SC32_Radix4_fs_unsafe_s.S \
	Sources/fft/armv7/sp/src/armSP_FFT_CToC_SC32_Radix4_ls_unsafe_s.S \
	Sources/fft/armv7/sp/src/armSP_FFT_CToC_SC32_Radix4_unsafe_s.S \
	Sources/fft/armv7/sp/src/armSP_FFT_CToC_SC32_Radix8_fs_unsafe_s.S \
	Sources/fft/armv7/sp/src/armSP_FFTInv_CCSToR_S32_preTwiddleRadix2_unsafe_s.S \
	Sources/fft/armv7/sp/src/omxSP_FFTFwd_RToCCS_S32_Sfs_s.S \
	Sources/fft/armv7/sp/src/omxSP_FFTFwd_CToC_SC32_Sfs_s.S \
	Sources/fft/armv7/sp/src/omxSP_FFTInv_CCSToR_S32_Sfs_s.S

endif
endif

ifdef CONFIG_TANGO_USE_STREAMING

LOCAL_C_INCLUDES += \
	$(LOCAL_PATH)/Sources/mmp

LOCAL_SRC_FILES += \
	Sources/mmp/MMP_AudioInput.c \
	Sources/mmp/MMP_BufferList.c \
	Sources/mmp/MMP_Car_Spat.c \
	Sources/mmp/MMP_Car_SpatData.c \
	Sources/mmp/MMP_CSv2.c \
	Sources/mmp/MMP_DBE.c \
	Sources/mmp/MMP_DBEConst.c \
	Sources/mmp/MMP_Decoder.c \
	Sources/mmp/MMP_Decoder_utils.c \
	Sources/mmp/MMP_Decoder_pcm.c \
	Sources/mmp/MMP_DSPToolbox.c \
	Sources/mmp/MMP_Encoder.c \
	Sources/mmp/MMP_Equalizer.c \
	Sources/mmp/MMP_FilterToolbox.c \
	Sources/mmp/MMP_FilterToolbox_Extended.c \
	Sources/mmp/MMP_GenericXO.c \
	Sources/mmp/MMP_CSv2_const.c \
	Sources/mmp/MMP_CSv2_const_clio.c \
	Sources/mmp/MMP_CSv2_const_bmw.c \
	Sources/mmp/MMP_Headspat.c \
	Sources/mmp/MMP_Headspat_const.c \
	Sources/mmp/MMP_Hole.c \
	Sources/mmp/MMP_PLC.c \
	Sources/mmp/MMP_Limiter.c \
	Sources/mmp/MMP_MBC.c \
	Sources/mmp/MMP_MonoReduction.c \
	Sources/mmp/MMP_Playback.c \
	Sources/mmp/MMP_Resampling.c \
	Sources/mmp/MMP_SAD.c \
	Sources/mmp/MMP_Sequencer.c \
	Sources/mmp/MMP_Soundflex.c \
	Sources/mmp/MMP_Soundflex_const.c \
	Sources/mmp/MMP_Spatialization.c \
	Sources/mmp/MMP_Spatialization_const.c \
	Sources/mmp/MMP_Streaming.c \
	Sources/mmp/MMP_UpDownMix.c \
	Sources/mmp/MMP_Utils.c \
	Sources/mmp/MMP_VB2.c \
	Sources/mmp/MMP_VirtualBass.c \
	Sources/mmp/MMP_VirtualBassData.c \
	Sources/mmp/MMP_WideStereo.c \
	Sources/mmp/MMP_MonoStereoDetection.c \
	Sources/mmp/MMP_DBESpeaker.cpp \
	Sources/mmp/MMP_LPKE.cpp \
	Sources/mmp/MMP_Spatialization_arm32.S \
	Sources/mmp/MMP_VirtualBass_arm32.S \
	Sources/mmp/MMP_Toolbox_arm32.S \
	Sources/mmp/MMP_DSPASMToolbox.S \
	Sources/mmp/MMP_FilterToolbox_ASM.S \
	Sources/mmp/MMP_FilterToolbox_Extended_ASM.S \
	Sources/mmp/MMP_Headspat_arm32.S \
	Sources/mmp/MMP_Headspat_ER_arm32.S \
	Sources/mmp/MMP_VB2_ASM.S \
	Sources/pfd/pfd_api.c \
	Sources/pfd/pfd_codec_heaac.c \
	Sources/pfd/pfd_codec_flac.c \
	Sources/pfd/pfd_codec_mp3.c \
	Sources/pfd/pfd_codec_ogv.c \
	Sources/pfd/pfd_codec_wav.c \
	Sources/pfd/pfd_codec_wma.c \
	Sources/pfd/pfd_convert.c \
	Sources/pfd/pfd_filehandler.c \
	Sources/pfd/pfd_reader.c \
	Sources/pfd/pfd_var.c

endif

# TODO : only when either CONFIG_TANGO_DSP_ENABLE or CONFIG_TANGO_VOICE_ENABLE

LOCAL_C_INCLUDES += \
	$(LOCAL_PATH)/Sources/dsp/API

LOCAL_SRC_FILES += \
	Sources/tools/xml/tools_xmlParseOption.cpp \
	Sources/tools/xml/tools_xml.cpp \
	Sources/tools/logTools.c \
	Sources/tools/logTools_spc.S \
	Sources/dsp/API/DSP_API_redirect.c \
	Sources/dsp/API/DSP_API_redirect2.c

ifdef CONFIG_TANGO_DSP_ENABLE

LOCAL_C_INCLUDES += \
	$(LOCAL_PATH)/Sources/dsp \
	$(LOCAL_PATH)/Sources/dsp/tools \
	$(LOCAL_PATH)/Sources/dsp/tools/parameters \
	$(LOCAL_PATH)/Sources/dsp/absproba \
	$(LOCAL_PATH)/Sources/dsp/aec \
	$(LOCAL_PATH)/Sources/dsp/alc \
	$(LOCAL_PATH)/Sources/dsp/ams \
	$(LOCAL_PATH)/Sources/dsp/apa \
	$(LOCAL_PATH)/Sources/dsp/apa15 \
	$(LOCAL_PATH)/Sources/dsp/apa20 \
	$(LOCAL_PATH)/Sources/dsp/avc \
	$(LOCAL_PATH)/Sources/dsp/common \
	$(LOCAL_PATH)/Sources/dsp/compressor \
	$(LOCAL_PATH)/Sources/dsp/compr2 \
	$(LOCAL_PATH)/Sources/dsp/softlim \
	$(LOCAL_PATH)/Sources/dsp/gsmb \
	$(LOCAL_PATH)/Sources/dsp/hpf \
	$(LOCAL_PATH)/Sources/dsp/lms \
	$(LOCAL_PATH)/Sources/dsp/lpf \
	$(LOCAL_PATH)/Sources/dsp/misc \
	$(LOCAL_PATH)/Sources/dsp/nr \
	$(LOCAL_PATH)/Sources/dsp/omlsa \
	$(LOCAL_PATH)/Sources/dsp/parameq \
	$(LOCAL_PATH)/Sources/dsp/rx \
	$(LOCAL_PATH)/Sources/dsp/FreqGainStart \
	$(LOCAL_PATH)/Sources/dsp/FreqAlcBark \
	$(LOCAL_PATH)/Sources/dsp/FreqCutFrequency \
	$(LOCAL_PATH)/Sources/dsp/spatial_filtering \
	$(LOCAL_PATH)/Sources/dsp/TimeCombiAdapt \
	$(LOCAL_PATH)/Sources/dsp/TimeMixage \
	$(LOCAL_PATH)/Sources/dsp/TimeGain \
	$(LOCAL_PATH)/Sources/dsp/TimeIIR \
	$(LOCAL_PATH)/Sources/dsp/traces \
	$(LOCAL_PATH)/Sources/dsp/wnr

LOCAL_SRC_FILES += \
	Sources/dsp/tools/parameters/DSP_tools_parameters.c \
	Sources/dsp/absproba/DSP_AbsProba.c \
	Sources/dsp/absproba/DSP_AbsProba_const.c \
	Sources/dsp/absproba/DSP_Double_MCRA.c \
	Sources/dsp/aec/DSP_Aec.c \
	Sources/dsp/aec/DSP_Aec_Const.c \
	Sources/dsp/aec/DSP_Aec_Variance.c \
	Sources/dsp/aec/DSP_Aec_Whitening.c \
	Sources/dsp/alc/DSP_ALC.c \
	Sources/dsp/ams/DSP_AMS.c \
	Sources/dsp/apa/DSP_APA.c \
	Sources/dsp/apa/DSP_APA_const.c \
	Sources/dsp/apa/DSP_APA_dcd.c \
	Sources/dsp/apa15/DSP_APA15.c \
	Sources/dsp/apa15/DSP_APA15_spc_c.c \
	Sources/dsp/apa20/DSP_APA20.c \
	Sources/dsp/apa20/DSP_APA20_spc_c.c \
	Sources/dsp/apa20/DSP_APA20_computeBkgd.c \
	Sources/dsp/apa20/DSP_APA20_computeSBE.c \
	Sources/dsp/apa20/DSP_APA20_ResBoost.c \
	Sources/dsp/avc/DSP_AVC.c \
	Sources/dsp/avc/DSP_AVC_Common.c \
	Sources/dsp/common/DSP_Common.c \
	Sources/dsp/common/DSP_Common_const.c \
	Sources/dsp/common/DSP_Main.c \
	Sources/dsp/common/DSP_Signals.c \
	Sources/dsp/common/DSP_mixSignal.c \
	Sources/dsp/gsmb/DSP_GSMB.c \
	Sources/dsp/gsmb/DSP_GSMB_const.c \
	Sources/dsp/gsmb/DSP_GSMB_LMS.c \
	Sources/dsp/hpf/DSP_HPF.c \
	Sources/dsp/FreqCutFrequency/DSP_FreqCutFrequency.c \
	Sources/dsp/compressor/DSP_Compressor.c \
	Sources/dsp/compr2/DSP_Compr2.c \
	Sources/dsp/softlim/DSP_SoftLim.c \
	Sources/dsp/lms/DSP_LMS.c \
	Sources/dsp/lms/DSP_LMS_LmsCalc.c \
	Sources/dsp/lpf/DSP_LPF.c \
	Sources/dsp/misc/DSP_Biquad.c \
	Sources/dsp/nr/DSP_NONr.c \
	Sources/dsp/nr/DSP_NRAccelero.c \
	Sources/dsp/nr/DSP_NRCobe.c \
	Sources/dsp/nr/DSP_NRCobe_Plus.c \
	Sources/dsp/nr/DSP_NRStereo16_Plus.c \
	Sources/dsp/nr/DSP_NRStereo20.c \
	Sources/dsp/nr/DSP_RXAlc.c \
	Sources/dsp/omlsa/DSP_ComfortNoise.c \
	Sources/dsp/omlsa/DSP_OMLSA.c \
	Sources/dsp/omlsa/DSP_OMLSA_const.c \
	Sources/dsp/parameq/DSP_Parameq.c \
	Sources/dsp/rx/DSP_RX.c \
	Sources/dsp/FreqGainStart/DSP_FreqGainStart.c \
	Sources/dsp/FreqAlcBark/DSP_FreqAlcBark.c \
	Sources/dsp/spatial_filtering/DSP_SpatialFiltering.c \
	Sources/dsp/spatial_filtering/DSP_SpatialFiltering_const.c \
	Sources/dsp/TimeCombiAdapt/DSP_TimeCombiAdapt.c \
	Sources/dsp/TimeGain/DSP_TimeGain.c \
	Sources/dsp/TimeIIR/DSP_TimeIIR.c \
	Sources/dsp/TimeMixage/DSP_TimeMixage.c \
	Sources/dsp/traces/DSP_Traces.c \
	Sources/dsp/wnr/DSP_WNR.c \
	Sources/dsp/wnr/DSP_WNR_const.c \
	Sources/dsp/wnr/DSP_WNR_Mat.c \
	Sources/dsp/wnr/DSP_WNR_NNMF.c \
	Sources/dsp/API/DSP_API_avc.c \
	Sources/dsp/API/DSP_API_communication.c \
	Sources/dsp/API/action_avc.c \
	Sources/dsp/API/action_communication.c \
	Sources/dsp/API/action_communicationDouble.c \
	Sources/dsp/aec/DSP_AEC_arm32.S \
	Sources/dsp/apa/DSP_APA_arm32.S \
	Sources/dsp/apa15/DSP_APA15_spc_3_arm_v5.S \
	Sources/dsp/apa15/DSP_APA15_spc_4_arm_v5.S \
	Sources/dsp/apa20/DSP_APA20_spc.S \
	Sources/dsp/common/DSP_Common_arm32.S \
	Sources/dsp/lms/DSP_LMS_LmsCalc_arm32.S \

endif

LOCAL_LIBRARIES := \
	tinyxml tala unirecorder ckcm \
	tango-speex \
	tango-wav \
	tango-tremor \
	pal-codec \
	pal-utils \
	pal-core

ifdef CONFIG_TANGO_USE_FLAC_DECODER
LOCAL_SRC_FILES += \
	Sources/mmp/MMP_Decoder_flac.c
LOCAL_LIBRARIES += \
	tango-flac
endif

ifdef CONFIG_TANGO_USE_MP3_DECODER
LOCAL_SRC_FILES += \
	Sources/mmp/MMP_Decoder_mp3.c
LOCAL_LIBRARIES += \
	tango-mp3
endif

ifdef CONFIG_TANGO_USE_OGG_DECODER
LOCAL_SRC_FILES += \
	Sources/mmp/MMP_Decoder_ogv.c
LOCAL_LIBRARIES += \
	tango-ogg
endif

ifdef CONFIG_TANGO_USE_WMA_DECODER
LOCAL_SRC_FILES += \
	Sources/mmp/MMP_Decoder_wma.c
LOCAL_LIBRARIES += \
	tango-wma
endif

ifdef CONFIG_TANGO_USE_AAC_DECODER
LOCAL_SRC_FILES += \
	Sources/mmp/MMP_Decoder_heaac.c
LOCAL_LIBRARIES += \
	tango-aac-parser \
	tango-aac-wrapper \
	tango-opencore
endif

include $(BUILD_SHARED_LIBRARY)

###############################################################################
# Ogg
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := tango-ogg

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Sources/ogg/include

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES :=

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	Sources/ogg/src/bitwise.c \
	Sources/ogg/src/framing.c
           
LOCAL_LIBRARIES := pal-core

include $(BUILD_SHARED_LIBRARY)

###############################################################################
# Speex
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := tango-speex

LOCAL_ARM_MODE := arm

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Sources/speex/include

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES :=

LOCAL_CFLAGS := \
	-DHAVE_CONFIG_H \
	-DFIXED_POINT

LOCAL_SRC_FILES := \
	Sources/speex/src/libspeex/bits.c \
	Sources/speex/src/libspeex/cb_search.c \
	Sources/speex/src/libspeex/exc_10_16_table.c \
	Sources/speex/src/libspeex/exc_10_32_table.c \
	Sources/speex/src/libspeex/exc_20_32_table.c \
	Sources/speex/src/libspeex/exc_5_256_table.c \
	Sources/speex/src/libspeex/exc_5_64_table.c \
	Sources/speex/src/libspeex/exc_8_128_table.c \
	Sources/speex/src/libspeex/fftwrap.c \
	Sources/speex/src/libspeex/filters.c \
	Sources/speex/src/libspeex/gain_table.c \
	Sources/speex/src/libspeex/gain_table_lbr.c \
	Sources/speex/src/libspeex/hexc_10_32_table.c \
	Sources/speex/src/libspeex/hexc_table.c \
	Sources/speex/src/libspeex/high_lsp_tables.c \
	Sources/speex/src/libspeex/jitter.c \
	Sources/speex/src/libspeex/kiss_fft.c \
	Sources/speex/src/libspeex/kiss_fftr.c \
	Sources/speex/src/libspeex/lbr_48k_tables.c \
	Sources/speex/src/libspeex/lpc.c \
	Sources/speex/src/libspeex/lsp.c \
	Sources/speex/src/libspeex/lsp_tables_nb.c \
	Sources/speex/src/libspeex/ltp.c \
	Sources/speex/src/libspeex/math_approx.c \
	Sources/speex/src/libspeex/mdf.c \
	Sources/speex/src/libspeex/misc.c \
	Sources/speex/src/libspeex/modes.c \
	Sources/speex/src/libspeex/nb_celp.c \
	Sources/speex/src/libspeex/preprocess.c \
	Sources/speex/src/libspeex/quant_lsp.c \
	Sources/speex/src/libspeex/sb_celp.c \
	Sources/speex/src/libspeex/smallft.c \
	Sources/speex/src/libspeex/speex.c \
	Sources/speex/src/libspeex/speex_callbacks.c \
	Sources/speex/src/libspeex/speex_header.c \
	Sources/speex/src/libspeex/stereo.c \
	Sources/speex/src/libspeex/vbr.c \
	Sources/speex/src/libspeex/vorbis_psy.c \
	Sources/speex/src/libspeex/vq.c \
	Sources/speex/src/libspeex/window.c
           
LOCAL_LIBRARIES := pal-core

include $(BUILD_SHARED_LIBRARY)

###############################################################################
# Mp3
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := tango-mp3

LOCAL_ARM_MODE := arm

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Sources/mp3/CDK_tools \
	$(LOCAL_PATH)/Sources/mp3/INT_mp3dec

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES :=

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	Sources/mp3/INT_mp3dec/crc16.cpp \
	Sources/mp3/INT_mp3dec/huffdec.cpp \
	Sources/mp3/INT_mp3dec/huffmanbitobj.cpp \
	Sources/mp3/INT_mp3dec/huffmandecoder.cpp \
	Sources/mp3/INT_mp3dec/huffmantable.cpp \
	Sources/mp3/INT_mp3dec/l3table.cpp \
	Sources/mp3/INT_mp3dec/mdct.cpp \
	Sources/mp3/INT_mp3dec/mp3decifc.cpp \
	Sources/mp3/INT_mp3dec/mp3decode.cpp \
	Sources/mp3/INT_mp3dec/mp3quant.cpp \
	Sources/mp3/INT_mp3dec/mp3read.cpp \
	Sources/mp3/INT_mp3dec/mp3ssc.cpp \
	Sources/mp3/INT_mp3dec/mp3tools.cpp \
	Sources/mp3/INT_mp3dec/mpegbitstream.cpp \
	Sources/mp3/INT_mp3dec/mpegheader.cpp \
	Sources/mp3/INT_mp3dec/mpgadecoder.cpp \
	Sources/mp3/INT_mp3dec/polyphase.cpp \
	Sources/mp3/CDK_tools/CDK_bitbuffer.cpp \
	Sources/mp3/CDK_tools/genericStds.cpp

ifeq ("$(TARGET_ARCH)","arm")
LOCAL_SRC_FILES += \
	Sources/mp3/INT_mp3dec/armtools.s
endif

LOCAL_LIBRARIES := pal-core

include $(BUILD_SHARED_LIBRARY)

###############################################################################
# Wav
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := tango-wav
LOCAL_PBUILD_HOOK := 1

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Sources/wav

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES :=

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	Sources/wav/wav_api.c
   
LOCAL_LIBRARIES := pal-core

include $(BUILD_SHARED_LIBRARY)

###############################################################################
# Tremor
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := tango-tremor

LOCAL_ARM_MODE := arm

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Sources/tremor

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES :=

# svox has the same symbol and we don't have its source code, do a hack here...
LOCAL_CFLAGS := \
	-Dmdct_backward=tremor_mdct_backward

LOCAL_SRC_FILES := \
	Sources/tremor/block.c \
	Sources/tremor/codebook.c \
	Sources/tremor/floor0.c \
	Sources/tremor/floor1.c \
	Sources/tremor/info.c \
	Sources/tremor/mapping0.c \
	Sources/tremor/mdct.c \
	Sources/tremor/registry.c \
	Sources/tremor/res012.c \
	Sources/tremor/sharedbook.c \
	Sources/tremor/synthesis.c \
	Sources/tremor/vorbisfile.c \
	Sources/tremor/window.c

LOCAL_LIBRARIES := tango-ogg pal-core

include $(BUILD_SHARED_LIBRARY)

###############################################################################
# Aac parser
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := tango-aac-parser

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Sources/aac/include

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/Sources/aac/parser/include

LOCAL_CFLAGS := \
	-DGCC_LINUX -DTEL_GCCLINUX -DMS -DIS -DTNS -DPNS -O2

ifdef CONFIG_AAC_EHE
LOCAL_CFLAGS +=	-DTEL_HEAACDEC -DTEL_EHEAACDEC
endif

LOCAL_SRC_FILES := \
	Sources/aac/parser/src/MP4_API.c \
	Sources/aac/parser/src/telaacparser.c \
	Sources/aac/parser/src/Telbitstream.c \
	Sources/aac/parser/src/Telmdia_box.c \
	Sources/aac/parser/src/Telmoov_box.c \
	Sources/aac/parser/src/Telmp4parser.c \
	Sources/aac/parser/src/Telstaticmalloc.c \
	Sources/aac/parser/src/Teludta_box.c
           
LOCAL_LIBRARIES := pal-core

include $(BUILD_SHARED_LIBRARY)

###############################################################################
# Aac wrapper
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := tango-aac-wrapper

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Sources/aac/include

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/Sources/aac/wrapper/include

LOCAL_CFLAGS := \
	-DGCC_LINUX -DTEL_GCCLINUX -DMS -DIS -DTNS -DPNS -O2

ifdef CONFIG_AAC_EHE
LOCAL_CFLAGS +=	-DTEL_HEAACDEC -DTEL_EHEAACDEC
endif

LOCAL_SRC_FILES := \
	Sources/aac/wrapper/src/TELPlayerwrapper.c \
	Sources/aac/wrapper/src/TELMp4ExtractFrame.c \
	Sources/aac/wrapper/src/TELExtractADTSFrame.c
           
LOCAL_LIBRARIES := pal-core

include $(BUILD_SHARED_LIBRARY)

###############################################################################
# Wma
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := tango-wma

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Sources/wma

LOCAL_EXPORT_CFLAGS :=

LOCAL_LDLIBS := \
	-Wl,--whole-archive \
	-L$(LOCAL_PATH)/Sources/wma -lDecoderWMA-eabi \
	-Wl,--no-whole-archive

LOCAL_C_INCLUDES :=

LOCAL_CFLAGS :=

LOCAL_SRC_FILES :=

LOCAL_LIBRARIES := pal-core

include $(BUILD_SHARED_LIBRARY)

###############################################################################
# Opencore
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := tango-opencore

LOCAL_ARM_MODE := arm

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Sources/opencore/include

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES :=

LOCAL_CFLAGS := \
	-DAAC_PLUS -DHQ_SBR -DPARAMETRIC_STEREO -DPV_ARM_GCC_V5 -O2

LOCAL_SRC_FILES := \
	Sources/opencore/src/opencore_bridge.cpp \
	Sources/opencore/src/analysis_sub_band.cpp \
	Sources/opencore/src/apply_ms_synt.cpp \
	Sources/opencore/src/apply_tns.cpp \
	Sources/opencore/src/buf_getbits.cpp \
	Sources/opencore/src/byte_align.cpp \
	Sources/opencore/src/calc_auto_corr.cpp \
	Sources/opencore/src/calc_gsfb_table.cpp \
	Sources/opencore/src/calc_sbr_anafilterbank.cpp \
	Sources/opencore/src/calc_sbr_envelope.cpp \
	Sources/opencore/src/calc_sbr_synfilterbank.cpp \
	Sources/opencore/src/check_crc.cpp \
	Sources/opencore/src/dct16.cpp \
	Sources/opencore/src/dct64.cpp \
	Sources/opencore/src/decode_huff_cw_binary.cpp \
	Sources/opencore/src/decode_noise_floorlevels.cpp \
	Sources/opencore/src/deinterleave.cpp \
	Sources/opencore/src/digit_reversal_tables.cpp \
	Sources/opencore/src/dst16.cpp \
	Sources/opencore/src/dst32.cpp \
	Sources/opencore/src/dst8.cpp \
	Sources/opencore/src/esc_iquant_scaling.cpp \
	Sources/opencore/src/extractframeinfo.cpp \
	Sources/opencore/src/fft_rx4_long.cpp \
	Sources/opencore/src/fft_rx4_short.cpp \
	Sources/opencore/src/fft_rx4_tables_fxp.cpp \
	Sources/opencore/src/find_adts_syncword.cpp \
	Sources/opencore/src/fwd_long_complex_rot.cpp \
	Sources/opencore/src/fwd_short_complex_rot.cpp \
	Sources/opencore/src/gen_rand_vector.cpp \
	Sources/opencore/src/get_adif_header.cpp \
	Sources/opencore/src/get_adts_header.cpp \
	Sources/opencore/src/get_audio_specific_config.cpp \
	Sources/opencore/src/get_dse.cpp \
	Sources/opencore/src/get_ele_list.cpp \
	Sources/opencore/src/get_ga_specific_config.cpp \
	Sources/opencore/src/get_ics_info.cpp \
	Sources/opencore/src/get_prog_config.cpp \
	Sources/opencore/src/get_pulse_data.cpp \
	Sources/opencore/src/get_sbr_bitstream.cpp \
	Sources/opencore/src/get_sbr_startfreq.cpp \
	Sources/opencore/src/get_sbr_stopfreq.cpp \
	Sources/opencore/src/get_tns.cpp \
	Sources/opencore/src/getfill.cpp \
	Sources/opencore/src/getgroup.cpp \
	Sources/opencore/src/getics.cpp \
	Sources/opencore/src/getmask.cpp \
	Sources/opencore/src/hcbtables_binary.cpp \
	Sources/opencore/src/huffcb.cpp \
	Sources/opencore/src/huffdecode.cpp \
	Sources/opencore/src/hufffac.cpp \
	Sources/opencore/src/huffspec_fxp.cpp \
	Sources/opencore/src/idct16.cpp \
	Sources/opencore/src/idct32.cpp \
	Sources/opencore/src/idct8.cpp \
	Sources/opencore/src/imdct_fxp.cpp \
	Sources/opencore/src/infoinit.cpp \
	Sources/opencore/src/init_sbr_dec.cpp \
	Sources/opencore/src/intensity_right.cpp \
	Sources/opencore/src/inv_long_complex_rot.cpp \
	Sources/opencore/src/inv_short_complex_rot.cpp \
	Sources/opencore/src/iquant_table.cpp \
	Sources/opencore/src/long_term_prediction.cpp \
	Sources/opencore/src/long_term_synthesis.cpp \
	Sources/opencore/src/lt_decode.cpp \
	Sources/opencore/src/mdct_fxp.cpp \
	Sources/opencore/src/mdct_tables_fxp.cpp \
	Sources/opencore/src/mdst.cpp \
	Sources/opencore/src/mix_radix_fft.cpp \
	Sources/opencore/src/ms_synt.cpp \
	Sources/opencore/src/pns_corr.cpp \
	Sources/opencore/src/pns_intensity_right.cpp \
	Sources/opencore/src/pns_left.cpp \
	Sources/opencore/src/ps_all_pass_filter_coeff.cpp \
	Sources/opencore/src/ps_all_pass_fract_delay_filter.cpp \
	Sources/opencore/src/ps_allocate_decoder.cpp \
	Sources/opencore/src/ps_applied.cpp \
	Sources/opencore/src/ps_bstr_decoding.cpp \
	Sources/opencore/src/ps_channel_filtering.cpp \
	Sources/opencore/src/ps_decode_bs_utils.cpp \
	Sources/opencore/src/ps_decorrelate.cpp \
	Sources/opencore/src/ps_fft_rx8.cpp \
	Sources/opencore/src/ps_hybrid_analysis.cpp \
	Sources/opencore/src/ps_hybrid_filter_bank_allocation.cpp \
	Sources/opencore/src/ps_hybrid_synthesis.cpp \
	Sources/opencore/src/ps_init_stereo_mixing.cpp \
	Sources/opencore/src/ps_pwr_transient_detection.cpp \
	Sources/opencore/src/ps_read_data.cpp \
	Sources/opencore/src/ps_stereo_processing.cpp \
	Sources/opencore/src/pulse_nc.cpp \
	Sources/opencore/src/pv_div.cpp \
	Sources/opencore/src/pv_log2.cpp \
	Sources/opencore/src/pv_normalize.cpp \
	Sources/opencore/src/pv_pow2.cpp \
	Sources/opencore/src/pv_sine.cpp \
	Sources/opencore/src/pv_sqrt.cpp \
	Sources/opencore/src/pvmp4audiodecoderconfig.cpp \
	Sources/opencore/src/pvmp4audiodecoderframe.cpp \
	Sources/opencore/src/pvmp4audiodecodergetmemrequirements.cpp \
	Sources/opencore/src/pvmp4audiodecoderinitlibrary.cpp \
	Sources/opencore/src/pvmp4audiodecoderresetbuffer.cpp \
	Sources/opencore/src/q_normalize.cpp \
	Sources/opencore/src/qmf_filterbank_coeff.cpp \
	Sources/opencore/src/sbr_aliasing_reduction.cpp \
	Sources/opencore/src/sbr_applied.cpp \
	Sources/opencore/src/sbr_code_book_envlevel.cpp \
	Sources/opencore/src/sbr_crc_check.cpp \
	Sources/opencore/src/sbr_create_limiter_bands.cpp \
	Sources/opencore/src/sbr_dec.cpp \
	Sources/opencore/src/sbr_decode_envelope.cpp \
	Sources/opencore/src/sbr_decode_huff_cw.cpp \
	Sources/opencore/src/sbr_downsample_lo_res.cpp \
	Sources/opencore/src/sbr_envelope_calc_tbl.cpp \
	Sources/opencore/src/sbr_envelope_unmapping.cpp \
	Sources/opencore/src/sbr_extract_extended_data.cpp \
	Sources/opencore/src/sbr_find_start_andstop_band.cpp \
	Sources/opencore/src/sbr_generate_high_freq.cpp \
	Sources/opencore/src/sbr_get_additional_data.cpp \
	Sources/opencore/src/sbr_get_cpe.cpp \
	Sources/opencore/src/sbr_get_dir_control_data.cpp \
	Sources/opencore/src/sbr_get_envelope.cpp \
	Sources/opencore/src/sbr_get_header_data.cpp \
	Sources/opencore/src/sbr_get_noise_floor_data.cpp \
	Sources/opencore/src/sbr_get_sce.cpp \
	Sources/opencore/src/sbr_inv_filt_levelemphasis.cpp \
	Sources/opencore/src/sbr_open.cpp \
	Sources/opencore/src/sbr_read_data.cpp \
	Sources/opencore/src/sbr_requantize_envelope_data.cpp \
	Sources/opencore/src/sbr_reset_dec.cpp \
	Sources/opencore/src/sbr_update_freq_scale.cpp \
	Sources/opencore/src/set_mc_info.cpp \
	Sources/opencore/src/sfb.cpp \
	Sources/opencore/src/shellsort.cpp \
	Sources/opencore/src/synthesis_sub_band.cpp \
	Sources/opencore/src/tns_ar_filter.cpp \
	Sources/opencore/src/tns_decode_coef.cpp \
	Sources/opencore/src/tns_inv_filter.cpp \
	Sources/opencore/src/trans4m_freq_2_time_fxp.cpp \
	Sources/opencore/src/trans4m_time_2_freq_fxp.cpp \
	Sources/opencore/src/unpack_idx.cpp \
	Sources/opencore/src/window_tables_fxp.cpp \
	Sources/opencore/src/pvmp4setaudioconfig.cpp

LOCAL_LIBRARIES := pal-core

include $(BUILD_SHARED_LIBRARY)

###############################################################################
# Flac
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := tango-flac

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Sources/flac/include

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/Sources/flac/src/libFLAC

LOCAL_CFLAGS := \
	-DHAVE_CONFIG_H -DFLAC__HAS_OGG=0 -DWORDS_BIGENDIAN=0

LOCAL_SRC_FILES := \
	Sources/flac/src/libFLAC/bitmath.c \
	Sources/flac/src/libFLAC/bitreader.c \
	Sources/flac/src/libFLAC/bitwriter.c \
	Sources/flac/src/libFLAC/cpu.c \
	Sources/flac/src/libFLAC/crc.c \
	Sources/flac/src/libFLAC/fixed.c \
	Sources/flac/src/libFLAC/float.c \
	Sources/flac/src/libFLAC/format.c \
	Sources/flac/src/libFLAC/lpc.c \
	Sources/flac/src/libFLAC/md5.c \
	Sources/flac/src/libFLAC/memory.c \
	Sources/flac/src/libFLAC/stream_decoder.c \
	Sources/flac/src/libFLAC/window.c

LOCAL_LIBRARIES := pal-core

include $(BUILD_SHARED_LIBRARY)

