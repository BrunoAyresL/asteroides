extern render_nave
extern nave_angulo, nave_movendo, nave_tras
extern iniciar_teclado, encerrar_teclado
extern render_asteroide, spawn_asteroide
extern checar_colisao
extern escrever_string

global key_q, key_a, key_d, key_w, key_s, key_p, dificuldade

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

; ---------- GAME LOOP ----------
        MOV CX, 0
game_loop:
        
		
        CMP     byte [key_q], 1
        JE      sair 
		CMP		byte [key_p], 1
		JNE 	checar_pausa
		XOR		byte [jogo_pausado], 1
		MOV		byte [key_p], 0
checar_pausa:
		CMP		byte [jogo_pausado], 1
		JE 		continua

		INC 	byte [contador_spawn]
		CMP 	byte [contador_spawn], 10
		JNE 	segue_loop
		MOV		byte [contador_spawn], 0
		CALL 	spawn_asteroide
segue_loop:
		CALL	checar_colisao
        CALL    render_nave
		CALL 	render_asteroide
  
		CMP 	byte [key_a], 1
		JNE		checar_d
		ADD		byte [nave_angulo], 2
checar_d:
		CMP 	byte [key_d], 1
		JNE		checar_w
		SUB		byte [nave_angulo], 2
checar_w:
		CMP 	byte [key_w], 1
		JNE		checar_s
		MOV		byte [nave_movendo], 1
checar_s:
		CMP 	byte [key_s], 1
		JNE		continua
		MOV		byte [nave_movendo], 1
		MOV		byte [nave_tras], 1
continua:

        JMP     game_loop

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
		MOV 	DL, 30
		
		MOV 	byte [cor], 1

		CALL 	escrever_string
		RET





;*******************************************************************

segment data public

cor		db		branco_intenso

;	I R G B COR
;	0 0 0 0 preto
;	0 0 0 1 azul
;	0 0 1 0 verde
;	0 0 1 1 cyan
;	0 1 0 0 vermelho
;	0 1 0 1 magenta
;	0 1 1 0 marrom
;	0 1 1 1 branco
;	1 0 0 0 cinza
;	1 0 0 1 azul claro
;	1 0 1 0 verde claro
;	1 0 1 1 cyan claro
;	1 1 0 0 rosa
;	1 1 0 1 magenta claro
;	1 1 1 0 amarelo
;	1 1 1 1 branco intenso

preto		    equ		0
azul		    equ		1
verde		    equ		2
cyan		    equ		3
vermelho	    equ		4
magenta		    equ		5
marrom		    equ		6
branco		    equ		7
cinza		    equ		8
azul_claro	    equ		9
verde_claro	    equ		10
cyan_claro	    equ		11
rosa		    equ		12
magenta_claro	equ		13
amarelo		    equ		14
branco_intenso	equ		15

modo_anterior	db		0
linha   	    dw  	0
coluna  	    dw  	0
deltax		    dw		0
deltay		    dw		0	

dificuldade		db		5

key_q db 0
key_a db 0
key_d db 0
key_w db 0
key_s db 0
key_p db 0
nave_vel_ang    dw 0
contador_spawn  db 0



estado_jogo			db 0			; define o estado atual do jogo
estado_menu 		equ 0
estado_jogando 		equ 1
estado_sair			equ 2
estado_gameover		equ 3
estado_pausado		equ 4

texto_pause db 'JOGO PAUSADO$', 0

;*************************************************************************
segment stack stack
		DW 		512
stacktop:
