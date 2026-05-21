extern dificuldade, cor, circle, tabela_cos, tabela_sen
global render_asteroide, spawn_asteroide, asteroides
global ast_x, ast_y, ast_vivo, ast_size, max_asteroides

numero_rng:                             ; número aleatório usando LCG
        PUSH    BX                      ; salva contexto
        PUSH    DX

        MOV     AX, word [seed]         ; pega a seed inicial
        
        MOV     BX, 25173               
        MUL     BX
        ADD     AX, 13849               ; LCG básico para definir aleatório

        MOV     word [seed], AX         ; salva a nova seed

        POP     DX                      ; recupera contexto
        POP     BX
        RET

spawn_asteroide:
        PUSH    AX                      ; salva contexto
        PUSH    BX
        PUSH    CX      
        PUSH    DX
        PUSH    SI

        MOV     CX, max_asteroides
        MOV     SI, asteroides
loop_spawn:
        CMP     byte [SI + ast_vivo], 0
        JNE     continua_spawn

        MOV     byte [SI + ast_vivo], 1

        CALL    numero_rng              ; angulo aleatório
        MOV     AL, AH
        AND     AL, 3Fh                 ; angulo 0 - 64 (0 - 89 graus)
        MOV     byte [SI + ast_angulo], AL

        CALL    ast_pos_aleatoria
        CALL    ast_vel_aleatoria
        JMP     termina_spawn

continua_spawn:
        ADD     SI, ast_size
        LOOP    loop_spawn
termina_spawn:
        POP     SI                      ; recupera contexto
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET

ast_pos_aleatoria:                      ; escolhe uma posição para o asteroide
        CALL    numero_rng              ; escolhe quadrante aleatório
        MOV     AL, AH                  ; pega os bits mais significativos
        AND     AL, 3                   ; 0, 1, 2 ou 3
        
        CMP     AL, 0                   ; 0 = esquerda
        JNE     spawn_direita

        CALL    numero_rng              ; escolhe número aleatório 0-480
        MOV     BX, 480
        XOR     DX, DX
        DIV     BX
        MOV     word [SI + ast_x], -20  ; seta x na esquerda
        MOV     word [SI + ast_y], DX   ; seta y aleatório
        SUB     byte [SI + ast_angulo], 32  ; muda ângulo para direção do centro

        JMP     fim_pos_aleatoria
spawn_direita:
        CMP     AL, 1                   ; 1 = direita
        JNE     spawn_cima

        CALL    numero_rng              ; escolhe número aleatório 0-480
        MOV     BX, 480
        XOR     DX, DX
        DIV     BX
        MOV     word [SI + ast_x], 660  ; seta x na direita
        MOV     word [SI + ast_y], DX   ; seta y aleatório
        ADD     byte [SI + ast_angulo], 96  ; muda ângulo para direção do centro

        JMP     fim_pos_aleatoria 
spawn_cima:
        CMP     AL, 2                   ; 2 = cima
        JNE     spawn_baixo

        CALL    numero_rng              ; escolhe número aleatório 0-640
        MOV     BX, 640
        XOR     DX, DX
        DIV     BX      
        MOV     word [SI + ast_x], DX   ; seta x aleatório
        MOV     word [SI + ast_y], 500  ; seta y em cima
        SUB     byte [SI + ast_angulo], 96  ; muda ângulo para direção do centro

        JMP     fim_pos_aleatoria

spawn_baixo:
        CALL    numero_rng              ; escolhe número aleatório 0-640
        MOV     BX, 640
        XOR     DX, DX
        DIV     BX      
        MOV     word [SI + ast_x], DX   ; seta x aleatório
        MOV     word [SI + ast_y], -20  ; seta y em baixo
        ADD     byte [SI + ast_angulo], 32  ; muda ângulo para direção do centro
fim_pos_aleatoria: 
        RET


ast_vel_aleatoria:                      ; escolhe uma velocidade para o asteroide
        CALL    numero_rng              ; velocidade aleatória 
        AND     AX, 3
        MOV     DX, AX                  

        MOV     BL, byte [SI + ast_angulo]
        XOR     BH, BH
        MOV     AL, [tabela_cos + BX]   ; calcula cos
        MOV     AH, DL
        IMUL    AH
        SAR     AX, 7
        MOV     word [SI + ast_vx], AX
        MOV     AL, [tabela_sen + BX]   ; calcula sen
        MOV     AH, DL
        IMUL    AH
        SAR     AX, 7
        MOV     word [SI + ast_vy], AX
        RET

render_asteroide:                       ; desenha os asteroides
        PUSH    AX                      ; salva contexto
        PUSH    CX
        PUSH    SI
        
        MOV     CX, max_asteroides
        MOV     SI, asteroides
loop_render:
        CMP     byte [SI + ast_vivo], 0
        JE      continua_render
        MOV     byte [cor], 0
        PUSH    word [SI + ast_x]
        PUSH    word [SI + ast_y]
        MOV     AX, 20
        PUSH    AX
        CALL    circle


        MOV     AX, word [SI + ast_vx]          ; atualiza posição em x
        ADD     word [SI + ast_x], AX

        MOV     AX, word [SI + ast_vy]          ; atualiza posição em y
        ADD     word [SI + ast_y], AX

        ; checa colisão
        MOV     AX, [SI + ast_x]
        CMP     AX, -20                         ; parede esquerda 
        JLE      matar_asteroide 
        CMP     AX, 660                         ; parede direita
        JGE      matar_asteroide    
        MOV     AX, [SI + ast_y]
        CMP     AX, -20                         ; parede baixo
        JLE      matar_asteroide
        CMP     AX, 500                         ; parede cima
        JGE      matar_asteroide
        JMP  fim_colisao

matar_asteroide:
        MOV     byte [SI + ast_vivo], 0 

        JMP     continua_render 
fim_colisao:

        MOV     byte [cor], 4                   ; cor vermelha
        PUSH    word [SI + ast_x]               
        PUSH    word [SI + ast_y]
        MOV     AX, 20
        PUSH    AX              
        CALL    circle                          ; desenha circulo (raio 20)


continua_render:
        ADD     SI, ast_size
        LOOP    loop_render

        POP     SI
        POP     CX
        POP     AX
        RET


segment data public

seed    dw      1234

max_asteroides  equ 6


; asteriode: x, y, vx, vy, vivo  
ast_x           equ 0
ast_y           equ 2
ast_vx          equ 4
ast_vy          equ 6
ast_vivo        equ 8 
ast_angulo      equ 9
ast_size        equ 10

ast_modelo:
        db  -10, 0
        db  -7,  7
        db   0,  10
        db   7,  7
        db  10,  0
        db   7, -7
        db   0, -10
        db  -7, -7

asteroides:
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



