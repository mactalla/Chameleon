;@Id: boot.tpl#890 @
;=============================================================================
;  FILENAME:   boot.asm
;  VERSION:    BootLdrUSB_v1_1
;  DATE:       11 feb 2008
;
;  DESCRIPTION:
;  M8C Boot Code for CY8C24x90 microcontroller devices.
;
;  Copyright (c) Cypress Semiconductor 2010. All Rights Reserved.
;
; NOTES:
; PSoC Designer's Device Editor uses a template file, BOOT.TPL, located in
; the project's root directory to create BOOT.ASM. Any changes made to
; BOOT.ASM will be  overwritten every time the project is generated; therefore
; changes should be made to BOOT.TPL not BOOT.ASM. Care must be taken when
; modifying BOOT.TPL so that replacement strings (such as @PROJECT_NAME)
; are not accidentally modified.
;
;=============================================================================

include ".\lib\GlobalParams.inc"
include ".\lib\PSoCapi.inc"
include "m8c.inc"
include "m8ssc.inc"
include "memory.inc"

;--------------------------------------
; Export Declarations
;--------------------------------------

export __Start
export __StartApp
IF	(TOOLCHAIN & HITECH)
ELSE
export __bss_start
export __data_start
export __idata_start
export __func_lit_start
export __text_start
ENDIF
export  _bGetPowerSetting
export   bGetPowerSetting


;--------------------------------------
; Optimization flags
;--------------------------------------
;
; To change the value of these flags, modify the file boot.tpl, not
; boot.asm. See the notes in the banner comment at the beginning of
; this file.

; Optimization for Assembly language (only) projects and C-language projects
; that do not depend on the C compiler to initialize the values of RAM variables.
;   Set to 1: Support for C Run-time Environment initialization
;   Set to 0: Support for C not included. Faster start up, smaller code space.
;
IF	(TOOLCHAIN & HITECH)
; The C compiler will customize the startup code - it's not required here

C_LANGUAGE_SUPPORT:              equ 0
ELSE
C_LANGUAGE_SUPPORT:              equ 1
ENDIF


; For historical reasons, by default the boot code uses an lcall instruction
; to invoke the user's _main code. If _main executes a return instruction,
; boot provides an infinite loop. By changing the following equate from zero
; to 1, boot's lcall will be replaced by a ljmp instruction, saving two
; bytes on the stack which are otherwise required for the return address. If
; this option is enabled, _main must not return. (Beginning with the 4.2
; release, the C compiler automatically places an infinite loop at the end
; of main, rather than a return instruction.)
;
ENABLE_LJMP_TO_MAIN:             equ 0


;-----------------------------------------------------------------------------
; Interrupt Vector Table
;-----------------------------------------------------------------------------
;
; Interrupt vector table entries are 4 bytes long.  Each one contains
; a jump instruction to an ISR (Interrupt Service Routine), although
; very short ISRs could be encoded within the table itself. Normally,
; vector jump targets are modified automatically according to the user
; modules selected. This occurs when the 'Generate Application' opera-
; tion is run causing PSoC Designer to create boot.asm and the other
; configuration files. If you need to hard code a vector, update the
; file boot.tpl, not boot.asm. See the banner comment at the beginning
; of this file.
;-----------------------------------------------------------------------------


    AREA TOP (ROM, ABS, CON)

  ;********************************************************************;
 ;*** Blocks 0 and 1 0000h through 007F Write-Protected Jump table ***;
;********************************************************************;

	org   0                        ;Reset Interrupt Vector
IF	(TOOLCHAIN & HITECH)
    ;ljmp bootLoaderVerify		   ;First instruction executed following a Reset  	  ;<-???Note I'm not jumping to a location "__Start"
	                                                                                  ;<-???Function bootLoaderVerify is a checksum routine
																					  ;<-???that will determine the validity of the application
ELSE
    ljmp __Start
    ;ljmp bootLoaderVerify		   ;First instruction executed following a Reset  
ENDIF

    org   04h                      ;Supply Monitor Interrupt Vector
    ljmp INT_VEC1

    org   08h                      ;Analog Column 0 Interrupt Vector
	ljmp INT_VEC2

    org   0Ch                      ;Analog Column 1 Interrupt Vector
	ljmp INT_VEC3

    org   18h                      ;VC3 Interrupt Vector
	ljmp INT_VEC6
    
    org   1Ch                      ;GPIO Interrupt Vector
    ljmp INT_VEC7

    org   20h                      ;PSoC Block DBB00 Interrupt Vector
    ljmp INT_VEC8

    org   24h                      ;PSoC Block DBB01 Interrupt Vector
    ljmp INT_VEC9
    
    org   28h                      ;PSoC Block DCB02 Interrupt Vector
    ljmp INT_VEC10
    
    org   2Ch                      ;PSoC Block DCB03 Interrupt Vector
    ljmp  INT_VEC11
    
    org   40h                      ;USB Reset Interrupt Vector
    ljmp bootResetIsr
    ;ljmp INT_VEC16

    org   44h                      ;USB SOF Interrupt Vector
    ljmp bootSofIsr
    ;ljmp INT_VEC17

    org   48h                      ;USB EP0 Interrupt Vector
    ljmp bootEp0Isr
    ;ljmp INT_VEC18

    org   4Ch                      ;USB EP1 Interrupt Vector
    ljmp bootEp1Isr
    ;ljmp INT_VEC19

    org   50h                      ;USB EP2 Interrupt Vector
    ljmp bootEp2Isr
    ;ljmp INT_VEC20

    org   54h                      ;USB EP3 Interrupt Vector
    ljmp bootEp3Isr
    ;ljmp INT_VEC21

    org   58h                      ;USB EP4 Interrupt Vector
    ljmp bootEp4Isr
    ;ljmp INT_VEC22

    org   5Ch                      ;USB Wakeup Interrupt Vector
    ljmp bootWakeupIsr
    ;ljmp INT_VEC23

    org   60h                      ;PSoC I2C Interrupt Vector
    ljmp INT_VEC24				   ;Bootloader I2C

    org   64h                      ;Sleep Timer Interrupt Vector
	ljmp INT_VEC25

;;
;;  reserve the last 12 bytes of the interrupt vector table for a generic bootloader entry point.  An app can always use
;;  this address to dereference the real address of the bootloader start address.  Bootloader will not return other than
;;  via a device reset.
;;
;;
;;  org 74h Actually defined in flashapi.asm (reserved)
;;	ljmp bFlashWriteBlock_internal
;;
;;	org 78h	Actually defined in flashapi.asm (reserved)
;;	ljmp FlashReadBlock_internal
;;
;;
 	org 7Ch
	;;provide a completely generic label that is exported to start the bootloader.
	_ENTER_BOOTLOADER::
	 ENTER_BOOTLOADER::
	ljmp GenericBootloaderEntry
    halt                           ;DO NOT plan on returning here
    
        
;*******************************************************;
;*** Blocks X and X+1  Writable Boot table ***;
;*******************************************************;

;**********************************************;
;*** Block 2 to 223 080h to 37FFh Writable  ***;
;**********************************************;

area reloc_vecs  (ROM, ABS, CON)	  ;<-??????? This are represents a two blocks of code that could be placed anywhere
                                      ;<-??????? The interrupt vectors assisigned above will jump to these locations to 
									  ;<-??????? be "redirected"	  It's possible that I can just leave this alone if the 
									  ;<-??????? org statements work correctly.


RELOC_INT_VECTORS: equ IntVectorAddr
org RELOC_INT_VECTORS
nop
nop
nop
nop

INT_VEC1: equ   (RELOC_INT_VECTORS + 4h)					  ;Supply Monitor Interrupt Vector
INT_VEC2: equ   (RELOC_INT_VECTORS + 8h)                      ;Analog Column 0 Interrupt Vector
INT_VEC3: equ   (RELOC_INT_VECTORS + Ch)                      ;Analog Column 1 Interrupt Vector
INT_VEC6: equ   (RELOC_INT_VECTORS + 10h)                     ;VC3 Interrupt Vector
INT_VEC7: equ   (RELOC_INT_VECTORS +  1Ch)                     ;GPIO Interrupt Vector
INT_VEC8: equ   (RELOC_INT_VECTORS + 20h)                     ;PSoC Block DBB00 Interrupt Vector
INT_VEC9: equ   (RELOC_INT_VECTORS + 24h)                     ;PSoC Block DBB01 Interrupt Vector
INT_VEC10: equ  (RELOC_INT_VECTORS + 28h)                      ;PSoC Block DCB02 Interrupt Vector
INT_VEC11: equ  (RELOC_INT_VECTORS + 2Ch)                      ;PSoC Block DCB03 Interrupt Vector
INT_VEC16: equ  (RELOC_INT_VECTORS + 40h)                      ;USB Reset Interrupt Vector
INT_VEC17: equ  (RELOC_INT_VECTORS + 44h)                      ;USB SOF Interrupt Vector
INT_VEC18: equ  (RELOC_INT_VECTORS + 48h)                      ;USB EP0 Interrupt Vector
INT_VEC19: equ  (RELOC_INT_VECTORS + 4Ch)                      ;USB EP1 Interrupt Vector
INT_VEC20: equ  (RELOC_INT_VECTORS + 50h)                      ;USB EP2 Interrupt Vector
INT_VEC21: equ  (RELOC_INT_VECTORS + 54h)                      ;USB EP3 Interrupt Vector
INT_VEC22: equ  (RELOC_INT_VECTORS + 58h)                      ;USB EP4 Interrupt Vector
INT_VEC23: equ  (RELOC_INT_VECTORS + 5Ch)                      ;USB Wakeup Interrupt Vector
INT_VEC24: equ  (RELOC_INT_VECTORS + 60h)                      ;PSoC I2C Interrupt Vector
INT_VEC25: equ  (RELOC_INT_VECTORS + 64h)                      ;Sleep Timer Interrupt Vector



;;INT_VEC1: equ  RELOC_INT_VECTORS + 4h                      ;Supply Monitor Interrupt Vector
    org INT_VEC1											 ;default definition is a halt
	;
	;remove the halt instruction (below) to be vectored to the interrupt specified below
	;
	halt   
    ;`@INTERRUPT_1`
    reti

    	
;;INT_VEC2: equ  RELOC_INT_VECTORS + 8h                      ;Analog Column 0 Interrupt Vector
    org INT_VEC2
    `@INTERRUPT_2`
    reti

;;INT_VEC3: equ  RELOC_INT_VECTORS + Ch                      ;Analog Column 1 Interrupt Vector
    org INT_VEC3
    `@INTERRUPT_3`
    reti

;;INT_VEC6: equ  RELOC_INT_VECTORS + 10h                      ;VC3 Interrupt Vector
    org INT_VEC6
    `@INTERRUPT_6`
    reti
	
;;INT_VEC7: equ  RELOC_INT_VECTORS +  1ch                      ;GPIO Interrupt Vector
    org INT_VEC7
    `@INTERRUPT_7`
    reti

;;INT_VEC8: equ  RELOC_INT_VECTORS + 20h                      ;PSoC Block DBB00 Interrupt Vector
    org INT_VEC8
    `@INTERRUPT_8`
    reti

;;INT_VEC9: equ  RELOC_INT_VECTORS + 24h                      ;PSoC Block DBB01 Interrupt Vector
    org INT_VEC9
    `@INTERRUPT_9`
    reti

;;INT_VEC10: equ  RELOC_INT_VECTORS + 28h                      ;PSoC Block DCB02 Interrupt Vector
    org INT_VEC10
    `@INTERRUPT_10`
    reti

;;INT_VEC11: equ  RELOC_INT_VECTORS + 2Ch                      ;PSoC Block DCB03 Interrupt Vector
    org INT_VEC11
    `@INTERRUPT_11`
    reti

;;INT_VEC16: equ  RELOC_INT_VECTORS + 40h                      ;USB Reset Interrupt Vector
    org INT_VEC16
export USB_RESET_USER_ISR_VECTOR
USB_RESET_USER_ISR_VECTOR:
    `@INTERRUPT_16`
    reti

;;INT_VEC17: equ  RELOC_INT_VECTORS + 44h                      ;USB SOF Interrupt Vector
    org INT_VEC17
export USB_SOF_USER_ISR_VECTOR
USB_SOF_USER_ISR_VECTOR:
    `@INTERRUPT_17`
    reti

;;INT_VEC18: equ  RELOC_INT_VECTORS + 48h                      ;USB EP0 Interrupt Vector
    org INT_VEC18
export USB_ENDPT0_USER_ISR_VECTOR
USB_ENDPT0_USER_ISR_VECTOR:
    `@INTERRUPT_18`
    reti

;;INT_VEC19: equ  RELOC_INT_VECTORS + 4Ch                      ;USB EP1 Interrupt Vector
    org INT_VEC19
export USB_ENDPT1_USER_ISR_VECTOR
USB_ENDPT1_USER_ISR_VECTOR:
    `@INTERRUPT_19`
    reti

;;INT_VEC20: equ  RELOC_INT_VECTORS + 50h                      ;USB EP2 Interrupt Vector
    org INT_VEC20
export USB_ENDPT2_USER_ISR_VECTOR
USB_ENDPT2_USER_ISR_VECTOR:
    `@INTERRUPT_20`
    reti

;;INT_VEC21: equ  RELOC_INT_VECTORS + 54h                      ;USB EP3 Interrupt Vector
    org INT_VEC21
export USB_ENDPT3_USER_ISR_VECTOR
USB_ENDPT3_USER_ISR_VECTOR:
    `@INTERRUPT_21`
    reti

;;INT_VEC22: equ  RELOC_INT_VECTORS + 58h                      ;USB EP4 Interrupt Vector
    org INT_VEC22
export USB_ENDPT4_USER_ISR_VECTOR
USB_ENDPT4_USER_ISR_VECTOR:
    `@INTERRUPT_22`
    reti

;;INT_VEC23: equ  RELOC_INT_VECTORS + 5Ch                      ;USB Wakeup Interrupt Vector
    org INT_VEC23
export USB_WAKEUP_USER_ISR_VECTOR
USB_WAKEUP_USER_ISR_VECTOR:
    `@INTERRUPT_23`
    reti

;;INT_VEC24: equ  RELOC_INT_VECTORS + 60h                      ;PSoC I2C Interrupt Vector
    org INT_VEC24
    `@INTERRUPT_24`
    ;reti

;;INT_VEC25: equ  RELOC_INT_VECTORS + 64h                      ;Sleep Timer Interrupt Vector
    org INT_VEC25
	`@INTERRUPT_25`
    reti

;;
;; Add fixed jumop vectors so that a bootloader and an application that are both built with these blocks in the
;; at the same location will be able to work together.
;;

GENERIC_VEC26: equ  (RELOC_INT_VECTORS + 68h)                      ;Generic Entry Vector
    org GENERIC_VEC26

ret

GENERIC_VEC27: equ  (RELOC_INT_VECTORS + 6ch)                      ;Generic Entry Vector
    org GENERIC_VEC27

ret
 
GENERIC_VEC28: equ  (RELOC_INT_VECTORS + 70h)                      ;Generic Entry Vector
    org GENERIC_VEC28
    export Global_String_Table_Location
    Global_String_Table_Location: 
	DW GLOBAL_USB_StringTable

ret


GENERIC_VEC29:                      equ  (RELOC_INT_VECTORS + 74h)                      ;Generic Entry Vector
    org GENERIC_VEC29
    export Global_Device_Descr_Table_Location
    Global_Device_Descr_Table_Location: 
	DW GLOBAL_APP_DEVICE_DESCR_TABLE

ret

GENERIC_VEC30:                       equ  (RELOC_INT_VECTORS + 78h)                      ;Generic Entry Vector
    org GENERIC_VEC30
    export Global_Device_Table_Lookup_Location
    Global_Device_Table_Lookup_Location: 
	DW  GLOBAL_APP_DEVICE_LOOKUP

ret

GENERIC_VEC31: equ  (RELOC_INT_VECTORS + 7ch)                      ;Last Generic Entry in Block reserved for 
    org GENERIC_VEC31											   ;application __Start vector redirection
    export  GenericApplicationStart
	export _GenericApplicationStart
 GenericApplicationStart:
_GenericApplicationStart:
	ljmp __StartApp												   ;--a bootloader can always call this absolute address
															   ;  and get to the user app entry point 
																   ;  that was created with this vector table 
ret

 
  
;**********************************************;
;*** Block 2 to 223 080h to 37FFh Writable  ***;
;**********************************************;

IF	(TOOLCHAIN & HITECH)						
AREA PD_startup(CODE, REL, CON)	 ;this Hi-Tech psect will be placed within the bounds of the bootloader
ELSE
    ;---------------------------------
    ; Order Critical RAM & ROM AREAs
	; See another set of area definitions at the bottom of this file
    ;---------------------------------
    ;  'TOP' is all that has been defined so far...

    ;  ROM AREAs for C CONST, static & global items
    ;
    ;;Area Lit always has to be first
    AREA lit               (ROM, REL, CON)   ; 'const' definitions 
    AREA Bootloader        (ROM, REL, CON)
	AREA UserApp		   (ROM, REL, CON)
foo::


    AREA idata             (ROM, REL, CON)   ; Constants for initializing RAM
__idata_start:

    AREA func_lit          (ROM, REL, CON)   ; Function Pointers
__func_lit_start:

IF ( SYSTEM_LARGE_MEMORY_MODEL )
    ; We use the func_lit area to store a pointer to extended initialized
    ; data (xidata) area that follows the text area. Func_lit isn't
    ; relocated by the code compressor, but the text area may shrink and
    ; that moves xidata around.
    ;
__pXIData:         word __text_end           ; ptr to extended idata
ENDIF

    AREA psoc_config       (ROM, REL, CON)   ; Configuration Load & Unload
    AREA UserModules       (ROM, REL, CON)   ; User Module APIs

    ; Critical intial start up code must in in the Bootloader ara
    ;
    AREA Bootloader (ROM, REL, CON)

ENDIF ; TOOLCHAIN


_START_USER_CODE::      
__Start:
    M8C_SetBank1
    mov reg[0FAh], 0  ;set the page register for supervisory ops to 0
    M8C_SetBank0
	

;;;	;set up a default stack
;;;	; Enables paging and set zero
;;;	and f, 0x00
;;;	or f, (FLAG_PGMODE_2 | FLAG_ZERO)
;;;	;default stack page is 3
;;;	mov reg[STK_PP], 3
;;;	If this gets changed 

    ljmp bootLoaderVerify		   ;First instruction executed following a Reset  

IF	(TOOLCHAIN & HITECH)						;<- ??? I rearrange the order of the areas to make them work better 
psect init                                      ;<- ??? (by default) for the bootloader (I still need to control 
ELSE
    ; CODE segment for general use
	;
    ; Any areas defined as will be pushed into the UserApp area defined 
    ;above by setting the relocatable code start address

    AREA text (ROM, REL, CON)
__text_start:
ENDIF ;TOOLCHAIN

__StartApp:		;this is the vector that will start the user application
M8C_ClearWDTAndSleep
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Clear out all memory for consistancy
;;
;; This __Start function has to be re-entrant because of BootLoader and Watchdog
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
;
M8C_DisableGInt
M8C_SetBank0
;
; Disable and Clear all interrupts
;
mov reg[INT_MSK3], 0x00 ; Must set first because of SoftWare Interrupt capability
mov reg[INT_MSK2], 0x00 ; Disables the hardware's ability to generate an interrupt
mov reg[INT_MSK1], 0x00 ;
mov reg[INT_MSK0], 0x00 ;
;
mov reg[INT_CLR3], 0x00 ; Clears any pending interrups
mov reg[INT_CLR2], 0x00 ;
mov reg[INT_CLR1], 0x00 ;
mov reg[INT_CLR0], 0x00 ;
;
; Enables paging and set zero
and f, 0x00
or f, (FLAG_PGMODE_2 | FLAG_ZERO)
;
mov reg[CUR_PP], 0
mov reg[IDX_PP], 0
mov reg[MVR_PP], 0
mov reg[MVW_PP], 0
mov reg[STK_PP], 0
;    
mov A, 4						; Clear all 4 pages (0 - 3)
clear_memory_1_page_at_a_time:
	dec A
 	mov reg[IDX_PP], A
 	
    mov X, 0   					; Clear 1 thru 255 then clear 0 
	clear_memory_loop:
    	inc X
    	mov [X], 0
    jnz clear_memory_loop
	
	cmp A, 0
	M8C_ClearWDTAndSleep
jnz clear_memory_1_page_at_a_time
;
; Disable paging
and f, FLAG_ZERO

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Clear out all memory for consistancy
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   

    ; initialize values for voltage stabilization, if required,
    ; leaving power-on reset (POR) level at the default (low) level, at
    ; least for now. 
    ;
    M8C_SetBank1
    mov   reg[VLT_CR], LVD_TBEN_JUST | TRIP_VOLTAGE_JUST
    M8C_SetBank0

IF ( WATCHDOG_ENABLE )             ; WDT selected in Global Params
    M8C_EnableWatchDog
ENDIF
;
;;
; make sure the USB SIE is OFF
    mov  reg[USB_CR0], 0
    mov  reg[USBIO_CR1], 0
    
    and  reg[CPU_SCR1], ~CPU_SCR1_ECO_ALLOWED  ; Prevent ECO from being enabled

    ;---------------------------
    ; Set up the Temporary stack
    ;---------------------------
    ; A temporary stack is set up for the SSC instructions.
    ; The real stack start will be assigned later.
    ;
_stack_start:          equ 80h
    mov   A, _stack_start          ; Set top of stack to end of used RAM
    swap  SP, A                    ; This is only temporary if going to LMM

    ;------------------------
    ; Set Power-related Trim 
    ;------------------------

M8C_ClearWDTAndSleep
IF ( POWER_SETTING & POWER_SET_5V0)            ; *** 5.0 Volt operation   ***
  IF ( AGND_BYPASS )
    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    ; The 5V trim has already been set, but we need to update the AGNDBYP
    ; bit in the write-only BDG_TR register. Recalculate the register
    ; value using the proper trim values.
    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    M8SSC_SetTableVoltageTrim 1, SSCTBL1_TRIM_BGR_5V, AGND_BYPASS_JUST
  ENDIF
ELSE
    M8SSC_SetTableTrims  1, SSCTBL1_TRIM_IMO_3V_24MHZ, SSCTBL1_TRIM_BGR_3V, AGN_BYPASS_JUST
    mov   [bSSC_TABLE_TableId], 2          ; Point to requested Flash Table
    SSC_Action TABLE_READ                  ; Perform a table read supervisor call
    M8C_SetBank1
    mov   A, [0xfa]                        ; acquire the IMO_TR2 value programmed at test
    jz    .NoTrimValSet                    ; version AA parts may not have a trim set here DONT USE 00h
    mov   reg[0xef], A                     ; store the trim setting for 3V
.NoTrimValSet:
    M8C_SetBank0

ENDIF ; 3.3 Volt Operation

    mov  [bSSC_KEY1],  0           ; Lock out Flash and Supervisiory operations
    mov  [bSSC_KEYSP], 0

    ;---------------------------------------
    ; Initialize Crystal Oscillator and PLL
    ;---------------------------------------

    ; Either no ECO, or waiting for stable clock is to be done in main
    M8C_SetBank1
    mov   reg[OSC_CR0], (SLEEP_TIMER_JUST | OSC_CR0_CPU_12MHz)
    M8C_SetBank0
    M8C_ClearWDTAndSleep           ; Reset the watch dog

	;-------------------------------------------------------
    ; Initialize Proper Drive Mode for External Clock Pin
    ;-------------------------------------------------------

    ; Change EXTCLK pin from Hi-Z Analog (110b) drive mode to Hi-Z (010b) drive mode
IF (SYSCLK_SOURCE)
    and reg[PRT1DM2],  ~0x10        ; Clear bit 4 of EXTCLK pin's DM2 register 
ENDIF
    ; EXTCLK pin is now in proper drive mode to input the external clock signal

IF	(TOOLCHAIN & HITECH)
    ;---------------------------------------------
    ; HI-TECH initialization: Enter the Large Memory Model, if applicable
    ;---------------------------------------------
	global		__Lstackps
	mov     a,low __Lstackps
	swap    a,sp

IF ( SYSTEM_LARGE_MEMORY_MODEL )
    RAM_SETPAGE_STK SYSTEM_STACK_PAGE      ; relocate stack page ...
    RAM_SETPAGE_IDX2STK            ; initialize other page pointers
    RAM_SETPAGE_CUR 0
    RAM_SETPAGE_MVW 0
    RAM_SETPAGE_MVR 0
    or    F, FLAG_PGMODE_10b       ; LMM w/ independent IndexPage
ENDIF ;  SYSTEM_LARGE_MEMORY_MODEL
ELSE
    ;---------------------------------------------
    ; ImageCraft Enter the Large Memory Model, if applicable
    ;---------------------------------------------
IF ( SYSTEM_LARGE_MEMORY_MODEL )
    RAM_SETPAGE_STK SYSTEM_STACK_PAGE      ; relocate stack page ...
    mov   A, SYSTEM_STACK_BASE_ADDR        ;   and offset, if any
    swap  A, SP
    RAM_SETPAGE_IDX2STK            ; initialize other page pointers
    RAM_SETPAGE_CUR 0
    RAM_SETPAGE_MVW 0
    RAM_SETPAGE_MVR 0

  IF ( SYSTEM_IDXPG_TRACKS_STK_PP ); Now enable paging:
    or    F, FLAG_PGMODE_11b       ; LMM w/ IndexPage<==>StackPage
  ELSE
    or    F, FLAG_PGMODE_10b       ; LMM w/ independent IndexPage
  ENDIF ;  SYSTEM_IDXPG_TRACKS_STK_PP
ELSE
    mov   A, __ramareas_end        ; Set top of stack to end of used RAM
    swap  SP, A
ENDIF ;  SYSTEM_LARGE_MEMORY_MODEL
ENDIF ;	TOOLCHAIN

    ;------------------------
    ; Close CT leakage path.
    ;------------------------
    mov   reg[ACB00CR0], 05h
    mov   reg[ACB01CR0], 05h

    ;-------------------------
    ; Load Base Configuration
    ;-------------------------
    ; Load global parameter settings and load the user modules in the
    ; base configuration. Exceptions: (1) Leave CPU Speed fast as possible
    ; to minimize start up time; (2) We may still need to play with the
    ; Sleep Timer.
    ;
    lcall LoadConfigInit
	M8C_SetBank1
	and  reg[DEC_CR1], 0x3F
	or   reg[DEC_CR1], 0x80
	M8C_SetBank0
    ;-----------------------------------
    ; Initialize C Run-Time Environment
    ;-----------------------------------
IF ( C_LANGUAGE_SUPPORT )
IF ( SYSTEM_SMALL_MEMORY_MODEL )
    mov  A,0                           ; clear the 'bss' segment to zero
    mov  [__r0],<__bss_start
BssLoop:
    cmp  [__r0],<__bss_end
    jz   BssDone
    mvi  [__r0],A
    jmp  BssLoop
BssDone:
    mov  A,>__idata_start              ; copy idata to data segment
    mov  X,<__idata_start
    mov  [__r0],<__data_start
IDataLoop:
    cmp  [__r0],<__data_end
    jz   C_RTE_Done
    push A
    romx
    mvi  [__r0],A
    pop  A
    inc  X
    adc  A,0
    jmp  IDataLoop

ENDIF ; SYSTEM_SMALL_MEMORY_MODEL

IF ( SYSTEM_LARGE_MEMORY_MODEL )
    mov   reg[CUR_PP], >__r0           ; force direct addr mode instructions
                                       ; to use the Virtual Register page.

    ; Dereference the constant (flash) pointer pXIData to access the start
    ; of the extended idata area, "xidata." Xidata follows the end of the
    ; text segment and may have been relocated by the Code Compressor.
    ;
    mov   A, >__pXIData                ; Get the address of the flash
    mov   X, <__pXIData                ;   pointer to the xidata area.
    push  A
    romx                               ; get the MSB of xidata's address
    mov   [__r0], A
    pop   A
    inc   X
    adc   A, 0
    romx                               ; get the LSB of xidata's address
    swap  A, X
    mov   A, [__r0]                    ; pXIData (in [A,X]) points to the
                                       ;   XIData structure list in flash
    jmp   .AccessStruct

    ; Unpack one element in the xidata "structure list" that specifies the
    ; values of C variables. Each structure contains 3 member elements.
    ; The first is a pointer to a contiguous block of RAM to be initial-
    ; ized. Blocks are always 255 bytes or less in length and never cross
    ; RAM page boundaries. The list terminates when the MSB of the pointer
    ; contains 0xFF. There are two formats for the struct depending on the
    ; value in the second member element, an unsigned byte:
    ; (1) If the value of the second element is non-zero, it represents
    ; the 'size' of the block of RAM to be initialized. In this case, the
    ; third member of the struct is an array of bytes of length 'size' and
    ; the bytes are copied to the block of RAM.
    ; (2) If the value of the second element is zero, the block of RAM is
    ; to be cleared to zero. In this case, the third member of the struct
    ; is an unsigned byte containing the number of bytes to clear.

.AccessNextStructLoop:
    inc   X                            ; pXIData++
    adc   A, 0
.AccessStruct:                         ; Entry point for first block
    ;
    ; Assert: pXIData in [A,X] points to the beginning of an XIData struct.
    ;
    M8C_ClearWDT                       ; Clear the watchdog for long inits
    push  A
    romx                               ; MSB of RAM addr (CPU.A <- *pXIData)
    mov   reg[MVW_PP], A               ;   for use with MVI write operations
    inc   A                            ; End of Struct List? (MSB==0xFF?)
    jz    .C_RTE_WrapUp                ;   Yes, C runtime environment complete
    pop   A                            ; restore pXIData to [A,X]
    inc   X                            ; pXIData++
    adc   A, 0
    push  A
    romx                               ; LSB of RAM addr (CPU.A <- *pXIData)
    mov   [__r0], A                    ; RAM Addr now in [reg[MVW_PP],[__r0]]
    pop   A                            ; restore pXIData to [A,X]
    inc   X                            ; pXIData++ (point to size)
    adc   A, 0
    push  A
    romx                               ; Get the size (CPU.A <- *pXIData)
    jz    .ClearRAMBlockToZero         ; If Size==0, then go clear RAM
    mov   [__r1], A                    ;             else downcount in __r1
    pop   A                            ; restore pXIData to [A,X]

.CopyNextByteLoop:
    ; For each byte in the structure's array member, copy from flash to RAM.
    ; Assert: pXIData in [A,X] points to previous byte of flash source;
    ;         [reg[MVW_PP],[__r0]] points to next RAM destination;
    ;         __r1 holds a non-zero count of the number of bytes remaining.
    ;
    inc   X                            ; pXIData++ (point to next data byte)
    adc   A, 0
    push  A
    romx                               ; Get the data value (CPU.A <- *pXIData)
    mvi   [__r0], A                    ; Transfer the data to RAM
    tst   [__r0], 0xff                 ; Check for page crossing
    jnz   .CopyLoopTail                ;   No crossing, keep going
    mov   A, reg[ MVW_PP]              ;   If crossing, bump MVW page reg
    inc   A
    mov   reg[ MVW_PP], A
.CopyLoopTail:
    pop   A                            ; restore pXIData to [A,X]
    dec   [__r1]                       ; End of this array in flash?
    jnz   .CopyNextByteLoop            ;   No,  more bytes to copy
    jmp   .AccessNextStructLoop        ;   Yes, initialize another RAM block

.ClearRAMBlockToZero:
    pop   A                            ; restore pXIData to [A,X]
    inc   X                            ; pXIData++ (point to next data byte)
    adc   A, 0
    push  A
    romx                               ; Get the run length (CPU.A <- *pXIData)
    mov   [__r1], A                    ; Initialize downcounter
    mov   A, 0                         ; Initialize source data

.ClearRAMBlockLoop:
    ; Assert: [reg[MVW_PP],[__r0]] points to next RAM destination and
    ;         __r1 holds a non-zero count of the number of bytes remaining.
    ;
    mvi   [__r0], A                    ; Clear a byte
    tst   [__r0], 0xff                 ; Check for page crossing
    jnz   .ClearLoopTail               ;   No crossing, keep going
    mov   A, reg[ MVW_PP]              ;   If crossing, bump MVW page reg
    inc   A
    mov   reg[ MVW_PP], A
    mov   A, 0                         ; Restore the zero used for clearing
.ClearLoopTail:
    dec   [__r1]                       ; Was this the last byte?
    jnz   .ClearRAMBlockLoop           ;   No,  continue
    pop   A                            ;   Yes, restore pXIData to [A,X] and
    jmp   .AccessNextStructLoop        ;        initialize another RAM block

.C_RTE_WrapUp:
    pop   A                            ; balance stack

ENDIF ; SYSTEM_LARGE_MEMORY_MODEL

C_RTE_Done:

ENDIF ; C_LANGUAGE_SUPPORT


    ;-------------------------------
    ; Set Power-On Reset (POR) Level
    ;-------------------------------
    M8C_SetBank1

IF (POWER_SETTING & POWER_SET_3V3)             ; 3.3V Operation?
    or   reg[VLT_CR], VLT_CR_POR_LOW           ;   Yes, change to midpoint trip
ELSE										   ; 5V Operation
  IF ( CPU_CLOCK_JUST ^ OSC_CR0_CPU_24MHz )    ;      As fast as 24MHz?
    or   reg[VLT_CR], VLT_CR_POR_LOW           ;         No, change to midpoint trip
  ELSE ; 24HMz                                 ;
    or    reg[VLT_CR], VLT_CR_POR_HIGH         ;        Yes, switch to	highest setting
  ENDIF ; 24MHz
ENDIF ; 3.3V Operation

    M8C_SetBank0

    ;----------------------------
    ; Wrap up and invoke "main"
    ;----------------------------

    ; Disable the Sleep interrupt that was used for timing above.  In fact,
    ; no interrupts should be enabled now, so may as well clear the register.
    ;
    mov  reg[INT_MSK0],0

    ; Everything has started OK. Now select requested CPU & sleep frequency.
    ;
    M8C_SetBank1
    mov  reg[OSC_CR0],(SLEEP_TIMER_JUST | CPU_CLOCK_JUST)
    M8C_SetBank0

    ; Global Interrupt are NOT enabled, this should be done in main().
    ; LVD is set but will not occur unless Global Interrupts are enabled.
    ; Global Interrupts should be enabled as soon as possible in main().
    ;
    mov  reg[INT_VC],0             ; Clear any pending interrupts which may
                                   ; have been set during the boot process.
IF	(TOOLCHAIN & HITECH)
	ljmp  startup                  ; Jump to C compiler startup code		   ;<-??? I'm confused what startup is and where it's defined
	                                                                           ;<-??? don't we have a label "main: 0r _main:" by default????
                															   ;<-??? additionally this is confusing because of the similarity to
																			   ;<-??? __Start:
ELSE
IF ENABLE_LJMP_TO_MAIN
    ljmp  _main                    ; goto main (no return)
ELSE
    lcall _main                    ; call main
.Exit:
    jmp  .Exit                     ; Wait here after return till power-off or reset
ENDIF
ENDIF ; TOOLCHAIN

AREA Bootloader (ROM, REL, CON)
    ;---------------------------------
    ; Library Access to Global Parms
    ;---------------------------------
    ;
 bGetPowerSetting:
_bGetPowerSetting:
    ; Returns value of POWER_SETTING in the A register.
    ; No inputs. No Side Effects.
    ;
    mov   A, POWER_SETTING          ; Supply voltage and internal main osc
    ret
    
IF	(TOOLCHAIN & HITECH)
ELSE
    ;---------------------------------
    ; Order Critical RAM & ROM AREAs
	; these are more areas that are  still in order of default placement.  
	; there is another group of them above in this file.
	; (just below the 're-directed vector' secton)
    ;---------------------------------

	AREA BLChecksum (ROM, REL, CON)

    ; RAM area usage
    ;
    AREA data              (RAM, REL, CON)   ; initialized RAM
__data_start:

    AREA virtual_registers (RAM, REL, CON)   ; Temp vars of C compiler
    AREA InterruptRAM      (RAM, REL, CON)   ; Interrupts, on Page 0
    AREA bss               (RAM, REL, CON)   ; general use
__bss_start:

ENDIF ; TOOLCHAIN

; end of file boot.asm
