org 0h 
	back: clr p1.0
		acall delay
		setb p1.0
		acall delay
		sjmp back
	delay: mov r0,#0ffh
	again: mov r1,#0ffh
	here: djnz r1,here
		djnz r0,again
		ret
end