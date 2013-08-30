;;*****************************************************************************
;;*****************************************************************************
;;  FILENAME: PWM8_WHITEINT.asm
;;   Version: 2.5, Updated on 2010/6/8 at 12:37:18
;;  Generated by PSoC Designer 5.1.2309
;;
;;  DESCRIPTION: PWM8 Interrupt Service Routine
;;-----------------------------------------------------------------------------
;;  Copyright (c) Cypress Semiconductor 2010. All Rights Reserved.
;;*****************************************************************************
;;*****************************************************************************

include "m8c.inc"
include "PWM8_WHITE.inc"
include "memory.inc"


;-----------------------------------------------
;  Global Symbols
;-----------------------------------------------
export  _PWM8_WHITE_ISR


AREA InterruptRAM (RAM,REL,CON)

;@PSoC_UserCode_INIT@ (Do not change this line.)
;---------------------------------------------------
; Insert your custom declarations below this banner
;---------------------------------------------------

;------------------------
; Includes
;------------------------

	
;------------------------
;  Constant Definitions
;------------------------


;------------------------
; Variable Allocation
;------------------------


;---------------------------------------------------
; Insert your custom declarations above this banner
;---------------------------------------------------
;@PSoC_UserCode_END@ (Do not change this line.)


AREA UserModules (ROM, REL)

;-----------------------------------------------------------------------------
;  FUNCTION NAME: _PWM8_WHITE_ISR
;
;  DESCRIPTION: Unless modified, this implements only a null handler stub.
;
;-----------------------------------------------------------------------------
;

_PWM8_WHITE_ISR:

   ;@PSoC_UserCode_BODY@ (Do not change this line.)
   ;---------------------------------------------------
   ; Insert your custom code below this banner
   ;---------------------------------------------------
   ;   NOTE: interrupt service routines must preserve
   ;   the values of the A and X CPU registers.

   ;---------------------------------------------------
   ; Insert your custom code above this banner
   ;---------------------------------------------------
   ;@PSoC_UserCode_END@ (Do not change this line.)

   reti


; end of file PWM8_WHITEINT.asm
