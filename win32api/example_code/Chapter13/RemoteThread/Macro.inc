;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 将参数列表的顺序翻转
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reverseArgs	macro	arglist:VARARG
		local	txt,count
    
	txt	TEXTEQU	<>
	count	= 0
	for	i,<arglist>
	        count	= count + 1
	        txt	TEXTEQU @CatStr(i,<!,>,<%txt>)
	endm
	if	count GT 0
	        txt	SUBSTR  txt,1,@SizeStr(%txt)-1
	endif
	exitm	txt
endm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 建立一个类似于 invoke 的 Macro
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_invoke		macro	_Proc,args:VARARG
		local	count
    
	count	= 0
%	for	i,< reverseArgs( args ) >
		count	= count + 1
		push	i
	endm
	call	dword ptr _Proc    
    
endm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
