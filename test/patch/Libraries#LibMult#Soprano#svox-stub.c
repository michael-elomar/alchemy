
#include <stdio.h>

#ifdef ANDROID

#undef stdin
#undef stdout
#undef stderr

FILE* stdin	= (&__sF[0]);
FILE* stdout = (&__sF[1]);
FILE* stderr = (&__sF[2]);

long gethostid(void)
{
	return 0;
}

extern int bsd_signal(int, int);
int signal(int signum, int handler)
{
	return bsd_signal(signum, handler);
}

int _IO_getc(FILE* fp)
{
	return getc(fp);
}

#endif

