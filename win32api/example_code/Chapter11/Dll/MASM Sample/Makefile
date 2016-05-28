NAME = UseDll

ML_FLAG = /c /coff
LINK_FLAG = /subsystem:windows

$(NAME)1.exe $(NAME)2.exe:

$(NAME)1.exe: $(NAME)1.obj $(NAME).res
	Link  $(LINK_FLAG) $(NAME)1.obj $(NAME).res

$(NAME)2.exe: $(NAME)2.obj $(NAME).res
	Link  $(LINK_FLAG) $(NAME)2.obj $(NAME).res

.asm.obj:
	ml $(ML_FLAG) $<
.rc.res:
	rc $<

clean:
	del *.obj
	del *.res
