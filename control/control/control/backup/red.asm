;;*****************************************************************************
;;*****************************************************************************
;;  FILENAME:   RED.asm
;;  Version: 1.3, Updated on 2010/6/8 at 12:37:13
;;  Generated by PSoC Designer 5.4.2946
;;
;;  DESCRIPTION: LED user module.
;;
;;
;;  NOTE: User Module APIs conform to the fastcall16 convention for marshalling
;;        arguments and observe the associated "Registers are volatile" policy.
;;        This means it is the caller's responsibility to preserve any values
;;        in the X and A registers that are still needed after the API functions
;;        returns. For Large Memory Model devices it is also the caller's 
;;        responsibility to perserve any value in the CUR_PP, IDX_PP, MVR_PP and 
;;        MVW_PP registers. Even though some of these registers may not be modified
;;        now, there is no guarantee that will remain the case in future releases.
;;-----------------------------------------------------------------------------
;;  Copyright (c) Cypress Semiconductor 2010. All Rights Reserved.
;;*****************************************************************************
;;*****************************************************************************

include "RED.inc"
include "memory.inc"

export _RED_Start
export  RED_Start

export _RED_Stop
export  RED_Stop

export _RED_On
export  RED_On

export _RED_Off
export  RED_Off

export _RED_Switch
export  RED_Switch

export _RED_Invert
export  RED_Invert

export _RED_GetState
export  RED_GetState


AREA UserModules (ROM, REL)


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: RED_Start(void)
;  FUNCTION NAME: RED_Stop(void)
;
;  FUNCTION NAME: RED_Switch(void)
;
;  DESCRIPTION: ( Switch )
;     Turn LED on or off     
;
;  DESCRIPTION: ( Start, Stop )
;     Turn LED off                       
;
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:  ( Switch )
;     A => If 0, turn off LED, if > 0 turn on LED
;
;  ARGUMENTS:  ( Start, Stop )
;      None
;
;  RETURNS:  none
;
;  SIDE EFFECTS:
;    REGISTERS ARE VOLATILE: THE A AND X REGISTERS MAY BE MODIFIED!
;
;-----------------------------------------------------------------------------
_RED_On:
 RED_On:
   mov  A,0x01
   jmp  RED_Switch 

_RED_Start:
 RED_Start:
_RED_Stop:
 RED_Stop:
_RED_Off:
 RED_Off:
   mov  A,0x00

_RED_Switch:
 RED_Switch:
   RAM_PROLOGUE RAM_USE_CLASS_4
   RAM_PROLOGUE RAM_USE_CLASS_2
   RAM_SETPAGE_CUR >Port_4_Data_SHADE

   or   A,0x00                                   ; Check mode
   jz   .Turn_Off_LED

.Turn_On_LED:
IF(1)                                            ; Active High Digit Drive
   or   [Port_4_Data_SHADE],RED_PinMask
ELSE                                             ; Active Low Digit Drive
   and  [Port_4_Data_SHADE],~RED_PinMask
ENDIF
   jmp  .Switch_LED

.Turn_Off_LED:
IF(1)                      ; Active High Digit Drive
   and  [Port_4_Data_SHADE],~RED_PinMask
ELSE                              ; Active Low Digit Drive
   or   [Port_4_Data_SHADE],RED_PinMask
ENDIF

.Switch_LED:
   mov  A,[Port_4_Data_SHADE]
   mov  reg[RED_PortDR],A

   RAM_EPILOGUE RAM_USE_CLASS_2
   RAM_EPILOGUE RAM_USE_CLASS_4
   ret
.ENDSECTION



.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: RED_Invert(void)
;
;  DESCRIPTION:
;     Invert state of LED                               
;
;-----------------------------------------------------------------------------
;
;  ARGUMENTS: none
;
;  RETURNS:  none
;
;  SIDE EFFECTS:
;    REGISTERS ARE VOLATILE: THE A AND X REGISTERS MAY BE MODIFIED!
;
;-----------------------------------------------------------------------------
_RED_Invert:
 RED_Invert:
   RAM_PROLOGUE RAM_USE_CLASS_4
   RAM_PROLOGUE RAM_USE_CLASS_2
   RAM_SETPAGE_CUR >Port_4_Data_SHADE

   xor  [Port_4_Data_SHADE],RED_PinMask
   mov  A,[Port_4_Data_SHADE]
   mov  reg[RED_PortDR],A

   RAM_EPILOGUE RAM_USE_CLASS_2
   RAM_EPILOGUE RAM_USE_CLASS_4
   ret
.ENDSECTION

.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: RED_GetState(void)
;
;  DESCRIPTION:
;     Get state of LED
;
;-----------------------------------------------------------------------------
;
;  ARGUMENTS: none
;
;  RETURNS:  
;    State of LED   1 = ON,  0 = OFF
;
;  SIDE EFFECTS:
;    REGISTERS ARE VOLATILE: THE A AND X REGISTERS MAY BE MODIFIED!
;
;-----------------------------------------------------------------------------
_RED_GetState:
 RED_GetState:
   RAM_PROLOGUE RAM_USE_CLASS_4
   RAM_PROLOGUE RAM_USE_CLASS_2
   RAM_SETPAGE_CUR >Port_4_Data_SHADE

   mov   A,[Port_4_Data_SHADE]         ; Get shade value
IF(1)                                  ; Active High Digit Drive
   // Nothing for now
ELSE                                   ; Active Low Digit Drive
   cpl   A                             ; Invert bit if Active low
ENDIF
   and   A,RED_PinMask                 ; Mask off the trash
   jz    .End_LED_GS                   ; If zero, we're done
   mov   A,0x01                        ; Return a 1 no mater what the mask is.

.End_LED_GS:
   RAM_EPILOGUE RAM_USE_CLASS_2
   RAM_EPILOGUE RAM_USE_CLASS_4
   ret
.ENDSECTION
