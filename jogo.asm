extern teclas, tecla_w, tecla_s, tecla_a, tecla_d, tecla_p, tecla_space	; teclado.asm
extern render_nave, nave_angulo, nave_movendo, nave_tras	; nave.asm
extern render_asteroide, spawn_asteroide, reseta_asteroides	; ast.asm
extern checar_colisao	; colisao.asm
extern cor, line, escrever_string, limpa_tela 	; render.asm
extern estado_atual, dificuldade 	; main.asm
extern render_tiro, spawn_tiro, reseta_tiros 		; tiro.asm

global processar_entrada, atualizar_nave, atualizar_asteroides, atualizar_tiro, render_jogo, reiniciar_jogo, inicia_jogo
global ast_tempo_spawn, vidas, tempo

inicia_jogo:										; lê a dificuldade escolhida e inicia o jogo
		CMP 	byte [dificuldade], 0				; verifica se a dificuldade é fácil
		JNE		dificuldade_media
		MOV 	word [ast_tempo_spawn], 30			; escolhe o tempo de spawn dos asteroides
dificuldade_media:
		CMP 	byte [dificuldade], 1				; verifica se a dificuldade é médio
		JNE		dificuldade_dificil
		MOV 	word [ast_tempo_spawn], 20			; escolhe o tempo de spawn dos asteroides
dificuldade_dificil:
		CMP 	byte [dificuldade], 2				; verifica se a dificuldade é difícil
		JNE		fim_inicia_jogo
		MOV 	word [ast_tempo_spawn], 12			; escolhe o tempo de spawn dos asteroides
fim_inicia_jogo:
		MOV 	byte [estado_atual], 1				; muda o estado para jogando
		CALL 	reiniciar_jogo						; reseta tudo para começar o jogo
		RET


processar_entrada:									; interpreta a saída do teclado para o jogo
        TEST    word [teclas], tecla_w				; tecla W move a nave para frente
        JZ      checar_a
        MOV     byte [nave_movendo], 1				; flag movendo da nave é alterada

checar_a:
        TEST    word [teclas], tecla_a				; tecla A gira a nave para a esquerda
        JZ      checar_s
        ADD		byte [nave_angulo], 5				; aumenta o ângulo da nave em 5

checar_s:
        TEST    word [teclas], tecla_s				; tecla S move a nave para trás
        JZ      checar_d
        MOV     byte [nave_movendo], 1				; flag movendo da nave é alterada
		MOV		byte [nave_tras], 1					; flag tras da nave é alterada

checar_d:
        TEST    word [teclas], tecla_d				; tecla D gira a nave para a direita
        JZ      checar_p
        SUB     byte [nave_angulo], 5				; diminui o ângulo da nave em 5

checar_p:
		TEST	word [teclas], tecla_p				; tecla P pausa o jogo
		JZ		checar_space
		MOV		byte [estado_atual], 4				; muda o estado para pausado
		MOV 	AX, tecla_p							; faz uma máscara de bits para alterar o estado da tecla
		NOT 	AX	
		AND		word [teclas], AX					; altera tecla_p para 0

checar_space:
		TEST 	word [teclas], tecla_space			; tecla space atira
		JZ 		fim_entrada
		MOV 	byte [atirando], 1					; flag atirando é alterada

fim_entrada:
		RET


atualizar_nave:										; roda as funções da nave e colisões
		CALL	checar_colisao						; checa a colisão entre asteroide - nave e asteroide - tiro
		CALL    render_nave							; calcula a posição e desenha a nave
		RET

atualizar_asteroides:								; roda as funções dos asteroides
		INC 	word [ast_contador_spawn]			; incrementa o contador de spawn do asteroide
		MOV		AX, word [ast_tempo_spawn]	

		CMP 	word [ast_contador_spawn], AX		; compara com o tempo definido pela dificuldade
		JNE 	atualizar_asteroides_fim
		MOV		byte [ast_contador_spawn], 0		; quando atingir o tempo definido, reinicia o contador
		CALL 	spawn_asteroide						; spawna 1 asteroide

atualizar_asteroides_fim:
		CALL 	render_asteroide					; calcula a posição e desenha os asteroides
		RET

atualizar_tiro:										; roda as funções dos tiros
		INC 	word [tiro_timer]					; incrementa o contador do tiro

		MOV 	AX, word [tiro_cooldown]
		CMP 	word [tiro_timer], AX 				; compara com o cooldown definido
		JB		continua_tiro

		MOV 	word [tiro_timer], 0				; quando acabar o cooldown, reinicia o contador

		CMP		byte [atirando], 0					; verifica a flag atirando
		JE   	continua_tiro

		MOV		byte[atirando], 0					; muda a flag atirando para 0
		CALL 	spawn_tiro							; spawna 1 tiro

continua_tiro:
		CALL 	render_tiro							; calcula a posição e desenha os tiros
		RET

render_jogo:										; desenha o HUD
		PUSH 	AX									; salva o contexto
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
        CALL    line  								; desenha as bordas em branco

		MOV		AX, 40
		PUSH	AX
		MOV 	AX, 40
		PUSH 	AX
		MOV 	AX, 40
		PUSH 	AX
		MOV 	AX, 440
		PUSH 	AX
        CALL    line  								; desenha as bordas em branco  							

		MOV		AX, 600
		PUSH	AX
		MOV 	AX, 40
		PUSH 	AX
		MOV 	AX, 600
		PUSH 	AX
		MOV 	AX, 440
		PUSH 	AX
        CALL    line  								; desenha as bordas em branco  

		MOV		AX, 40
		PUSH	AX
		MOV 	AX, 440
		PUSH 	AX
		MOV 	AX, 600
		PUSH 	AX
		MOV 	AX, 440
		PUSH 	AX
        CALL    line  								; desenha as bordas em branco  

		CALL 	atualiza_timer						; atualiza o timer
		CALL 	tempo2ascii							; converte o número do timer em ascii
		MOV		SI, texto_timer
		MOV		DH, 1
		MOV 	DL, 4
		CALL 	escrever_string						; exibe o timer na tela

		MOV 	SI, vida_hud_pontos					; SI aponta para o endereço dos pontos dos triângulos de vida
		MOV 	DX, 0								; DX é o offset no x entre as vidas desenhadas
		
		MOV 	CL, byte [vidas]					; CL = vidas
		XOR 	CH, CH
		CMP 	CL, 0								; se não tem vidas, continua
		JBE		fim_render_jogo
desenhar_vidas:
		MOV		AX, word [vida_hud_pontos]			
		ADD		AX, DX								; soma o offset ao x
		PUSH	AX
		MOV		AX, word [vida_hud_pontos + 2]
		PUSH 	AX
		MOV		AX, word [vida_hud_pontos + 4]
		ADD		AX, DX								; soma o offset ao x
		PUSH 	AX
		MOV		AX, word [vida_hud_pontos + 6]
		PUSH 	AX
        CALL    line  								

		MOV		AX, word [vida_hud_pontos]
		ADD		AX, DX								; soma o offset ao x
		PUSH	AX	
		MOV		AX, word [vida_hud_pontos + 2]
		PUSH 	AX
		MOV		AX, word [vida_hud_pontos + 8]
		ADD		AX, DX								; soma o offset ao x
		PUSH 	AX
		MOV		AX, word [vida_hud_pontos + 10]
		PUSH 	AX
        CALL    line  

		MOV		AX, word [vida_hud_pontos + 8]
		ADD		AX, DX								; soma o offset ao x
		PUSH	AX
		MOV		AX, word [vida_hud_pontos + 10]
		PUSH 	AX
		MOV		AX, word [vida_hud_pontos + 4]
		ADD		AX, DX								; soma o offset ao x
		PUSH 	AX
		MOV		AX, word [vida_hud_pontos + 6]
		PUSH 	AX
        CALL    line  								; desenha as linhas do triângulo

		ADD 	DX, 40								; adiciona o espaçamento do x para o próximo triângulo
		LOOP	desenhar_vidas						; repete

fim_render_jogo:
		POP 	SI									; recupera o contexto
		POP		DX
		POP 	CX
		POP 	AX
		RET


atualiza_timer:										; usa interrupções para atualizar o timer
		MOV 	AH, 00h								 
		INT		1Ah									; usa a interrupção 1Ah para pegar o tempo atual

		MOV 	AX, DX								
		SUB 	AX, [tick_atual]					; subtrai do tempo anterior para ver a diferença

		CMP 	AX, 18								; verifica se passaram 18 ticks
		JB 		fim_timer

		MOV 	word [tick_atual], DX				
		DEC		byte [tempo]						; diminui o timer em 1

fim_timer:
		RET


tempo2ascii:										; transforma o tempo em ascii
		MOV		AL, byte [tempo]					; AL = tempo
		XOR 	AH, AH
		XOR 	DX, DX
		MOV 	BX, 100								; BX = divisor
		DIV 	BX									; obtêm o primeiro algarismo (tempo // 100)

		ADD 	AL, '0'								; soma '0' para ajustar para ascii
		MOV 	byte [texto_timer], AL				; salva o valor em texto_timer

		MOV 	AX, DX								; pega o resto da divisão para seguir o algoritmo
		MOV 	BX, 10								; muda o divisor
		XOR		DX, DX
		DIV 	BX									; obtêm o segundo algarismo (tempo // 10)

		ADD 	AL, '0'								; soma '0' para ajustar para ascii	
		MOV 	[texto_timer + 1], AL				; salva o valor em texto_timer
		ADD	 	DL, '0'								; soma '0' para ajustar para ascii
		MOV		[texto_timer + 2], DL				; salva o valor em texto_timer

		RET

reiniciar_jogo:										; reinicia as variáveis do jogo
		CALL 	reseta_tiros						; mata todos os tiros
		CALL 	reseta_asteroides					; mata todos os asteroides
		MOV 	byte [vidas], 3						; retorna para 3 vidas
		MOV 	byte [tempo], 180					; retorna o timer
		MOV		word [ast_contador_spawn], 0		; zera o contador de spawn de asteroides
		CALL 	limpa_tela							; limpa a tela para piscar e remover textos e desenhos antigos
		RET


segment data 

atirando					db 	 0
tiro_cooldown				dw 	 6
tiro_timer					dw   0

ast_tempo_spawn				dw   30
ast_contador_spawn			dw   0
vidas       				db   3
tempo       				db   180
tick_atual					dw 	 0

texto_timer					db 	'000',0

vida_hud_pontos:
	dw 500, 450
	dw 510, 470
	dw 520, 450