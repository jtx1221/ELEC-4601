{;
; Carleton University
; ELEC 4601 - Lab 2A
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
EOI  = $20;     {what you send to the PIC to notify an End of Interrupt}
PIC  = $20;     {the PIC chip address (see your lab manual)}
IRQ7 = $F;      {the vector of IRQ7}
LPT1 = $378;    {the address of the parallel port (LEDs on the PC/104)}
{;
; Next, define some variables to be used (a Pascal construct).
;}
var
counter: word;      {16-bit number}
saveint: pointer;   {32-bit pointer}
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
; 4 - Send the EOI command to the PIC, otherwise you'll never see another interrupt
; 5 - Restore the registers that you have changed (and saved)
; 6 - Make an Interrupt Return (IRET), as opposed to a regular procedure return
;}
Procedure LptIsr ; far ; assembler ; {this is a Pascal construct for assembly procedures}
asm
{_____________________________________________ >}
{****************************************}
{***START OF INTERRUPT SERVICE ROUTINE***}
{****************************************}

{Step 1: Save the registers that you need here}
push ax
push ds
push dx

{This does nothing important; just something we can see on the Logic Analyzer}
{Recall from Lab 1, that the 'in' instruction READS from a specific address}
mov dx, $379
in al, dx

{Step 2: Set the ds register because it might be anything at this point}
mov ax, seg counter
mov ds, ax

{Step 3: The actual purpose of the ISR/program}
inc counter

{Step 4: Send EOI command to PIC}
{Recall from Lab 1, that the 'out' instruction WRITES from a specific address}
mov al, EOI
out PIC, al

{Step 5: Restore the saved registers}
pop dx
pop ds
pop ax

{Step 6: Make the Interrupt Return call}
iret

{**************************************}
{***END OF INTERRUPT SERVICE ROUTINE***}
{**************************************}
{<_____________________________________________ }
end;
{;
; Now, the main program that just waits for an interrupt and puts up some
; sort of a status display.
;}
begin
asm
{;
; Put 0 in the 'counter' variable.
;}
{_____________________________________________ >}
mov counter, 0
{<_____________________________________________ }
{;
; Now the painful steps of setting the system up to allow
; recognizing and handling the interrupt.
;
; ******************
; ***Setup Step 1***
; ******************
; Send the EOI command to the PIC to ready it for interrupts.
;}
{_____________________________________________ >}
mov al, EOI
out PIC, al
{<_____________________________________________ }
{;
; ******************
; ***Setup Step 2***
; ******************
; Disable IRQ7 using the Interrupt Mask Register (IMR) bit in PIC #1,
; so that we don't get an interrupt before we are ready to actually
; process one.
;}
{_____________________________________________ >}
in al, PIC+1
or al, $80
out PIC+1, al
{<_____________________________________________ }
{;
; ******************
; ***Setup Step 3***
; ******************
; Save the current IRQ7 vector for restoring later. For this processor,
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
{_____________________________________________ >}
mov ah, $35
mov al, IRQ7
int $21 {vector returned as 32-bits in es:bx}
{<_____________________________________________ }
{;
; And put the values of ES and BX into the 32-bit 'saveint' variable
; so that we can restore the interrupt pointer at the end of the program.
;}
{_____________________________________________ >}
mov [offset saveint+2], es  {save high word in saveint}
mov word ptr saveint, bx    {save low word in saveint}
{<_____________________________________________ }
{;
; ******************
; ***Setup Step 4***
; ******************
; Move the address of the ISR into the IRQ7 slot in the table.
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
{_____________________________________________ >}
push ds {save the ds register because we are about to change it}

mov ah, $25
mov al, IRQ7

mov bx, seg LptIsr
mov dx, offset LptIsr
mov ds, bx {ds:dx has address of LptIsr in it}

int $21

pop ds {restore the ds register}
{<_____________________________________________ }
{;
; ******************
; ***Setup Step 5***
; ******************
; Enable interrupts at the LPT1 device so that signals coming
; in on Pin 10 on the LPT1 connector will cause an interrupt.
; Set the bit in the control register (byte) of LPT1, which should be
; at the address of LPT1+1.
;}
{_____________________________________________ >}
mov dx, LPT1+2
in al, dx
or al, $10
out dx, al
{<_____________________________________________ }
{;
; ******************
; ***Setup Step 6***
; ******************
; Everything is ready; so lastly, set up the PIC to allow
; interrupts on IRQ7.
;}
{_____________________________________________ >}
in al, PIC+1
and al, $7F
out PIC+1, al
{<_____________________________________________ }
{;
; At this point, interrupts should be enabled; and if they occur, our
; ISR is set up to handle the interrupt by just
; counting the interrupts as they occur. This is happening in the
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
; Write the value of the 'counter' variable to the LPT1 port to light the LEDs.
;}
{_____________________________________________ >}
mov dx, LPT1
mov ax, counter
out dx, ax
{<_____________________________________________ }
jmp @loop {jump back to loop and check for key to quit}
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
{_____________________________________________ >}
in al, PIC+1    {disable IRQ7 on the PIC}
or al, $80
out PIC+1, al
{<_____________________________________________ }
{;
; ***********************
; ***Undo Setup Step 5***
; ***********************
;}
{_____________________________________________ >}
mov dx, LPT1+2  {disable interrupts through Pin 10 on LPT1}
in al, dx
and al, $EF
out dx, al
{<_____________________________________________ }
{;
; ***********************
; ***Undo Setup Step 4***
; ***********************
; Replace the interrupt service routine address with the original
; one we saved in 'saveint' when we started up. This is the same system call
; that you made before, which sets a vector in the interrupt table,
; except this time the value for the pointer is in 'saveint'.
;}
{_____________________________________________ >}
push ds         {save the ds register because we will change it}

mov ah, $25     {call a system function that puts an ISR address}
mov al, IRQ7    {into the vector table at the position for IRQ7}

mov ax, word ptr saveint
mov ds, ax
mov dx, word ptr saveint+2

int $21         {set the interrupt vector}

pop ds          {restore the ds register}
{<_____________________________________________ }
{;
; And that should do it. Everything that was done to the system has been undone.
; It is now safe to quit.
;}
end;
end.
