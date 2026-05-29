global main_menu, sair_menu, pause_menu, gameover_menu

extern dificuldade, estado_atual, estado_anterior, sair   ; main.asm
extern cor, escrever_string     ; render.asm
extern inicia_jogo ; jogo.asm
extern teclas, tecla_w, tecla_a, tecla_s, tecla_d, tecla_p, tecla_q, tecla_y, tecla_n, tecla_enter, tecla_space 

main_menu:
		MOV 	byte [cor], 15
		CALL 	print_texto_menu							; desenha texto do menu

segue_main_menu:
		CMP 	byte [dificuldade], 0
		JNE		printa_facil
		MOV 	byte [cor], 14
printa_facil:
		MOV		SI, texto_facil
		MOV		DH, 14
		MOV 	DL, 37
		CALL 	escrever_string

		MOV 	byte [cor], 15
		CMP 	byte [dificuldade], 1
		JNE		printa_medio
		MOV 	byte [cor], 14
printa_medio:		
		MOV		SI, texto_medio
		MOV		DH, 16
		MOV 	DL, 37
		CALL 	escrever_string

		MOV 	byte [cor], 15
		CMP 	byte [dificuldade], 2
		JNE		printa_dificil
		MOV 	byte [cor], 14
printa_dificil:
		MOV		SI, texto_dificil
		MOV		DH, 18
		MOV 	DL, 36
		CALL 	escrever_string

testa_tecla_enter:
		TEST 	word [teclas], tecla_enter
		JZ 		testa_tecla_s
		CALL 	inicia_jogo


		JMP 	fim_main_menu

testa_tecla_s:
		TEST	word [teclas], tecla_s						; checa se tecla s foi pressionada
		JZ		testa_tecla_w
		INC 	byte [dificuldade]
		AND 	byte [dificuldade], 3
		
		MOV 	AX, tecla_s
		NOT 	AX
		AND		word [teclas], AX							; retorna o input da tecla s

testa_tecla_w:		
		TEST	word [teclas], tecla_w						; checa se tecla w foi pressionada
		JZ		seta_dificuldade
		DEC 	byte [dificuldade]
		AND 	byte [dificuldade], 3

		MOV 	AX, tecla_w
		NOT 	AX
		AND		word [teclas], AX							; retorna o input da tecla w
seta_dificuldade:

		CMP 	byte [dificuldade], 3
		JNE		fim_main_menu
		MOV 	byte [dificuldade], 0
fim_main_menu:
		RET

pause_menu:
		MOV 	byte [cor], 14
		CALL 	print_texto_pausado							; desenha texto de pause

		TEST	word [teclas], tecla_p						; checa se tecla p foi pressionada
		JZ		fim_pause_menu
		
		MOV 	AX, tecla_p
		NOT 	AX
		AND		word [teclas], AX							; retorna o input da tecla p
		MOV		byte [estado_atual], 1		            	; retorna o estado jogando

		MOV 	byte [cor], 0
		CALL 	print_texto_pausado							; apaga o texto de pause

fim_pause_menu:
		RET


sair_menu:
		MOV 	byte [cor], 11
		CALL 	print_texto_sair						; desenha texto do gameover 

		TEST	word [teclas], tecla_y						; checa se tecla y foi pressionada
		JZ		segue_sair_menu										; se foi, fecha o programa
		CALL 	sair
segue_sair_menu:		

		TEST 	word [teclas], tecla_n  					; checa se tecla n foi pressionada
		JZ		fim_sair_menu									; se não foi, segue o loop 

		MOV 	AL, byte [estado_anterior]
		MOV		byte [estado_atual], AL			; muda o estado para o anterior

		MOV 	byte [cor], 0
		CALL 	print_texto_sair						; apaga o texto 
fim_sair_menu:
		RET

gameover_menu:
		MOV 	byte [cor], 13
		CALL 	print_texto_gameover						; desenha texto do gameover 

		TEST	word [teclas], tecla_n						; checa se tecla n foi pressionada
		JZ		segue_gameover_menu							
		CALL    sair										; se foi, fecha o programa
segue_gameover_menu:
		TEST 	word [teclas], tecla_y						; checa se tecla y foi pressionada
		JZ		fim_gameover_menu							; se não foi, segue o loop 

		MOV		byte [estado_atual], 1          			; muda o estado para jogando
		CALL 	inicia_jogo								    ; reinicia o jogo
		MOV 	byte [cor], 0
		CALL 	print_texto_gameover						; apaga o texto 
fim_gameover_menu:
        RET

print_texto_gameover:
		MOV		SI, texto_gameover
		MOV		DH, 10
		MOV 	DL, 35
		CALL 	escrever_string
		MOV		SI, texto_gameover2
		MOV		DH, 18
		MOV 	DL, 28
		CALL 	escrever_string
		MOV		SI, texto_sim_ou_nao
		MOV		DH, 20
		MOV 	DL, 30
		CALL 	escrever_string
		RET

print_texto_sair:

		MOV		SI, texto_sair
		MOV		DH, 10
		MOV 	DL, 28
		CALL 	escrever_string
		MOV		SI, texto_sim_ou_nao
		MOV		DH, 18
		MOV 	DL, 30
		CALL 	escrever_string
		RET


print_texto_pausado:
		MOV		SI, texto_pause
		MOV		DH, 10
		MOV 	DL, 34
		CALL 	escrever_string
		MOV		SI, texto_pause2
		MOV		DH, 18
		MOV 	DL, 28
		CALL 	escrever_string
		RET
		RET


print_texto_menu:
		MOV		SI, texto_menu
		MOV		DH, 7
		MOV 	DL, 34
		CALL 	escrever_string
		MOV		SI, texto_menu2
		MOV		DH, 12
		MOV 	DL, 28
		CALL 	escrever_string
		RET


segment data 

texto_menu db 'ASTEROIDES', 0
texto_menu2 db 'SELECIONE A DIFICULDADE', 0
texto_facil db 'FACIL', 0
texto_medio db 'MEDIO', 0
texto_dificil db 'DIFICIL', 0

texto_pause db 'JOGO PAUSADO', 0
texto_pause2 db 'PRESSIONE P PARA RETOMAR', 0
texto_gameover db 'GAME OVER', 0
texto_gameover2 db 'DESEJA JOGAR NOVAMENTE?', 0
texto_sim_ou_nao db 'Y (SIM) ou N (NAO)', 0
texto_sair db 'DESEJA REALMENTE SAIR?', 0