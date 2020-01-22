---
layout: post
title: Lema de Arden
categories: [Lenguajes Formales]
toc: true
---

Demostración del Lema de Arden.

## Teoría

### Autómata Finito
<div class="definition" data-number="1" data-name=" (AFN)"> 
Un Autómata Finito no determinista (AFN) es una quíntupla $(Q,\Sigma,\delta,s,F)$ donde:
<div markdown="1">
1. $ Q$ es un conjunto finito de estados.
2. $ \Sigma $ es un alfabeto finito.
3. $ s \in Q$ es el estado inicial.
4. $ F \subseteq Q$ es el conjunto de estados finales (de aceptación).
</div>
</div>

### Lenguajes y operaciones
<div class="definition" data-number="2" data-name=" (Alfabetos, Cadenas, Lenguajes)" markdown="1">
1. Un **alfabeto** $\Sigma$ es un conjunto finito no vació cuyos elementos son 
   denominados símbolos (o letras).
2. Una **cadena** (o palabra) $w = w_1\,w_2 \dots w_n$ es una secuencia finita formada 
   por la concatenación de $n$ símbolos tal que $w_i\in\Sigma$. El número de símbolos en $w$, 
   denotado $\len{w}$, es el largo de $w$. La cadena vacía, sin símbolos, se denota $\veps$ y es la 
   única cadena con largo $0$. Para toda cadena $w$ definimos $w^0=\veps$ y $w^k=w^{k-1}\,w$. 
3. Un **lenguaje** formal $L$ definido sobre $\Sigma$ es un conjunto de cadenas formadas a 
   partir de los símbolos de $\Sigma$.
</div>

Algunos lenguajes particulares son:

* $ \varnothing$ es el lenguaje vacío, no tiene cadenas.
* $ \lbrace \veps \rbrace$ es el lenguaje que tiene únicamente la cadena vacía.
* $ \Sigma^\star$ es el lenguaje de todas las cadenas que se 
  pueden formar sobre $\Sigma$, incluyendo la cadena vacía. Por lo tanto, 
  para cualquier lenguaje $L$ definido sobre $\Sigma$, 
  tenemos $L \,\subseteq\, \Sigma^\star$. 

Se pueden obtener lenguajes nuevos a partir de otros aplicando operaciones 
sobre estos. Como un lenguaje es un conjunto, entonces valen las operaciones 
ordinarias sobre conjuntos como Union, Intersección, etc. Adicionalmente, se 
definen otras operaciones especiales.

<div class="definition" data-number="3" data-name=" (Union)">
Sean $L_1$ y $L_2$ lenguajes. La union de $L_1$ y $L_2$ se define:

 $$ L_1 \cup L_2 \,=\, \{\, w \,\,|\,\, w \in L_1 \text{ o } w \in L_2  \,\} $$
</div>

<div class="definition" data-number="4" data-name=" (Concatenación)">
Sean $L_1$ y $L_2$ lenguajes. La concatenación de $L_1$ y $L_2$ se define:

 $$ L_1 \cdot L_2 \,=\, \{\, w \,\,|\,\, w = w_1 \, w_2 \text{ con }
   w_1 \in L_1 \text{ y } w_2 \in L_2  \,\} $$
</div>

<div class="definition" data-number="5" data-name=" (Potencia)">
Sea $L$ un lenguaje y $n \in \mathbb{N}$. La potencia de $L$ a la $n$ se define:

 $$ L^n \,=\,
  \begin{cases}
    \{ \veps \}       &\text{si } \,n=0   \\
    L^{n-1} \cdot L   &\text{si } \,n>0
  \end{cases}$$
</div>

<div class="definition" data-number="6" data-name=" (Clausura Kleene)">
Sea $L$ un lenguaje. La clausura Kleene de $L$ se define:

  $$L^\star \,=\, L^0 \,\cup\, L^1 \,\cup\, L^2 \,\cup\, \dots  
     \,=\, \bigcup\limits_{k=0}^{\infty}L^k$$ 

Alternativamente, una definición recursiva:

  $$L^\star \,=\, \{ \veps \} \,\cup\, \{\, w \,\,|\,\, w = w_1 \, w_2 \text{ con } 
       w_1 \in L \text{ y } w_2 \in L^\star \,\}$$
</div>

<div class="definition" data-number="7" data-name=" (Clausura Kleene+)">
Sea $L$ un lenguaje. La clausura Kleene+ de $L$ se define:

  $$L^+ \,=\, L \cdot L^\star $$
</div>

### Lenguaje/Expresión Regular
<div class="theorem" data-number="1" data-name=" (Kleene 1, Lenguaje Regular)">
Un lenguaje $L$ definido sobre un alfabeto $\Sigma$ es regular si y solo si $L$ 
es aceptado por un Autómata Finito.
</div>

<div class="theorem" data-number="2" data-name=" (Kleene 2)">
Todo lenguaje regular $L$ definido sobre un alfabeto $\Sigma$ puede ser construido 
a partir de $\varnothing$ y $\{ a \}$ (con $a\in\Sigma$) mediante las operaciones 
de Union, Concatenación y Clausura Kleene.
</div>

Otras operaciones como Intersección y Complemento también son cerradas sobre 
lenguajes regulares, pero no son esenciales.

Se define un lenguaje formal de Expresiones Regulares (ER) para denotar lenguajes 
complejos construidos mediante las operaciones elementales, de manera que para cada 
lenguaje regular $L$ hay una ER $r$ tal que $\mathcal{L}(r)=L$. [^notation_abuse]

<div class="definition" data-number="8" data-name=" (ER)">
Sean $r_1,r_2$ expresiones regulares y un alfabeto $\Sigma$. Entonces el lenguaje de ER
definido sobre $\Sigma$ se construye según las siguientes reglas de sintaxis con su 
semántica asociada.
<div class="table-responsive">
<table class="table">
  <thead class="thead-light">
    <tr>
      <th class="tg-0lax"></th>
      <th class="tg-0pky">Descripción</th>
      <th class="tg-0pky">Sintaxis</th>
      <th class="tg-0pky">Semántica</th>
    </tr>
  </thead>
  <tr>
    <td class="tg-0lax" rowspan="3">Caso base</td>
    <td class="tg-xldj">Lenguaje vacío</td>
    <td class="tg-xldj">$\emptyset$</td>
    <td class="tg-xldj">$\mathcal{L}(\emptyset) \,=\, \{ \} = \varnothing$</td>
  </tr>
  <tr>
    <td class="tg-0lax">Cadena vacía</td>
    <td class="tg-0lax">$\veps$</td>
    <td class="tg-0lax">$\mathcal{L}(\veps) \,=\, \{ \veps \}$</td>
  </tr>
  <tr>
    <td class="tg-0lax">$a\in\Sigma$</td>
    <td class="tg-0lax">$a$</td>
    <td class="tg-0lax">$\mathcal{L}(a) \,=\, \{ a \}$</td>
  </tr>
  <tr>
    <td class="tg-0lax" rowspan="3">Paso inductivo</td>
    <td class="tg-0lax">Clausura Kleene</td>
    <td class="tg-0lax">$r_{1}^{\star}$</td>
    <td class="tg-0lax">$\mathcal{L}(r_{1}^{\star}) \,=\, \mathcal{L}(r_1)^\star$</td>
  </tr>
  <tr>
    <td class="tg-0lax">Union</td>
    <td class="tg-0lax">$r_1 \,+\, r_2$</td>
    <td class="tg-0lax">$\mathcal{L}(r_1 \,+\, r_2) \,=\, \mathcal{L}(r_1) \,\cup\, \mathcal{L}(r_2)$</td>
  </tr>
  <tr>
    <td class="tg-0lax">Concatenación</td>
    <td class="tg-0lax">$r_1 \, r_2$</td>
    <td class="tg-0lax">$\mathcal{L}(r_1 \, r_2) \,=\, \mathcal{L}(r_1) \,\cdot\, \mathcal{L}(r_2)$</td>
  </tr>
</table>
</div>
</div>

<div class="definition" data-number="9">
Sean $r_1,r_2$ expresiones regulares. Entonces $r_1$ y $r_2$ son iguales si y 
solo si ambas denotan el mismo lenguaje. Es decir:  

  $$r_1 \,=\, r_2  \,\,\iff\,\,  \mathcal{L}(r_1) \,=\, \mathcal{L}(r_2)$$
</div>

La definición de $\veps$ (cadena vacía) como primitiva es conveniente, pero redundante
porque $\mathcal{L}(\emptyset^\star) \,=\, \mathcal{L}(\veps)=\{ \veps \}$. Notar que 
un lenguaje puede ser denotado por más de una RE. 

<div class="lemma" data-number="1" data-name=" (Identidades)">
Sean $r_1,r_2,r_3$ expresiones regulares. Algunas identidades básicas:

<div markdown="1">
1. Conmutatividad: 

   $$r_1 \,+\, r_2 \,=\, r_2 \,+\, r_1$$
2. Asociatividad: 

   $$\begin{aligned}
     r_1 \,+\, (r_2 \,+\, r_3)  \,&=\, (r_1 \,+\, r_2) \,+\, r_3   && \\
     r_1 \, (r_2 \, r_3)  \,&=\, (r_1 \, r_2) \, r_3               &&
   \end{aligned}$$
3. Distributividad:

   $$\begin{aligned}
     r_1 \, (r_2 \,+\, r_3)  \,&=\, r_1 \,r_2 \,+\, r_1 \,r_3   && \\
     (r_1 \,+\, r_2) \, r_3  \,&=\, r_1 \,r_3 \,+\, r_2 \,r_3   &&
   \end{aligned}$$
4. Elemento Neutro: 

   $$\begin{aligned}
     & r_1 \, \veps  \,=\, \veps \,  r_1      \,=\,  r_1           && \\
     & r_1 \,+\, \emptyset  \,=\, \emptyset \,+\, r_1 \,=\,  r_1   && \\           
     & r_1 \,+\, \veps       \,=\, \veps   \,+\, r_1  \,=\,  r_1   && \text{ sii } \,\veps \in \mathcal {L}(r_1) 
   \end{aligned}$$
5. Elemento Cero: 

   $$r_1 \, \emptyset  \,=\,  \emptyset \,  r_1 \,=\, \emptyset$$
6. Otros: 

   $$\begin{aligned}
     r_1^+ \,+\, \veps  \,&=\,  r_1^\star   && \\           
     (r_1^\star)^\star  \,&=\,  r_1^\star   && \\    
     r_1^+              \,&=\,  r_1^\star   && \text{ sii } \,\veps \in \mathcal{L}(r_1) \\ 
     \emptyset^\star    \,&=\,  \veps       &&
   \end{aligned}$$
</div>
</div>

<div class="example" data-number="1">
Sea $\Sigma=\{0,1\}$ :

<div markdown="1">
* $0^\star+1^\star$ denota el lenguaje de cadenas formadas con $0$ o $1$: 
 
    $$\{\veps, 0, 1, 00, 11, 000, 111, ... \}$$

* $(0\,1)^\star$ denota el lenguaje de cadenas formadas con $0$ y $1$:  

    $$\{\veps, 01, 0101, 010101, 01010101, ... \}$$

* $(0+1)^\star$ denota el lenguaje de cadenas formadas con $0$ y/o $1$:  

    $$\{\veps, 0, 1, 00, 11, 01, 10, ... \}$$
</div>
</div>

## Lema de Arden

<div class="lemma" data-number="2" data-name=" (Arden)">
Sean $X,A,B\subseteq\Sigma^\star$ con $\veps\not\in A$. Entonces:
 
   $$X \,=\, A \cdot X \,\cup\, B  \,\,\,\iff\,\,\,  X \,=\, A^\star \cdot B$$ 

En palabras, $A^\star \cdot B$ es el lenguaje más pequeño tal que es solución en la 
ecuación lineal $X \,=\, A \cdot X \,\cup\, B$. Además, si $\veps\not\in A$ entonces
dicha solución es única.
</div>

<div class="proof">
Procedemos en ambas direcciones.  

<div markdown="1">
$\large\Longleftarrow)$ Sea $X \,=\, A^\star \cdot B$. Verificamos que $X$ es una 
solución para la ecuación:

$$\begin{aligned}
  X  \,&=\, A^\star\cdot B                       && \\
   \,&=\, (A^+ \,\cup\, \{\veps\})\cdot B        && \\
   \,&=\, A^+\cdot B \,\cup\, B                  && \\ 
   \,&=\, (A\cdot A^\star)\cdot B \,\cup\, B     && \\
   \,&=\, A\cdot (A^\star \cdot B) \,\cup\, B    && \\
   \,&=\, A\cdot X \,\cup\, B                    &&
\end{aligned}$$

$\large\Longrightarrow)$ Sea $S$ una solución cualquiera de $X = A \cdot X \,\cup\, B$. 
Expandiendo tenemos:

$$\begin{aligned}
S \,&=\, A\cdot S  \,\cup\, B                                   && \\
 \,&=\, A\cdot (A\cdot S \,\cup\, B) \,\cup\, B                 && \\
 \,&=\, A^2\cdot S \,\cup\, A\cdot B \,\cup\, B                 && \\
 \,&=\, A^2\cdot (A\cdot S \,\cup\, B) \,\cup\, A\cdot B \,\cup\, B     && \\ 
 \,&=\, A^3\cdot S \,\cup\, A^2\cdot B \,\cup\, A\cdot B \,\cup\, B     && \\
 \,&\,\,\vdots                                                        && \\
 \,&=\, A^{n+1}\cdot S \,\cup\, A^{n}\cdot B \,\cup\, \dots \,\cup\, A^3\cdot B \,\cup\, A^2\cdot B \,\cup\, A\cdot B \,\cup\, B &&\\
 \,&=\, A^{n+1}\cdot S \,\cup\, (A^{n} \,\cup\, \dots \,\cup\, A^3 \,\cup\, A^2 \,\cup\, A \,\cup\, \{\veps\})\cdot B           &&
\end{aligned}$$ 

Entonces para todo $n \geq 0$:

  $$ S \,=\, A^{n+1}\cdot S \,\cup\, \left(\bigcup\limits_{k=0}^{n}A^k\right)\cdot B \tag{1}\label{eq1}$$ 

Esto significa en particular $A^k \cdot B \,\subseteq\, S$ para todo $n \geq 0$, 
entonces $A^\star \cdot B \,\subseteq\, S$.


Hasta acá tenemos que $A^\star \cdot B$ es una solución, y es la más pequeña porque está 
incluida en cualquier otra solución. Ahora, para determinar que esta solución es única, 
supongamos $\veps\not\in A$. Sea $w\in S$ tal que $\len{w}=n$ con $n \geq 0$, entonces por
$\eqref{eq1}$ tenemos dos casos posibles a considerar:

* $\, w \in A^{n+1}\cdot S \,\,\text{:}$ Pero si $\veps\not\in A$ entonces la cadena 
  más corta que puede haber en $A^{n+1}\cdot S$ es de largo $n+1$. Luego 
  $w \not\in A^{n+1}\cdot S$ y este caso queda descartado.
* $\, w \in \left(\bigcup\limits_{k=0}^{n}A^k\right)\cdot B \,\,\text{:}$ Se cumple 
  por haber descartado el caso anterior.

Necesariamente $w \in \left(\bigcup\limits_{k=0}^{n}A^k\right)\cdot B \,\subseteq\, A^\star \cdot B$, 
entonces $S \,\subseteq\, A^\star \cdot B$.  
Por lo tanto $S=A^\star \cdot B$.
</div>
</div>

Alternativamente, otra manera de probar el lema es usando inducción. 
Consideremos la dirección $\Longrightarrow$. Supongamos $X = A \cdot X \,\cup\, B$ con $\veps\not\in A$, 
entonces tenemos que demostrar $X = A^\star \cdot B$, esto es: $X \subseteq A^\star \cdot B$ y $X \supseteq A^\star \cdot B$. 
Ahora demostramos ambas inclusiones por separado.

$\large\subseteq)$ Notar que:

  $$X \subseteq A^\star \cdot B \iff \forall w \in X \,:\, w \in A^\star \cdot B$$ 

Procedemos por inducción fuerte en el largo de la cadena $w\in X$:

**Caso Base.** Sea $\len{w}=0$, o sea $w=\veps$.  
Tenemos que $w\in X$ y $X = A \cdot X \,\cup\, B$, entonces $w \in A \cdot X \,\cup\, B$, 
esto es: $w \in A \cdot X$ o bien $w \in B$.  
Pero $\veps\not\in A$, entonces $w \not\in A \cdot X$. Luego necesariamente $w \in B$.  
Además $B \subseteq A^\star \cdot B$, y por lo tanto $w \in A^\star \cdot B$.

**Paso Inductivo.**  
**HI.** $v \in A^\star \cdot B$ para todo $v\in X$ con $1 \leq \len{v} \leq n $.  
**TI.** $w \in A^\star \cdot B$ para $\len{w} \gt n$.  
Por casos:
* Supongamos $w \in B$. Entonces $w \in A^\star \cdot B$.
* Supongamos $w \not\in B$. Tenemos que $w\in X$ y $X = A \cdot X \,\cup\, B$, 
  entonces $w \in A \cdot X \,\cup\, B$, esto es: $w \in A \cdot X$ o bien $w \in B$. 
  Pero $w \not\in B$, luego necesariamente $w \in A \cdot X$.  
  Si $w \in A \cdot X$ entonces existen $w_1\in A$ y $w_2\in X$ tal que $w = w_1\,w_2$.
  Como $\veps\not\in A$ tenemos que $\len{w_1}\geq 1$ y entonces $\len{w} \gt \len{w_2}$. Tomando $w_2=v$, 
  entonces por la HI: $w_2 \in A^\star \cdot B$.  
  Ahora tenemos que $w=w_1\,w_2 \,\in\, A \cdot (A^\star \cdot B)$.  
  Además:

    $$A \cdot (A^\star \cdot B) \,=\, (A \cdot A^\star) \cdot B 
      \,=\, A^+ \cdot B \,\,\subseteq\,\, A^\star \cdot B$$ 

  Por lo tanto $w \in A^\star \cdot B$.

Habiendo completado la inducción, hemos demostrado $X \subseteq A^\star \cdot B$.

$\large\supseteq)$ Se puede demostrar de manera similar.
<span style="float:right;font-size:1.7em">&#x20DE;</span>

<hr style="clear:both;">
Observaciones del lema:
* Si los lenguajes $A$ y $B$ son regulares, entonces la solución $A^\star \cdot B$ es un 
  lenguaje regular. Esto es porque las operaciones de Clausura Kleene y Concatenación son 
  cerradas sobre lenguajes regulares.
* Si $\veps\in A$, entonces la ecuación $X = A \cdot X \,\cup\, B$ tiene infinitas soluciones 
  de la forma $A^\star\cdot(B \,\cup\, C)$ donde $C\subseteq\Sigma^\star$ es un lenguaje
  arbitrario. Verificación:

  $$\begin{aligned}
   X  \,&=\, A^\star\cdot(B \,\cup\, C)                              && \\
   \,&=\, A^\star\cdot B \,\cup\, A^\star\cdot C                  && \\
   \,&=\, (A^+\,\cup\, \{\veps\})\cdot B \,\cup\, A^\star\cdot C  && \\ 
   \,&=\, A^+\cdot B \,\cup\, B \,\cup\, A^\star\cdot C           && \\
   \,&=\, A^+\cdot B \,\cup\, A^\star\cdot C \,\cup\, B           && \\
   \,&=\, A^+\cdot B \,\cup\, A^+\cdot C \,\cup\, B               && \\
   \,&=\, A^+\cdot(B \,\cup\, C) \,\cup\, B                       && \\
   \,&=\, A\cdot A^\star\cdot(B \,\cup\, C) \,\cup\, B            && \\
   \,&=\, A\cdot X \,\cup\, B                                     &&
  \end{aligned}$$
* Otra versión del Lema de Arden se cumple de manera análoga para gramáticas lineales por
  izquierda: [^arden_variant]

    $$X \,=\, X \cdot A \,\cup\, B  \,\,\,\iff\,\,\,  X \,=\, B \cdot A^\star$$

## Conversión de AFN a ER
Un método de conversión de AFN a ER consiste en resolver el sistema de ecuaciones
lineales regulares asociado al AFN.  Una aplicación util del lema de Arden es en la 
resolución de dicho sistema de ecuaciones, específicamente en las ecuaciones recursivas. [^afn_epsilon] 

<div class="definition" data-number="10" >
Sea $M=(Q,\Sigma,\delta,s,F)$ un AFD/AFN tal que $Q=\{ q_1,q_2,...,q_n \}$. El sistema 
de ecuaciones asociado a $M$ tiene $n$ incógnitas $Q_1,Q_2,...,Q_n$ y $n$ ecuaciones, una 
por cada $Q_i$, de la forma:

$$Q_i \,=\, \sum_{q_j\in\delta(q_i,x)} x\,Q_j 
   \,\,+\,\, \begin{cases} \veps &\text{si } \,q_i\in F \\ \emptyset &\text{si } \,q_i\not\in F \end{cases} $$
</div>

Cada $Q_i$ es una ER que denota aquellas cadenas aceptadas por $M$ comenzando desde el 
estado $q_i$. Entonces si $q_1$ es el estado inicial, la solución de $Q_1$ es la ER que 
denota el lenguaje aceptado por $M$, o sea $\mathcal{L}(Q_1)=\mathcal{L}(M)$.

<div class="example" data-number="2">
Sea $M=(Q,\Sigma,\delta,s,F)$ un AFN con:
<div markdown="1">
* $ Q=\lbrace q_1, q_2, q_3, q_4 \rbrace$
* $ \Sigma=\lbrace \texttt{a}, \texttt{b} \rbrace$
* $ s=q_1 $
* $ F=\lbrace q_1 \rbrace$
</div>
y el siguiente diagrama de transición:

<img src="/assets/images/lema-arden/example2.svg" alt=""
     width="280" class="aligncenter" />

El sistema de ecuaciones correspondiente a $M$ es:

$$\left\{\begin{aligned}
  Q_1 \,\,&=\,\, a\,Q_2 \,+\, b\,Q_4 \,+\, \veps & (1) \\ 
  Q_2 \,\,&=\,\, a\,Q_1 \,+\, b\,Q_3             & (2)\\ 
  Q_3 \,\,&=\,\, b\,Q_2 \,+\, a\,Q_4             & (3)\\ 
  Q_4 \,\,&=\,\, b\,Q_1 \,+\, a\,Q_3             & (4)
\end{aligned}\right.$$ 

Sustitución de $(2)$ en $(1)$ y $(3)$:

$$\begin{aligned}
  Q_1 \,\,&=\,\, a\,(a\,Q_1 \,+\, b\,Q_3) \,+\, b\,Q_4 \,+\, \veps    & \\ 
      \,\,&=\,\, a\,a\,Q_1 \,+\, a\,b\,Q_3 \,+\, b\,Q_4 \,+\, \veps   &
\end{aligned}$$ 

$$\begin{aligned}
  Q_3 \,\,&=\,\, b\,(a\,Q_1 \,+\, b\,Q_3) \,+\, a\,Q_4    & \\ 
      \,\,&=\,\, b\,a\,Q_1 \,+\, b\,b\,Q_3 \,+\, a\,Q_4   &
\end{aligned}$$ 

Nos queda un sistema en 3 incógnitas:

$$\left\{\begin{aligned}
 Q_1 \,\,&=\,\, a\,a\,Q_1 \,+\, a\,b\,Q_3 \,+\, b\,Q_4 \,+\, \veps  & (5) \\ 
 Q_3 \,\,&=\,\, b\,a\,Q_1 \,+\, b\,b\,Q_3 \,+\, a\,Q_4              & (6)\\ 
 Q_4 \,\,&=\,\, b\,Q_1 \,+\, a\,Q_3                                 & 
\end{aligned}\right.$$ 

Sustitución de $(4)$ en $(5)$ y $(6)$:

$$\begin{aligned}
 Q_1 \,\,&=\,\, a\,a\,Q_1 \,+\, a\,b\,Q_3 \,+\, b\,(b\,Q_1 \,+\, a\,Q_3)  \,+\, \veps  & \\ 
   \,\,&=\,\, a\,a\,Q_1 \,+\, a\,b\,Q_3 \,+\, b\,b\,Q_1 \,+\, b\,a\,Q_3 \,+\, \veps    & \\ 
   \,\,&=\,\, (a\,a \,+\, b\,b)\,Q_1 \,+\, (a\,b \,+\, b\,a)\,Q_3  \,+\, \veps         &
\end{aligned}$$ 

$$\begin{aligned}
 Q_3 \,\,&=\,\, b\,a\,Q_1 \,+\, b\,b\,Q_3 \,+\, a\,(b\,q_1 \,+\, a\,Q_3)   & \\ 
   \,\,&=\,\, b\,a\,Q_1 \,+\, b\,b\,Q_3 \,+\, a\,b\,q_1 \,+\, a\,a\,Q_3    & \\ 
   \,\,&=\,\, (a\,a \,+\, b\,b)\,Q_3 \,+\, (a\,b \,+\, b\,a)\,Q_1          & \\
   \,\,&=\,\, (a\,a \,+\, b\,b)^\star\,(a\,b \,+\, b\,a)\,Q_1              & \text{(lema de Arden)}
\end{aligned}$$ 

Nos queda un sistema en 2 incógnitas:

$$\left\{\begin{aligned}
 Q_1 \,\,&=\,\, (a\,a \,+\, b\,b)\,Q_1 \,+\, (a\,b \,+\, b\,a)\,Q_3  \,+\, \veps  & (7) \\ 
 Q_3 \,\,&=\,\, (a\,a \,+\, b\,b)^\star\,(a\,b \,+\, b\,a)\,Q_1                   & (8)\\ 
\end{aligned}\right.$$ 

Sustitución de $(8)$ en $(7)$:

$$\begin{aligned}
 Q_1 \,\,&=\,\, (a\,a \,+\, b\,b)\,Q_1 \,+\, (a\,b \,+\, b\,a)\,(a\,a \,+\, b\,b)^\star\,(a\,b \,+\, b\,a)\,Q_1 \,+\, \veps  & \\ 
   \,\,&=\,\, ((a\,a \,+\, b\,b) \,+\, (a\,b \,+\, b\,a)\,(a\,a \,+\, b\,b)^\star\,(a\,b \,+\, b\,a))\,Q_1 \,+\, \veps     & \\
   \,\,&=\,\, ((a\,a \,+\, b\,b) \,+\, (a\,b \,+\, b\,a)\,(a\,a \,+\, b\,b)^\star\,(a\,b \,+\, b\,a))^\star \,\veps      &    \text{(lema de Arden)} \\
   \,\,&=\,\, ((a\,a \,+\, b\,b) \,+\, (a\,b \,+\, b\,a)\,(a\,a \,+\, b\,b)^\star\,(a\,b \,+\, b\,a))^\star  &
\end{aligned}$$ 

Por lo tanto, el lenguaje aceptado por $M$ es el lenguaje denotado por:

  $$ ((a\,a \,+\, b\,b) \,+\, (a\,b \,+\, b\,a)\,(a\,a \,+\, b\,b)^\star\,(a\,b \,+\, b\,a))^\star $$

</div>

## Notas
* [^notation_abuse]: Es común hacer abuso de notación y tratar la ER $r$ como si esta fuera
                     el lenguaje denotado $\mathcal{L}(r)$.
* [^arden_variant]: Así es presentado en el paper original de Arden.
* [^afn_epsilon]: Si se tiene un AFN-e, se puede convertir a AFN (o AFD) antes de aplicar el método.
{:footnotes}

## Bibliografía
{% bibliography -q
   @*[key=Hopcroft-Motwani-Ullman2000 
   || key=Arden1961] 
%}