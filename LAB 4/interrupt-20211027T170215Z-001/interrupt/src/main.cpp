/*-------------------------------
LAB EXERCISE 4 - INTERRUPT IN/OUT
PROGRAMMING USING MBED API
 --------------------------------*/

#include "mbed.h"

//Define your outputs
//Write your code here
DigitalOut RED_LED(PB_4);
DigitalOut GREEN_LED(PC_7);
DigitalOut BLUE_LED(PA_9);

//Define your interrupt inputs
//Write your code here
InterruptIn JOY_UP(PA_4);
InterruptIn JOY_DOWN(PB_0);
InterruptIn JOY_RIGHT(PC_0);
InterruptIn JOY_CENTER(PB_5);
InterruptIn JOY_LEFT(PC_1);

//Define ISRs for the interrupts
//If the switch is high, so should the LED
//If the switch is low, so should the LED
//Remember, the LED will turn on when we give it a '0'
void button_1_handler(){
	//Write your code here
	RED_LED =! JOY_LEFT;
}

void button_2_handler(){
	//Write your code here
	BLUE_LED =! JOY_UP;
}

void button_3_handler(){
	//Write your code here
	GREEN_LED =! JOY_RIGHT;
}

void button_4_handler(){
	//Write your code here
	RED_LED =! JOY_CENTER;
	BLUE_LED =! JOY_CENTER;
	GREEN_LED =! JOY_CENTER;
}

/*----------------------------------------------------------------------------
 MAIN function
 *----------------------------------------------------------------------------*/

int main(){
	//Enable interrupts
	//Think about which header file has this method
	//Write your code here
  __enable_irq();

	//Initially turn off all LEDs
	//Remember, the LED will turn on when we give it a '0'
	//Write your code here
	RED_LED = 1;
	BLUE_LED = 1;
	GREEN_LED = 1;
	
	//Attach the handler to the interrupt
	//Think about which header file has this method
	//Write your code here
	JOY_LEFT.rise(button_1_handler);
	JOY_UP.rise(button_2_handler);
	JOY_RIGHT.rise(button_3_handler);
	JOY_CENTER.rise(button_4_handler);
	
	JOY_LEFT.fall(button_1_handler);
	JOY_UP.fall(button_2_handler);
	JOY_RIGHT.fall(button_3_handler);
	JOY_CENTER.fall(button_4_handler);
	//Wait for an interrupt
	while(1){
		//__wfi();
		//Leave this line of code commented out for now
	}
}

// *******************************ARM University Program Copyright (c) ARM Ltd 2014*************************************
