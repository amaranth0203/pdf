;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Author:	罗云彬
; Web:		http://asm.yeah.net （罗云彬的编程乐园）
; E-mail:	luoyunbin@sina.com
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Version	1.0
;		Date: 2004.05.01
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample.dll 导出函数：
;
; 1、invoke _IncCounter
;	增加 Dll 内部计数器的值（最大增加到10）并返回计数值
; 2、invoke _DecCounter
;	减少 Dll 内部计数器的值（最小减少到0）并返回计数值
; 3、invoke _Mod,dwNumber1,dwNumber2
;	输入：dwNumber1 和 dwNumber2 为两个整数
;	输出：两数的模 dwNumber1 % dwNumber2
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

_IncCounter	proto
_DecCounter	proto
_Mod		proto	dwNumber1:dword,dwNumber2:dword