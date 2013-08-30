;;*****************************************************************************
;;*****************************************************************************
;;  FILENAME: USB_BL_flashapi.asm
;;  Version: 1.50, Updated on 2011/6/28 at 6:8:6
;;  Generated by PSoC Designer 5.4.2946
;;
;;  DESCRIPTION: USB User Module Descriptors
;;
;;  NOTE: User Module APIs conform to the fastcall convention for marshalling
;;        arguments and observe the associated "Registers are volatile" policy.
;;        This means it is the caller's responsibility to preserve any values
;;        in the X and A registers that are still needed after the API
;;        function returns. Even though these registers may be preserved now,
;;        there is no guarantee they will be preserved in future releases.
;;-----------------------------------------------------------------------------
;;  Copyright (c) Cypress Semiconductor 2011. All Rights Reserved.
;;*****************************************************************************
;;*****************************************************************************


include "m8c.inc"       ; part specific constants and macros
include "memory.inc"
include "USB_bt_loader.inc"
include "USB_Flash.inc"
include "USB.inc"


export  bFlashWriteBlock
export _bFlashWriteBlock

IF FLASHLITE
export  FlashWriteLite
export _FlashWriteLite
ENDIF

export  FlashReadBlock
export _FlashReadBlock	
    AREA TOP (ROM, ABS, CON)

org 74h ;;Actually defined in flashapi.asm (reserved)
 bFlashWriteBlock:
_bFlashWriteBlock:
	ljmp bFlashWriteBlock_internal

org 78h	;;Actually defined in flashapi.asm (reserved)
 FlashReadBlock:
_FlashReadBlock:
	ljmp FlashReadBlock_internal

;------------------------------------------------------------------------------
;  Declare Flash RAM storage at top of RAM
;     This data area is reserved for exclusive use by Supervisory operations.
;------------------------------------------------------------------------------
   bSSC_KEY1:             equ      F8h     ;F8h  KEY1 and Return code for SSC
   bTEMP_SPACE:           equ      F8h     ; temporary storage when not used for KEY1
   bSSC_RETURNCODE:       equ      F8h     ;F8h  result code
   bSSC_KEY2:             equ      F9h     ;F9h  supervisory stack ptr key
   bSSC_BLOCKID:          equ      FAh     ;FAh  block ID
   pSSC_POINTER:          equ      FBh     ;FBh  pointer to data buffer
   bTEMP_M:               equ      FBh     ;FBh  M of Mx+B
   bSSC_CLOCK:            equ      FCh     ;FCh  Clock
   bTEMP_B:               equ      FCh     ;FCh  B of Mx+B
   bTEMP_Mult:            equ      FDh     ;FDh  ClockW ClockE multiplier
   bSSC_DELAY:            equ      FEh     ;FEh  flash macro sequence delay count
   bSSC_TEMP_Revision:    equ      FFh 
   bSSC_WRITE_ResultCode: equ      FFh     ;FFh  temporary result code

;;added flashAPI equates to support conventional Flash operations.
;-------------------------------------
; Flash temperature programming table
;-------------------------------------
TEMPERATURE_TABLE_ID:               equ      3     ; flash temperature programming table ID


   bSSC_ResultCode:                 equ      F8h   ; result code
   bSSC_KEYSP:                      equ      F9h   ; supervisory stack ptr key

;SSC Return Codes
   bSSC_FAIL:                       equ      01h   ; fail return code
   bSSC_SUCCESS:                    equ      00h   ; success return code

;Flash Erase Operation Template
   bSSC_FLASH_BlockId:              equ      FAh   ; blockId for Erase and Read
   bSSC_FLASH_BlockID_BANK:         equ      FAh   ; block ID page register in bank 1
   bSSC_FLASH_PulseWidth:           equ      FCh   ; Erase pulse width
   
;Flash Write Operation Template
   bSSC_WRITE_BlockId:              equ      FAh   ; block ID
   bSSC_WRITE_BlockID_BANK:         equ      FAh   ; block ID page register in bank 1
   pSSC_WRITE_FlashBuffer:          equ      FBh   ; pointer to data buffer
   bSSC_WRITE_PulseWidth:           equ      FCh   ; flash write pulse width or ReadCount
   bSSC_WRITE_State:                equ      FDh   ; reserved
   bSSC_WRITE_Delay:                equ      FEh   ; flash macro sequence delay count
   bSSC_WRITE_ResultCode:           equ      FFh   ; temporary result code

;Flash Write Operation Return Code
   bSSC_WRITE_FAIL:                 equ      00h   ; failure
   bSSC_WRITE_SUCCESS:              equ      01h   ; pass

;Flash Sequence Time Delay
   bSSC_WRITE_DELAY:                equ      56h   ; 100us delay at 12MHz

;Flash Read Operation Template
   pSSC_READ_FlashBuffer:           equ      FBh   ; pointer to data buffer
   wSSC_READ_Counter:               equ      FDh   ; byte counter

; Table Lookup Template - NOTE that result is a table overlaying reserved area
   bSSC_TABLE_TableId:              equ      FAh   ; table ID

; Temperature Table Template - returned data after performing a
;     Table lookup of table #7 - Pulse Width Equation data based on Temperature - y= mt+b
;     Composed to two structures - 3 Bytes each - contains slope, y intercept and multiplier
;     Structure 1 is for temperatures from [-40,0]C and structure 2 is for temperaturs from [0,40]C.
   sTEMP_LineEquationBelowZero:     equ      F8h   ; Line Equation data below zero - m,b,Erase->Program multiplier
   sTEMP_LineEquationAboveZero:     equ      FBh   ; Line Equation data above zero - m,b,Erase->Program multiplier
   bTEMP_TempTableRevision:         equ      FFh   ; Table Revision number
   bTEMP_PulseWidthErase:           equ      FEh   ; Temporary storage area after table validation
   bTEMP_PulseWidthProgram:         equ      FFh   ; Temporary storage area after table validation
   ;offsets into each substructure
   cTEMP_SlopeOffset:               equ      0     ; Slope offset in Temp table template
   cTEMP_InterceptOffset:           equ      1     ; Intercept offset in Temp table template
   bTEMP_ProgMultOffset:            equ      2     ; Program multiplier

   VALID_TABLE_REVISION:            equ      1     ; Temp Table revision number


; Flash State mode bits - these bits are used to prevent inadvertent jumping into
; the flash write API.  If the state does not match then a HALT instruction will
; be executed.

   STATE_SET_CLOCK:                 equ      01h
   STATE_CALCULATE_PW:              equ      02h
   STATE_ERASE_BLOCK:               equ      04h
   STATE_WRITE_BLOCK:               equ      08h
   STATE_RESTORE_CLOCK:             equ      10h
   STATE_DONE:                      equ      20h

;------------------------------------------------------------------------------
; SSC_Action macro command codes
;------------------------------------------------------------------------------
FLASH_TEMP_TABLE_LOOKUP:            equ      6     ; flash temperature table command

;;end new flashAPI section

IF FLASHLITE

   TempE:                 equ      FBh
   MultHB:                equ      FCh
   MultLB:                equ      FDh
   ResultHB:              equ      FEh
   ResultLB:              equ      FFh
  
;   wFlashBlock:           equ      3Fh  ;data write block !!!!!!!!!!
ENDIF
;------------------------------------------------------------------------------
; SSC_Action macro command codes
;------------------------------------------------------------------------------
FLASH_OPER_KEY:           equ      3Ah   ; flash operation key
FLASH_READ:               equ      1     ; flash read supervisory command
FLASH_WRITE:              equ      2     ; flash write supervisory command
FLASH_ERASE:              equ      3     ; flash erase supervisory command
FLASH_TABLE_READ:         equ      6     ; flash read table command
TEMP_TABLE:               equ      3     ; 


;Flash Read Operation Template
;------------------------------------------------------------------------------
; Supervisory Operation Templates:
;   Each system supervisory call uses the reserved data area a little
;   different. Create overlay templates to improve readability and maintenance.
;------------------------------------------------------------------------------

;SSC Return Codes
   bSSC_SUCCESS:                    equ      00h   ; success return code

;Flash Sequence Time Delay
   bSSC_DELAY_VALUE:                equ      56h   ; 100us delay at 12MHz

; Temperature Table Template - returned data after performing a
   VALID_TABLE_REVISION:            equ      1     ; Temp Table revision number

;Flash Read Operation Template
   pSSC_READ_FlashBuffer:           equ      FBh   ; pointer to data buffer
   bSSC_READ_Counter:               equ      FDh   ; byte counter

area Bootloader(rom,rel)

;------------------------------------------------------------------------------
;  MACRO NAME: SpecialSCC
;
;  DESCRIPTION:
;     Performs locally defined supervisory operations. Provides synchronization
;     with PSoC ICE. If the sequence in the macro is changed, the ICE will not 
;     successfully exectute the supervisor functions.
;     !!! DO NOT CHANGE THIS CODE !!!
;
;  RETURNS:
;     BYTE - Nothing
;  SIDE EFFECTS:
;     A and X registers are destroyed
;
;  PROCEDURE:
;     1) specify a 3 byte stack frame.  Save in [KEY2]
;     2) insert the flash Supervisory key in [KEY1]
;     3) store flash operation function code in A
;     4) call the supervisory code
;------------------------------------------------------------------------------
IF FLASHLITE

macro SpecialSSC:
   mov   X, SP                         ; copy SP into X
   mov   A, X                          ; A temp stored in X
   add   A, 3                          ; create 3 byte stack frame (2 + pushed A)
   mov   [bSSC_KEY2], A                ; save stack frame for supervisory code
   mov   [bSSC_KEY1], FLASH_OPER_KEY   ; load the supervisory code for flash ops
   mov   A,@0                          ; load A with specific Flash operation
   SSC                                 ; SSC call the supervisory code
endm

ENDIF
;------------------------------------------------------------------------------
;  FUNCTION NAME: bFlashWriteBlock
;
;  DESCRIPTION:
;     Writes 64 bytes of data to the flash at the specified blockId.
;
;     Regardless of the size of the buffer, this routine always writes 64 bytes
;     of data. If the buffer is less than 64 bytes, then the next 64-N bytes of
;     RAM will be written to fill the rest of flash block data.
;
;  ASSUMPTIONS:
;     Single block Write
;     CPU clock is 12MHz
;     Temperature is hardcoded to be 32 degees Celcius
;
;  ARGUMENTS:
;    [SP-5] - Block Number to be written
;    [SP-4] - MSB of the source pointer
;    [SP-3] - LSB of the source pointer
;
;  RETURNS:
;     0 if Successful
;     1 if Invalid Revision Error
;     2 if erase failure
;     3 if Write failure
;
;  PROCEDURE:
;    1 ) Compute the programming pulsewidths
;    2 ) Erase the specified block
;    3 ) Program the specified block
;------------------------------------------------------------------------------

IF FLASHLITE


   halt       ; Wandering Protect Protect
   halt       ; only way to get to next instruction is jmp and call
   halt       ; three byte is biggest instruction size

 bFlashWriteBlock:
_bFlashWriteBlock:

 FlashWriteLite:
_FlashWriteLite:
   M8C_DisableGInt
 
; 1 ) Compute the programming pulsewidths
   ;Calculate ClockE amd ClockW
   ;Get Cal values from Table in PSoC
   RAM_SETPAGE_CUR 0
   RAM_SETPAGE_IDX 0
   RAM_SETPAGE_MVW 0
   RAM_CHANGE_PAGE_MODE 0

   M8C_SetBank1
   mov  reg[FAh],0x00
   M8C_SetBank0
   mov  [bSSC_BLOCKID], TEMP_TABLE  
   SpecialSSC FLASH_TABLE_READ

   cmp  [bSSC_TEMP_Revision], VALID_TABLE_REVISION
   jz   ValidRevision

   ; Return with Invalid Table Revision Error
   mov  A,1
   jmp  EndFlashWrite

ValidRevision:
   ;calc ClockE
   asr  [bTEMP_M]                      ;M/8 16C 16C 60F
   asr  [bTEMP_M]
   asr  [bTEMP_M]					   ; Added one more shift
   mov  A, [bTEMP_B]
   sub  A, [bTEMP_M]                   ;B - M/8
   push A                              ; Save ClockE on stack
     
   ;calc ClockW
   mov  [TempE], A
   mov  A, 0                           ;TempE contains ClockE
   mov  [ResultHB], A
   mov  [ResultLB], A
   mov  [MultHB], A
loop:
   asr  [TempE]
; if1 
   jnc  endif1 
   mov  A, [MultLB]                    ;add Mult to Result
   add  [ResultLB], A
   mov  A, [MultHB]
   adc  [ResultHB], A
endif1:
   cmp  [TempE], 0
   jz   exitloop
   asl  [MultLB]
   rlc  [MultHB]
   jmp  loop
exitloop:   

   mov  A, [ResultHB]   
   asl  [ResultLB]
   rlc  A
   asl  [ResultLB]
   rlc  A
   push A                              ; Push ClockW on Stack 

; 2 ) Erase the specified block
   RAM_SET_NATIVE_PAGING
   mov  X, SP
   mov  A,[X-7]
   mov  [bSSC_BLOCKID], A              ; Block ID
   and  [bSSC_BLOCKID], 0x7F
   and  A,0x80
   jz   FlashBank0
   M8C_SetBank1
   mov  reg[0xFA],0x01
   M8C_SetBank0
   jmp  NextOp
FlashBank0:
   M8C_SetBank1
   mov  reg[0xFA],0x00
   M8C_SetBank0
NextOp:
   mov  A, [X-2]                       ; get Clock E
   mov  [bSSC_CLOCK], A
   mov  [bSSC_DELAY], bSSC_DELAY_VALUE ; get Delay

   SpecialSSC FLASH_ERASE
   
;   SpecialSSC FLASH_ERASE
   cmp  [bSSC_RETURNCODE], bSSC_SUCCESS
   jz   Erase_Success
   mov  A,2

   ; Return with Unsuccessful Erase Error
   add  SP,-2
   jmp  EndFlashWrite

Erase_Success:
; 3 ) Program the specified block
   pop  A                              ; ClockW
   mov  [bSSC_CLOCK], A
   pop  A                              ; ClockE
   mov  X,SP
   mov  A,[X-5]                        ; Block Number
   mov  [bSSC_BLOCKID], A              ; Block ID
   and  [bSSC_BLOCKID], 0x7F
   and  A,0x80
   jz   FlashBank00
   M8C_SetBank1
   mov  reg[0xFA],0x01
   M8C_SetBank0
   jmp  NextOp1
FlashBank00:
   M8C_SetBank1
   mov  reg[0xFA],0x00
   M8C_SetBank0
NextOp1:
   mov  A,[X-4]
   RAM_SETPAGE_MVR A
   mov  A,[X-3]                        ; RAM Pointer
   mov  [pSSC_POINTER], A
   SpecialSSC FLASH_WRITE
   cmp  [bSSC_RETURNCODE], bSSC_SUCCESS
   jz   Write_Success
   ; Return with Unsuccessful Write Error
   mov  A,3
   jmp  EndFlashWrite
Write_Success:
   ; Return with Success
   mov  A,0
EndFlashWrite:
   RAM_SETPAGE_IDX2STK
   RAM_SET_NATIVE_PAGING
   ret
   
ENDofFlash:

		
;;  START OF NEW

.SECTION
;------------------------------------------------------------------------------
;	FUNCTION NAME: FlashReadBlock
;
;	DESCRIPTION:
;	Reads a specified flash block to a buffer in RAM.
;
;	ARGUMENTS:
;	
;   [SP-3] -> LSB of Pointer to the buffer in RAM
;   [SP-4] -> MSB of Pointer to the buffer in RAM
;   [SP-5] -> LSB of Block Id
;   [SP-6] -> MSB of Block Id
;   [SP-7] -> Read Count
;                            
;	RETURNS:
;	Data read is returned at specified pFlashBuffer.
;
;	SIDE EFFECTS:
;	Uses SSC storage at FBh and FDh
;
;	PROCEDURE:  
;	BlockID is converted to absolute address and then ROMX command is used
;	to read the data from flash into the specified buffer.
;
;------------------------------------------------------------------------------
 FlashReadBlock:
_FlashReadBlock:	

;   RAM_SETPAGE_CUR 0
;   RAM_SETPAGE_IDX 0
;   RAM_SETPAGE_MVW 0
;   RAM_CHANGE_PAGE_MODE 2
   mov  X,SP

   ; mov some args to SSC storage for temp usage
   ; Get LSB of pointer
   mov	A, [X-3]
   ; Store it temporarily in SSC storage area
   mov	[pSSC_READ_FlashBuffer],A
   ; Get MSB of pointer
   mov   A,[X-4]
   ; Set the MVW page pointer to MSB of pointer
   RAM_SETPAGE_MVW A
   ; Get number of bytes to be read
   mov	A, [X-7]
   ; Store it temporarily in SSC Storage area
   mov	[bSSC_READ_Counter],A

   ; Compute the absolute address of the flash block
   ; After the computation, X will have the LSB and A will have the MSB
   ; Compute LSB = BlockId*64
   mov	A, [X-5]
   rrc	A
   rrc	A
   rrc	A
   and	A, C0h
   ; Store LSB temporarily on stack
   push	A                  
   ; Compute MSB = BlockId/4
   mov	A, [X-5]
   asr	A
   asr	A
   ; mask off sign extension bits
   and	A,  3Fh
   ; Restore the stored LSB to X  
   pop	X

   ; Read the Flash
ReadFlash:	
   ; Save MSB
   push	A 
   ; Read Flash
   romx                            
   ; Store the byte in buffer and increment pointer
   mvi	[pSSC_READ_FlashBuffer], A
   ; Restore MSB
   pop	A                             ; restore MSB
   ; Increment LSB
   inc	X 
   ; Check if all bytes read
   dec	[bSSC_READ_Counter]
   ; Loop til all bytes are read
   jnz 	ReadFlash

   ; Done reading the flash
   ; Restore native paging
;   RAM_SET_NATIVE_PAGING
   ret


.ENDSECTION
ELSE	
;-----------------------------------------------------------------------------
;  MACRO NAME: SSC_Action
;
;  DESCRIPTION:
;     Performs locally defined supervisory operations.
;
;     !!! DO NOT CHANGE THIS CODE !!!
;        This sequence of opcodes provides a
;        signature for the debugger and ICE.
;     !!! DO NOT CHANGE THIS CODE !!!
;
;  ARGUMENTS:
;     BYTE  bOperation   - specified supervisory operation - defined operations
;                          are:  FLASH_WRITE, FLASH_ERASE, FLASH_TEMP_TABLE_LOOKUP.
;
;  RETURNS:
;     none.
;
;  SIDE EFFECTS:
;     A and X registers are destroyed
;
;  PROCEDURE:
;     1) specify a 3 byte stack frame.  Save in [KEYSP]
;     2) insert the flash Supervisory key in [KEY1]
;     3) store flash operation function code in A
;     4) call the supervisory code
;-----------------------------------------------------------------------------

macro SSC_Action
IF USB_ALLOW_SSC
      mov   X, SP                         ; copy SP into X
      mov   A, X                          ; mov to A
      add   A, 3                          ; create 3 byte stack frame
      mov   [bSSC_KEYSP], A               ; save stack frame for supervisory code
      mov   [bSSC_KEY1], FLASH_OPER_KEY   ; load the supervisory code for flash operations
      mov   A, @0                         ; load A with specific Flash operation
      SSC                                 ; SSC call the supervisory code
ELSE
nop
ENDIF
endm
 


;-----------------------------------------------------------------------------
;  FUNCTION NAME: bFlashWriteBlock
;
;  DESCRIPTION:
;     Writes 64 bytes of data to the flash at the specified blockId.
;
;     Regardless of the size of the buffer, this routine always writes 64
;     bytes of data. If the buffer is less than 64 bytes, then the next
;     64-N bytes of data will be written to fill the rest of flash block data.
;
;  ARGUMENTS:
;     X ->  psBlockWriteData  -  a structure that holds the
;                                calling arguments and some reserved space
;
;  RETURNS:
;     BYTE - successful if NON-Zero returned.
;
;     ASSEMBLER - returned in Accumulator.
;
;  SIDE EFFECTS:
;     1) CPU clock temporarily set to 12MHz.
;
;  PROCEDURE:
;     1) Setup the proper CPU clock - 12 MHz or 6MHz depending on state of SLIMO
;     2) Compute the pulsewidths
;     3) Erase the specified block
;     4) Program the specified block
;     5) restore the original CPU rate
;     6) check the result code and return
;-----------------------------------------------------------------------------
; Place Halt instruction code here to mitigate wondering into this code from the top
   halt
.SECTION
 bFlashWriteBlock_internal:
_bFlashWriteBlock_internal:
   ; Preserve the SMM or LMM paging mode
   RAM_SETPAGE_CUR 0          ; set paging mode

   mov   [bTEMP_SPACE], A     ; temporarily store the MSB of the WriteBlock structure
   mov   A, reg[CPU_F]        ; grab the current CPU flag register and save on stack
   push  A
   and   a, c0h
   jnz   YesPging
   ;  Enforce MSB to 0 when not in a paging mode
   mov   [X+pARG_FlashBuffer], 0
   mov   [bTEMP_SPACE], 0
YesPging:
   mov   A, [bTEMP_SPACE]     ; restore the MSB of the WriteBlock structure

   ; Since the flash SSC operations all reference page 0, save and set the current ptr
   ; to page 0 and the X_ptr to track input data page.
   RAM_PROLOGUE RAM_USE_CLASS_3
   RAM_SETPAGE_IDX A

   ; Set the intial state variable - if code entered from the top - then state
   ; variable will not catch this inadvertent entry.  However, any entry from
   ; made after this statement should be caught!
   mov   [bSSC_WRITE_State], STATE_SET_CLOCK

; Step 1 - setup the proper CPU clock - 12 MHz if SLIMO NOT enabled, else 6MHz
   ; Check the state variable - are we supposed to be here?
   cmp   [bSSC_WRITE_State], STATE_SET_CLOCK
   jnz   bFlashWriteStateError

   ; State - Set Clock
   M8C_SetBank1
   mov   A, reg[OSC_CR0]                  ; Get the System Oscillator control register
   push  A                                ;     and save it on the stack
   and   A, ~OSC_CR0_CPU                  ; Clear the CPU clock selects

   ; Check state of SLIMO
   tst   reg[CPU_SCR1], CPU_SCR1_SLIMO
   jz    .Set12MHz                        ; if Z=0 then SLIMO NOT enabled - set 12MHz

.Set6MHz:
   or    A, OSC_CR0_CPU_24MHz             ; SLIMO enabled - set CPU clock to 6MHz
   jmp   .SetOSC                          ;  IMO clock max is 6MHz - DIVISOR = 1 ==> 24MHz setting
.Set12MHz:
   or    A, OSC_CR0_CPU_12MHz             ; Set CPU clock to 12 MHz
.SetOSC:
   mov   reg[OSC_CR0], A
   M8C_SetBank0

; Step 2 - compute the pulsewidths
ComputePulseWidths:
   asl   [bSSC_WRITE_State]               ; update the state variable
   ; Check the state variable - are we supposed to be here?
   cmp   [bSSC_WRITE_State], STATE_CALCULATE_PW
   jnz   bFlashWriteStateError

   ; State - Calculate PW
   call  bComputePulseWidth
IF USB_ALLOW_SSC
   ; Preset the resturn code to Success
   cmp   A, bSSC_SUCCESS                  ; Check the return value
   jz    EraseBlock                       ;     the pulse width was computed OK
ELSE
   mov A, bSSC_SUCCESS
   cmp   A, bSSC_SUCCESS                  ; Check the return value
   jz    EraseBlock                       ;     the pulse width was computed OK
ENDIF
   ; A bad pulse width table was found!
   ; Need to set the result code, restore the clock, and then exit!
   mov   [bSSC_WRITE_ResultCode], bSSC_WRITE_FAIL
   mov   [bSSC_WRITE_State], STATE_RESTORE_CLOCK
   jmp   RestoreClock

; Step 3 - Erase the specified flash block
EraseBlock:
   asl   [bSSC_WRITE_State]               ; update the state variable
   ; State - Erase Block

   mov   A, [X+wARG_BlockId+1]            ; set block ID to be 128 blocks by N Banks
   rlc   A
   mov   A, [X+wARG_BlockId]
   rlc   A
   M8C_SetBank1
   mov   reg[bSSC_FLASH_BlockID_BANK], A  ; set the bank of the blockID
   M8C_SetBank0
   push  A
   mov   A, [X+wARG_BlockId+1]
   and   A, 0x7F
   mov   [bSSC_WRITE_BlockId], A          ; set the block-within-Bank-ID
   push  A

   mov   A, [X+bDATA_PWErase]             ; set the pulse width
   mov   [bSSC_WRITE_PulseWidth], A
   mov   [bSSC_WRITE_Delay], bSSC_WRITE_DELAY   ; load the sequence delay count
   ; Check the state variable - are we supposed to be here?
   mov   A, [bSSC_WRITE_State]
   cmp   A, STATE_ERASE_BLOCK
   jnz   bFlashWriteStateError
   push  A                                ; save the State variable
   push  X

IF	(TOOLCHAIN & HITECH)
ELSE
	.nocc_start
ENDIF

_FlashBlockLocal1::
   SSC_Action FLASH_ERASE                 ; Erase the specified block

IF	(TOOLCHAIN & HITECH)
ELSE
	.nocc_end
ENDIF

   pop   X
   pop   A                                ; restore the State variable
   mov   [bSSC_WRITE_State], A
   ; Check the return code for success
IF USB_ALLOW_SSC
   cmp   [bSSC_ResultCode], bSSC_SUCCESS
   jz    WriteBlock
ELSE
   mov   [bSSC_ResultCode], bSSC_SUCCESS
   cmp   [bSSC_ResultCode], bSSC_SUCCESS
   jz    WriteBlock
ENDIF
   ; Erase operation failed!
   ; Need to set the result code, restore the clock, and then exit!
   mov   [bSSC_WRITE_ResultCode], bSSC_WRITE_FAIL
   mov   [bSSC_WRITE_State], STATE_RESTORE_CLOCK
   add   SP, -2                           ; retire the bank and block #s
   jmp   RestoreClock

; Step 4 - Program the flash
WriteBlock:
   ; Update the state variable
   asl   [bSSC_WRITE_State]
   ; State - Write Block

   pop   A                                ; load WRITE opeation parameters
   mov   [bSSC_WRITE_BlockId], A          ; set the LSB of the blockID
   pop   A
   M8C_SetBank1
   mov   reg[bSSC_FLASH_BlockID_BANK], A  ; set the bank of the blockID
   M8C_SetBank0

   mov   A, [X+pARG_FlashBuffer+1]        ; set the LSB of the RAM buffer ptr
   mov   [pSSC_WRITE_FlashBuffer], A
   mov   A, [X+pARG_FlashBuffer]          ; set the MSB of the RAM buffer ptr
   mov   reg[MVR_PP], A


   mov   A, [X+bDATA_PWProgram]
   mov   [bSSC_WRITE_PulseWidth], A
   mov   [bSSC_WRITE_Delay], bSSC_WRITE_DELAY   ; load the sequence delay count
   ; Check the state variable - are we supposed to be here?
   mov   A, [bSSC_WRITE_State]
   cmp   A, STATE_WRITE_BLOCK
   jnz   bFlashWriteStateError
   push  A                                ; save the State variable
   push  X

IF	(TOOLCHAIN & HITECH)
ELSE
	.nocc_start
ENDIF

_FlashBlockLocal2::
   SSC_Action FLASH_WRITE                 ; Program the flash

IF	(TOOLCHAIN & HITECH)
ELSE
	.nocc_end
ENDIF

   pop   X
   pop   A                                ; restore the state variable
   mov   [bSSC_WRITE_State], A
   ; Set the return code
IF USB_ALLOW_SSC
   mov   [bSSC_WRITE_ResultCode], bSSC_WRITE_SUCCESS
   cmp   [bSSC_ResultCode], bSSC_SUCCESS
   jz    NextState
ELSE
   mov   [bSSC_WRITE_ResultCode], bSSC_WRITE_SUCCESS
   mov   [bSSC_ResultCode], bSSC_SUCCESS
   cmp   [bSSC_ResultCode], bSSC_SUCCESS
   jz    NextState
ENDIF
   ; Write operation failed!
   ; Need to set the result code, restore the clock, and then exit!
   mov   [bSSC_WRITE_ResultCode], bSSC_WRITE_FAIL

; Step 5 - restore the original CPU rate
NextState:
   asl   [bSSC_WRITE_State]               ; update the state variable
   ; Check the state variable - are we supposed to be here?
RestoreClock:
   cmp   [bSSC_WRITE_State], STATE_RESTORE_CLOCK
   jnz   bFlashWriteStateError

   ; State - Restore Clock
   pop   A
   M8C_SetBank1
   mov   reg[OSC_CR0], A                  ; Restore org CPU rate
   M8C_SetBank0                           ; Switch back to Bank 0
   asl   [bSSC_WRITE_State]               ; update the state variable

; Step 6 - Compute the return result code
   mov   A, [bSSC_WRITE_ResultCode]

bFlashWriteBlockEnd:
; check the state variable for proper exit -
   cmp   [bSSC_WRITE_State], STATE_DONE
   jz    bFlashWriteExit

; if we arrived here, it means that the flashWrite API was randomly entered!!!
bFlashWriteStateError:
   halt
   jmp   bFlashWriteStateError

bFlashWriteExit:
   RAM_EPILOGUE RAM_USE_CLASS_3

   ; default critical paging registers to PAGE 0 to support both LMM and SMM
   RAM_SETPAGE_CUR 0                      ; cur_ptr page 
   RAM_SETPAGE_MVW 0                      ; MW_ptr page 
   RAM_SETPAGE_MVR 0                      ; Mr_ptr page

; return with a RETI to preserve the last paging mode - SMM or LMM
   reti



; Put halt here in case we jump inadvertently
   halt
   halt
   halt

;-----------------------------------------------------------------------------
;  FUNCTION NAME:    ComputePulseWidth
;
;  DESCRIPTION:
;     Computes the Block Erase and Block Program pulse width counts for the
;     Flash Erase and Flash Program supervisory calls.
;
;     This routine gets its data from the FlashWriteBlock data structure
;     and saves the return data in the same structure.
;
;     First, the Temperature data table is accessed via the Table Read SSC
;     function.  Then the Erase  and Program pulse width counts are computed.
;
;     Temperature table gives the slope, Y intercept, and Erase to Program pulse
;     width converion.  Two equations are given - temperatures below 0 and
;     temperatures above 0. Data is scaled to fit within specified byte range.
;
;        PW(erase) = B - M*T*2/256 and PW(program)= PW(erase)*Multiplier/64
;
;     ADJUSTMENT FOR SLIMO:
;     --------------------
;     After calculation of both the PW(erase) and PW(Program), the SLIMO bit
;     is detected. If the SLIMO bit is enabled then both programming pulses are
;     divided by TWO and incremented by one for roundoff.  This is due to the fact
;     that the CPU clock will be set for 6MHz instead of 12MHz which means that the
;     SSC EraseBlk and WriteBlk operation will take twice as long.
;
;  ARGUMENTS:
;     X points to bFlashWriteBlock calling structure.
;
;  RETURNS:
;     BYTE  bResult - return in Accumulator
;           0 = valid
;           1 = invalid revision
;
;     Erase and Program pulse widths are returned in bFlashWriteBlock calling
;     structure.
;
;  SIDE EFFECTS:
;     none.
;
;  REQUIREMENTS:
;
;     1) The calculated erase pulse width is always < 128 (does not overflow 7 bits)
;     2) The calculated write pulse width is always < 256 (does not overflow 8 bits)
;     3) If SLIMO is enabled, then this algorithm assumes the CPU clock will be set
;        for 6MHz and NOT 12MHz!
;
;     These requirements MUST be guaranteed during device calibration.
;     They are not checked.  If they are not met, the pulse width calculation will fail.
;
;  PROCEDURE:
;     1) Get the flash programming temperature table
;     2) Check the table revision number
;     3) Select the correct data set, based on temperature
;     4) Compute the Erase Pulsewidth count
;     5) Compute the Program Pulsewidth count
;     6) Save the result data
;     7) Adjust for SLIMO
;
;-----------------------------------------------------------------------------
bComputePulseWidth:

   ; 1) Get the flash programming temperature table
   mov   [bSSC_TABLE_TableId], TEMPERATURE_TABLE_ID
   RAM_SETPAGE_MVW 0                      ; set table WRITE page to 0
   M8C_SetBank1
   mov   reg[bSSC_FLASH_BlockID_BANK], 0  ; set the SSC operation page to 0
   M8C_SetBank0

   ; Check the State
M8C_SetBank0
   mov   A, [bSSC_WRITE_State]
   cmp   A, STATE_CALCULATE_PW
   jnz   bFlashWriteStateError
   push  A                                ; save the State variable
   push  X
   REG_PRESERVE  IDX_PP                   ; save the X pointer page

IF	(TOOLCHAIN & HITECH)
ELSE
	.nocc_start
ENDIF

_FlashBlockLocal3::
   SSC_Action  FLASH_TEMP_TABLE_LOOKUP

IF	(TOOLCHAIN & HITECH)
ELSE
	.nocc_end
ENDIF

   REG_RESTORE  IDX_PP                   ; save the X pointer page
   pop   X

   ; 2) Check table revision
IF USB_ALLOW_SSC
   cmp   [bTEMP_TempTableRevision], VALID_TABLE_REVISION
   jnz   ComputePulseWidthTableError      ; jump if revision is out of date!

ELSE
   mov   [bTEMP_TempTableRevision], VALID_TABLE_REVISION
   cmp   [bTEMP_TempTableRevision], VALID_TABLE_REVISION
   jnz   ComputePulseWidthTableError      ; jump if revision is out of date!
ENDIF
   ; 3) Select the correct data set, based on temperature
   push  X                                ; save the X pointer
   REG_PRESERVE  IDX_PP                   ; save the X pointer page

   mov   A, [X+cARG_Temperature]          ; load temperature into the MULTIPLIER
   mov   REG[MUL0_X], A
   and   A, 80h                           ; Test for sign of temperature
   jnz   BelowZero

AboveZero:                                ; Positive temperature
   mov   A, [sTEMP_LineEquationAboveZero + bTEMP_ProgMultOffset]
   mov   [X+bDATA_PWMultiplier], A        ; Save the multiplier for later use
   mov   X, sTEMP_LineEquationAboveZero   ; X pts to Temp table above zero
   jmp   ComputeData

BelowZero:                                ; Negative temperature
   mov   A, [sTEMP_LineEquationBelowZero + bTEMP_ProgMultOffset]
   mov   [X+bDATA_PWMultiplier], A        ; Save the multiplier for later use
   mov   X, sTEMP_LineEquationBelowZero   ; X pts to Temp table data below zero

   ; 4) Compute the Erase PulseWidth count => PW(e) = B - M*T*2/256
ComputeData:
   RAM_SETPAGE_IDX  0                     ; set the X pointer page to pt to zero page
                                          ; where the temp table data is located.
   mov   A, [X+cTEMP_SlopeOffset]         ; compute M*T
   mov   REG[MUL0_Y], A
   mov   A, REG[MUL0_DL]                   ; compute M*T*2
   asl   A
   mov   A, REG[MUL0_DH]
   rlc   A                                ; A = M*T*2/256
   cpl   A                                ; 2's complement the data - complement and then increment
   inc   A                                ; A = -(M*T*2/256)
   add   A, [X+cTEMP_InterceptOffset]     ; Add it to B to compute PW(e) => B - (M*T*2/256) => ERASE PulseWidth
   mov   [bTEMP_PulseWidthErase], A       ; Save the Erase Pulse width in temp area

   ; 5) Compute the Program PulseWidth      PW(program) = PW(erase) * ProgramMultiplier / 64
   and   A, 7Fh                           ; Mac is signed - Erase pulse width MUST always be < 128
   mov   REG[MUL0_X], A                    ; compute PW(e) * ProgMult
   mov   A, [X+bTEMP_ProgMultOffset]      ; Mac is signed - First multiply by high 7 bits of ProgMult
   asr   A                                ; shift high 7 bits down to low 7 bits (divide by 2)
   and   A, 0x7f                          ; zero out high bit to make it an unsigned divide by 2
   mov   REG[MUL0_Y], A                    ; Do the 7 bit x 7 bit hardware multiply
.mult7x7done:
   mov   A, REG[MUL0_DH]                   ; Load 16 bit result into (PulseWidthProg, A)
   mov   [bTEMP_PulseWidthProgram], A
   mov   A, REG[MUL0_DL]
   asl   A                                ; Shift left to compensate for divide by 2 above
   rlc   [bTEMP_PulseWidthProgram]
.shift7x7done:
   tst   [X+bTEMP_ProgMultOffset], 0x01   ; If low bit of ProgMult was set (lost during divide by 2),
   jz    .mult7x8done                     ; add 1 * PulseWidthErase to product
   add   A, [bTEMP_PulseWidthErase]
   adc   [bTEMP_PulseWidthProgram], 0
.mult7x8done:                             ; PW(e) * ProgMult is in (PulseWidthProg, A)
   asl   A                                ; shift left twice to get
   rlc   [bTEMP_PulseWidthProgram]        ; 4 * PW(e) * ProgMult in (PulseWidthProg, A)
   asl   A                                ; or 4*PW(e)*ProgMult/256 == PW(e)*ProgMult/64 in PulseWidthProg
   rlc   [bTEMP_PulseWidthProgram]        ; The product MUST be < 2**14 for this to work.
                                          ; PW(p) = PW(e) * ProgMult / 64
   ; 6) Save the result data
SaveResultData:
   REG_RESTORE IDX_PP                     ; restore the XPP to point to the PW Data
   mov   A, [bTEMP_PulseWidthProgram]
   pop   X                                ; restore the X pointer
   mov   [X+bDATA_PWProgram], A           ; Save Program pulse width in BlockWrite calling frame
   mov   A, [bTEMP_PulseWidthErase]       ; Save Erase pulse width in BlockWrite calling frame
   mov   [X+bDATA_PWErase], A

   ; 7) Adjust the Pulse Width for SLIMO setting
AdjustForSLIMO:
   tst   reg[CPU_SCR1], CPU_SCR1_SLIMO    ; Check state of SLIMO
   jz    ComputePulseWidthEnd             ; if Z=0 then SLIMO NOT enabled - do nothing

   ;SLIMO is enabled - divide the pulsewidths by two and add one for round-off error
   asr   [X+bDATA_PWProgram]
   inc   [X+bDATA_PWProgram]
   asr   [X+bDATA_PWErase]
   inc   [X+bDATA_PWErase]

ComputePulseWidthEnd:                     ; NORMAL Termination
   pop   A                                ;  restore the STATE
   cmp   A, STATE_CALCULATE_PW            ;  make sure we are supposed to be here
   jnz   bFlashWriteStateError
   mov   [bSSC_WRITE_State], A            ;  restore the state variable
   mov   A, bSSC_SUCCESS                  ; load return value with success!
   ret

ComputePulseWidthTableError:              ; TABLE Error Termination
   pop   A                                ;  restore the STATE
   cmp   A, STATE_CALCULATE_PW            ;  make sure we are supposed to be here
   jnz   bFlashWriteStateError
   mov   [bSSC_WRITE_State], A            ;  restore the state variable
   mov   A, bSSC_FAIL                     ; load return value with Failure!
   ret

.ENDSECTION

;------------------------------------------------------------------------------
;   FUNCTION NAME: FlashReadBlock
;
;   DESCRIPTION:
;   Reads a specified flash block to a buffer in RAM.
;
;   ARGUMENTS:
;   A,X -> FLASH_READ_STRUCT
;
;   RETURNS:
;   Data read is returned at specified pFlashBuffer.
;
;   SIDE EFFECTS:
;   Uses SSC storage at FBh and FDh
;
;   PROCEDURE:
;   BlockID is converted to absolute address and then ROMX command is used
;   to read the data from flash into the specified buffer.
;
;------------------------------------------------------------------------------
.SECTION
 FlashReadBlock_internal:
_FlashReadBlock_internal:

   ; Preserve the SMM or LMM paging mode
   RAM_SETPAGE_CUR  0
   mov   [bTEMP_SPACE], A     ; temporarily store the MSB of the ReadBlock structure
   mov   A, reg[CPU_F]        ; grab the current CPU flag register and save on stack
   push  A
   and   a, c0h
   jnz   YesPaging
   ;  Enforce MSB to 0 when not in a paging mode
   mov   [X+pARG_FlashBuffer], 0
   mov   [bTEMP_SPACE], 0
YesPaging:

   mov   A, [bTEMP_SPACE]     ; restore the MSB of the WriteBlock structure

   ; Since the SSC operations all reference page 0, save and set the current ptr
   ; to page 0 and the X_ptr to track the stack page.
   RAM_PROLOGUE RAM_USE_CLASS_3
   RAM_SETPAGE_IDX  A

   ; mov some args to SSC storage

   mov   A, [X+pARG_FlashBuffer+1]    ; get pointer - LSB
   mov   [pSSC_READ_FlashBuffer],A    ; use SSC storage area
   mov   A, [X+pARG_FlashBuffer]      ; get pointer - MSB
   RAM_SETPAGE_MVW A                  ; set the MSB in the MVI Write Pointer
   mov   A, [X+wARG_ReadCount]        ; get count
   inc   A                            ; bump by one to account for testing
   mov   [wSSC_READ_Counter],A        ; use SSC storage area
   mov   A, [X+wARG_ReadCount+1]
   mov   [wSSC_READ_Counter+1],A

   ; Compute the absolute address of the flash block

   mov   A, [X+wARG_BlockId+1]        ; compute the LSB = wBlockId * 64
   asl   A
   rlc   [X+wARG_BlockId]
   asl   A
   rlc   [X+wARG_BlockId]
   asl   A
   rlc   [X+wARG_BlockId]
   asl   A
   rlc   [X+wARG_BlockId]
   asl   A
   rlc   [X+wARG_BlockId]
   asl   A
   rlc   [X+wARG_BlockId]

   push  A                            ; save LSB
   mov   A, [X+wARG_BlockId]          ; mov MSB into A
   pop   X                            ; put LSB into X

   ; Read the Flash
ReadFlash:
   push	 A                            ; save MSB
   romx                               ; Read the flash
   mvi   [pSSC_READ_FlashBuffer], A   ; store the data in the RAM buffer
   pop   A                            ; restore MSB
   inc   X                            ; increment the LSB of the flash addr
   jnz   TestCounter
   inc   A
TestCounter:
   dec   [wSSC_READ_Counter+1]        ; decrement the byte counter
   jnz   TestPageBoundary
   dec   [wSSC_READ_Counter]
   jz    ReadFlashDone                ; if counter is zero - done!

TestPageBoundary:                     ; Test Buffer pointer to see if the page ptr
   cmp   [pSSC_READ_FlashBuffer],0x00 ; has wrapped
   jnz   ReadFlash
   push  A
   mov   A, reg[MVW_PP]
   inc   A
   mov   reg[MVW_PP], A
   pop   A
   jmp   ReadFlash

   ; Done reading the flash
ReadFlashDone:
   RAM_EPILOGUE RAM_USE_CLASS_3

   ; set the CUR and MVW page pointer to zero to support both LMM and SMM
   RAM_SETPAGE_CUR 0                      ; cur_ptr page 
   RAM_SETPAGE_MVW 0                      ; MW_ptr page 

   ;return using RETI to be sure the SMM or LMM paging mode is restored
   reti
.ENDSECTION

ENDIF

;---------------------
;  End of File
;---------------------
