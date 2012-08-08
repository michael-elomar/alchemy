/**
 */

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
//#include "parrotOS_assert.h"
//#include "parrotOS_log.h"

//#ifdef PAL_LOG_DYN_LEVEL

struct pal_log_dyn_data {
	int* level;
	const char *ident;
	struct pal_log_dyn_data *next;
};

static struct pal_log_dyn_data *pal_log_dyn_head = NULL;

/**
 * Register a dynamic level.
 * @param data : level data. No copy is done, so it shal resides in memory
 * until the end of the program. It is also modified when added in the linked
 * list.
 * @remarks : it is not thread safe so it shall only be called during init
 */
void pal_log_dyn_add(struct pal_log_dyn_data *data)
{
	data->next = pal_log_dyn_head;
	pal_log_dyn_head = data;
}

/**
 */
int pal_log_dyn_set_level(const char *ident, int level)
{
	int ret = -1;
	struct pal_log_dyn_data *data = pal_log_dyn_head;

	/* the level can be found several times, update all pointers */
	while (data != NULL) {
		if (strcmp(data->ident, ident) == 0) {
			*data->level = level;
			ret = 0;
		}
		data = data->next;
	}
	return ret;
}

/**
 */
int pal_log_dyn_get_level(const char *ident)
{
	struct pal_log_dyn_data *data = pal_log_dyn_head;

	/* only get value of first level found */
	while (data != NULL) {
		if (strcmp(data->ident, ident) == 0) {
			return *data->level;
		}
		data = data->next;
	}

	/* not found */
	return -1;
}

/**
 */
int pal_log_dyn_get_modules(const char **modules[])
{
	static const char **__modules = {NULL};

	if (modules != NULL) {
		*modules = __modules;
		return 0;
	}

	return -1;
}


//#endif /* PAL_LOG_DYN_LEVEL */

