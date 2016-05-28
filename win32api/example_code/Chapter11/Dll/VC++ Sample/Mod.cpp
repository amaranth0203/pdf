/********************************************************************
; Sample code for < Win32ASM Programming >
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Mod.cpp
; 自编 Sample.dll 中的函数的使用方法演示程序
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
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
