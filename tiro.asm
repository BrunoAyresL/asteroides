extern nave_real, nave_vx, nave_vy, nave_angulo
extern tabela_cos, tabela_sen
extern cor, circle

global spawn_tiro, render_tiro, reseta_tiros, limpar_tiro
global tiros, tiro_x, tiro_y, tiro_size, tiro_vivo, max_tiros




spawn_tiro:
        PUSH    AX                              ; salva contexto
        PUSH    BX
        PUSH    CX      
        PUSH    DX
        PUSH    SI
        MOV     CX, max_tiros
        MOV     SI, tiros
loop_spawn:     
        CMP     byte [SI + tiro_vivo], 1
        JE      continua_spawn

        MOV     byte [SI + tiro_vivo], 1

        MOV     AX, word [nave_real + 8]
        MOV     word [SI + tiro_x], AX
        MOV     AX, word [nave_real + 10]
        MOV     word [SI + tiro_y], AX

        MOV     AX, word [nave_vx]
        MOV     word [SI + tiro_vx], AX
        MOV     AX, word [nave_vy]
        MOV     word [SI + tiro_vy], AX

        MOV     DL, 20                          ; velocidade do tiro

        MOV     BL, byte [nave_angulo]
        XOR     BH, BH
        MOV     AL, [tabela_cos + BX]                   ; calcula cos
        MOV     AH, DL
        IMUL    AH
        SAR     AX, 7
        MOV     word [SI + tiro_vx], AX
        MOV     AL, [tabela_sen + BX]                   ; calcula sen
        MOV     AH, DL
        IMUL    AH
        SAR     AX, 7
        MOV     word [SI + tiro_vy], AX
        
        JMP     fim_spawn

continua_spawn:

        ADD     SI, tiro_size
        LOOP    loop_spawn

fim_spawn:
        POP     SI                               ; recupera contexto
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET

render_tiro:
        MOV     CX, max_tiros
        MOV     SI, tiros
loop_render:

        CMP     byte [SI + tiro_vivo], 0
        JE      continua_render

        MOV     byte [cor], 0
        PUSH    word [SI + tiro_x]
        PUSH    word [SI + tiro_y]
        MOV     AX, tiro_raio
        PUSH    AX
        CALL    circle

        ; checa colisão
        MOV     AX, [SI + tiro_x]
        CMP     AX, 39                           ; parede esquerda 
        JLE     matar_tiro 
        CMP     AX, 601                          ; parede direita
        JGE     matar_tiro    
        MOV     AX, [SI + tiro_y]
        CMP     AX, 39                           ; parede baixo
        JLE     matar_tiro
        CMP     AX, 441                          ; parede cima
        JGE     matar_tiro
        JMP     desenha_tiro        

matar_tiro:
        MOV     byte [SI + tiro_vivo], 0
        JMP     continua_render

desenha_tiro:

        MOV     AX, word [SI + tiro_vx]
        ADD     word [SI + tiro_x], AX
        MOV     AX, word [SI + tiro_vy]
        ADD     word [SI + tiro_y], AX

        MOV     byte [cor], 14
        PUSH    word [SI + tiro_x]
        PUSH    word [SI + tiro_y]
        MOV     AX, tiro_raio
        PUSH    AX
        CALL    circle


continua_render:

        ADD     SI, tiro_size
        LOOP    loop_render
        RET

reseta_tiros:
        PUSH    CX
        PUSH    SI
        MOV     CX, max_tiros
        MOV     SI, tiros
loop_reset:

        MOV     byte [SI + tiro_vivo], 0         ; mata todos os tiros

        ADD     SI, tiro_size
        LOOP    loop_reset
        POP     SI
        POP     CX
        RET

limpar_tiro:
        PUSH    DI
        MOV     byte [DI + tiro_vivo], 0

        MOV     byte [cor], 0           
        PUSH    word [DI + tiro_x]
        PUSH    word [DI + tiro_y]
        MOV     AX, tiro_raio
        PUSH    AX
        CALL    circle

        POP     DI
        RET


segment data

max_tiros        equ 20

tiro_x           equ 0
tiro_y           equ 2
tiro_vx          equ 4
tiro_vy          equ 6
tiro_vivo        equ 8 
tiro_angulo      equ 9
tiro_size        equ 10

tiro_raio        equ 1

tiros:
        db 0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0            
        db 0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0   
        db 0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0   
        db 0,0,0,0,0,0,0,0,0,0