global iniciar_teclado
global encerrar_teclado
extern key_q, key_a, key_d, key_w, key_s, key_p

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
        MOV     WORD [ES:INT9*4],keyINT	; Atualiza o valor do IP do vector de INTerrupção 9 com o offset "keyINT" do programa atual
        STI								; Habilita INTerrupções por hardware - pin INTR SIM atende INTerrupções externas
        RET


encerrar_teclado:										; Ao sair do programa temos que restaurar o CS:IP da INTerrupção 9, que incialmente alteramos nas linhas 26 e 27
        CLI								; Deshabilita INTerrupções por hardware - pin INTR NÃO atende INTerrupções externas
        XOR     AX, AX					; Limpa o registrador AX, é equivalente a fazer "MOV AX,0"				
        MOV     ES, AX					; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
        MOV     AX, [cs_dos]			; Carrega em AX o valor do CS do vector de INTerrupção 9 que foi salvo na variável cs_dos -> linha 25
        MOV     [ES:INT9*4+2], AX		; Atualiza o valor do CS do vector de INTerrupção 9 que foi salvo na variável cs_dos
        MOV     AX, [offset_dos]		; Carrega em AX o valor do IP do vector de INTerrupção 9 que foi salvo na variável offset_dos -> linha 23
        MOV     [ES:INT9*4], AX 		; Atualiza o valor do IP do vector de INTerrupção 9 que foi salvo na variável offset_dos
        STI
        RET						; Chama Interrupção 21h para retornar o controle ao sistema operacional -> sai de forma segura da execução do programa


keyINT:									; Este segmento de código só será executado se uma tecla for presionada, ou seja, se a INT 9h for acionada!
        PUSH    AX	
        PUSH    DS
        MOV     AX, SEG key_q
        MOV     DS, AX			; Le a porta 60h, que é onde está o byte do Make/Break da tecla. Esse valor é fornecido pelo chip "8255 PPI"
        IN      AL, kb_data
a_press:
        CMP     AL, 1Eh
        JNE     a_break
        MOV     byte [key_a], 1
        JMP     fim

a_break:
        CMP     AL, 9Eh
        JNE     d_press
        MOV     byte [key_a], 0
        JMP     fim
d_press:
        CMP     AL, 20h
        JNE     d_break
        MOV     byte [key_d], 1
        JMP     fim

d_break:
        CMP     AL, 0A0h
        JNE     q_press
        MOV     byte [key_d], 0
        JMP     fim
q_press:
        CMP     AL, 10h
        JNE     q_break
        MOV     byte [key_q], 1
        JMP     fim

q_break:
        CMP     AL, 90h
        JNE     w_press
        MOV     byte [key_q], 0
        JMP     fim
w_press:
        CMP     AL, 11h
        JNE     w_break
        MOV     byte [key_w], 1
        JMP     fim

w_break:
        CMP     AL, 91h
        JNE     s_press
        MOV     byte [key_w], 0
        JMP     fim
s_press:
        CMP     AL, 1Fh
        JNE     s_break
        MOV     byte [key_s], 1
        JMP     fim

s_break:
        CMP     AL, 9Fh
        JNE     p_press
        MOV     byte [key_s], 0
        JMP     fim
p_press:
        CMP     AL, 19h
        JNE     p_break
        MOV     byte [key_p], 1
        JMP     fim

p_break:
        CMP     AL, 99h
        JNE     fim
        MOV     byte [key_p], 0
        JMP     fim

fim:    
        IN      AL, kb_ctl				; Le porta 61h, pois o bit mais significativo "bit 7" 
        OR      AL, 80h					; Faz operação lógica OR com o bit mais significativo do registrador AL (1XXXXXXX) -> Valor lido da porta 61h 
        OUT     kb_ctl, AL				; Seta o bit mais significativo da porta 61h
        AND     AL, 7Fh					; Restablece o valor do bit mais significativo do registrador AL (0XXXXXXX), alterado na linha 90 	
        OUT     kb_ctl, AL				; Reinicia o registrador de dislocamento 74LS322 e Livera a interrupção "CLR do flip-flop 7474". O 8255 - Programmable Peripheral Interface (PPI) fica pronto para recever um outro código da tecla https://es.wikipedia.org/wiki/INTel_8255
        MOV     AL, eoi					; Carrega o AL com a byte de End of Interruption, -> 20h por default
        OUT     pictrl, AL				; Livera o PIC
        
	POP     DS	
        POP     AX
        IRET							; Retorna da interrupção

segment data public
        kb_data EQU 60h  				; PORTA DE LEITURA DE TECLADO
        kb_ctl  EQU 61h  				; PORTA DE RESET PARA PEDIR NOVA INTERRUPCAO
        pictrl  EQU 20h					; PORTA DO PIC DE TECLADO
        eoi     EQU 20h					; Byte de final de interrupção PIC - resgistrador
        INT9    EQU 9h					; Interrupção por hardware do teclado
        cs_dos  DW  1					; Variável de 2 bytes para armacenar o CS da INT 9
        offset_dos  DW 1				; Variável de 2 bytes para armacenar o IP da INT 9


segment stack stack						; Segmento da pilha -> SS
    resb 256							; Reserva 256 bytes para a pilha
stacktop:								; Define ponteiro do topo da pilha -> SP

