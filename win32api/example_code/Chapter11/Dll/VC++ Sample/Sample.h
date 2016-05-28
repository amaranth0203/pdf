/*******************************************************************
; Author:	罗云彬
; Web:		http://asm.yeah.net （罗云彬的编程乐园）
; E-mail:	luoyunbin@sina.com
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Version	1.0
;		Date: 2004.05.01
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample.dll 导出函数：
;
; 1、_IncCounter()
;	增加 Dll 内部计数器的值（最大增加到10）并返回计数值
; 2、_DecCounter()
;	减少 Dll 内部计数器的值（最小减少到0）并返回计数值
; 3、_Mod(unsigned num1,unsigned num2)
;	num1 和 num2 为两个整数
;	输出：两个输入数之模 num1 % num2
;********************************************************************/

#ifdef __cplusplus
extern "C" {
#endif

__stdcall _IncCounter();
__stdcall _DecCounter();
__stdcall _Mod(unsigned num1,unsigned num2);

#ifdef __cplusplus
}
#endif
