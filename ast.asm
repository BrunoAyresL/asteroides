extern cor, circle      ; render.asm
extern tabela_cos, tabela_sen   ; tabelas.asm

global render_asteroide, spawn_asteroide, asteroides, reseta_asteroides, limpar_asteroide
global ast_x, ast_y, ast_vivo, ast_size, max_asteroides

numero_rng:                                     ; gera um número pseudoaleatório usando LCG
        PUSH    BX                              ; salva contexto
        PUSH    DX

        MOV     AX, word [seed]                 ; pega a seed atual
        MOV     BX, 25173                       ; mutliplicador 
        MUL     BX                              ; DX:AX recebe AX * BX
        ADD     AX, 13849                       ; incremento 

        MOV     word [seed], AX                 ; salva a nova seed com os 16 bits baixos

        POP     DX                              ; recupera contexto
        POP     BX
        RET

spawn_asteroide:                                ; spawna um novo asteroide em uma das bordas do jogo, com velocidade aleatória 
        PUSH    AX                              ; salva contexto
        PUSH    BX
        PUSH    CX      
        PUSH    DX
        PUSH    SI

        MOV     CX, max_asteroides              ; itera por todos os asteroides
        MOV     SI, asteroides                  ; SI aponta para o endereço dos asteroides
loop_spawn:
        CMP     byte [SI + ast_vivo], 0         ; checa se o asteroide não está vivo
        JNE     continua_spawn                  ; se estiver, ignora

        MOV     byte [SI + ast_vivo], 1         ; altera o estado para vivo

        CALL    numero_rng                      ; gera um número aleatório
        MOV     AL, AH                          
        AND     AL, 3Fh                         ; pega os primeiros 6 bits (0-63)
        MOV     byte [SI + ast_angulo], AL

        CALL    ast_pos_aleatoria               ; gera a posição aleatória
        CALL    ast_vel_aleatoria               ; gera as velocidades aleatórias
        JMP     termina_spawn   

continua_spawn:
        ADD     SI, ast_size                    ; muda o offset do SI para o próximo asteroide
        LOOP    loop_spawn                      ; repete 

termina_spawn:
        POP     SI                              ; recupera contexto
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET

ast_pos_aleatoria:                              ; escolhe uma posição nas bordas do jogo para o asteroide
        CALL    numero_rng                      ; escolhe quadrante aleatório
        MOV     AL, AH                          ; pega os bits mais significativos
        AND     AL, 3                           ; 0, 1, 2 ou 3
        
        CMP     AL, 0                           ; 0 = esquerda
        JNE     spawn_direita

        CALL    numero_rng                      ; gera número aleatório 0-479
        MOV     BX, 480
        XOR     DX, DX
        DIV     BX                              ; limita o número entre 0 e 479
        MOV     word [SI + ast_x], 0            ; seta x na esquerda
        MOV     word [SI + ast_y], DX           ; seta y aleatório
        SUB     byte [SI + ast_angulo], 32      ; muda ângulo para direção do centro (-32, 31)

        JMP     fim_pos_aleatoria
spawn_direita:
        CMP     AL, 1                           ; 1 = direita
        JNE     spawn_cima

        CALL    numero_rng                      ; escolhe número aleatório 0-479
        MOV     BX, 480
        XOR     DX, DX
        DIV     BX                              ; limita o número entre 0 e 479
        MOV     word [SI + ast_x], 640          ; seta x na direita
        MOV     word [SI + ast_y], DX           ; seta y aleatório
        ADD     byte [SI + ast_angulo], 96      ; muda ângulo para direção do centro (96, 159)

        JMP     fim_pos_aleatoria 
spawn_cima:
        CMP     AL, 2                           ; 2 = cima
        JNE     spawn_baixo

        CALL    numero_rng                      ; escolhe número aleatório 0-639
        MOV     BX, 640
        XOR     DX, DX
        DIV     BX                              ; limita o número entre 0 e 639
        MOV     word [SI + ast_x], DX           ; seta x aleatório
        MOV     word [SI + ast_y], 480          ; seta y em cima
        SUB     byte [SI + ast_angulo], 96      ; muda ângulo para direção do centro (-96, 0)

        JMP     fim_pos_aleatoria

spawn_baixo:
        CALL    numero_rng                      ; escolhe número aleatório 0-640
        MOV     BX, 640
        XOR     DX, DX
        DIV     BX                              ; limita o número entre 0 e 639
        MOV     word [SI + ast_x], DX           ; seta x aleatório
        MOV     word [SI + ast_y], 0            ; seta y em baixo
        ADD     byte [SI + ast_angulo], 32      ; muda ângulo para direção do centro (32, 96)
fim_pos_aleatoria: 
        RET


ast_vel_aleatoria:                              ; escolhe uma velocidade para o asteroide baseada no ângulo definido antes
        CALL    numero_rng                      ; gera um número aleatório
        MOV     BX, 4                           
        XOR     DX, DX
        DIV     BX                              ; limita o número entre 0 e 3
        ADD     DX, 3                           ; muda intervalo de velocidade para 3-6

        MOV     BL, byte [SI + ast_angulo]      ; recebe o ângulo do asteroide
        XOR     BH, BH
        MOV     AL, [tabela_cos + BX]           ; calcula cos
        MOV     AH, DL
        IMUL    AH                              ; vx = vel * cos 
        SAR     AX, 7                           ; divide por 128 para ajustar a escala
        MOV     word [SI + ast_vx], AX          ; salva a velocidade x do asteroide
        MOV     AL, [tabela_sen + BX]           ; calcula sen
        MOV     AH, DL
        IMUL    AH                              ; vy = vel * sen 
        SAR     AX, 7                           ; divide por 128 para ajustar a escala
        MOV     word [SI + ast_vy], AX          ; salva a velocidade y do asteroide
        RET


render_asteroide:                               ; desenha e atualiza os asteroides
        PUSH    AX                              ; salva contexto
        PUSH    CX
        PUSH    SI
        
        MOV     CX, max_asteroides              ; itera por todos os asteroides
        MOV     SI, asteroides                  ; SI aponta para o endereço dos asteroides
loop_render:
        CMP     byte [SI + ast_vivo], 0         ; verifica se o asteróide é vivo
        JE      continua_render                 ; se não for, não desenha

        MOV     byte [cor], 0   
        PUSH    word [SI + ast_x]
        PUSH    word [SI + ast_y]
        MOV     AX, 16
        PUSH    AX
        CALL    circle                          ; apaga o desenho anterior do asteroide

        MOV     AX, word [SI + ast_vx]
        ADD     word [SI + ast_x], AX           ; soma a velocidade x na posição x

        MOV     AX, word [SI + ast_vy]
        ADD     word [SI + ast_y], AX           ; soma a velocidade y na posição y

        MOV     AX, [SI + ast_x]                ; verifica se está fora do espaço do jogo, se estiver, mata o asteroide
        CMP     AX, 0                           ; parede esquerda 
        JLE     matar_asteroide 
        CMP     AX, 640                         ; parede direita
        JGE     matar_asteroide    
        MOV     AX, [SI + ast_y]
        CMP     AX, 0                           ; parede baixo
        JLE     matar_asteroide
        CMP     AX, 480                         ; parede cima
        JGE     matar_asteroide
        JMP     fim_colisao

matar_asteroide:
        MOV     byte [SI + ast_vivo], 0         ; muda o estado para não vivo
        JMP     continua_render 
fim_colisao:
        MOV     byte [cor], 12                   ; cor rosa
        PUSH    word [SI + ast_x]               
        PUSH    word [SI + ast_y]
        MOV     AX, 16
        PUSH    AX              
        CALL    circle                          ; desenha o asteroide 

continua_render:
        ADD     SI, ast_size                    ; muda o offset do SI para o próximo asteroide
        LOOP    loop_render                     ; repete 

        POP     SI                              ; recupera contexto
        POP     CX
        POP     AX
        RET


reseta_asteroides:                              ; reseta o estado de todos os asteroides
        PUSH    CX                              ; salva contexto
        PUSH    SI
        MOV     CX, max_asteroides              ; itera por todos os asteroides
        MOV     SI, asteroides                  ; aponta para o endereço dos asteroides
loop_reset:
        MOV     byte [SI + ast_vivo], 0         ; mata o asteroide

        ADD     SI, ast_size                    ; muda o offset do SI para o próximo asteroide
        LOOP    loop_reset                      ; repete

        POP     SI                              ; recupera contexto
        POP     CX
        RET

limpar_asteroide:                               ; apaga o desenho e reseta um asteroide em SI
        PUSH    SI                              ; salva contexto
        MOV     byte [SI + ast_vivo], 0         ; mata o asteroide

        MOV     byte [cor], 0                   ; cor preta
        PUSH    word [SI + ast_x]               
        PUSH    word [SI + ast_y]
        MOV     AX, 16
        PUSH    AX              
        CALL    circle                          ; apaga circulo 

        POP     SI                              ; recupera contexto
        RET

segment data public

seed    dw      1234                            ; seed usada para gerar o número pseudoaleatório

max_asteroides  equ 20                          ; número máximo de asteroides vivos ao mesmo tempo


; asteriode: x, y, vx, vy, vivo, angulo  
ast_x           equ 0
ast_y           equ 2
ast_vx          equ 4
ast_vy          equ 6
ast_vivo        equ 8 
ast_angulo      equ 9
ast_size        equ 10

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



