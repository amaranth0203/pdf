/*******************************************************************
; Author:	���Ʊ�
; Web:		http://asm.yeah.net �����Ʊ�ı����԰��
; E-mail:	luoyunbin@sina.com
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Version	1.0
;		Date: 2004.05.01
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample.dll ����������
;
; 1��_IncCounter()
;	���� Dll �ڲ���������ֵ��������ӵ�10�������ؼ���ֵ
; 2��_DecCounter()
;	���� Dll �ڲ���������ֵ����С���ٵ�0�������ؼ���ֵ
; 3��_Mod(unsigned num1,unsigned num2)
;	num1 �� num2 Ϊ��������
;	���������������֮ģ num1 % num2
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
