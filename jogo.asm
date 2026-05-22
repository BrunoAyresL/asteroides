global processar_entrada, atualizar_nave, atualizar_asteroides, render_jogo
global ast_tempo_spawn, vidas, tempo

extern teclas, tecla_w, tecla_s, tecla_a, tecla_d, tecla_p	; teclado.asm
extern render_nave, nave_angulo, nave_movendo, nave_tras	; nave.asm
extern render_asteroide, spawn_asteroide	; ast.asm
extern checar_colisao	; colisao.asm
extern cor, line 	; render.asm
extern estado_atual, estado_pausado 	; main.asm

processar_entrada:								; interpreta a saída do teclado para o jogo
        TEST    word [teclas], tecla_w			; tecla W move a nave para frente
        JZ      checar_a
        MOV     byte [nave_movendo], 1
checar_a:
        TEST    word [teclas], tecla_a			; tecla A gira a nave para a esquerda
        JZ      checar_s
        ADD		byte [nave_angulo], 7
checar_s:
        TEST    word [teclas], tecla_s			; tecla S move a nave para trás
        JZ      checar_d
        MOV     byte [nave_movendo], 1
		MOV		byte [nave_tras], 1
checar_d:
        TEST    word [teclas], tecla_d			; tecla D gira a nave para a direita
        JZ      checar_p
        SUB     byte [nave_angulo], 7
checar_p:
		TEST	word [teclas], tecla_p			; tecla P pausa o jogo
		JZ		fim_entrada
		MOV		byte [estado_atual], 4
		MOV 	AX, tecla_p
		NOT 	AX
		AND		word [teclas], AX

fim_entrada:
		RET



atualizar_nave:
		CALL	checar_colisao						; checa a colisão entre asteroide - nave
		CALL    render_nave							; calcula a posição e desenha a nave
		RET

atualizar_asteroides:
		PUSH 	AX									; salva contexto
		INC 	word [ast_contador_spawn]			; incrementa o contador de spawn
		MOV		AX, word [ast_tempo_spawn]	
		CMP 	word [ast_contador_spawn], AX		; compara com o tempo definido pela dificuldade
		JNE 	atualizar_asteroides_fim
		MOV		byte [ast_contador_spawn], 0	
		CALL 	spawn_asteroide						; spawna 1 asteroide
atualizar_asteroides_fim:
		CALL 	render_asteroide					; calcula a posição e desenha os asteroides
		POP 	AX									; recupera contexto
		RET

render_jogo:										; desenha o HUD
		PUSH 	AX
		PUSH	CX
		PUSH 	DX
		PUSH 	SI


		MOV 	byte [cor], 7
		MOV		AX, 40
		PUSH	AX
		MOV 	AX, 40
		PUSH 	AX
		MOV 	AX, 600
		PUSH 	AX
		MOV 	AX, 40
		PUSH 	AX
        CALL    line  

		MOV		AX, 40
		PUSH	AX
		MOV 	AX, 40
		PUSH 	AX
		MOV 	AX, 40
		PUSH 	AX
		MOV 	AX, 440
		PUSH 	AX
        CALL    line  

		MOV		AX, 600
		PUSH	AX
		MOV 	AX, 40
		PUSH 	AX
		MOV 	AX, 600
		PUSH 	AX
		MOV 	AX, 440
		PUSH 	AX
        CALL    line  

		MOV		AX, 40
		PUSH	AX
		MOV 	AX, 440
		PUSH 	AX
		MOV 	AX, 600
		PUSH 	AX
		MOV 	AX, 440
		PUSH 	AX
        CALL    line  


		MOV 	SI, vida_hud_pontos
		MOV 	DX, 0
		
		MOV 	CL, byte [vidas]
		XOR 	CH, CH
		CMP 	CL, 0
		JBE		fim_render_jogo
desenhar_vidas:

		MOV		AX, word [vida_hud_pontos]
		ADD		AX, DX
		PUSH	AX
		MOV		AX, word [vida_hud_pontos + 2]
		PUSH 	AX
		MOV		AX, word [vida_hud_pontos + 4]
		ADD		AX, DX
		PUSH 	AX
		MOV		AX, word [vida_hud_pontos + 6]
		PUSH 	AX
        CALL    line  

		MOV		AX, word [vida_hud_pontos]
		ADD		AX, DX
		PUSH	AX
		MOV		AX, word [vida_hud_pontos + 2]
		PUSH 	AX
		MOV		AX, word [vida_hud_pontos + 8]
		ADD		AX, DX
		PUSH 	AX
		MOV		AX, word [vida_hud_pontos + 10]
		PUSH 	AX
        CALL    line  

		MOV		AX, word [vida_hud_pontos + 8]
		ADD		AX, DX
		PUSH	AX
		MOV		AX, word [vida_hud_pontos + 10]
		PUSH 	AX
		MOV		AX, word [vida_hud_pontos + 4]
		ADD		AX, DX
		PUSH 	AX
		MOV		AX, word [vida_hud_pontos + 6]
		PUSH 	AX
        CALL    line  

		ADD 	DX, 40
		LOOP	desenhar_vidas

fim_render_jogo:

		POP 	SI
		POP		DX
		POP 	CX
		POP 	AX
		RET


segment data 

ast_tempo_spawn				dw   30
ast_contador_spawn			dw   0
vidas       				db   3
tempo       				dw   0

vida_hud_pontos:
	dw 500, 450
	dw 510, 470
	dw 520, 450