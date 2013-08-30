//*****************************************************************************
//*****************************************************************************
//  FILENAME: PWM.h
//   Version: 1.40, Updated on 2011/9/2 at 9:40:1                                          
//  Generated by PSoC Designer 5.1.2309
//
//  DESCRIPTION: PWM User Module C Language interface file
//-----------------------------------------------------------------------------
//  Copyright (c) Cypress Semiconductor 2011. All Rights Reserved.
//*****************************************************************************
//*****************************************************************************
#ifndef PWM_INCLUDE
#define PWM_INCLUDE

#include <m8c.h>


/* Create pragmas to support proper argument and return value passing */
#pragma fastcall16  PWM_Stop
#pragma fastcall16  PWM_Start
#pragma fastcall16  PWM_On
#pragma fastcall16  PWM_Off
#pragma fastcall16  PWM_Switch
#pragma fastcall16  PWM_Invert
#pragma fastcall16  PWM_GetState


//-------------------------------------------------
// Constants for PWM API's.
//-------------------------------------------------
//
#define  PWM_ON   1
#define  PWM_OFF  0

//-------------------------------------------------
// Prototypes of the PWM API.
//-------------------------------------------------
extern void  PWM_Start(void);                                     
extern void  PWM_Stop(void);                                      
extern void  PWM_On(void);                                      
extern void  PWM_Off(void);                                      
extern void  PWM_Switch(BYTE bSwitch);
extern void  PWM_Invert(void);                                         
extern BYTE  PWM_GetState(void);                                         

//-------------------------------------------------
// Define global variables.                 
//-------------------------------------------------



#endif