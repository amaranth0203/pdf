;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; FIFO（First in, first out）消息队列的实现
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;
;
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
QUEUE_SIZE	equ	100		;消息队列的长度
MSG_QUEUE_ITEM	struct			;队列中单条消息的格式定义
  dwMessageId	dd	?		;消息编号
  szSender	db	12 dup (?)	;发送者
  szContent	db	256 dup (?)	;聊天内容
MSG_QUEUE_ITEM	ends
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.data?

stCS		CRITICAL_SECTION <?>
stMsgQueue	MSG_QUEUE_ITEM QUEUE_SIZE dup (<?>)
dwMsgCount	dd	?		;队列中当前消息数量

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.data

dwSequence	dd	1	;消息序号，从1开始

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 在队列中加入一条消息
; -- 如果队列已经满了，则将整个队列前移一个位置，相当于最早的消息被覆盖
;    然后在队列尾部空出的位置加入新消息
; -- 如果队列未满，则在队列的最后加入新消息
; -- 消息编号从1开始递增，这样保证队列中各消息的编号是连续的
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 入口：_lpszSender = 指向发送者字符串的指针
;	_lpszContent = 指向聊天语句内容字符串的指针
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_InsertMsgQueue	proc	_lpszSender,_lpszContent

		pushad
		invoke	EnterCriticalSection,addr stCS
		mov	eax,dwMsgCount
;********************************************************************
; 如果队列满，则移动队列，并在队列尾部添加新消息
;********************************************************************
		.if	eax >= QUEUE_SIZE
			mov	edi,offset stMsgQueue
			mov	esi,offset stMsgQueue + sizeof MSG_QUEUE_ITEM
			mov	ecx,(QUEUE_SIZE-1) * sizeof MSG_QUEUE_ITEM
			mov	eax,ecx
			cld
			rep	movsb
;********************************************************************
; 否则直接添加到队列尾部
;********************************************************************
		.else
			inc	dwMsgCount
			mov	ecx,sizeof MSG_QUEUE_ITEM
			mul	ecx
		.endif
;********************************************************************
; 前面的语句执行完毕后，eax指向队列中空位置的偏移量
;********************************************************************
		lea	esi,[stMsgQueue+eax]
		assume	esi:ptr MSG_QUEUE_ITEM
		invoke	lstrcpy,addr [esi].szSender,_lpszSender
		invoke	lstrcpy,addr [esi].szContent,_lpszContent
		inc	dwSequence
		mov	eax,dwSequence
		mov	[esi].dwMessageId,eax
		assume	esi:nothing
		invoke	LeaveCriticalSection,addr stCS
		popad
		ret

_InsertMsgQueue	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 从队列获取指定编号的消息
; -- 如果指定编号的消息已经被清除出消息队列，则返回编号最小的一条消息
;    当向连接速度过慢的客户端发消息的速度比不上消息被清除的速度，则中间
;    的消息等于被忽略，这样可以保证慢速链路不会影响快速链路
; -- 如果队列中的所有消息的编号都比指定编号小（意味着这些消息以前都被获取过）
;    那么不返回任何消息
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 入口：_dwMessageId = 需要获取的消息编号
;	_lpszSender = 用于返回消息中发送者字符串的缓冲区指针
;	_lpszSender = 用于返回消息中聊天内容字符串的缓冲区指针
; 返回：eax = 0（队列为空，或者队列中没有小于等于指定编号的消息）
;	eax <> 0（已经获取了一条消息，获取的消息编号返回到eax中）
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_GetMsgFromQueue	proc	_dwMessageId,_lpszSender,_lpszContent
			local	@dwReturn

		pushad
		invoke	EnterCriticalSection,addr stCS
		xor	eax,eax
		mov	@dwReturn,eax
		cmp	dwMsgCount,eax
		jz	_Ret

		mov	esi,offset stMsgQueue
		assume	esi:ptr MSG_QUEUE_ITEM
;********************************************************************
; esi 指向队列头部，所以这条消息的编号就是最小编号
; 最大编号＝最小编号＋队列长度－1
;********************************************************************
		mov	ecx,[esi].dwMessageId	;ecx=队列中的最小消息编号
		mov	edx,dwMsgCount
		lea	edx,[edx+ecx-1]		;edx=队列中的最大消息编号
;********************************************************************
; 如果指定编号 < 最小编号，则返回最小编号的消息
; 如果指定编号 > 最大编号，则不返回任何消息
;********************************************************************
		mov	eax,_dwMessageId
		cmp	eax,ecx
		jae	@F
		mov	eax,ecx
		@@:
		cmp	eax,edx
		ja	_Ret
		mov	@dwReturn,eax
;********************************************************************
; 要获取的消息在队列中的位置 = 指定消息编号－最小消息编号
;********************************************************************
		sub	eax,ecx
		mov	ecx,sizeof MSG_QUEUE_ITEM
		mul	ecx
		lea	esi,[esi+eax]
		invoke	lstrcpy,_lpszSender,addr [esi].szSender
		invoke	lstrcpy,_lpszContent,addr [esi].szContent
;********************************************************************
		assume	esi:nothing
_Ret:
		invoke	LeaveCriticalSection,addr stCS
		popad
		mov	eax,@dwReturn
		ret

_GetMsgFromQueue	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
