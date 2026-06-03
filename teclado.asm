global teclas, tecla_w, tecla_a, tecla_s, tecla_d, tecla_p, tecla_q, tecla_y, tecla_n, tecla_enter, tecla_space
global iniciar_teclado, encerrar_teclado

segment code

iniciar_teclado:
	CLI	
        XOR     AX, AX
        MOV     ES, AX
        MOV     AX, [ES:INT9*4]
        MOV     [offset_dos], AX 
        MOV     AX, [ES:INT9*4+2] 
        MOV     [cs_dos], AX			; Salva na variável cs_dos o valor do CS do vector de INTerrupção 9     
        MOV     [ES:INT9*4+2], CS		; Atualiza o valor do CS do vector de INTerrupção 9 com o CS do programa atual 
        MOV     WORD [ES:INT9*4],keyINT	        ; Atualiza o valor do IP do vector de INTerrupção 9 com o offset "keyINT" do programa atual
        STI					; Habilita INTerrupções por hardware - pin INTR SIM atende INTerrupções externas
        RET


encerrar_teclado:				; Ao sair do programa temos que restaurar o CS:IP da INTerrupção 9, que incialmente alteramos nas linhas 26 e 27
        CLI					; Deshabilita INTerrupções por hardware - pin INTR NÃO atende INTerrupções externas
        XOR     AX, AX				; Limpa o registrador AX, é equivalente a fazer "MOV AX,0"				
        MOV     ES, AX				; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
        MOV     AX, [cs_dos]			; Carrega em AX o valor do CS do vector de INTerrupção 9 que foi salvo na variável cs_dos -> linha 25
        MOV     [ES:INT9*4+2], AX		; Atualiza o valor do CS do vector de INTerrupção 9 que foi salvo na variável cs_dos
        MOV     AX, [offset_dos]		; Carrega em AX o valor do IP do vector de INTerrupção 9 que foi salvo na variável offset_dos -> linha 23
        MOV     [ES:INT9*4], AX 		; Atualiza o valor do IP do vector de INTerrupção 9 que foi salvo na variável offset_dos
        STI
        RET					; Chama Interrupção 21h para retornar o controle ao sistema operacional -> sai de forma segura da execução do programa


keyINT:			                	; Interrupção que roda quando tecla é pressionada
        PUSH    AX	
        PUSH    DS
        MOV     AX, SEG teclas
        MOV     DS, AX			        ; lê o valor da tecla
        IN      AL, kb_data
a_press:                                        ; verifica cada tecla relevante pro jogo, se foi pressionada ou solta
        CMP     AL, 1Eh
        JNE     a_break
        OR      word [teclas], tecla_a
a_break:
        CMP     AL, 9Eh
        JNE     d_press
        MOV     AX, tecla_a     
        NOT     AX
        AND     word [teclas], AX
d_press:
        CMP     AL, 20h
        JNE     d_break
        OR      word [teclas], tecla_d
d_break:
        CMP     AL, 0A0h
        JNE     q_press
        MOV     AX, tecla_d     
        NOT     AX
        AND     word [teclas], AX
q_press:
        CMP     AL, 10h
        JNE     q_break
        OR      word [teclas], tecla_q
q_break:
        CMP     AL, 90h
        JNE     w_press
        MOV     AX, tecla_q     
        NOT     AX
        AND     word [teclas], AX
w_press:
        CMP     AL, 11h
        JNE     w_break
        OR      word [teclas], tecla_w
w_break:
        CMP     AL, 91h
        JNE     s_press
        MOV     AX, tecla_w     
        NOT     AX
        AND     word [teclas], AX
s_press:
        CMP     AL, 1Fh
        JNE     s_break
        OR      word [teclas], tecla_s
s_break:
        CMP     AL, 9Fh
        JNE     p_press
        MOV     AX, tecla_s    
        NOT     AX
        AND     word [teclas], AX
p_press:
        CMP     AL, 19h
        JNE     p_break
        OR      word [teclas], tecla_p
p_break:
        CMP     AL, 99h
        JNE     y_press
        MOV     AX, tecla_p   
        NOT     AX
        AND     word [teclas], AX
y_press:
        CMP     AL, 15h
        JNE     y_break
        OR      word [teclas], tecla_y
y_break:
        CMP     AL, 95h
        JNE     n_press
        MOV     AX, tecla_y   
        NOT     AX
        AND     word [teclas], AX
n_press:
        CMP     AL, 31h
        JNE     n_break
        OR      word [teclas], tecla_n
n_break:
        CMP     AL, 0B1h
        JNE     space_press
        MOV     AX, tecla_n   
        NOT     AX
        AND     word [teclas], AX
space_press:
        CMP     AL, 39h
        JNE     space_break
        OR      word [teclas], tecla_space
space_break:
        CMP     AL, 0B9h
        JNE     enter_press
        MOV     AX, tecla_space   
        NOT     AX
        AND     word [teclas], AX
enter_press:
        CMP     AL, 1Ch
        JNE     enter_break
        OR      word [teclas], tecla_enter
enter_break:
        CMP     AL, 9Ch
        JNE     fim
        MOV     AX, tecla_enter   
        NOT     AX
        AND     word [teclas], AX

fim:    
        IN      AL, kb_ctl				; Le porta 61h, pois o bit mais significativo "bit 7" 
        OR      AL, 80h					; Faz operação lógica OR com o bit mais significativo do registrador AL (1XXXXXXX) -> Valor lido da porta 61h 
        OUT     kb_ctl, AL				; Seta o bit mais significativo da porta 61h
        AND     AL, 7Fh					; Restablece o valor do bit mais significativo do registrador AL (0XXXXXXX), alterado na linha 90 	
        OUT     kb_ctl, AL				; Reinicia o registrador de dislocamento 74LS322 e Livera a interrupção "CLR do flip-flop 7474". O 8255 - Programmable Peripheral Interface (PPI) fica pronto para recever um outro código da tecla https://es.wikipedia.org/wiki/INTel_8255
        MOV     AL, eoi					; Carrega o AL com a byte de End of Interruption, -> 20h por default
        OUT     pictrl, AL				; Libera o PIC
        
	POP     DS	                                ; recupera o contexto
        POP     AX
        IRET						

segment data public
        kb_data EQU 60h  				; PORTA DE LEITURA DE TECLADO
        kb_ctl  EQU 61h  				; PORTA DE RESET PARA PEDIR NOVA INTERRUPCAO
        pictrl  EQU 20h					; PORTA DO PIC DE TECLADO
        eoi     EQU 20h					; Byte de final de interrupção PIC - resgistrador
        INT9    EQU 9h					; Interrupção por hardware do teclado
        cs_dos  DW  1					; Variável de 2 bytes para armacenar o CS da INT 9
        offset_dos  DW 1				; Variável de 2 bytes para armacenar o IP da INT 9
        
        teclas				dw 0            ; o estado das teclas é armazenada em uma word, cada bit é uma tecla
        tecla_w				equ 0000000000000001b
        tecla_a				equ 0000000000000010b
        tecla_s				equ 0000000000000100b
        tecla_d				equ 0000000000001000b
        tecla_q				equ 0000000000010000b
        tecla_p				equ 0000000000100000b
        tecla_y				equ 0000000001000000b
        tecla_n				equ 0000000010000000b
        tecla_enter			equ 0000000100000000b
        tecla_space                     equ 0000001000000000b

segment stack stack					; Segmento da pilha -> SS
    resb 256						; Reserva 256 bytes para a pilha
stacktop:						; Define ponteiro do topo da pilha -> SP

