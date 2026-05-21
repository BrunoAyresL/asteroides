extern nave_real, matar_nave
extern asteroides, ast_x, ast_y, ast_vivo, ast_size, max_asteroides

global checar_colisao

; (x - xc)^2 + (y - yc)^2 <= R^2 
; R = 20

checar_colisao:
        MOV     CX, max_asteroides
        MOV     SI, asteroides
colisao:
        CMP     byte [SI + ast_vivo], 0
        PUSH    CX
        JE      continua_colisao 
        MOV     CX, 3
        MOV     DI, nave_real
colisao_ponto:

        MOV     AX, word [DI]               ; x
        SUB     AX, word [SI + ast_x]       ; x - xc
        IMUL    AX
        MOV     word [dist_x], AX           ; dist_x LOW
        MOV     word [dist_x + 2], DX       ; dist_x HIGH
                    ; resultado = DX:AX
        MOV     AX, word [DI + 2]
        SUB     AX, word [SI + ast_y]
        IMUL    AX

        ADD     AX, word [dist_x]
        ADC     DX, word [dist_x + 2]

        CMP     DX, 0
        JNE     continua_colisao_ponto

        CMP     AX, 400
        JA      continua_colisao_ponto  

        CALL    matar_nave
        JMP     continua_colisao

  
continua_colisao_ponto:
        ADD     DI, 4
        LOOP    colisao_ponto

continua_colisao:
        ADD     SI, ast_size
        POP     CX
        LOOP    colisao
        RET

segment data

dist_x dw 0, 0