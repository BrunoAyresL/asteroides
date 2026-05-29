extern iniciar_teclado, encerrar_teclado, teclas, tecla_q	; teclado.asm
extern main_menu, sair_menu, pause_menu, gameover_menu		; menu.asm
extern processar_entrada, atualizar_nave, atualizar_asteroides, atualizar_tiro, render_jogo, vidas ; jogo.asm

global estado_atual, estado_anterior, dificuldade, sair

segment code

..start:
        MOV     AX,data									; inicializa os registradores
    	MOV 	DS,AX
    	MOV 	AX,stack
    	MOV 	SS,AX
    	MOV 	SP,stacktop

        MOV  	AH,0Fh
    	INT  	10h
    	MOV  	[modo_anterior],AL   					; salva o modo de vídeo anterior

    	MOV     AL,12h									
   		MOV     AH,0
    	INT     10h										; altera o modo de vídeo para 640x480, 16 cores

        CALL    iniciar_teclado							; inicializa as interrupções de teclado

main_loop:
        
verifica_sair:
		TEST	word [teclas], tecla_q						; verifica a tecla q
		JZ		verifica_gameover							; se não foi pressionada, segue
		MOV		AL, byte [estado_atual]						
		MOV 	byte [estado_anterior], AL					; salva o estado atual como anterior
		MOV		byte [estado_atual], estado_sair			; muda o estado para sair
		MOV 	AX, tecla_q
		NOT 	AX
		AND		word [teclas], AX							; retorna o input da tecla q
		JMP 	verifica_estado
verifica_gameover:
		CMP 	byte [vidas], 0								; verifica se a vida chegou a 0
		JA		verifica_estado
		MOV		byte [estado_atual], estado_gameover		; muda o estado para gameover
		JMP 	verifica_estado

verifica_estado:											; verificação do estado do jogo atual
		CMP 	byte [estado_atual], estado_menu			; estado menu -> loop_menu
		JE 		loop_menu

		CMP		byte [estado_atual], estado_pausado			; estado pausado -> loop_pausado
		JE 		loop_pausado

		CMP		byte [estado_atual], estado_gameover		; estado gameover -> loop_gameover
		JE 		loop_gameover

		CMP		byte [estado_atual], estado_sair			; estado sair -> loop_sair
		JE 		loop_sair

		CMP		byte [estado_atual], estado_jogando			; estado jogando -> loop_jogo
		JE 		loop_jogo


loop_menu:
		CALL 	main_menu											
		JMP 	main_loop
loop_pausado:
		CALL 	pause_menu									
		JMP 	main_loop
loop_gameover:
		CALL 	gameover_menu								
		JMP 	main_loop
loop_sair:
		CALL 	sair_menu
		JMP 	main_loop
loop_jogo:													; realiza as atualizações do jogo
		CALL	processar_entrada
		CALL 	atualizar_nave
		CALL	atualizar_asteroides
		CALL 	atualizar_tiro
		CALL 	render_jogo
		JMP     main_loop

sair:
        CALL    encerrar_teclado							; termina de monitorar o teclado
	    MOV  	AH, 0   									
	    MOV  	AL, [modo_anterior]   						; muda o modo de vídeo para o anterior
	    INT  	10h
		MOV     AX, 4c00h
		INT     21h											; fecha o programa
		




;*******************************************************************

segment data public

modo_anterior		 db	0

dificuldade			 db	0

estado_atual		 db 0			
estado_anterior	     db 0 			
estado_menu 		equ 0
estado_jogando 		equ 1
estado_sair			equ 2
estado_gameover		equ 3
estado_pausado		equ 4


;*************************************************************************
segment stack stack
		DW 		512
stacktop:
