extern tabela_sen   ; tabelas.asm
extern line, cor        ; render.asm
extern vidas    ; jogo.asm
extern reseta_asteroides        ; ast.asm
extern reseta_tiros     ; tiros.asm

global render_nave, matar_nave, nave_movendo
global nave_tras, nave_real, nave_vx, nave_vy, nave_angulo

render_nave:                                    ; desenha e apaga a nave
        MOV     byte [cor], 0                   
        CALL    desenha_nave                    ; apaga o desenho da nave

        CALL    atualizar_posicao               ; atualiza a nave
        CALL    transformar_pontos
        CALL    checar_colisao
        CALL    transformar_pontos

        MOV     byte [cor], 7                   ; desenha a nave em branco
        CALL    desenha_nave                                        
        RET

desenha_nave:                                   ; desenha o triângulo da nave
        PUSH    word [nave_real]
        PUSH    word [nave_real + 2]
        PUSH    word [nave_real + 4]
        PUSH    word [nave_real + 6]
        CALL    line                            ; desenha linha da nave

        PUSH    word [nave_real]
        PUSH    word [nave_real + 2]
        PUSH    word [nave_real + 8]
        PUSH    word [nave_real + 10]
        CALL    line                            ; desenha linha da nave
        
        PUSH    word [nave_real + 4]
        PUSH    word [nave_real + 6]
        PUSH    word [nave_real + 8]
        PUSH    word [nave_real + 10]
        CALL    line                            ; desenha linha da nave
        RET


atualizar_posicao:                              ; atualiza x e y baseado na velocidade
        PUSH    AX                              ; salva contexto
        PUSH    BX

        INC     byte [contador_mov]
        CMP     byte [contador_mov], 1          ; só atualiza a posição da nave a cada 3 ciclos
        JB      final_pos
        MOV     byte [contador_mov], 0

        CMP     byte [nave_movendo], 1          ; checa input W ou S
        JNE     final_pos

        MOV     AL, [nave_vel]                  ; usa a velocidade base da nave
        MOV     AH, byte [cos]                  ; calcula a velocidade em x baseada no ângulo 
        IMUL    AH                              ; vy = v * sen
        SAR     AX, 7                           ; divide por 128 para retornar a escala
        MOV     BX, AX                          ; salva resultado em BX
        
        MOV     AL, [nave_vel]                  ; usa a velocidade base da nave
        MOV     AH, byte [sen]                  ; calcula a velocidade em y baseada no ângulo 
        IMUL    AH                              ; vy = v * sen
        SAR     AX, 7                           ; divide por 128 para ajustar a escala

        CMP     byte [nave_tras], 1             ; se a tecla S foi pressionada
        JNE     soma_pos                        
        NEG     BX                              ; inverte velocidade em x
        NEG     AX                              ; inverte velocidade em y
soma_pos:
        MOV     word [nave_vx], BX              ; atualiza a velocidade
        MOV     word [nave_vy], AX
        ADD     word [nave_y],  AX              ; atualiza a posição
        ADD     word [nave_x],  BX

final_pos:
        MOV	byte [nave_movendo], 0
	MOV	byte [nave_tras], 0
        POP     BX                              ; recupera contexto
        POP     AX
        RET


checar_colisao:                         ; checa colisões com as paredes e corrije a posição da nave
        PUSH    AX                      ; salva o contexto
        PUSH    CX
        PUSH    SI

        MOV     SI, nave_real           ; SI -> x0, y0, x1, y1, x2, y2 dos pontos
        MOV     CX, 3                   ; loop nos 3 pontos da nave
colisao_ponto_x1:
        CMP     word [SI], 40            ; parede esquerda 
        JGE     colisao_ponto_x2        
        MOV     AX, 40   
        SUB     AX, word [SI]
        ADD     word [nave_x], AX       ; reposiciona a nave
colisao_ponto_x2:
        CMP     word [SI], 599         ; parede direita
        JLE     colisao_ponto_y1    
        MOV     AX, 599
        SUB     AX, word [SI]           ; reposiciona a nave
        ADD     word [nave_x], AX
colisao_ponto_y1:
        CMP     word [SI + 2], 40        ; parede baixo
        JGE     colisao_ponto_y2
        MOV     AX, 40
        SUB     AX, word [SI + 2]
        ADD     word [nave_y], AX       ; reposiciona a nave
colisao_ponto_y2:
        CMP     word [SI + 2], 439     ; parede cima
        JLE     fim_colisao
        MOV     AX, 439
        SUB     AX, [SI + 2]
        ADD     word [nave_y], AX       ; reposiciona a nave
fim_colisao:

        ADD     SI, 4                   ; vai para o próximo ponto
        LOOP    colisao_ponto_x1

        POP     SI      
        POP     CX
        POP     AX                      ; retorna o contexto
        RET



transformar_pontos:                     ; transforma os pontos do modelo da nave em pontos no espaço real
        PUSH    AX                      ; salva contexto
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    SI
        PUSH    DI

        CALL    calcular_sen_cos        ; calcula sen e cos para evitar repetição
        MOV     SI, nave_modelo         ; SI aponta para modelo
        MOV     DI, nave_real           ; DI aponta para real
        MOV     CX, 3                   ; loop nos 3 pontos

transf_ponto:

        MOV     AL, byte [SI]           ; x
        MOV     AH, byte [cos]          ; cos
        IMUL    AH                      ; x * cos
        MOV     BX, AX                  ; salva resultado

        MOV     AL, byte [SI + 1]       ; y 
        MOV     AH, byte [sen]          ; sen
        IMUL    AH                      ; y * sen
        SUB     BX, AX                  ; x * cos - y * sen
        SAR     BX, 7                   ; divide por 128 para ajustar a escala

        ADD     BX, word [nave_x]       ; adiciona posição do centro da nave
        MOV     word [DI], BX           ; salva em nave real

        MOV     AL, byte [SI]           ; x
        MOV     AH, byte [sen]          ; sen
        IMUL    AH                      ; x * sen
        MOV     BX, AX                  ; salva resultado

        MOV     AL, byte [SI + 1]       ; y
        MOV     AH, byte [cos]          ; cos
        IMUL    AH                      ; y * cos
        ADD     AX, BX                  ; x * sen + y * cos
        SAR     AX, 7                   ; divide por 128 para ajustar a escala

        ADD     AX, word [nave_y]       ; adiciona posição do centro da nave  
        MOV     word [DI + 2], AX       ; salva em nave real

        ADD     SI, 2
        ADD     DI, 4

        LOOP transf_ponto

        POP     DI                      ; recupera contexto
        POP     SI
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        
        RET

calcular_sen_cos:
        PUSH    AX                      ; salva contexto
        PUSH    BX

        MOV     BL, [nave_angulo]       ; usa o ângulo da nave (0-255)
        XOR     BH, BH                  ; usa só a parte baixa
        MOV     AL, [tabela_sen + BX]   ; usa a tabela_sen para achar o valor sen * 127
        MOV     [sen], AL               ; salva em sen
        ADD     BL, 64                  ; cos = sen (x + 90 graus)
        XOR     BH, BH
        MOV     AL, [tabela_sen + BX]   ; usa a tabela_sen para achar o valor cos * 127
        MOV     [cos], AL               ; salva em cos

        POP     BX                      ; recupera contexto
        POP     AX
        RET

matar_nave:
        MOV     word [nave_x], 320      ; retorna a nave para o meio
        MOV     word [nave_y], 240          
        MOV     byte [nave_angulo], 64  ; reseta o ângulo da nave
        DEC     byte [vidas]            ; diminui uma vida
        CALL    reseta_asteroides       ; mata todos asteroides
        CALL    reseta_tiros            ; mata todos os tiros
        MOV     AL,12h                  ; limpa a tela e pisca para indicar morte
   	MOV     AH,0
    	INT     10h
        RET


segment data

nave_x dw 320 
nave_y dw 240
nave_angulo db 64                       ; ângulo da nave de 0, 255 -> [0, 2pi)
nave_vx dw 0
nave_vy dw 0

nave_vel db 8

nave_movendo db 0
nave_tras db 0
contador_mov db 0

sen db 0
cos db 0

nave_modelo:                            ; pontos da nave em relação ao centro (0,0)
    db      -6, 8
    db      -6, -8
    db      14, 0

nave_real:                              ; pontos na tela
    dw      0, 0
    dw      0, 0 
    dw      0, 0
