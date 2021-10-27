{;
; Carleton University
; ELEC 4601 - Lab 2B
; Version: September 29, 2017
;
; Start with standard 80x86 assembler boilerplate (i.e., a skeleton of a program),
; which is common to most assembler code. This program is more comments and
; discussion than anything else. All the heavy lifting is done for you,
; except in the areas marked as:
;
;__________________________________________>
; Your code goes here
;<__________________________________________
;
; Here, you will put a few lines of code. The important things to note
; are the steps, and how they relate to handling interrupts in this
; particular microprocessor: the 80x86 in real mode.
;
; Some acronyms that we'll use:
; PIC:  Priority Interrupt Controller (there are 2 in a classic PC)
; OS:   Operating System
; ISR:  Interrupt Service Routine
; EOI:  End of Interrupt
;
; NOTE
; ****
; For this particular exercise, you are actually using a Pascal compiler
; to 'assemble' your program. The advantage is that you still get to see
; how the actual code does stuff, but you don't have to worry about every little
; detail. This is the main advantage of any compiler. We could have used a C compiler
; as well, but this one works just fine. The little constructs that make your life
; easier will be noted. Note that hex values are designated by a '$' symbol, so
; the usual 0x0FF or 0FFh notation becomes $FF. Comments are also noted as
; anything enclosed in curly brackets.
;
; We will first define some constants. It is always best to
; define all constants, and use the names, rather than using the raw numbers.
;}
const
EOI  = $20;
PIC  = $20;
IRQ4 = $0C;     {the IRQ used by the serial port}
COM1 = $3F8;    {the address of the serial port}
DIVL = 12;      {baud rate divider numbers}
DIVH = 0;       {for 9600 baud}
LPT1 = $378;

{register offsets for the serial port}
IER = 1; {interrupt enable register}
IIR = 2; {interrupt identification register}
LCR = 3; {line control register}
MCR = 4; {modem control register}
LSR = 5; {line status register}
MSR = 6; {modem status register}
{;
; Variables to be used (a Pascal construct).
;}
var
counter: word;      {16-bit number}
saveint: pointer;   {32-bit pointer}
rxchar: byte;       {the received serial character}
txchar: byte;       {the transmitted character}
indx: integer;
{;
; We start with the Interrupt Service Routine (ISR).
; If you only ever call your own routines, and they are all in this
; file, AND if everything fits into a single 64K segment, then you probably
; wouldn't have to worry about making sure that the segment registers
; are valid and point to your variables properly.
; It is more likely, and better to assume, that you have NO idea
; what the segment registers are, or pretty much anything else. An interrupt
; can occur at any time, and a jump to this routine will just happen. It is
; up to you to set things up the way that you want them, handle the
; interrupt, and then put everything back the way it was. The symptom
; that you haven't done this right is that the system will completely lock
; up after an interrupt, and you will have to reboot and try again. Interrupt handlers
; must put everything back EXACTLY as it was before the handler was called.
; For this processor, the FLAGS register and the Program Counter are pushed onto the
; stack when the interrupt handler is called (automatically), and popped off the stack
; with the IRET instruction.
;
; The important steps of an ISR:
; 1 - Save any registers that you are going to change
; 2 - Set the DS register to point to the data segment of your variables
; 3 - Do what you have to do for your program's functionality
;     (i.e., read from serial port -> write to serial port -> increment counter)
; 4 - Send the EOI command to the PIC, otherwise you'll never see another interrupt
; 5 - Restore the registers that you have changed (and saved)
; 6 - Make an Interrupt Return (IRET), as opposed to a regular procedure return
;}
Procedure ComIsr ; far ; assembler ; {this is a Pascal construct for assembly procedures}
asm
{_____________________________________________>}
{****************************************}
{***START OF INTERRUPT SERVICE ROUTINE***}
{****************************************}

{;
; Refer to the notes above, your classnotes, and LAB2A.PAS
; for help writing this Instruction Service Routine.
;
; The purpose of this program is to read a character from the COM1 serial port,
; write the uppercased character back to the same serial port, and increment the interrupt counter
; (like in LAB2A). Use TeraTerm on the Windows machine to send/receive the data.
;
; NOTE: A few other sections of code in this program are left out. Fill in the code for
; the marked sections.
;}

{WRITE YOUR CODE BELOW}

{Step 1}

{Step 2}

{Step 3}

{Step 4}

{Step 5}

{Step 6}

{**************************************}
{***END OF INTERRUPT SERVICE ROUTINE***}
{**************************************}
{<_____________________________________________}
end;
{
; The main program that just waits and services characters coming through
; the serial port (each is an interrupt that should be counted).
;}
begin
asm
{;
; Put 0 in the 'counter' variable.
;}
{_____________________________________________>}
mov counter, 0
{<_____________________________________________}
{;
; The additional part for the COM1 device is that you have
; to set up the serial parameters to allow communication
; with a serial terminal. This is a bit fussy, so here are the basic steps
; 1 - Figure out the 16-bit baud rate divisor value from this formula:
;     Divisor = 1843200/16/baud_rate, where baud_rate is a number like 2400, 9600, 19200 up to 115200
; 2 - Set the most significant bit of the byte at address (COM1+LCR) to a '1' (DLAB=1)
; 3 - Now you have write access to the baud rate bytes at COM1 (the low byte) and (COM1+1) the high byte,
;     so set the two bytes according to your divisor value calculated above
; 4 - Now clear the most siginficant of the byte at address (COM1+LCR) to a '0' (DLAB=0)
; 5 - The baud rate is set, so now also set the number of serial bits, the number of stop bits, and the parity.
;     This is just a single byte code from the documentation, something like:
;     No parity (00000...) +1 stop bit (.....1..) +8-bit data (......11) -> which comes to 00000111
; 6 - Write this value to register (COM1+LCR), and the serial communications are all set up
;}
{_____________________________________________>}
mov dx, COM1+3
in al, dx
or al, $80
out dx, al

mov dx, COM1
mov al, IRQ4
out dx, al
inc dx
mov al, $0
out dx, al

mov dx, COM1+3

in al, dx
and al, $7F
out dx, al

mov al, 3
out dx, al
{<_____________________________________________}
{;
; ******************
; ***Setup Step 1***
; ******************
; Send the EOI command to the PIC to ready it for interrupts.
;}
{_____________________________________________>}
mov al, EOI
out PIC, al
{<_____________________________________________}
{;
; ******************
; ***Setup Step 2***
; ******************
; Disable IRQ4 using the Interrupt Mask Register (IMR) bit in PIC #1,
; so that we don't get an interrupt before we are ready to actually
; process one.
;}
{_____________________________________________>}
{************************************}
{************************************}
{************************************}
{YOUR CODE GOES RIGHT UNDER THIS LINE}

{YOUR CODE GOES RIGHT ABOVE THIS LINE}
{************************************}
{************************************}
{************************************}
{<_____________________________________________}
{;
; ******************
; ***Setup Step 3***
; ******************
; Save the current IRQ4 vector for restoring later. For this processor,
; this is just always done.
; This is a system function call in any OS, but in the simple DOS that
; we are testing on, the call is made through INT 0x21, with some registers
; defined as follows:
;
; AH = 0x35 (this is the function number that fetches a vector)
; AL = the software interrupt vector that we want to read (0...255)
; INT 0x21 (the standard way of getting at DOS services. Any OS running
; on this processor will use some variation of this idea)
;
; When the function call returns, you will find the interrupt vector
; in the ES:BX registers.
;}
{_____________________________________________>}
mov ah, $35
mov al, IRQ4
int $21 {vector returned as 32-bits in es:bx}
{<_____________________________________________}
{;
; And put the values of ES and BX into the 32-bit 'saveint' variable
; so that we can restore the interrupt pointer at the end of the program.
;}
{_____________________________________________>}
lea di, saveint {point ds:[di] at the variable saveint}
mov [di+2], es  {save high word in saveint}
mov [di], bx    {save low word in saveint}
{<_____________________________________________}
{;
; ******************
; ***Setup Step 4***
; ******************
; Move the address of the ISR into the IRQ4 slot in the table.
; Unless you do this step, nothing is going to happen when an interrupt
; occurs---at least nothing that you have any control over.
; Just like above, there is a system call to do this. You could do it
; yourself, but it is always good practice to use a system call if there is
; one. Again, the call is made through INT 0x21 with some registers
; defined as follows:
;
; AH = 0x25 (this is the function number that sets a vector)
; AL = the software interrupt vector that we want to set (0...255)
; DS:DX = the 32-bit address of our ISR
;
; Watch that you have to change the value of the DS register in order to
; satisfy the function call. So be sure to save it, then restore it after the call.
;
; You can find the segment part and offset part of the address
; of the procedure LptIsr using the 'seg' and 'offset' assembler operations.
;}
{_____________________________________________>}
push ds {save the ds register because we are about to change it}

mov ax, seg ComIsr
mov ds, ax
mov ah, $25
mov al, IRQ4
mov dx, offset ComIsr

int $21

pop ds  {restore the ds register}
{<_____________________________________________}
{;
; ******************
; ***Setup Step 5***
; ******************
; Enable interrupts at the COM1 device so that once a serial character
; is received from the Windows terminal, you will get an interrupt.
; Note to students that there is a fussy bit here that I wouldn't
; expect them to know about.
;}
{_____________________________________________>}
{**odd bit only required on some systems, like this one**}
mov dx, COM1+4
mov ax, $0f
out dx, ax
{**end of fussy bit**}

{************************************}
{************************************}
{************************************}
{YOUR CODE GOES RIGHT UNDER THIS LINE}

{YOUR CODE GOES RIGHT ABOVE THIS LINE}
{************************************}
{************************************}
{************************************}
{<_____________________________________________}
{;
; ******************
; ***Setup Step 6***
; ******************
; Everything is ready; so lastly, set up the PIC to allow
; interrupts on IRQ4.
;}
{_____________________________________________>}
{************************************}
{************************************}
{************************************}
{YOUR CODE GOES RIGHT UNDER THIS LINE}

{YOUR CODE GOES RIGHT ABOVE THIS LINE}
{************************************}
{************************************}
{************************************}
{<_____________________________________________}
{;
; At this point, interrupts should be enabled; and if they occur, our
; ISR is set up to handle the interrupt by just counting the interrupts as
; they occur, and echoeing the characters received. This is happening in the
; background, so we can do whatever we want in the foreground. In this
; case, we will simply give some sort of indication of the value of the
; interrupt counter. The LEDs on the printer port would be easy.
;}
@loop:
{;
; *******************
; *****Main Loop*****
; *******************
; Check for a keypress to exit out; otherwise, send the low 8-bits of the
; counter variable to the LED display on LPT1 so that you can see the
; results of counting the interrupts.
;}
mov ah, 1
int $16
jnz @alldone
{;
; Write the value of the 'counter' variable to the LPT1 port to light the LEDs. The ISR takes care of echoing the characters.
;}
{_____________________________________________>}
{************************************}
{************************************}
{************************************}
{YOUR CODE GOES RIGHT UNDER THIS LINE}

{YOUR CODE GOES RIGHT ABOVE THIS LINE}
{************************************}
{************************************}
{************************************}
{<_____________________________________________}
jmp @loop   {jump back to loop and check for key to quit}
@alldone:
{;
; So we have done what we have set out to do. An interrupt was generated,
; the code handled it and displayed something. Now undo all the steps
; that we went through in setup, to restore the machine to its original state
;
; ***********************
; ***Undo Setup Step 6***
; ***********************
;}
{_____________________________________________>}
{************************************}
{************************************}
{************************************}
{YOUR CODE GOES RIGHT UNDER THIS LINE}

{YOUR CODE GOES RIGHT ABOVE THIS LINE}
{************************************}
{************************************}
{************************************}
{<_____________________________________________}
{;
; ***********************
; ***Undo Setup Step 5***
; ***********************
;}
{_____________________________________________>}
{************************************}
{************************************}
{************************************}
{YOUR CODE GOES RIGHT UNDER THIS LINE}

{YOUR CODE GOES RIGHT ABOVE THIS LINE}
{************************************}
{************************************}
{************************************}
{<_____________________________________________}
{;
; ***********************
; ***Undo Setup Step 4***
; ***********************
; Replace the interrupt service routine address with the original
; one we saved in 'saveint' when we started up. This is the same system call
; that you made before, which sets a vector in the interrupt table,
; except this time the value for the pointer is in 'saveint'.
;}
{_____________________________________________>}
push ds         {save the ds register because we will change it}

mov ah, $25     {call a system function that puts an ISR address}
mov al, IRQ4    {into the vector table at the position for IRQ4}

les di, saveint {so es:di now has old vector in it}
mov dx, di
mov bx, es
mov ds, bx      {ds:dx now also has old vector in it}

int $21         {set the interrupt vector}

pop ds          {restore the ds register}
{<_____________________________________________}
{;
; And that should do it. Everything that was done to the system has been undone.
; It is now safe to quit.
;}
end;
end.
