---
categories: [Concurrencia]
layout: page-note
published: false
tags: []
title: "Concurrencia - Problema de Exclusión mutua"
toc: true
---
{% include fragments/pseudocode.html %}


## Definición del problema
Se tienen $N$ procesos en loop infinito ejecutando una secuencia de operaciones donde se 
distinguen dos secciones, la *sección crítica* y la *sección no crítica*.

Requerimientos:
1. **Exclusión mutua**: en ningún momento puede haber más de un proceso dentro de 
   la sección critica.
2. **Libre de interbloqueo**: si algún proceso intenta entrar a la sección crítica, entonces 
   uno de ellos en algún momento logra entrar.
3. **Libre de inanición**: si un proceso intenta entrar a la sección crítica, entonces 
   en algún momento ese proceso logra entrar.

Asunciones:
1. La ejecución en la sección crítica debe *progresar*, es decir que si un proceso entra a la 
   sección crítica entonces en algún momento deberá salir.
2. La ejecución en la sección no crítica no necesita *progresar*, es decir que un proceso 
   puede quedar en loop infinito mientras ejecuta la sección no crítica.   
   
Se debe proveer un mecanismo de sincronización para satisfacer dichos requerimientos.

## Solución para dos procesos

### Intento 1
Variable global
{% pseudocode | {"lineNumber":false} %}
  \STATE turn := 1
{% endpseudocode %}
<div class="row">
<div class="col-sm-6">
<p class="text-center">Proceso P</p>
{% pseudocode %}
\SN \WHILE{\TRUE} 
      \STATE \textit{sección no crítica} 
      \STATE \textbf{await} turn = 1
      \STATE \textit{sección crítica}
      \STATE turn := 2
    \ENDWHILE
{% endpseudocode %}
</div>
<div class="col-sm-6">
<p class="text-center">Proceso Q</p>
{% pseudocode %}
\SN \WHILE{\TRUE} 
      \STATE \textit{sección no crítica} 
      \STATE \textbf{await} turn = 2
      \STATE \textit{sección crítica}
      \STATE turn := 1
    \ENDWHILE
{% endpseudocode %}
</div>
</div>


### Intento 2
Variable global
{% pseudocode | {"lineNumber":false} %}
  \STATE turn := 1
{% endpseudocode %}
<div class="row">
<div class="col-sm-6">
<p class="text-center">Proceso P</p>
{% pseudocode %}
\SN \WHILE{\TRUE} 
      \STATE \textit{sección no crítica} 
      \STATE \textbf{await} turn = 1
      \STATE \textit{sección crítica}
      \STATE turn := 2
    \ENDWHILE
{% endpseudocode %}
</div>
<div class="col-sm-6">
<p class="text-center">Proceso Q</p>
{% pseudocode %}
\SN \WHILE{\TRUE} 
      \STATE \textit{sección no crítica} 
      \STATE \textbf{await} turn = 2
      \STATE \textit{sección crítica}
      \STATE turn := 1
    \ENDWHILE
{% endpseudocode %}
</div>
</div>

### Intento 3

### Intento 4

### Algoritmo de Dekker

### Algoritmo de Peterson


## Solución para N procesos


## Bibliografía
{% bibliography -q
   @*[key=Hopcroft-Motwani-Ullman2000] 
%}
