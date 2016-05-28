DLL = Sample

ML_FLAG = /c /coff
LINK_FLAG = /subsystem:windows /Dll

####################################################
# 创建共享数据段的DLL时使用的连接选项
# LINK_FLAG = /subsystem:windows /Dll /section:.bss,S
####################################################

$(DLL).dll: $(DLL).obj $(DLL).def
	Link  $(LINK_FLAG) /Def:$(DLL).def $(DLL).obj

.asm.obj:
	ml $(ML_FLAG) $<
.rc.res:
	rc $<

clean:
	del *.obj
	del *.exp

