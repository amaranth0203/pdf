ML_FLAG = /c /coff
LINK_FLAG = /subsystem:windows

DLL.dll Load.exe:

DLL.dll: DLL.obj
	Link  $(LINK_FLAG) /Dll DLL.obj
Load.exe: Load.obj Load.res
	Link  $(LINK_FLAG) Load.obj Load.res

.asm.obj:
	ml $(ML_FLAG) $<
.rc.res:
	rc $<

clean:
	del *.obj
	del *.res
