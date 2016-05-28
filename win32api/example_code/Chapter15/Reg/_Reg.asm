;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; _Reg.asm
; ����ע�������Ĺ����ӳ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ��ѯ��ֵ
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RegQueryValue	proc	_lpszKey,_lpszValueName,_lpszValue,_lpdwSize,_lpdwType
		local	@hKey,@dwReturn

		mov	@dwReturn,-1
		invoke	RegOpenKeyEx,HKEY_LOCAL_MACHINE,_lpszKey,NULL,\
			KEY_QUERY_VALUE,addr @hKey
		.if	eax == ERROR_SUCCESS
			invoke	RegQueryValueEx,@hKey,_lpszValueName,NULL,_lpdwType,\
				_lpszValue,_lpdwSize
			mov	@dwReturn,eax
			invoke	RegCloseKey,@hKey
		.endif
		mov	eax,@dwReturn
		ret

_RegQueryValue	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ü�ֵ
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RegSetValue	proc	_lpszKey,_lpszValueName,_lpszValue,_dwValueType,_dwSize
		local	@hKey

		invoke	RegCreateKey,HKEY_LOCAL_MACHINE,_lpszKey,addr @hKey
		.if	eax == ERROR_SUCCESS
			invoke	RegSetValueEx,@hKey,_lpszValueName,NULL,\
				_dwValueType,_lpszValue,_dwSize
			invoke	RegCloseKey,@hKey
		.endif
		ret

_RegSetValue	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����Ӽ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RegCreateKey	proc	_lpszKey,_lpszSubKeyName
		local	@hKey,@hSubkey,@dwDisp

		invoke	RegOpenKeyEx,HKEY_LOCAL_MACHINE,_lpszKey,NULL,\
			KEY_CREATE_SUB_KEY,addr @hKey
		.if	eax == ERROR_SUCCESS
			invoke	RegCreateKeyEx,@hKey,_lpszSubKeyName,NULL,NULL,\
				NULL,NULL,NULL,addr @hSubkey,addr @dwDisp
			invoke	RegCloseKey,@hKey
			invoke	RegCloseKey,@hSubkey
		.endif
		ret

_RegCreateKey	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ɾ����ֵ
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RegDelValue	proc	_lpszKey,_lpszValueName
		local	@hKey

		invoke	RegOpenKeyEx,HKEY_LOCAL_MACHINE,_lpszKey,NULL,\
			KEY_WRITE,addr @hKey
		.if	eax == ERROR_SUCCESS
			invoke	RegDeleteValue,@hKey,_lpszValueName
			invoke	RegCloseKey,@hKey
		.endif
		ret

_RegDelValue	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ɾ���Ӽ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RegDelSubKey	proc	_lpszKey,_lpszSubKeyName
		local	@hKey

		invoke	RegOpenKeyEx,HKEY_LOCAL_MACHINE,_lpszKey,NULL,\
			KEY_WRITE,addr @hKey
		.if	eax == ERROR_SUCCESS
			invoke	RegDeleteKey,@hKey,_lpszSubKeyName
			invoke	RegCloseKey,@hKey
		.endif
		ret

_RegDelSubKey	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
