/********************************************************************
; Sample code for < Win32ASM Programming >
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Mod.cpp
; �Ա� Sample.dll �еĺ�����ʹ�÷�����ʾ����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; cl Mod.cpp Sample.lib
;*******************************************************************/
#include "stdio.h"
#include "Sample.h"

void main(int argc, char* argv[])
{
	unsigned num1,num2;
	if (3 == argc)
	{
		sscanf(argv[1],"%u",&num1);
		sscanf(argv[2],"%u",&num2);
		printf("%u %% %u = %u",num1,num2,_Mod(num1,num2));
	}
	else
		printf("Usage: Mod num1 num2\n");
}
