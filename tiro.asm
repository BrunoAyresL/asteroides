extern nave_real, nave_vx, nave_vy, nave_angulo ; nave.asm
extern tabela_sen       ; tabelas.asm
extern cor, circle      ; render.asm

global spawn_tiro, render_tiro, reseta_tiros, limpar_tiro
global tiros, tiro_x, tiro_y, tiro_size, tiro_vivo, max_tiros

spawn_tiro:                                     ; spawna um tiro na frente da nave com velocidade na mesma direção da nave
        PUSH    AX                              ; salva contexto
        PUSH    BX
        PUSH    CX      
        PUSH    DX
        PUSH    SI
        MOV     CX, max_tiros                   ; itera por todos os tiros
        MOV     SI, tiros                       ; SI aponta para o endereço dos tiros
loop_spawn:     
        CMP     byte [SI + tiro_vivo], 1        ; verifica se o tiro está vivo
        JE      continua_spawn                  ; se não, segue

        MOV     byte [SI + tiro_vivo], 1        ; altera o estado para vivo        

        MOV     AX, word [nave_real + 8]        ; posiciona tiro na frente da nave
        MOV     word [SI + tiro_x], AX
        MOV     AX, word [nave_real + 10]       ; posiciona tiro na frente da nave
        MOV     word [SI + tiro_y], AX          

        MOV     DL, 20                          ; DL = velocidade do tiro

        MOV     BL, byte [nave_angulo]          ; BL = angulo atual da nave
        ADD     BL, 64
        XOR     BH, BH
        MOV     AL, [tabela_sen + BX]           ; calcula cos
        MOV     AH, DL
        IMUL    AH                              ; vx = v * cos
        SAR     AX, 7                           ; divide por 128 para ajustar a escala
        MOV     word [SI + tiro_vx], AX         ; seta a velocidade do tiro em x

        MOV     BL, byte [nave_angulo]          ; BL = angulo atual da nave
        MOV     AL, [tabela_sen + BX]           ; calcula sen
        MOV     AH, DL
        IMUL    AH                              ; vy = v * sen
        SAR     AX, 7                           ; divide por 128 para ajustar a escala
        MOV     word [SI + tiro_vy], AX         ; seta a velocidade do tiro em y
        
        JMP     fim_spawn

continua_spawn:
        ADD     SI, tiro_size                   ; muda o offset do SI para o próximo tiro
        LOOP    loop_spawn                      ; repete

fim_spawn:
        POP     SI                              ; recupera contexto
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET

render_tiro:
        MOV     CX, max_tiros                   ; itera por todos os tiros
        MOV     SI, tiros                       ; SI aponta para o endereço dos tiros
loop_render:
        CMP     byte [SI + tiro_vivo], 0        ; verifica se o tiro está vivo
        JE      continua_render

        MOV     byte [cor], 0                   
        PUSH    word [SI + tiro_x]
        PUSH    word [SI + tiro_y]
        MOV     AX, tiro_raio
        PUSH    AX
        CALL    circle                          ; apaga o tiro na posição anterior

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
        MOV     byte [SI + tiro_vivo], 0        ; se o tiro está fora da tela, mata
        JMP     continua_render

desenha_tiro:
        MOV     AX, word [SI + tiro_vx]         ; soma a velocidade x na posição x
        ADD     word [SI + tiro_x], AX
        MOV     AX, word [SI + tiro_vy]         ; soma a velocidade y na posição y
        ADD     word [SI + tiro_y], AX

        MOV     byte [cor], 14
        PUSH    word [SI + tiro_x]
        PUSH    word [SI + tiro_y]
        MOV     AX, tiro_raio
        PUSH    AX
        CALL    circle                          ; desenha o tiro em amarelo

continua_render:
        ADD     SI, tiro_size                   ; muda o offset do SI para o próximo tiro
        LOOP    loop_render                     ; repete
        RET

reseta_tiros:                                   ; limpa todos os tiros
        PUSH    CX                              ; salva o contexto
        PUSH    SI
        MOV     CX, max_tiros                   ; itera por todos os tiros
        MOV     SI, tiros                       ; SI aponta para o endereço dos tiros
loop_reset:
        MOV     byte [SI + tiro_vivo], 0        ; mata todos os tiros

        ADD     SI, tiro_size                   ; muda o offset do SI para o próximo tiro
        LOOP    loop_reset                      ; repete
        POP     SI                              ; recupera o contexto
        POP     CX
        RET

limpar_tiro:                                    ; deleta um tiro em DI
        PUSH    DI                              ; salva o contexto
        MOV     byte [DI + tiro_vivo], 0        ; mata o tiro

        MOV     byte [cor], 0                   
        PUSH    word [DI + tiro_x]
        PUSH    word [DI + tiro_y]
        MOV     AX, tiro_raio
        PUSH    AX
        CALL    circle                          ; apaga o desenho do tiro

        POP     DI                              ; recupera o contexto
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