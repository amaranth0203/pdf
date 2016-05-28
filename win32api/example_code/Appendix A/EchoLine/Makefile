NAME = EchoLine
OBJS = $(NAME).obj

$(NAME).exe: $(OBJS)
	Link /SUBSYSTEM:CONSOLE $(OBJS)
$(NAME).obj: $(NAME).asm
	ml /c /coff $(NAME).asm

clean:
	del *.obj
