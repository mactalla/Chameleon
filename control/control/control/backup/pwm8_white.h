//*****************************************************************************
//*****************************************************************************
//  FILENAME: PWM8_WHITE.h
//   Version: 2.5, Updated on 2010/6/8 at 12:37:18
//  Generated by PSoC Designer 5.1.2309
//
//  DESCRIPTION: PWM8 User Module C Language interface file
//-----------------------------------------------------------------------------
//  Copyright (c) Cypress Semiconductor 2010. All Rights Reserved.
//*****************************************************************************
//*****************************************************************************
#ifndef PWM8_WHITE_INCLUDE
#define PWM8_WHITE_INCLUDE

#include <m8c.h>

#pragma fastcall16 PWM8_WHITE_EnableInt
#pragma fastcall16 PWM8_WHITE_DisableInt
#pragma fastcall16 PWM8_WHITE_Start
#pragma fastcall16 PWM8_WHITE_Stop
#pragma fastcall16 PWM8_WHITE_bReadCounter              // Read  DR0
#pragma fastcall16 PWM8_WHITE_WritePeriod               // Write DR1
#pragma fastcall16 PWM8_WHITE_bReadPulseWidth           // Read  DR2
#pragma fastcall16 PWM8_WHITE_WritePulseWidth           // Write DR2

// The following symbols are deprecated.
// They may be omitted in future releases
//
#pragma fastcall16 bPWM8_WHITE_ReadCounter              // Read  DR0 (Deprecated)
#pragma fastcall16 bPWM8_WHITE_ReadPulseWidth           // Read  DR2 (Deprecated)


//-------------------------------------------------
// Prototypes of the PWM8_WHITE API.
//-------------------------------------------------

extern void PWM8_WHITE_EnableInt(void);                        // Proxy Class 1
extern void PWM8_WHITE_DisableInt(void);                       // Proxy Class 1
extern void PWM8_WHITE_Start(void);                            // Proxy Class 1
extern void PWM8_WHITE_Stop(void);                             // Proxy Class 1
extern BYTE PWM8_WHITE_bReadCounter(void);                     // Proxy Class 2
extern void PWM8_WHITE_WritePeriod(BYTE bPeriod);              // Proxy Class 1
extern BYTE PWM8_WHITE_bReadPulseWidth(void);                  // Proxy Class 1
extern void PWM8_WHITE_WritePulseWidth(BYTE bPulseWidth);      // Proxy Class 1

// The following functions are deprecated.
// They may be omitted in future releases
//
extern BYTE bPWM8_WHITE_ReadCounter(void);            // Deprecated
extern BYTE bPWM8_WHITE_ReadPulseWidth(void);         // Deprecated


//--------------------------------------------------
// Constants for PWM8_WHITE API's.
//--------------------------------------------------

#define PWM8_WHITE_CONTROL_REG_START_BIT       ( 0x01 )
#define PWM8_WHITE_INT_REG_ADDR                ( 0x0e1 )
#define PWM8_WHITE_INT_MASK                    ( 0x08 )


//--------------------------------------------------
// Constants for PWM8_WHITE user defined values
//--------------------------------------------------

#define PWM8_WHITE_PERIOD                      ( 0x00 )
#define PWM8_WHITE_PULSE_WIDTH                 ( 0x00 )


//-------------------------------------------------
// Register Addresses for PWM8_WHITE
//-------------------------------------------------

#pragma ioport  PWM8_WHITE_COUNTER_REG: 0x02c              //DR0 Count register
BYTE            PWM8_WHITE_COUNTER_REG;
#pragma ioport  PWM8_WHITE_PERIOD_REG:  0x02d              //DR1 Period register
BYTE            PWM8_WHITE_PERIOD_REG;
#pragma ioport  PWM8_WHITE_COMPARE_REG: 0x02e              //DR2 Compare register
BYTE            PWM8_WHITE_COMPARE_REG;
#pragma ioport  PWM8_WHITE_CONTROL_REG: 0x02f              //Control register
BYTE            PWM8_WHITE_CONTROL_REG;
#pragma ioport  PWM8_WHITE_FUNC_REG:    0x12c              //Function register
BYTE            PWM8_WHITE_FUNC_REG;
#pragma ioport  PWM8_WHITE_INPUT_REG:   0x12d              //Input register
BYTE            PWM8_WHITE_INPUT_REG;
#pragma ioport  PWM8_WHITE_OUTPUT_REG:  0x12e              //Output register
BYTE            PWM8_WHITE_OUTPUT_REG;
#pragma ioport  PWM8_WHITE_INT_REG:       0x0e1            //Interrupt Mask Register
BYTE            PWM8_WHITE_INT_REG;


//-------------------------------------------------
// PWM8_WHITE Macro 'Functions'
//-------------------------------------------------

#define PWM8_WHITE_Start_M \
   PWM8_WHITE_CONTROL_REG |=  PWM8_WHITE_CONTROL_REG_START_BIT

#define PWM8_WHITE_Stop_M  \
   PWM8_WHITE_CONTROL_REG &= ~PWM8_WHITE_CONTROL_REG_START_BIT

#define PWM8_WHITE_EnableInt_M   \
   M8C_EnableIntMask(PWM8_WHITE_INT_REG, PWM8_WHITE_INT_MASK)

#define PWM8_WHITE_DisableInt_M  \
   M8C_DisableIntMask(PWM8_WHITE_INT_REG, PWM8_WHITE_INT_MASK)

#endif
// end of file PWM8_WHITE.h
