/**
***************************************************************************
* @file blues-alchemy-config.h
*
* @brief Configuration file for blues when building with alchemy.
*
* Copyright (C) 2012 Parrot S.A.
*
* @author Yves-Marie Morgan
* @date 2012/12/12
***************************************************************************
*/

#ifndef __BLUES_ALCHEMY_CONFIG_H__
#define __BLUES_ALCHEMY_CONFIG_H__

//==================================================================================================
/// Common settings
//==================================================================================================

// TODO: This part should be removed from blues requirements

/// Common settings
typedef struct EXTI_COMMON_SETTINGS_STRUCT_TAG
{
	unsigned int Dummy :8;
} __attribute__ ((packed)) EXTI_COMMON_SETTINGS_STRUCT;

/// Default common settings
#define BLUES_DEFAULT_COMMON_SETTINGS { 0 };

//==================================================================================================
// BLUES Block compilation
//==================================================================================================

// TODO: this part is specific to SoftAT build

/// Allow sync task in Blues to have a lower priority
#define EXTI_RECORDER_FILE_LOCATION            "/data/CKSOFT/" "recorder"
#define EXTI_UPDATE_FILE_RAM_LOCATION          "/data/CKSOFT/" "ftp/update"

#ifdef BLUES_SUPPORT_OBEX_FTP_BLOCK

	// FTP mount points
	#define BLP_FTP_ROOT_DIR_TREE			\
	{								   \
		{ "recorder", BLP_FTP_PFFS, EXTI_RECORDER_FILE_LOCATION},  \
		{ "update"  , BLP_FTP_PFFS, EXTI_UPDATE_FILE_RAM_LOCATION} \
	}

#endif // BLUES_SUPPORT_OBEX_FTP_BLOCK

//==================================================================================================
// BLUES DID defines
//==================================================================================================

// TODO: this part should be configurable

#define BLUES_GET_PARROT_DEVICE_ID_RESPONSE_CB(msg,cmd) \
	extern BOOL CUSTOM_DID_StoreHFPInfos(BLM_USER_HANDLE userhandle,U16 at_index,const char *buf); \
	CUSTOM_DID_StoreHFPInfos(BLM_USER_GetMostRecentlyConnected(),(cmd-AT_GMI),msg)

#define BLUES_GET_DEVICE_ID_INFO_CB(attr,value,userHandle) \
	extern BOOL CUSTOM_DID_StoreSDPInfos(BLM_USER_HANDLE userhandle,U16 attr,U16 value); \
	CUSTOM_DID_StoreSDPInfos(BLM_USER_GetMostRecentlyConnected(),(attr - 0x200),value)

#endif // __BLUES_ALCHEMY_CONFIG_H__

