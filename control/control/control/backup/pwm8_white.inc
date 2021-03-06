;;*****************************************************************************
;;*****************************************************************************
;;  FILENAME: PWM8_WHITE.inc
;;   Version: 2.5, Updated on 2010/6/8 at 12:37:18
;;  Generated by PSoC Designer 5.1.2309
;;
;;  DESCRIPTION: Assembler declarations for the PWM8 user module interface
;;-----------------------------------------------------------------------------
;;  Copyright (c) Cypress Semiconductor 2010. All Rights Reserved.
;;*****************************************************************************
;;*****************************************************************************

include "m8c.inc"


;--------------------------------------------------
; Constants for PWM8_WHITE API's.
;--------------------------------------------------

PWM8_WHITE_CONTROL_REG_START_BIT:          equ 0x01    ; Control register start bit
PWM8_WHITE_INT_REG:                        equ 0x0e1
PWM8_WHITE_INT_MASK:                       equ 0x08


;--------------------------------------------------
; Constants for PWM8_WHITE user defined values
;--------------------------------------------------

PWM8_WHITE_PERIOD:                         equ 0x00
PWM8_WHITE_PULSE_WIDTH:                    equ 0x00


;--------------------------------------------------
; Register Address Constants for PWM8_WHITE
;--------------------------------------------------

PWM8_WHITE_COUNTER_REG:                equ 0x2c   ; DR0 Count register
PWM8_WHITE_PERIOD_REG:                 equ 0x2d   ; DR1 Period register
PWM8_WHITE_COMPARE_REG:                equ 0x2e   ; DR2 Compare register
PWM8_WHITE_CONTROL_REG:                equ 0x2f   ; Control register
PWM8_WHITE_FUNC_REG:                   equ 0x2c   ; Function register
PWM8_WHITE_INPUT_REG:                  equ 0x2d   ; Input register
PWM8_WHITE_OUTPUT_REG:                 equ 0x2e   ; Output register


;--------------------------------------------------
; PWM8_WHITE Macro 'Functions'
;--------------------------------------------------

   macro PWM8_WHITE_Start_M
   or    reg[PWM8_WHITE_CONTROL_REG],  PWM8_WHITE_CONTROL_REG_START_BIT
   endm

   macro PWM8_WHITE_Stop_M
   and   reg[PWM8_WHITE_CONTROL_REG], ~PWM8_WHITE_CONTROL_REG_START_BIT
   endm

   macro PWM8_WHITE_EnableInt_M
   M8C_EnableIntMask PWM8_WHITE_INT_REG, PWM8_WHITE_INT_MASK
   endm

   macro PWM8_WHITE_DisableInt_M
   M8C_DisableIntMask PWM8_WHITE_INT_REG, PWM8_WHITE_INT_MASK
   endm


; end of file PWM8_WHITE.inc
