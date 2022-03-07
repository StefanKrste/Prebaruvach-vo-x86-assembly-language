.386
.model small, c
STACK_SEG SEGMENT STACK
DB 100 DUP(?)
STACK_SEG ENDS

DATA_SEG SEGMENT USE16 'DATA'

 datoteka db "datoteka.txt", 0h
 tekst DB 10000 dup(?)
 segmentt DB 'Zdravo',0d
 
 poraka1 db "Pronajden e pomegju bajtite:",024h
 poraka2 db "Vkupno e pronajden:",024h
 poraka3 db " pati",024h
 poraka4 db "Ne e pronajden",024h
  
 zapirka db ",",024h
 crta db "-",024h
 
 novRed DB 0DH, 0AH, 024H ; nov red

DATA_SEG ENDS

CODE_SEG SEGMENT USE16 'CODE'
ASSUME CS:CODE_SEG, DS:DATA_SEG
start:

    mov     ax, DATA_SEG
    mov     ds, ax
    mov     ax, STACK_SEG
    mov     ss, ax

main PROC    
 
	mov ah, 3dh	;Otvaranje na datotekata
	mov al, 00h ; Mod za pristap citanje
	lea dx, datoteka
	int 21h
	mov bx, ax	; File-handle

    mov ah, 3fh  
    lea dx, tekst
    mov cx, 10000d ; citanje na 10000 Byte
    int 21h	

    mov ah, 3eh ;Zatvaranje na datotekata
    int 21h
   
	lea si, tekst 
	push si
   
    lea si, segmentt
	push si

	call prebaraj ;procedura za prebaruvanje pomegju koj bajti se naoga segmentot i kolu pati e najden
	
	cmp cx,00h ; proverka dali e najden barem ednash
	jg PronajdenBaremEdnash
	
	mov ah,09h
	lea dx,poraka4	; Ne e pronajden poraka	
	int 021h
	jmp kraj

PronajdenBaremEdnash:
	mov ah, 09h 
	lea dx, novRed 
	int 021h 
	
	mov ah,09h
	lea dx,poraka2		
	int 021h
	
	mov ax,cx ;stavaje na cx vo ax za da go ispecati vo procedurata sto sledi
	call pechati
	
	mov ah,09h
	lea dx,poraka3		
	int 021h

kraj:
	nop
main ENDP

	mov ax, 04c00h
	int 021h

prebaraj PROC near
	push si  
	push bx 
	push dx 
	push bp
	push ax

	mov di,00d
	mov cx,00d ;cx=0
   ;zemanje na adresite od stekot
	mov bp, sp ; go stavame bp da pokazuva na vrvot na stekot
	mov bx, [bp+12] ; bx - adresata na segmentot koj go barame 12=2*5+2
	mov si, [bp+14] ; si - adresata na tekstot
	mov dx, bx ; kopija na adresata na segmentot
	mov bp, 01h ; dokolku segmentot pocnuva od prviot bajt da pocne da broj od nego
pak:
	cmp byte ptr [si], 0d ; izminata cel tekst?
	jne ponatamu ; ako ne e odi ponatamu
	jmp kraj
ponatamu:
	mov al, [bx] ; procitaj znak od segmentot
	cmp al, [si] ; sporedi go so znak od teskstot
	je isti ; ako se ednakvi odi na 'isti'
	cmp dx, bx ; dali bil najden barem eden znak
	jne pocetok ; ako bil varati se napocetok na segmentot
	inc si ; azuriraj pokazuvac na tekstot
	inc di ; broj na elementi vo tekstot
	mov bp,di ;prviot bajt od opsegot vo koj se naoga segmentot
	inc bp
	jmp pak ; baraj ponatamu
pocetok:
	mov bx, dx ; vrati se na pocetokot na segmentot
	jmp ponatamu ; baraj ponatamu
isti:
	inc si ; azuriraj pokazuvac na tekstot
	inc di ; broj na elementi vo tekstot
	inc bx ; azuriraj pokazuvac na segmentot
	cmp byte ptr [bx], 0d ; izminat cel segment
	jne pak ; ako ne e baraj pak bez da go zgolemish cx
	inc cx; ;kolku pati go nashol segmentot vo tekstot
	
	push dx ;za da ne go izgubime pri pecatenjeto
	cmp cx,01h ;koga cx =1 togas pecatime kolku pati e pronajdev segmentot poraka zosto vo toj slucaj imame bar ednas pronajden
	jne NeEPrvpat
	mov ah,09h  ;pechatenje pomegju koj bajti e pronajden segmentot
	lea dx,poraka1		
	int 021h
	jmp NeZapirka

NeEPrvpat:	
	
	mov ah,09h
	lea dx,zapirka		
	int 021h
	
NeZapirka:

	mov ax,bp
	call pechati ;pecatenje na lokacijata od kade pocnuva segmentot
	
	mov ah,09h
	lea dx,crta		
	int 021h
	pop dx ;vadenje na dx od stekot za da prodolzi od kade so zastanal 
	
	mov ax,di
	call pechati ;pecatenje na lokacijata od kade zavrsuva segmentot
	
	jmp pak; ako se pominala cela i nasol probaj pak
kraj:
	pop ax
	pop bp
	pop dx
	pop bx
	pop si
	ret 2 

prebaraj ENDP

pechati PROC near
	push cx
	push bx
    push dx
	push ax
	
	mov cx, 0
    mov bx, 10  
pak:
    mov dx, 0
    div bx                 ;delenje so 10

    add dl, '0'            ;vrednost na ascii 0

    push dx                ;stavanje na cifra na stekot
    inc cx                 ;brojme kolku cifri sme stavile na stekot
    cmp ax, 0              ;ako ax stignal do 0 togas sme zavrsile so rpetvaranje
	jnz pak				   ;ako ne e 0 odi na pak
	
    mov ah, 2              ;2 funkciski broj za pecatenje na ekran vo DOS Services.
pecatenje:
    pop dx                 ;vadenje na cifri od stekot i nivno pecatenje
    int 21h               
    loop pecatenje
	
	pop ax
	pop dx
	pop bx
	pop cx
	ret
pechati ENDP

CODE_SEG ENDS
END start