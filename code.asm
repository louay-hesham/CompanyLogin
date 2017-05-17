
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

      .MODEL SMALL
      .STACK 64
;-----------------
      .DATA                             
DATA2 DB  5,?,5 DUP (?)       
DATA3 DB 'ENTER YOUR ID: ','$'        
DATA1 DB '0123456789ABCDEFabcdef?'
DATA4 DB 'ERROR:THE ID NUMBER MUST BE 4 DIGIT HEXA','$'
DATA5 DB ''WRONG ENTRY'Your ID must contain data from 0-->9 or A-->F','$'   
DATA6 DW 0AAAAH,0BBBBH,0CCCCH,0DDDDH,0EEEEH,0FFFFH,1111H,2222H,3333H,4444H,5555H,6666H,7777H,8888H,9999H,0100H,0200H,0300H,0400H,5667H
DATA8 DW 1H,2H,3H,4H,5H,6H,0AH,0BH,0CH,0DH,0FH,0EH,1H,2H,3H,0AH,0BH,0CH,0DH,0AH
DATAA DB 'Your ID is wrong, Please try again!!','$' 
DATAB DB 'ENTER YOUR PASSWORD: ','$'   
DATAC DB 2,?,2 DUP (?)        
DATAD DB 'LOGIN SUCCESSFUL!','$' 
DATAE DB 'WRONG PASSWORD,TRY AGAIN','$'     
DATAF DB 00H
DATAG DB '---------------------------------------------------------------','$'    
;-----------------
               .CODE
MAIN             PROC FAR      
                 MOV AX,@DATA            ;move offset of data segment to AX
                 MOV DS,AX               ;Mov AX to DS
                 MOV ES,AX               ;Make DS and ES OVERLAPPED
                 MOV  DH,00H             ;Initialize DH With zeros
                 MOV  BP,OFFSET DATAF    ;Mov Offset dataf to BP to use it in setting cursor
START:           CALL SETCURSOR          ;Call SETCURSOR procedure 
ID:              CALL WELCOME            ;Call WELCOME
                 CALL GET_IN             ;Call GET_IN , bta5od el ID
                 CALL NO.LET             ;Call NO.LET , bishof en kan elrakm ely md5lo 4 arkam wla a2l
                 CALL CHECK              ;Call CHECK , bi-check iza kan elrakm ely d5lto in range (0-->9 aw a-->f aw A-->F) wla la2
                 MOV  SI,OFFSET DATA2+2  ;Initialize SI to point to the ID data in memory
                 CALL PUTIDINAX          ;Call PUTINAX, bt7ot el ID ely gy mn elmemory f AX 
                 CALL CHECKID            ;Call CHECKID , bi-check 3la el ID en kan sa7 wla 3'lt
                 CALL SETCURSOR          ;Call SETCURSOR, 3mltha tany 3shan yzbt elklam ,ynzl satr gdid w kda
                 CALL GETPASS            ;Call GETPASS ,elproc di hta5od mn el user el password
                 MOV  SI,OFFSET DATAC+2  ;Initialize, SI to point to datac in memory
                 CALL PUTPASSINAX        ;Call PUTINAX, bt7ot el password ely gy mn elmemory f AX 
                 CALL CHECKPASS          ;Call CHECKPASS, bi-check en kan elpassword sa7 wla 3'lt
                 CALL SETCURSOR          ;Call SETCURSOR, bizbt elklam ely bizhr 3la elDOS
                 CALL ENTER              ;Call ENTER, lw elpassword sa7 bitl3lo gomla 3la elshasha
NO_EROR:         CALL SETCURSOR          ;As shown before
                 CALL NOEROR             ;the entered nmber is less than 4!!
WR_ENT:          CALL SETCURSOR          ;As shown before
                 CALL WRONGENTRY         ;the number is between 0 --> 9 or a --> f or A --> F
WRONGID:         CALL SETCURSOR
                 CALL WRONG_ID
WRONGPASS:       CALL SETCURSOR
                 CALL WRONG_PW
OPERA:           MOV  AH,4CH
                 INT 21H
MAIN             ENDP        
;----------------     
SETCURSOR        PROC 
                 MOV AH,02H
                 MOV BH,00
                 MOV DL,00
                 MOV DH,DS:[BP]   ;coloumn   ;row
                 INT 10H
                 ADD DS:[BP],1
                 RET
SETCURSOR        ENDP
;----------------
WELCOME          PROC     
                 MOV AH,09H
                 LEA DX,DATA3
                 INT 21H
                 RET
WELCOME          ENDP      
;---------------- 
GET_IN           PROC
                 MOV AH,0AH
                 MOV DX,OFFSET DATA2
                 INT 21H 
                 RET
GET_IN           ENDP    
;----------------
NO.LET           PROC
                 LEA SI,DATA2+1
                 CMP [SI],04H
                 JNZ NO_EROR 
                 RET       
NO.LET           ENDP         
;----------------        
CHECK            PROC
                 MOV AH,4
                 LEA SI,DATA2+2
AGAIN:           LEA DI,DATA1
                 MOV CX,23  
                 MOV AL,[SI]
                 REPNZ SCASB
                 CMP CX,00
                 JZ  END
                 INC SI
                 DEC AH
                 JNZ AGAIN 
                 RET
END:             JMP WR_ENT       
CHECK            ENDP
;---------------- 
NOEROR           PROC
                 MOV AH,09H
                 MOV DX,OFFSET DATA4
                 INT 21H  
                 CALL 5AT
                 JMP START
                 RET
NOEROR           ENDP
;---------------    
WRONGENTRY       PROC    
                 MOV AH,09H
                 MOV DX,OFFSET DATA5
                 INT 21H 
                 CALL 5AT
                 JMP START
                 RET
WRONGENTRY       ENDP
;--------------
PUTIDINAX          PROC                  
                 MOV CX,04H
AGAIN2:          CMP [SI],39H
                 JZ  ZERO
                 JB  ZERO         
                 JA  OVER    
ZERO:            SUB [SI],30H
                 JMP STAR         
OVER:            CMP [SI],70
                 JZ  CAPITAL
                 JB  CAPITAL
                 JA  SMALL
CAPITAL:         SUB [SI],55
                 JMP STAR 
SMALL:           SUB [SI],87
                 JMP STAR       
STAR:            INC SI 
                 DEC CX   
                 JNZ AGAIN2       
                 SUB SI,4
                 MOV AH,[SI]
                 MOV AL,[SI+2]
                 MOV BH,[SI+1]
                 MOV BL,[SI+3]
                 SHL AX,4
                 OR  AX,BX  
                 RET
PUTIDINAX          ENDP
;--------------
PUTPASSINAX      PROC                  
                 CMP [SI],39H
                 JZ  ZEROP
                 JB  ZEROP         
                 JA  OVERP    
ZEROP:           SUB [SI],30H
                 JMP STARP         
OVERP:           CMP [SI],70
                 JZ  CAPITALP
                 JB  CAPITALP
                 JA  SMALLP
CAPITALP:        SUB [SI],55
                 JMP STARP 
SMALLP:          SUB [SI],87
                 JMP STARP       
STARP:           MOV AL,[SI]
                 RET
PUTPASSINAX      ENDP
;--------------         
CHECKID          PROC
                 MOV CX,21            ; Set the counter to 21 decimal
                 LEA DI,DATA6         ; DI = OFFSET DATA6
                 CLD                  ; DF = 0 (AUTO INCREAMENT)
                 REPNE SCASW          ; Check if the ID exists or not
                 CMP CX,0000H         ; Check if the ID exists or not
                 JZ WRONGID           ; If not exists jump to WRONGID
                 RET          
CHECKID          ENDP
;--------------
WRONG_ID         PROC 
                 MOV AH,09H
                 MOV DX,OFFSET DATAA
                 INT 21H     
                 CALL 5AT
                 JMP START
                 RET
WRONG_ID         ENDP
;-------------
GETPASS          PROC
                 MOV AH,09H
                 MOV DX,OFFSET DATAB
                 INT 21H   
                 MOV AH,0AH
                 MOV DX,OFFSET DATAC
                 INT 21H
                 RET             
GETPASS          ENDP
;-------------
CHECKPASS        PROC   
                 MOV BL,AL
                 ADD DI,38            ; If exist, jump to the password which equivalent to that ID
                 CMP BL,[DI]          ; Check if the password correct or not
                 JNZ WRONGPASS 
                 RET
CHECKPASS        ENDP      
;-------------
ENTER            PROC
                 MOV AH,09H
                 MOV DX,OFFSET DATAD
                 INT 21H 
                 CALL 5AT 
                 JMP START
                 RET
ENTER            ENDP
;------------          
WRONG_PW         PROC
                 MOV AH,09H
                 MOV DX,OFFSET DATAE
                 INT 21H   
                 CALL 5AT
                 JMP START
WRONG_PW         ENDP     
;------------  
5AT              PROC  
                 CALL SETCURSOR
                 MOV AH,09H
                 MOV DX,OFFSET DATAG
                 INT 21H
                 RET
5AT              ENDP
;-----------       
CHECKCONFIRM     PROC  
                 CLD
                 MOV SI,OFFSET DATAC+2
                 MOV DI,OFFSET DATAP+2
                 MOV CX,05H
                 REPE CMPSB 
                 CMP CX,0000H
                 RET
CHECKCONFIRM     ENDP
;-------------
                 END MAIN

ret




