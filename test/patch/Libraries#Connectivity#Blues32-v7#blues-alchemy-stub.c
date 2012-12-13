/**
***************************************************************************
* @file blues-alchemy-stub.c
*
* @brief Stib file for blues when building with alchemy.
*
* Copyright (C) 2012 Parrot S.A.
*
* @author Yves-Marie Morgan
* @date 2012/12/12
***************************************************************************
*/


#include "blues-alchemy-config.h"
#include "parrotOS.h"
#include "BLM_USER.h"

/**
 * TODO
 */
BOOL CUSTOM_DID_StoreHFPInfos(BLM_USER_HANDLE userhandle,U16 at_index,const char *buf)
{
	return TRUE;
}

/**
 * TODO
 */
BOOL CUSTOM_DID_StoreSDPInfos(BLM_USER_HANDLE userhandle,U16 attr,U16 value)
{
	return TRUE;
}

