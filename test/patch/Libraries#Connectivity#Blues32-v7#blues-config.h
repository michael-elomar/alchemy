/**
***************************************************************************
* @file config.h
*
* @brief Configuration file for.
*
* Copyright (C) 2006 Parrot S.A.
*
* @author	Yves-Marie Morgan
* @date	November/2006
***************************************************************************
*/

#ifndef __BLUES_CONFIG_H__
#define __BLUES_CONFIG_H__

#define CUSTOM_BT_FRIENDLY_NAME	"New Build"

//==================================================================================================
// Common Definitions.
//==================================================================================================

struct iovec;

// add autoconf file definitions
//#include "autoconf.h"

#ifdef __cplusplus
extern "C" {
#endif
// add parrot os headers
#include "parrotOS_define_c.h"
#include "parrotOS_supervis.h"
#include "parrotOS_log.h"

#ifdef __cplusplus
}
#endif


//==================================================================================================
/// Common settings
//==================================================================================================

#ifndef _CKCM
#undef	DEFINE_SETTINGS
#define DEFINE_SETTINGS(NAME,LEN)	U32 NAME:LEN;
#endif //_CKCM

/// Common settings
typedef struct EXTI_COMMON_SETTINGS_STRUCT_TAG
{
	U32 Dummy :8;
} __attribute__ ((packed)) EXTI_COMMON_SETTINGS_STRUCT;

/// Default common settings
#define BLUES_DEFAULT_COMMON_SETTINGS { 0 };

//==================================================================================================
// Modules.
//==================================================================================================
extern MODULE	EXTI;		///< External Interface Task
extern MODULE	EXTISDP;	///< SDP External Interface Task

//==================================================================================================
// BLUES Specific configuration
//==================================================================================================

/// Default class of device
#define BLM_DID_MSC_DEFAULT (BTH_COD_SERVICECLASS_OBJECTTRANSFER | BTH_COD_SERVICECLASS_AUDIO|BTH_COD_SERVICECLASS_RENDERING)

//==================================================================================================
// BLUES Block compilation
//==================================================================================================


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

#define USE_DID

#ifdef USE_DID


#define BLUES_GET_PARROT_DEVICE_ID_RESPONSE_CB(msg,cmd) \
	extern BOOL CUSTOM_DID_StoreHFPInfos(BLM_USER_HANDLE userhandle,U16 at_index,const char *buf); \
	CUSTOM_DID_StoreHFPInfos(BLM_USER_GetMostRecentlyConnected(),(cmd-AT_GMI),msg)

#define BLUES_GET_DEVICE_ID_INFO_CB(attr,value,userHandle) \
	extern BOOL CUSTOM_DID_StoreSDPInfos(BLM_USER_HANDLE userhandle,U16 attr,U16 value); \
	CUSTOM_DID_StoreSDPInfos(BLM_USER_GetMostRecentlyConnected(),(attr - 0x200),value)


#endif

//==================================================================================================
// BLUES Debug features
//==================================================================================================


//#define SMS_DEBUG			///< to use SMS test tool in CKCM
//#define PAN_DEBUG			///< to use PAN test tool in CKCM

//#define PAN_SPEED_TEST	///< speed test ( compile mode shall be release)

//#define SYNC_PBAP_DEBUG	///< OBEX and PBAP verbose

//==================================================================================================
// CK5050 configuration
//==================================================================================================

#ifdef BLUES_SUPPORT_SAFEUPDATE_BLOCK
#define CK5050_SUPPORT_UPDATE_BLOCK
#endif

/// BT serial PORT

#define CK5050_BLUES_INIT_SPEED BAUDS_115200

//for GCC4 WARNING : char signedness
#define CHAR char // Should not be here

#ifdef CONFIG_CK5050_ENABLE_BLUES_SYNCHRO_DEBUG
#define VPARSER_DUMP_ENABLE 1
#define SYNC_MAIN_DEBUG 1
#define SYNC_METHOD_MANAGER_DEBUG 1
#define SYNC_DEBUG_CONTACT_HANDLER 1
#define SYNC_PBAP_DEBUG 1
#define SYNC_IRMC_DEBUG 1
#define SYNC_SYNCML_DEBUG 1
#define SYNC_NOKIA_DEBUG 1
#define SYNC_AT_DEBUG 1
#define SYNC_APP_SYNC_DEBUG 1
#define SYNC_OBEX_SYNC_DEBUG 1
#define SYNC_SETTINGS_DEBUG 1
#endif

#endif // __CONFIG_H__

