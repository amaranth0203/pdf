NAME = Main
DLL = Hookdll

ML_FLAG = /c /coff
LINK_FLAG = /subsystem:windows
DLL_LINK_FLAG = /subsystem:windows /section:.bss,S

$(DLL).dll $(NAME).exe:

$(DLL).dll: $(DLL).obj $(DLL).def
	Link  $(DLL_LINK_FLAG) /Def:$(DLL).def /Dll $(DLL).obj
$(NAME).exe: $(NAME).obj $(NAME).res
	Link  $(LINK_FLAG) $(NAME).obj $(NAME).res

.asm.obj:
	ml $(ML_FLAG) $<
.rc.res:
	rc $<

clean:
	del *.obj
	del *.res
	del *.exp
	del *.lib

