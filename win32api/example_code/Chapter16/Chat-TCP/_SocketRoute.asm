;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 阻塞模式下使用的常用子程序
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;
;
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 在规定的时间内等待数据到达
; 输入：dwTime = 需要等待的时间（微秒）
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_WaitData	proc	_hSocket,_dwTime
		local	@stFdSet:fd_set,@stTimeval:timeval

		mov	@stFdSet.fd_count,1
		push	_hSocket
		pop	@stFdSet.fd_array
		push	_dwTime
		pop	@stTimeval.tv_usec
		mov	@stTimeval.tv_sec,0
		invoke	select,0,addr @stFdSet,NULL,NULL,addr @stTimeval
		ret

_WaitData	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 接收规定字节的数据，如果缓冲区中的数据不够则等待
; 返回：eax = TRUE，连接中断或发生错误
;	eax = FALSE，成功
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RecvData	proc	_hSocket,_lpData,_dwSize
		local	@dwStartTime

		mov	esi,_lpData
		mov	ebx,_dwSize
		invoke	GetTickCount
		mov	@dwStartTime,eax
;********************************************************************
		@@:
		invoke	GetTickCount			;查看是否超时
		sub	eax,@dwStartTime
		cmp	eax,10 * 1000
		jge	_Err
;********************************************************************
		invoke	_WaitData,_hSocket,100*1000	;等待数据100ms
		cmp	eax,SOCKET_ERROR
		jz	_Err
		or	eax,eax
		jz	@B
		invoke	recv,_hSocket,esi,ebx,0
		.if	(eax == SOCKET_ERROR) || ! eax
_Err:
			xor	eax,eax
			inc	eax
			ret
		.endif
		.if	eax <	ebx
			add	esi,eax
			sub	ebx,eax
			jmp	@B
		.endif
		xor	eax,eax
		ret

_RecvData	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 接收一个符合规范的数据包
; 返回：eax = TRUE （失败）
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RecvPacket	proc	_hSocket,_lpBuffer,_dwSize
		local	@dwReturn

		pushad
		mov	@dwReturn,TRUE
		mov	esi,_lpBuffer
		assume	esi:ptr MSG_STRUCT
;********************************************************************
; 接收数据包头部并检测数据是否正常
;********************************************************************
		invoke	_RecvData,_hSocket,esi,sizeof MSG_HEAD
		or	eax,eax
		jnz	_Ret
		mov	ecx,[esi].MsgHead.dwLength
		cmp	ecx,sizeof MSG_HEAD
		jb	_Ret
		cmp	ecx,_dwSize
		ja	_Ret
;********************************************************************
; 接收余下的数据
;********************************************************************
		sub	ecx,sizeof MSG_HEAD
		add	esi,sizeof MSG_HEAD
		.if	ecx
			invoke	_RecvData,_hSocket,esi,ecx
		.else
			xor	eax,eax
		.endif
		mov	@dwReturn,eax
_Ret:
		popad
		assume	esi:nothing
		mov	eax,@dwReturn
		ret

_RecvPacket	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
