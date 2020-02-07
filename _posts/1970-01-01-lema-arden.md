---
categories: [lenguajes-formales]
layout: post
published: true
title: "Lema de Arden"
toc: true
---

## Teoría

### Autómata Finito
<div class="definition" data-number="1" data-name=" (AFN)" markdown="1"> 
Un Autómata Finito no determinista (AFN) es una quíntupla $(Q,\Sigma,\delta,s,F)$ donde:

1. $Q$ es un conjunto finito de estados.
2. $\Sigma$ es un alfabeto finito.
3. $\delta \subseteq Q \times \Sigma^\star$ es la relación de transición.
4. $s \in Q$ es el estado inicial.
5. $F \subseteq Q$ es el conjunto de estados finales (de aceptación).
</div>

### Lenguajes y operaciones
<div class="definition" data-number="2" data-name=" (Alfabetos, Cadenas, Lenguajes)" markdown="1">
1. Un **alfabeto** $\Sigma$ es un conjunto finito no vació cuyos elementos son 
   denominados símbolos (o letras).
2. Una **cadena** (o palabra) $w = w_1\,w_2 \dots w_n$ es una secuencia finita formada 
   por la concatenación de $n$ símbolos tal que $w_i\in\Sigma$. El número de símbolos en $w$, 
   denotado $\len{w}$, es el largo de $w$. La cadena vacía, sin símbolos, se denota $\veps$ 
   y es la única cadena con largo $0$. Para toda cadena $w$ definimos $w^0=\veps \ $ 
   y $ \ w^k=w^{k-1}\,w$. 
3. Un **lenguaje** formal $L$ definido sobre $\Sigma$ es un conjunto de cadenas formadas a 
   partir de los símbolos de $\Sigma$.
</div>

Algunos lenguajes particulares son:

* $\varnothing$ es el lenguaje vacío, no tiene cadenas.
* $$\{ \veps \}$$ es el lenguaje que tiene únicamente la cadena vacía.
* $\Sigma^\star$ es el lenguaje de todas las cadenas que se 
  pueden formar sobre $\Sigma$, incluyendo la cadena vacía. Por lo tanto, 
  para cualquier lenguaje $L$ definido sobre $\Sigma$, 
  tenemos $L \subseteq \Sigma^\star$. 

Se pueden obtener lenguajes nuevos a partir de otros aplicando operaciones 
sobre estos. Como un lenguaje es un conjunto, entonces valen las operaciones 
ordinarias sobre conjuntos como Unión, Intersección, etc. Adicionalmente, se 
definen otras operaciones especiales.

<div class="definition" data-number="3" data-name=" (Unión)">
Sean $L_1$ y $L_2$ lenguajes. La unión de $L_1$ y $L_2$ se define:

 $$ L_1 \cup L_2 \ = \ \{\, w \ | \ w \in L_1 \text{ o } w \in L_2  \,\} $$
</div>

<div class="definition" data-number="4" data-name=" (Concatenación)">
Sean $L_1$ y $L_2$ lenguajes. La concatenación de $L_1$ y $L_2$ se define:

 $$ L_1 \cdot L_2 \ = \ \{\, w \ | \ w = w_1\,w_2 \text{ con }
                           w_1 \in L_1 \text{ y } w_2 \in L_2  \,\} $$
</div>

<div class="definition" data-number="5" data-name=" (Potencia)">
Sea $L$ un lenguaje y $n \in \mathbb{N}$. La potencia de $L$ a la $n$ se define:

 $$ L^n \ = \
  \begin{cases}
    \{ \veps \}       &\text{si } \,n=0   \\
    L^{n-1} \cdot L   &\text{si } \,n>0
  \end{cases}$$
</div>

<div class="definition" data-number="6" data-name=" (Clausura Kleene)">
Sea $L$ un lenguaje. La clausura Kleene de $L$ se define:

  $$L^\star \ = \ L^0 \,\cup\, L^1 \,\cup\, L^2 \,\cup\, \dots  
            \ = \ \bigcup\limits_{k=0}^{\infty}L^k$$ 

Alternativamente, una definición recursiva:

  $$L^\star \ = \ \{ \veps \} \,\cup\, \{\, w \ | \ w = w_1\,w_2 \text{ con } 
                     w_1 \in L \text{ y } w_2 \in L^\star \,\}$$
</div>

<div class="definition" data-number="7" data-name=" (Clausura Kleene+)">
Sea $L$ un lenguaje. La clausura Kleene+ de $L$ se define:

  $$L^+ \ = \ L \cdot L^\star $$
</div>

### Lenguaje/Expresión Regular
<div class="theorem" data-number="1" data-name=" (Kleene 1, Lenguaje Regular)" markdown="1">
Un lenguaje $L$ definido sobre un alfabeto $\Sigma$ es regular si y solo si $L$ 
es aceptado por un Autómata Finito.[^afn_afd]
</div> 

<div class="theorem" data-number="2" data-name=" (Kleene 2)">
Todo lenguaje regular $L$ definido sobre un alfabeto $\Sigma$ puede ser construido 
a partir de $\varnothing$ y $\{ a \}$ (con $a\in\Sigma$) mediante las operaciones 
de Unión, Concatenación y Clausura Kleene.
</div>

Otras operaciones como Intersección y Complemento también son cerradas sobre 
lenguajes regulares, pero no son esenciales.

Se define un lenguaje formal de Expresiones Regulares (ER) para denotar lenguajes 
complejos construidos mediante las operaciones elementales, de manera que para cada 
lenguaje regular $L$ hay una ER $r$ tal que $\mathcal{L}(r)=L$. [^notation_abuse]

<div class="definition" data-number="8" data-name=" (ER)">
Sean $r_1,r_2$ expresiones regulares y $\Sigma$ un alfabeto. Entonces el lenguaje de ER
definido sobre $\Sigma$ se construye de acuerdo con las siguientes reglas de sintaxis 
y semántica.
<div class="table-responsive">
<table class="table">
  <thead class="thead-light">
    <tr>
      <th></th>
      <th>Descripción</th>
      <th>Sintaxis</th>
      <th>Semántica</th>
    </tr>
  </thead>
  <tr>
    <td rowspan="3">Caso base</td>
    <td>Lenguaje vacío</td>
    <td>$\emptyset$</td>
    <td>$\mathcal{L}(\emptyset) \ = \ \{ \} \ = \ \varnothing$</td>
  </tr>
  <tr>
    <td>Cadena vacía</td>
    <td>$\veps$</td>
    <td>$\mathcal{L}(\veps) \ = \ \{ \veps \}$</td>
  </tr>
  <tr>
    <td>$a\in\Sigma$</td>
    <td>$a$</td>
    <td>$\mathcal{L}(a) \ = \ \{ a \}$</td>
  </tr>
  <tr>
    <td rowspan="3">Paso inductivo</td>
    <td>Clausura Kleene</td>
    <td>$r_{1}^{\star}$</td>
    <td>$\mathcal{L}(r_{1}^{\star}) \ = \ \mathcal{L}(r_1)^\star$</td>
  </tr>
  <tr>
    <td>Unión</td>
    <td>$r_1 + r_2$</td>
    <td>$\mathcal{L}(r_1 + r_2) \ = \ \mathcal{L}(r_1) \cup \mathcal{L}(r_2)$</td>
  </tr>
  <tr>
    <td>Concatenación</td>
    <td>$r_1\,r_2$</td>
    <td>$\mathcal{L}(r_1\,r_2) \ = \ \mathcal{L}(r_1) \cdot \mathcal{L}(r_2)$</td>
  </tr>
</table>
</div>
</div>

<div class="definition" data-number="9">
Sean $r_1,r_2$ expresiones regulares. Entonces $r_1$ y $r_2$ son iguales si y 
solo si ambas denotan el mismo lenguaje. Es decir:  

  $$r_1 = r_2 \ \iff \ \mathcal{L}(r_1) = \mathcal{L}(r_2)$$
</div>

La definición de $\veps$ (cadena vacía) como primitiva es conveniente, pero redundante
porque $$\mathcal{L}(\emptyset^\star) = \mathcal{L}(\veps) = \{ \veps \}$$. Notar que 
un lenguaje puede ser denotado por más de una RE. 

<div class="lemma" data-number="1" data-name=" (Identidades)" markdown="1">
Sean $r_1,r_2,r_3$ expresiones regulares sobre un alfabeto. Entonces las siguientes
son identidades básicas:

1. Conmutatividad: 

   $$r_1 + r_2 \ = \ r_2 + r_1$$
2. Asociatividad: 

   $$\begin{aligned}
     r_1 + (r_2 + r_3) \ &= \ (r_1 + r_2) + r_3   && \\
     r_1\,(r_2\,r_3)   \ &= \ (r_1\,r_2)\,r_3     &&
   \end{aligned}$$
3. Distributividad:

   $$\begin{aligned}
     r_1\,(r_2 + r_3)  \ &= \  r_1\,r_2 + r_1\,r_3   && \\
     (r_1 + r_2)\,r_3  \ &= \  r_1\,r_3 + r_2\,r_3   &&
   \end{aligned}$$
4. Elemento Neutro: 

   $$\begin{aligned}
     & r_1\,\veps      \ = \ \veps\,r_1      \ = \ r_1   && \\
     & r_1 + \emptyset \ = \ \emptyset + r_1 \ = \ r_1   && \\           
     & r_1 + \veps     \ = \ \veps     + r_1 \ = \ r_1   && \text{ si } \ \veps \in \mathcal {L}(r_1) 
   \end{aligned}$$
5. Elemento Cero: 

   $$r_1\,\emptyset \ = \ \emptyset\,r_1 \ = \ \emptyset$$
6. Otros: 

   $$\begin{aligned}
     r_1^+ + \veps      \ &= \  r_1^\star   && \\           
     (r_1^\star)^\star  \ &= \  r_1^\star   && \\    
     r_1^+              \ &= \  r_1^\star   && \text{ si } \ \veps \in \mathcal{L}(r_1) \\ 
     \emptyset^\star    \ &= \  \veps       &&
   \end{aligned}$$
</div>

<div class="example" data-number="1" markdown="1">
Sea $$\Sigma=\{ 0,1 \}$$ :

* $0^\star + 1^\star$ denota el lenguaje de cadenas formadas con $0$ o $1$: 
 
    $$\mathcal{L}(0^\star + 1^\star) = \{\veps, 0, 1, 00, 11, 000, 111, ... \}$$

* $(0\,1)^\star$ denota el lenguaje de cadenas formadas con $0$ y $1$:  

    $$\mathcal{L}((0\,1)^\star) = \{\veps, 01, 0101, 010101, 01010101, ... \}$$

* $(0 + 1)^\star$ denota el lenguaje de cadenas formadas con $0$ y/o $1$:  

    $$\mathcal{L}((0 + 1)^\star) = \{\veps, 0, 1, 00, 11, 01, 10, ... \}$$
</div>

## Lema de Arden

<div class="lemma" data-number="2" data-name=" (Arden)">
Sean $X,A,B\subseteq\Sigma^\star$ con $\veps\not\in A$. Entonces:
 
   $$X \ = \ A \cdot X \cup B \ \ \iff \ \ X \ = \ A^\star \cdot B$$ 

En palabras, $A^\star \cdot B$ es el lenguaje más pequeño tal que es solución
en la ecuación lineal $X = A \cdot X \cup B$. Además, si $\veps\not\in A$ 
entonces dicha solución es única.
</div>

### Demostración 1
Procedemos en ambas direcciones.  

<div markdown="1">
$\large\Longleftarrow)$ Sea $X = A^\star \cdot B$. Verificamos que $X$ es una 
solución para la ecuación:

$$\begin{aligned}
  X  &=  A^\star\cdot B                      && \\
     &=  (A^+ \cup \{\veps\}) \cdot B        && \\
     &=  A^+\cdot B \cup B                   && \\ 
     &=  (A \cdot A^\star) \cdot B  \cup B   && \\
     &=  A \cdot (A^\star \cdot B) \cup B    && \\
     &=  A \cdot X \cup B                    &&
\end{aligned}$$

$\large\Longrightarrow)$ Sea $S$ una solución cualquiera de $X = A \cdot X \,\cup\, B$. 
Expandiendo tenemos:

$$\begin{aligned}
S  &=  A \cdot S \cup B                                       && \\
   &=  A \cdot (A\cdot S \cup B) \cup B                       && \\
   &=  A^2 \cdot S \cup A\cdot B \cup B                       && \\
   &=  A^2 \cdot (A \cdot S \cup B) \cup A \cdot B \cup B     && \\ 
   &=  A^3 \cdot S \cup A^2 \cdot B \cup A \cdot B \cup B     && \\
   & \ \ \vdots                                               && \\
   &=  A^{n+1}\cdot S \cup A^{n}\cdot B \cup \dots \cup A^3\cdot B \cup A^2\cdot B \cup A\cdot B \cup B &&\\
   &=  A^{n+1}\cdot S \cup (A^{n} \cup \dots \cup A^3 \cup A^2 \cup A \cup \{\veps\})\cdot B            &&
\end{aligned}$$ 

Entonces para todo $n \geq 0$:

  $$ S \ = \ A^{n+1}\cdot S \ \cup \ \left(\bigcup\limits_{k=0}^{n}A^k\right)\cdot B \tag{1}\label{eq1}$$ 

Esto significa en particular $A^k \cdot B \ \subseteq \ S$ para todo $n \geq 0$, 
entonces $A^\star \cdot B \ \subseteq \ S$. Hasta aquí hemos probado que $A^\star \cdot B$
es una solución y debe ser la más pequeña porque está incluida en cualquier otra solución $S$. 

Ahora, considerando también la hipotesis $\veps\not\in A$ vamos a ver 
que dicha solución además es única. Sea $w\in S$ tal que $\len{w}=n$ con $n \geq 0$, 
entonces por $\eqref{eq1}$ tenemos dos casos posibles:

1. $\ w \in A^{n+1}\cdot S \ $: Pero si $\veps\not\in A$ entonces la cadena 
  más corta que puede haber en $A^{n+1}\cdot S$ es de largo $n+1$. Luego 
  $w \not\in A^{n+1}\cdot S$ y este caso queda descartado.
2. $\ w \in \left(\bigcup\limits_{k=0}^{n}A^k\right)\cdot B \ $: Se cumple 
  por haber descartado el caso anterior.

Necesariamente $w \in \left(\bigcup\limits_{k=0}^{n}A^k\right)\cdot B \ \subseteq \ A^\star \cdot B$, 
entonces $S \ \subseteq \ A^\star \cdot B$.  
Por lo tanto $S = A^\star \cdot B$.
<span style="float:right;font-size:1.2em">&#x20DE;</span>
</div>


### Demostración 2
Otra manera de probar la dirección $\Longrightarrow$ es por inducción. 
Supongamos $X = A \cdot X \cup B$ con $\veps\not\in A$, 
entonces tenemos que demostrar $X = A^\star \cdot B$, es decir: 
$X \ \subseteq \ A^\star \cdot B$ y $A^\star \cdot B \ \subseteq \ X $. 
Ahora demostramos ambas inclusiones por separado.

$\large\subseteq)$ Notar que:

  $$X \subseteq A^\star \cdot B \ \iff \ \forall w \in X \ : \ w \in A^\star \cdot B$$ 

Procedemos por inducción completa en el largo de la cadena $w\in X$:

**Caso Base.** Sea $\len{w}=0$, o sea $w=\veps$.  
Tenemos que $w\in X$ y $X = A \cdot X \cup B$. Luego $w \in A \cdot X \cup B$, 
es decir: $w \in A \cdot X$ o $w \in B$.  
Pero $\veps\not\in A$, entonces $w \not\in A \cdot X$. Luego necesariamente $w \in B$.  
Además $B \subseteq A^\star \cdot B$, por lo tanto $w \in A^\star \cdot B$.

**Paso Inductivo.**  
      **HI.** $v \in A^\star \cdot B$ para todo $v\in X$ con $1 \leq \len{v} \leq n $.  
&ensp;**T.** $w \in A^\star \cdot B$ para $\len{w} \gt n$.  
Por casos:
* Si $w \in B$. Entonces $w \in A^\star \cdot B$.
* Si $w \not\in B$. Tenemos que $w\in X$ y $X = A \cdot X \cup B$, 
  luego $w \in A \cdot X \cup B$, es decir: $w \in A \cdot X$ o $w \in B$. 
  Pero $w \not\in B$, luego necesariamente $w \in A \cdot X$.  
  Si $w \in A \cdot X$ entonces existen cadenas $w_1\in A$ y $w_2\in X$ tal que $w = w_1\,w_2$.  
  Como $\veps\not\in A$, tenemos que $\len{w_1}\geq 1$ y entonces $\len{w} \gt \len{w_2}$.  
  Tomando $w_2=v$, por la HI: $ \ w_2 \in A^\star \cdot B$.  
  Luego $w=w_1\,w_2 \in A \cdot (A^\star \cdot B)$.  
  Pero además:

    $$A \cdot (A^\star \cdot B) \ = \ (A \cdot A^\star) \cdot B 
                                \ = \ A^+ \cdot B 
                                \ \subseteq \ A^\star \cdot B$$ 

  Por lo tanto $w \in A^\star \cdot B$.

Habiendo completado la inducción, hemos demostrado $X \subseteq A^\star \cdot B$.

$\large\supseteq)$ Se procede de manera similar.
<span style="float:right;font-size:1.2em">&#x20DE;</span>

### Observaciones
* Si los lenguajes $A$ y $B$ son regulares, entonces la solución $A^\star \cdot B$ es un 
  lenguaje regular. Esto es porque las operaciones de Clausura Kleene y Concatenación son 
  cerradas sobre lenguajes regulares.
* Si $\veps\in A$, entonces la ecuación $X = A \cdot X \cup B$ tiene infinitas soluciones 
  de la forma $A^\star\cdot(B \cup C)$ donde $C \subseteq \Sigma^\star$ es un lenguaje
  arbitrario, como se puede verificar:

  $$\begin{aligned}
   X  &=  A^\star \cdot (B \cup C)                           && \\
      &=  A^\star \cdot B \cup A^\star \cdot C               && \\
      &=  (A^+ \cup \{\veps\}) \cdot B \cup A^\star \cdot C  && \\ 
      &=  A^+ \cdot B \cup B \cup A^\star \cdot C            && \\
      &=  A^+ \cdot B \cup A^\star \cdot C \cup B            && \\
      &=  A^+ \cdot B \cup A^+ \cdot C \cup B                && \\
      &=  A^+ \cdot(B \cup C) \cup B                         && \\
      &=  A \cdot A^\star \cdot (B \cup C) \cup B            && \\
      &=  A \cdot X \cup B                                   &&
  \end{aligned}$$
  
  En este caso, $A^\star \cdot B$ es una de las soluciones posibles cuando $C=\varnothing$,
  siendo así la más pequeña pero no la única. Por lo tanto, sin la hipótesis 
  $\veps \not\in A$ no hay unicidad y entonces el lema se cumple solo en la 
  dirección $\Longleftarrow$.

* Otra versión del Lema de Arden se cumple de manera análoga para gramáticas lineales por
  izquierda: [^arden_variant]

    $$X \ = \ X \cdot A \cup B \ \ \iff \ \ X \ = \ B \cdot A^\star$$

## Aplicación: conversión de AF a ER
Según el Teorema 1, todo Autómata Finito (AFD o AFN) acepta un lenguaje regular.
Un método de conversión de AF a ER consiste en resolver el sistema de ecuaciones
lineales regulares asociado al AF. Una aplicación del lema de Arden es en la 
resolución de dicho sistema de ecuaciones, específicamente en las 
ecuaciones recursivas. [^afn_epsilon] 

<div class="definition" data-number="10" >
Sea $M=(Q,\Sigma,\delta,s,F)$ un AFD/AFN tal que $Q=\{ q_1,q_2,...,q_n \}$. El sistema 
de ecuaciones asociado a $M$ tiene $n$ incógnitas $X_1,X_2,...,X_n$ y $n$ ecuaciones, una 
por cada $q_i$, de la forma:

$$X_i \ = \ \sum_{q_j \, \in \, \delta(q_i,x)} x\,X_j 
            \ + \ \begin{cases} \veps     &\text{si } \ q_i\in F     \\ 
                                \emptyset &\text{si } \ q_i\not\in F 
                  \end{cases} $$
</div>

Cada $X_i$ es una ER que denota aquellas cadenas aceptadas por $M$ comenzando desde el 
estado $q_i$. Entonces si $q_1$ es el estado inicial, la solución de $X_1$ es la ER que 
denota el lenguaje aceptado por $M$, o sea $\mathcal{L}(X_1)=\mathcal{L}(M)$.

<div class="example" data-number="2" markdown="1">
Sea $M=(Q,\Sigma,\delta,s,F)$ un AFN con:

* \$$Q=\{ q_1, q_2, q_3, q_4 \}$$
* \$$\Sigma=\{ \texttt{a}, \texttt{b} \}$$
* $s=q_1$
* \$$F=\{ q_1 \}$$

y $\delta$ representada por el siguiente diagrama de transición:

![transitions](/assets/images/lema-arden/example2.svg){:width="280"}

Siguiendo la definición 10, el sistema de ecuaciones correspondiente a $M$ es:

$$\left\{\begin{aligned}
  X_1  &=  a\,X_2 + b\,X_4 + \veps & (1) \\ 
  X_2  &=  a\,X_1 + b\,X_3         & (2) \\ 
  X_3  &=  b\,X_2 + a\,X_4         & (3) \\ 
  X_4  &=  b\,X_1 + a\,X_3         & (4)
\end{aligned}\right.$$ 

Sustitución de $(2)$ en $(1)$ y $(3)$:

$$\begin{aligned}
  X_1  &=  a\,(a\,X_1 + b\,X_3) + b\,X_4 + \veps    & \\ 
       &=  a\,a\,X_1 + a\,b\,X_3 + b\,X_4 + \veps   &
\end{aligned}$$ 

$$\begin{aligned}
  X_3  &=  b\,(a\,X_1 + b\,X_3) + a\,X_4    & \\ 
       &=  b\,a\,X_1 + b\,b\,X_3 + a\,X_4   &
\end{aligned}$$ 

Nos queda un sistema en 3 incógnitas:

$$\left\{\begin{aligned}
 X_1  &=  a\,a\,X_1 + a\,b\,X_3 + b\,X_4 + \veps  & (5) \\ 
 X_3  &=  b\,a\,X_1 + b\,b\,X_3 + a\,X_4          & (6) \\ 
 X_4  &=  b\,X_1 + a\,X_3                         & 
\end{aligned}\right.$$ 

Sustitución de $(4)$ en $(5)$ y $(6)$:

$$\begin{aligned}
 X_1  &=  a\,a\,X_1 + a\,b\,X_3 + b\,(b\,X_1 + a\,X_3)  + \veps    & \\ 
      &=  a\,a\,X_1 + a\,b\,X_3 + b\,b\,X_1 + b\,a\,X_3 + \veps    & \\ 
      &=  (a\,a + b\,b)\,X_1 + (a\,b + b\,a)\,X_3  + \veps         &
\end{aligned}$$ 

$$\begin{aligned}
 X_3  &=  b\,a\,X_1 + b\,b\,X_3 + a\,(b\,X_1 + a\,X_3)     & \\ 
      &=  b\,a\,X_1 + b\,b\,X_3 + a\,b\,X_1 + a\,a\,X_3    & \\ 
      &=  (a\,a + b\,b)\,X_3 + (a\,b + b\,a)\,X_1          & \\
      &=  (a\,a + b\,b)^\star (a\,b + b\,a)\,X_1           & \text{(lema de Arden)}
\end{aligned}$$ 

Nos queda un sistema en 2 incógnitas:

$$\left\{\begin{aligned}
 X_1  &=  (a\,a + b\,b)\,X_1 + (a\,b + b\,a)\,X_3 + \veps  & (7) \\ 
 X_3  &=  (a\,a + b\,b)^\star (a\,b + b\,a)\,X_1           & (8) \\ 
\end{aligned}\right.$$ 

Sustitución de $(8)$ en $(7)$:

$$\begin{aligned}
 X_1  &=  (a\,a + b\,b)\,X_1 + (a\,b + b\,a) (a\,a + b\,b)^\star (a\,b + b\,a)\,X_1 + \veps  & \\ 
      &=  ((a\,a + b\,b) + (a\,b + b\,a) (a\,a + b\,b)^\star (a\,b + b\,a))\,X_1 + \veps     & \\
      &=  ((a\,a + b\,b) + (a\,b + b\,a) (a\,a + b\,b)^\star (a\,b + b\,a))^\star \veps      & \text{(lema de Arden)} \\
      &=  ((a\,a + b\,b) + (a\,b + b\,a) (a\,a + b\,b)^\star (a\,b + b\,a))^\star            &
\end{aligned}$$ 

Por lo tanto, el lenguaje aceptado por $M$ es el lenguaje denotado por:

  $$ ((a\,a + b\,b) + (a\,b + b\,a) (a\,a + b\,b)^\star (a\,b + b\,a))^\star $$

</div>

## Referencias
* [^afn_afd]: Un resultado importante sobre Autómatas Finitos es que *deterministas* (AFD's) 
              y *no deterministas* (AFN's) son equivalentes en el sentido de que tienen el mismo
              poder expresivo, esto es que pueden reconocer/aceptar la misma clase
              de lenguajes denominada la clase de *lenguajes regulares*.
* [^notation_abuse]: Haciendo abuso de notación es común identificar la ER $r$ con el
                     el lenguaje denotado por $r$, o sea $\mathcal{L}(r)$.
* [^arden_variant]: Esta es la forma presentada originalmente en el paper de Arden.
* [^afn_epsilon]: Si se tiene un AFN-e, se puede convertir a AFN (o AFD) antes de aplicar el método.
{:footnotes}

## Relacionados
1. [Prueba de concepto - Virus: x86/DOS, COM, Overwriting]({% post_url 1970-01-01-poc-virus-x86dos-com-overwriting %})
2. [Project Euler - Problema 1: Múltiplos de 3 y 5]({% post_url 1970-01-01-project-euler-problema-1 %})

## Bibliografía
{% bibliography -q
   @*[key=Hopcroft-Motwani-Ullman2000 
   || key=Arden1961] 
%}