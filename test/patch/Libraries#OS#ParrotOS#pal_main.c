

#include "parrotOS.h"

#if defined(OS_LINUX)

int main(int argc, char* argv[])
{
	sup_core_init2(argc, argv, &sup_system_startup, 1);
	return 0;
}

#elif defined(OS_ECOS)

void cyg_user_start(void)
{
	sup_system_fs_init();

	pal_priority_init();

	pal_init_common(&sup_system_startup);
}

#endif

