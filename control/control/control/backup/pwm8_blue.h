//*****************************************************************************
//*****************************************************************************
//  FILENAME: PWM8_BLUE.h
//   Version: 2.5, Updated on 2010/6/8 at 12:37:18
//  Generated by PSoC Designer 5.1.2309
//
//  DESCRIPTION: PWM8 User Module C Language interface file
//-----------------------------------------------------------------------------
//  Copyright (c) Cypress Semiconductor 2010. All Rights Reserved.
//*****************************************************************************
//*****************************************************************************
#ifndef PWM8_BLUE_INCLUDE
#define PWM8_BLUE_INCLUDE

#include <m8c.h>

#pragma fastcall16 PWM8_BLUE_EnableInt
#pragma fastcall16 PWM8_BLUE_DisableInt
#pragma fastcall16 PWM8_BLUE_Start
#pragma fastcall16 PWM8_BLUE_Stop
#pragma fastcall16 PWM8_BLUE_bReadCounter              // Read  DR0
#pragma fastcall16 PWM8_BLUE_WritePeriod               // Write DR1
#pragma fastcall16 PWM8_BLUE_bReadPulseWidth           // Read  DR2
#pragma fastcall16 PWM8_BLUE_WritePulseWidth           // Write DR2

// The following symbols are deprecated.
// They may be omitted in future releases
//
#pragma fastcall16 bPWM8_BLUE_ReadCounter              // Read  DR0 (Deprecated)
#pragma fastcall16 bPWM8_BLUE_ReadPulseWidth           // Read  DR2 (Deprecated)


//-------------------------------------------------
// Prototypes of the PWM8_BLUE API.
//-------------------------------------------------

extern void PWM8_BLUE_EnableInt(void);                        // Proxy Class 1
extern void PWM8_BLUE_DisableInt(void);                       // Proxy Class 1
extern void PWM8_BLUE_Start(void);                            // Proxy Class 1
extern void PWM8_BLUE_Stop(void);                             // Proxy Class 1
extern BYTE PWM8_BLUE_bReadCounter(void);                     // Proxy Class 2
extern void PWM8_BLUE_WritePeriod(BYTE bPeriod);              // Proxy Class 1
extern BYTE PWM8_BLUE_bReadPulseWidth(void);                  // Proxy Class 1
extern void PWM8_BLUE_WritePulseWidth(BYTE bPulseWidth);      // Proxy Class 1

// The following functions are deprecated.
// They may be omitted in future releases
//
extern BYTE bPWM8_BLUE_ReadCounter(void);            // Deprecated
extern BYTE bPWM8_BLUE_ReadPulseWidth(void);         // Deprecated


//--------------------------------------------------
// Constants for PWM8_BLUE API's.
//--------------------------------------------------

#define PWM8_BLUE_CONTROL_REG_START_BIT        ( 0x01 )
#define PWM8_BLUE_INT_REG_ADDR                 ( 0x0e1 )
#define PWM8_BLUE_INT_MASK                     ( 0x04 )


//--------------------------------------------------
// Constants for PWM8_BLUE user defined values
//--------------------------------------------------

#define PWM8_BLUE_PERIOD                       ( 0x00 )
#define PWM8_BLUE_PULSE_WIDTH                  ( 0x00 )


//-------------------------------------------------
// Register Addresses for PWM8_BLUE
//-------------------------------------------------

#pragma ioport  PWM8_BLUE_COUNTER_REG:  0x028              //DR0 Count register
BYTE            PWM8_BLUE_COUNTER_REG;
#pragma ioport  PWM8_BLUE_PERIOD_REG:   0x029              //DR1 Period register
BYTE            PWM8_BLUE_PERIOD_REG;
#pragma ioport  PWM8_BLUE_COMPARE_REG:  0x02a              //DR2 Compare register
BYTE            PWM8_BLUE_COMPARE_REG;
#pragma ioport  PWM8_BLUE_CONTROL_REG:  0x02b              //Control register
BYTE            PWM8_BLUE_CONTROL_REG;
#pragma ioport  PWM8_BLUE_FUNC_REG: 0x128                  //Function register
BYTE            PWM8_BLUE_FUNC_REG;
#pragma ioport  PWM8_BLUE_INPUT_REG:    0x129              //Input register
BYTE            PWM8_BLUE_INPUT_REG;
#pragma ioport  PWM8_BLUE_OUTPUT_REG:   0x12a              //Output register
BYTE            PWM8_BLUE_OUTPUT_REG;
#pragma ioport  PWM8_BLUE_INT_REG:       0x0e1             //Interrupt Mask Register
BYTE            PWM8_BLUE_INT_REG;


//-------------------------------------------------
// PWM8_BLUE Macro 'Functions'
//-------------------------------------------------

#define PWM8_BLUE_Start_M \
   PWM8_BLUE_CONTROL_REG |=  PWM8_BLUE_CONTROL_REG_START_BIT

#define PWM8_BLUE_Stop_M  \
   PWM8_BLUE_CONTROL_REG &= ~PWM8_BLUE_CONTROL_REG_START_BIT

#define PWM8_BLUE_EnableInt_M   \
   M8C_EnableIntMask(PWM8_BLUE_INT_REG, PWM8_BLUE_INT_MASK)

#define PWM8_BLUE_DisableInt_M  \
   M8C_DisableIntMask(PWM8_BLUE_INT_REG, PWM8_BLUE_INT_MASK)

#endif
// end of file PWM8_BLUE.h
