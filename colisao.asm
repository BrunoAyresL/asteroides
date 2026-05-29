extern nave_real, matar_nave    ; nave.asm
extern asteroides, ast_x, ast_y, ast_vivo, ast_size, max_asteroides, limpar_asteroide   ; ast.asm
extern tiros, tiro_x, tiro_y, tiro_vivo, tiro_size, max_tiros, limpar_tiro      ; tiro.asm

global checar_colisao   

; (x - xc)^2 + (y - yc)^2 <= R^2

checar_colisao:                                 ; checa a colisão entre asteroide e nave, e asteroide e tiro
        MOV     CX, max_asteroides              ; itera por todos os asteroides
        MOV     SI, asteroides                  ; SI aponta para o endereço dos asteroides
colisao:
        PUSH    CX                              ; salva o CX do loop externo (asteroides)
        CMP     byte [SI + ast_vivo], 0         ; verifica se o asteroide está vivo
        JE      proximo_asteroide               ; se não, segue para o próximo
        MOV     CX, 3                           ; itera pelos 3 pontos da nave
        MOV     DI, nave_real                   ; DI aponta para o endereço dos pontos da nave
colisao_ponto:                                  
        MOV     AX, word [DI]                   ; AX = ponto_x
        SUB     AX, word [SI + ast_x]           ; AX = ponto_x - ast_x

        CMP     AX, 20                          ; verifica se o ponto está muito longe
        JG      continua_colisao_ponto          ; se estiver longe, não calcula mais e segue
        CMP     AX, -20 
        JL      continua_colisao_ponto          ; se estiver longe, não calcula mais e segue

        IMUL    AX                              ; DX:AX = (ponto_x - ast_x)^2
        MOV     word [dist_x], AX               ; salva a parte baixa da conta em dist_x
        MOV     word [dist_x + 2], DX           ; salva a parte  alta da conta em dist_x + 2
                   
        MOV     AX, word [DI + 2]               ; AX = ponto_y
        SUB     AX, word [SI + ast_y]           ; AX = ponto_y - ast_y
        IMUL    AX                              ; DX:AX = (ponto_y - ast_y)^2

        ADD     AX, word [dist_x]               ; soma parte baixa de AX e dist_x
        ADC     DX, word [dist_x + 2]           ; soma parte  alta de AX e dist_x

        CMP     DX, 0                           ; se DX for diferente de 0, a distância é muito grande
        JNE     continua_colisao_ponto

        CMP     AX, 256                         ; se AX é maior que o raio do asteroide, não existe colisão
        JA      continua_colisao_ponto  

        CALL    matar_nave                      ; colidiu, portanto a nave perde uma vida
        JMP     fim_colisao_ponto

continua_colisao_ponto:
        ADD     DI, 4                           ; muda o offset em DI para o próximo ponto
        LOOP    colisao_ponto                   ; repete

fim_colisao_ponto:                              
        CALL    checar_tiros                    ; faz o mesmo algoritmo, porém com os tiros
proximo_asteroide:
        ADD     SI, ast_size
        POP     CX
        LOOP    colisao
        RET


checar_tiros:
        MOV     CX, max_tiros                   ; itera por todos os tiros
        MOV     DI, tiros                       ; DI aponta para o endereço dos tiros
colisao_tiro:
        CMP     byte [DI + tiro_vivo], 0        ; verifica se tiro está vivo
        JE      continua_colisao_tiro           ; se não, segue para o próximo


        MOV     AX, word [DI + tiro_x]          ; AX = tiro_x
        SUB     AX, word [SI + ast_x]           ; AX = tiro_x - ast_x

        CMP     AX, 20                          ; verifica se o tiro está muito longe
        JG      continua_colisao_tiro           ; se estiver longe, não calcula mais e segue
        CMP     AX, -20 
        JL      continua_colisao_tiro           ; se estiver longe, não calcula mais e segue
        
        IMUL    AX                              ; DX:AX = (tiro_x - ast_x)^2
        MOV     word [dist_x], AX               ; salva a parte baixa da conta em dist_x
        MOV     word [dist_x + 2], DX           ; salva a parte  alta da conta em dist_x + 2
                   
        MOV     AX, word [DI + tiro_y]          ; AX = tiro_y
        SUB     AX, word [SI + ast_y]           ; AX = tiro_y - ast_y
        IMUL    AX                              ; DX:AX = (tiro_y - ast_y)^2

        ADD     AX, word [dist_x]               ; soma parte baixa de AX e dist_x
        ADC     DX, word [dist_x + 2]           ; soma parte  alta de AX e dist_x

        CMP     DX, 0                           ; se DX for diferente de 0, a distância é muito grande
        JNE     continua_colisao_tiro

        CMP     AX, 289                         ; se AX é maior que o raio do asteroide + raio do tiro, não existe colisão
        JA      continua_colisao_tiro  

        CALL    limpar_asteroide                ; colidiu, portanto o asteroide morre
        CALL    limpar_tiro                     ; colidiu, portanto o tiro morre
        JMP     fim_colisao_tiro  

continua_colisao_tiro:
        ADD     DI, tiro_size                   ; muda o offset em DI para o próximo tiro
        LOOP    colisao_tiro                    ; repete
fim_colisao_tiro:
        RET



segment data

dist_x dw 0, 0                                  ; variável temporária para o cálculo de distância