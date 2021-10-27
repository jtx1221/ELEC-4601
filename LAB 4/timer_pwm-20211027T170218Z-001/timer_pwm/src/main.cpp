/*----------------------------
LAB EXERCISE 4 - TIMER AND PWM
 -----------------------------*/

#include "mbed.h"

//Define the musical notes (the frequencies of sound)
# define Do     0.005
# define Re     0.0045
# define Mi     0.004
# define Fa     0.0036
# define So     0.0033
# define La     0.0031
# define Si     0.003
# define No     0

//Define the beat lengths (e.g., whole note and half note)
# define b1     0.5
# define b2     0.25
# define b3     0.125
# define b4     0.075

//Define the musical array
float note[] = {Mi,No,Mi,No,Mi,No, Mi,No,Mi,No,Mi,No, Mi,No,So,No,Do,No,Re,No,Mi,No, Fa,No,Fa,No,Fa,No,Fa,No, Fa,No,Mi,No,Mi,No,Mi,No,Mi,No, Mi,Re,No,Re,Mi, Re,No,So,No};
float beat[] = {b3,b3,b3,b3,b2,b2, b3,b3,b3,b3,b2,b2, b3,b3,b3,b3,b3,b3,b3,b3,b2,b1, b3,b3,b3,b3,b3,b3,b3,b3, b3,b3,b3,b3,b3,b3,b4,b4,b4,b4, b2,b3,b3,b2,b2, b2,b2,b2,b2};

//Define your RGB LED
//Write your code here
PwmOut RED_LED(PB_4);
PwmOut GREEN_LED(PC_7);
PwmOut BLUE_LED(PA_9);	

//Define your speaker
//Write your code here
PwmOut SPEAKER(PB_10);

//Define your 2 potentiometers
//Write your code here
AnalogIn POT_1(PA_0);
AnalogIn POT_2(PA_1);

//Static index variable
//Hint: you will need this in the ISR
static int k;

//Define your 'Ticker'
//Write your code here
Ticker timer;

/*----------------------------------------------------------------------------
 Interrupt Service Routine
 *----------------------------------------------------------------------------*/

void ticker_ISR(){
	/*
	This ISR will be periodically triggered by your 'Ticker'
	On every trigger, update the following:
		+ Update the PWM period of the speaker to play the next audio note
		+ Update the beat length of the next audio note
		+ The inputs from the two potentiometers will be used to adjust the volume and the speed
		+ Alternate the colour of the RGB LED by the last three digits of your student numbers:
			- Divide each of the last three digits of your student number by 10
			  e.g., 100123456 -> 0.4, 0.5, and 0.6
			- Set the RGB values of the LED to these three values
			- Alternate between your student numbers on each note
		+ Switch to the next note in the musical array
	*/
	//Write your code here
	// 0.8, 0.4, 0.8
	
	SPEAKER.period(note[k]);
	
	timer.attach(ticker_ISR,beat[k]*POT_1); // pot 1 changes beat speed
	
	SPEAKER.write(POT_2*0.8);
	
	if (k%2==0){
	RED_LED.write(0.8);
	GREEN_LED.write(0.4);
	BLUE_LED.write(0.8);
	}
	else if (k%2!=0){
	RED_LED.write(0.9);
	GREEN_LED.write(0.9);
	BLUE_LED.write(0.8);
	}
			
	
	/* if (note[k]>Mi) {
		RED_LED = 1;
	}
	if (note[k]<Mi) {
		RED_LED = 0;
	} */
	
	
	k++;
	if (k==48) {
		k = 0;
	}
	
	
}

/*----------------------------------------------------------------------------
 MAIN function
 *----------------------------------------------------------------------------*/

int main(){
	//Initialize the 'Ticker'
	//Write your code here
	RED_LED = 1;
	BLUE_LED = 1;
	GREEN_LED = 1;
	
	timer.attach(ticker_ISR,0);	
	//Wait for an interrupt
	while(1){
		//__wfi();
		//Leave this line of code commented out for now
	}
}

// *******************************ARM University Program Copyright (c) ARM Ltd 2014*************************************
