NAME = RecHook

ML_FLAG = /c /coff
LINK_FLAG = /subsystem:windows

$(NAME).exe: $(NAME).obj $(NAME).res
	Link  $(LINK_FLAG) $(NAME).obj $(NAME).res

.asm.obj:
	ml $(ML_FLAG) $<
.rc.res:
	rc $<

clean:
	del *.obj
	del *.res
