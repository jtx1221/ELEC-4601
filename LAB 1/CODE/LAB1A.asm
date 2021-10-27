; *********** lab1a.asm *************
; Displays the string (including the spaces)
; at various locations about the screen
; Note:
; - Code uses MASM 6.11 syntax
; - To assemble: ml lab1a.asm
; ***********************************
.MODEL small
.STACK 100h
.386
.data
	msg DB "Hello World, Welcome to ELEC4601 !!!", 0
	nSize DW ($ - msg)
.code
_main PROC
	XOR SI, SI
	XOR DI, DI
	MOV DX, @data
	MOV DS, DX
	MOV CX, nSize
	MOV SI, OFFSET msg
	MOV DX, 0B800h
	MOV ES, DX
scanLoop:
	MOV AL, byte ptr [SI]
	MOV byte ptr ES: [DI], AL
	INC DI
	INC SI
	INC DI
	LOOP scanloop
terminate:
	MOV AX, 4C00h
INT 21h
_main ENDP
END _main