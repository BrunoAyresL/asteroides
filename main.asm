extern render_nave
extern nave_angulo, nave_movendo, nave_tras
extern iniciar_teclado, encerrar_teclado
extern render_asteroide, spawn_asteroide
extern checar_colisao
extern escrever_string
extern cor

extern teclas, tecla_w, tecla_a, tecla_s, tecla_d, tecla_p, tecla_q, tecla_y, tecla_n, tecla_enter 
global estado_atual, estado_pausado

extern processar_entrada, atualizar_nave, atualizar_asteroides, render_jogo, vidas ; jogo.asm


segment code

;org 100h
..start:
        MOV     AX,data			;Inicializa os registradores
    	MOV 	DS,AX
    	MOV 	AX,stack
    	MOV 	SS,AX
    	MOV 	SP,stacktop

;Salvar modo corrente de video(vendo como esta o modo de video da maquina)
        MOV  	AH,0Fh
    	INT  	10h
    	MOV  	[modo_anterior],AL   

;Alterar modo de video para grafico 640x480 16 cores
    	MOV     AL,12h
   		MOV     AH,0
    	INT     10h

        CALL    iniciar_teclado

; ---------- MAIN LOOP ----------
main_loop:
        

verifica_sair:
		TEST	word [teclas], tecla_q
		JZ		verifica_gameover
		MOV		byte [estado_atual], estado_sair
		JMP 	verifica_estado
verifica_gameover:
		CMP 	byte [vidas], 0
		JA		verifica_estado
		MOV		byte [estado_atual], estado_gameover
		JMP 	verifica_estado

verifica_estado:
		; verificação do estado do jogo atual
		CMP 	byte [estado_atual], estado_menu
		JE 		loop_menu

		CMP		byte [estado_atual], estado_pausado
		JE 		loop_pausado

		CMP		byte [estado_atual], estado_gameover
		JE 		loop_gameover

		CMP		byte [estado_atual], estado_sair
		JE 		loop_sair

		CMP		byte [estado_atual], estado_jogando
		JE 		loop_jogo



loop_menu:
	
		JMP 	main_loop
loop_pausado:
		MOV 	byte [cor], 1
		CALL 	print_texto_pausado							; desenha texto de pause

		TEST	word [teclas], tecla_p						; checa se tecla p foi pressionada
		JZ		main_loop
		
		MOV 	AX, tecla_p
		NOT 	AX
		AND		word [teclas], AX							; retorna o input da tecla p
		MOV		byte [estado_atual], estado_jogando			; retorna o estado jogando

		MOV 	byte [cor], 0
		CALL 	print_texto_pausado							; apaga o texto de pause
		JMP 	main_loop
loop_gameover:
		
		JMP 	main_loop
loop_sair:
		JMP 	sair
loop_jogo:
		CALL	processar_entrada
		CALL 	atualizar_nave
		CALL	atualizar_asteroides
		CALL 	render_jogo



		JMP     main_loop

sair:
        CALL    encerrar_teclado
	    MOV  	AH,0   						; set video mode
	    MOV  	AL,[modo_anterior]   		; modo anterior
	    INT  	10h
		MOV     AX,4c00h
		INT     21h


print_texto_pausado:
		MOV		SI, texto_pause
		MOV		DH, 10
		MOV 	DL, 34
		CALL 	escrever_string
		RET


;*******************************************************************

segment data public

modo_anterior	db		0
linha   	    dw  	0
coluna  	    dw  	0
deltax		    dw		0
deltay		    dw		0	


nave_vel_ang    dw 0
contador_spawn  db 0



estado_atual		 db 1			; define o estado atual do jogo
estado_menu 		equ 0
estado_jogando 		equ 1
estado_sair			equ 2
estado_gameover		equ 3
estado_pausado		equ 4

texto_pause db 'JOGO PAUSADO', 0

;*************************************************************************
segment stack stack
		DW 		512
stacktop:
