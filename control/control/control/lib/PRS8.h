//*****************************************************************************
//*****************************************************************************
//  FILENAME: PRS8.h
//   Version: 3.4, Updated on 2013/5/19 at 10:44:3
//  Generated by PSoC Designer 5.4.2946
//
//  DESCRIPTION: PRS8 User Module C Language interface file.
//-----------------------------------------------------------------------------
//  Copyright (c) Cypress Semiconductor 2013. All Rights Reserved.
//*****************************************************************************
//*****************************************************************************
#ifndef PRS8_INCLUDE
#define PRS8_INCLUDE

#include <m8c.h>

#pragma fastcall16  PRS8_Start
#pragma fastcall16  PRS8_Stop
#pragma fastcall16  PRS8_WriteSeed
#pragma fastcall16  PRS8_WritePolynomial
#pragma fastcall16  PRS8_bReadPRS

//-------------------------------------------------
// Prototypes of the PRS8 API.
//-------------------------------------------------
extern void  PRS8_Start(void);
extern void  PRS8_Stop(void);
extern void  PRS8_WriteSeed(BYTE bSeed);
extern void  PRS8_WritePolynomial(BYTE bPolynomial);
extern BYTE  PRS8_bReadPRS(void);

//-------------------------------------------------
// Do not use! For backwards compatibility only.
#pragma fastcall16 bPRS8_ReadPRS
extern BYTE bPRS8_ReadPRS(void);
//-------------------------------------------------

//-------------------------------------------------
// Register Addresses for PRS8
//-------------------------------------------------
#pragma ioport  PRS8_CONTROL_REG:   0x027                  //Control register LSB
BYTE            PRS8_CONTROL_REG;
#pragma ioport  PRS8_SHIFT_REG: 0x024                      //Shift register LSB
BYTE            PRS8_SHIFT_REG;
#pragma ioport  PRS8_POLY_REG:  0x025                      //Polynomial register LSB
BYTE            PRS8_POLY_REG;
#pragma ioport  PRS8_SEED_REG:  0x026                      //Seed register LSB
BYTE            PRS8_SEED_REG;
#pragma ioport  PRS8_FUNC_REG:  0x124                      //Function register LSB
BYTE            PRS8_FUNC_REG;
#pragma ioport  PRS8_INPUT_REG: 0x125                      //Input register LSB
BYTE            PRS8_INPUT_REG;
#pragma ioport  PRS8_OUTPUT_REG:    0x126                  //Output register LSB
BYTE            PRS8_OUTPUT_REG;

#endif
// end of file PRS8.h
