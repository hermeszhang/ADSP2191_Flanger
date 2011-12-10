/*****************************************************************************************************************

main.asm

************************************************************************************************/

#include "def2191_stud-1.h"
#include "lcd_macro.h"
	
/************************************************************************************************/
/*			   GLOBAL & EXTERNAL DECLARATIONS					*/	
/************************************************************************************************/    
// Global symbols
.global	 	Start;
.global         PUSH1;
.global         CW1;
.global         CCW1;
.global         CW2;
.global         CCW2;


// External symbols
//egentillagda

//
//assignment 6
//filter 


.extern		Change_PLL_Multiplier;
.extern 	Codec_Reset;
.extern		Program_SPORT0_Registers;
.extern		Program_DMA_Controller;
.extern		AD1885_Codec_Initialization;
.extern		RX_Status;
.extern		Initialize_LCD;
.extern		Poll_Rotary_Encoder1;
.extern		Poll_Rotary_Encoder2;
.extern         Check_Rotary_Encoder1_Push;
.extern		Wait_10ms;




.extern centerDelay;
.extern centerDeviation;
.extern frequency;
.extern mix;
/************************************************************************************************/  
/*                              DM DATA                                                         */
/************************************************************************************************/ 
.SECTION/dm data0;
.var filtertext[7]='F','i','l','t','e','r',' ';
.var one='1';
.var two='2';
.var three='3';
.var four='4';

.var saturationtext[11]='S','a','t','u','r','a','t','i','o','n',' ';
.var saton[3]='O','n',' ';
.var satoff[3]='O','f','f';
/************************************************************************************************/  
/*                             Configuration variables                                          */
/************************************************************************************************/ 
.var cursetting=0; //0:delay,1:deviatoin,2:frequency,3:mix;
.var cdelaytext[16]='C','e','n','t','e','r','d','e','l','a','y',':',' ',' ',' ',' ';
.var devdelaytext[16]='D','e','v','i','a','t','i','o','n',':',' ',' ',' ',' ',' ',' ';
.var frequencytext[16]='F','r','e','q','u','e','n','c','y',':',' ',' ',' ',' ',' ',' ';
.var mixtext[16]='M','i','x',':',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ';
.var currcfg=0;
.var digits[10]='0','1','2','3','4','5','6','7','8','9';

.var tempdigit;
/************************************************************************************************/  
/*                              PM DATA                                                         */
/************************************************************************************************/ 
.SECTION/pm program0;

// ----- Program execution starts here...! -------	
Start:
	 
	call Change_PLL_Multiplier;		// Change the multiplier of the processor. External clock is only 16 MHz.
	call Codec_Reset;			// Reset the codec
	call Program_SPORT0_Registers;		// Initialize SPORT0 for codec communications 
	call Program_DMA_Controller;		// Start Serial Port 0 tx and rx DMA Transfers 
	call AD1885_Codec_Initialization;	// Initialize & program AD1885 
   

	// Set direction of flagpins
	IOPG = General_Purpose_IO;
   	nop;
  	ar = 0xFC8B;
	IO(DIRS) = AR;  
	
	call Initialize_LCD;			// Initialize the LCD
	call Wait_10ms;				// Wait 10 milliseconds...
	AR = 0x000B;
        IO(FLAGC) = AR;	
	
	
	AR=0;

	Output_LCD_Token(saturationtext,11,1,1);

	Call CCW2;


	// Clear RX_Status flag indicating incoming RX data is audio data and can be processed according 
	ax0=0x0000;
	dm(RX_Status) = ax0;
	
// ----- Go into infinite program loop after initialization... ------
wait_forever:

	idle;						

        // Check if Rotary Encoder 1 was pushed...
        CALL Check_Rotary_Encoder1_Push;

	// Check if Rotary Encoder 1 was turned
	CALL Poll_Rotary_Encoder1;

	// Check if Rotary Encoder 2 was turned	
	CALL Poll_Rotary_Encoder2;

	jump wait_forever;


PUSH1:     
                
        nop;
        RTS;
	
CW1:	AR=dm(cursetting);
	AX1=AR;
	AR=AX1+1;
	AX0=3;
	AY1=AR;
	AR=AX0-AX1;
	//	CNTR=AR;
	IF EQ JUMP nextsetting;
	AR=dm(cursetting);
	AX1=AR;
	AR=AX1+1;
	
nextsetting:
	dm(cursetting)=AR;
	//if AR > 4
	//AR = 0
	AR=AR-0;
	IF EQ JUMP changetodelay;
        AR=AR-1;
	IF EQ JUMP changetodeviation;
	AR=AR-1;
	IF EQ JUMP changetofrequency;
	AR=AR-1;
	IF EQ JUMP changetomix;
	nop;
        RTS;
CCW1:	
	
	nop;
	RTS;

CW2:
       
        RTS;
CCW2:	
	
	nop;
	RTS;

changetodelay:
	Output_LCD_Token(cdelaytext,16,1,0);
	AR=dm(centerDelay);
	dm(tempdigit)=AR;
	call printadigit;
	RTS;
	nop;



changetodeviation:
Output_LCD_Token(devdelaytext,16,1,0);
	AR=dm(centerDeviation);
	dm(tempdigit)=AR;
	call printadigit;
	RTS;
	nop;
changetofrequency:
	Output_LCD_Token(frequencytext,16,1,0);
	AR=dm(frequency);
	dm(tempdigit)=AR;
	call printadigit;
	RTS;
	nop;
changetomix:
	Output_LCD_Token(mixtext,16,1,0);
	AR=dm(mix);
	dm(tempdigit)=AR;
	call printadigit;
	RTS;
	nop;

printadigit:
	AR=dm(tempdigit);
	//tempdigit is the digit
	//AX1=AR;
	AX1=20;
	AR=AR-AX1;
	//	CNTR=AR;
	IF LT JUMP nextdelaydigit10;
	nop;
	dm(tempdigit)=AR;
	Output_LCD_Token(digits+2,1,1,14);
	//tempdigit is subtracted by 20
	nop;
	nop;
	nop;
	jump nextdelaydigit9;

nextdelaydigit10:
	AR=dm(tempdigit);
	//AX1=AR;
	AX1=10;
	AR=AR-AX1;
	//	CNTR=AR;
	IF LT JUMP nextdelaydigit9; 
	nop;
	dm(tempdigit)=AR;
	Output_LCD_Token(digits+1,1,1,14);

	
	nop;
	nop;
nextdelaydigit9:
	AR=dm(tempdigit);
	//AX1=AR;
	AX1=9;
	AR=AR-AX1;
	//	CNTR=AR;
	IF LT JUMP nextdelaydigit8; 
	Output_LCD_Token(digits+9,1,1,15);
	jump enddigit;

nextdelaydigit8:
	AR=dm(tempdigit);
	//AX1=AR;
	AX1=8;
	AR=AR-AX1;
	//	CNTR=AR;
	IF LT JUMP nextdelaydigit7; 
	Output_LCD_Token(digits+8,1,1,15);
	jump enddigit;

nextdelaydigit7:
	AR=dm(tempdigit);
	//AX1=AR;
	AX1=7;
	AR=AR-AX1;
	//	CNTR=AR;
	IF LT JUMP nextdelaydigit6; 
	Output_LCD_Token(digits+7,1,1,15);
	jump enddigit;

nextdelaydigit6:
	AR=dm(tempdigit);
	//AX1=AR;
	AX1=6;
	AR=AR-AX1;
	//	CNTR=AR;
	IF LT JUMP nextdelaydigit5; 
	Output_LCD_Token(digits+6,1,1,15);
	jump enddigit;
nextdelaydigit5:
	AR=dm(tempdigit);
	//AX1=AR;
	AX1=5;
	AR=AR-AX1;
	//	CNTR=AR;
	IF LT JUMP nextdelaydigit4; 
	Output_LCD_Token(digits+5,1,1,15);
	jump enddigit;
nextdelaydigit4:
	AR=dm(tempdigit);
	//AX1=AR;
	AX1=4;
	AR=AR-AX1;
	//	CNTR=AR;
	IF LT JUMP nextdelaydigit3; 
	Output_LCD_Token(digits+4,1,1,15);
	jump enddigit;
nextdelaydigit3:
	AR=dm(tempdigit);
	//AX1=AR;
	AX1=3;
	AR=AR-AX1;
	//	CNTR=AR;
	IF LT JUMP nextdelaydigit2; 
	Output_LCD_Token(digits+3,1,1,15);
	jump enddigit;
nextdelaydigit2:
	AR=dm(tempdigit);
	//AX1=AR;
	AX1=2;
	AR=AR-AX1;
	//	CNTR=AR;
	IF LT JUMP nextdelaydigit1; 
	Output_LCD_Token(digits+2,1,1,15);
	jump enddigit;
nextdelaydigit1:
	AR=dm(tempdigit);
	//AX1=AR;
	AX1=1;
	AR=AR-AX1;
	//	CNTR=AR;
	IF LT JUMP nextdelaydigit0; 
	Output_LCD_Token(digits+1,1,1,15);
	jump enddigit;
nextdelaydigit0:
	Output_LCD_Token(digits,1,1,15);
	jump enddigit;

enddigit:

RTS;
nop;