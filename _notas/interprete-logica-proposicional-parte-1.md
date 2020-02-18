---
categories: [Lenguajes Formales, Autómatas, Lógica]
layout: post
published: true
tags: [AFD, AFN, AFN-e, Myhill-Nerode]
title: "Intérprete para lenguaje de Lógica Proposicional - Parte I"
toc: true
---
{% include fragments/pseudocode.html %}
<style>
table.trans td:first-child {
  color: #495057;
  background-color: #e9ecef;
  border-color: #dee2e6;
  text-align: right;
}
table.borderless {
  border: none;
}
table.borderless tr,
table.borderless td {
    border: none;
}
</style>

Se diseña un intérprete para un lenguaje de Lógica Proposicional siguiendo un enfoque 
tradicional y sistemático.  
  
Representación de operadores lógicos en ASCII:
<div class="table-responsive">
<table class="table text-center">
  <thead class="thead-light">
    <tr>
      <th>Operador</th>
      <th>Símbolo</th>
      <th>ASCII</th>
    </tr>
  </thead>
  <tr>
    <td>Bicondicional</td>
    <td>$\longleftrightarrow$</td>
    <td>$\texttt{<->}$</td>
  </tr>
  <tr>
    <td>Condicional</td>
    <td>$\longrightarrow$</td>
    <td>$\texttt{->}$</td>
  </tr>
  <tr>
    <td>Disyunción</td>
    <td>$\lor$</td>
    <td>$\texttt{|}$</td>
  </tr>
  <tr>
    <td>Conjunción</td>
    <td>$\land$</td>
    <td>$\texttt{&}$</td>
  </tr>
  <tr>
    <td>Negación</td>
    <td>$\neg$</td>
    <td>$\texttt{-}$</td>
  </tr>
</table>
</div>

## Análisis Léxico
Sea $L$ el lenguaje que describe el léxico de la lógica proposicional sobre el 
alfabeto $$\Sigma=\{ \texttt{<}, \texttt{>}, \texttt{-}, \texttt{&}, \texttt{|}, \texttt{(}, 
\texttt{)}, ␣, \texttt{a}, \texttt{b}, \texttt{c}, ..., \texttt{z} \}$$, identificamos 4 
categorías léxicas (tokens) a reconocer durante el análisis:

<div class="table-responsive">
<table class="table">
  <thead class="thead-light text-center">
    <tr>
      <th>Categoría</th>
      <th>Descripción</th>
      <th>Patrón</th>
      <th>Lexemas</th>
    </tr>
  </thead>
  <tr>
    <td>$\text{op}$</td>
    <td>Operadores lógicos</td>
    <td>$\texttt{<-> } \mid \texttt{ -> } \mid \texttt{ & } \mid \texttt{ | } \mid \texttt{ -}$</td>
    <td>$\texttt{<->}$, $\texttt{->}$, $\texttt{&}$, $\texttt{|}$, $\texttt{-}$</td>
  </tr>
  <tr>
    <td>$\text{var}$</td>
    <td>Variables proposicionales</td>
    <td>$\texttt{a } \mid \texttt{ b } \mid \texttt{ c } \mid \ ... \ \mid \texttt{ z}$</td>
    <td>$\texttt{a}$, $\texttt{b}$, $\texttt{c}$, ..., $\texttt{z}$</td>
  </tr>
  <tr>
    <td>$\text{punct}$</td>
    <td>Simbolos de puntuación y precedencia</td>
    <td>$\texttt{( } \mid \texttt{ )}$</td>
    <td>$\texttt{(}$, $\texttt{)}$</td>
  </tr>
  <tr>
    <td>$\text{ws}$</td>
    <td>Espacios en blanco</td>
    <td>␣$+$</td>
    <td>␣, ␣␣, ␣␣␣, ...</td>
  </tr>
</table>
</div>

donde ␣ denota el espacio en blanco ASCII.

$L$ especificado en BNF:  

  $$
  \begin{aligned}  
    op   & \ ::= \ \texttt{ <-> } \mid \texttt{ -> } \mid \texttt{ & } \mid \texttt{ | } \mid \texttt{ - } \\  
    var  & \ ::= \ \texttt{ a } \mid \texttt{ b } \mid \texttt{ c } \mid \ ... \ \mid \texttt{ z }         \\  
    punt & \ ::= \ \texttt{ ( } \mid \texttt{ ) }                                                          \\  
    ws   & \ ::= \ ␣\,+  
  \end{aligned}
  $$

$L$ especificado por una expresión regular (ER):  

  $$
  \texttt{<->} \ + \ \texttt{->} 
               \ + \ \texttt{&} 
               \ + \ \texttt{|} 
               \ + \ \texttt{-} 
               \ + \ [\texttt{a}-\texttt{z}] 
               \ + \ \texttt{(} 
               \ + \ \texttt{)} 
               \ + \ ␣^+    \label{er:1.1}\tag{1.1}
  $$ 
                 
donde $[\texttt{a}-\texttt{z}] = \texttt{a} \,+\, \texttt{b} \,+\, \texttt{c} \,+\, ... \,+\, \texttt{z}$

### $L$ es regular

La ER \eqref{er:1.1} denota el lenguaje:  

  $$
  \begin{aligned}
    L & = \mathcal{L}(\texttt{<}) \cdot \mathcal{L}(\texttt{-}) \cdot \mathcal{L}(\texttt{>}) 
            \cup \mathcal{L}(\texttt{-}) \cdot \mathcal{L}(\texttt{>})) 
            \cup \mathcal{L}(\texttt{&}) 
            \cup \mathcal{L}(\texttt{|}) 
            \cup \mathcal{L}(\texttt{-}) 
            \cup \mathcal{L}([\texttt{a}-\texttt{z}]) 
            \cup \mathcal{L}(\texttt{(}) 
            \cup \mathcal{L}(\texttt{)}) 
            \cup \mathcal{L}(␣)^+ & \\
      & = \{ \texttt{<->},\ \texttt{->},\ \texttt{&},\ \texttt{|},\ \texttt{-},\ 
             \texttt{a},\ \texttt{b},\ \texttt{c},\ ...,\ \texttt{z},\ \texttt{(},\ 
             \texttt{)},\ ␣,\ ␣␣,\ ␣␣ ... \} &
  \end{aligned}
  $$

El teorema de Myhill-Nerode establece la condición necesaria y suficiente para que un 
lenguaje formal sea regular.

{% math definition 1 %}
Sea $L \subseteq \Sigma^\star$ y $x, y \in \Sigma^\star$. Entonces una cadena $z \in \Sigma^\star$ 
es una extensión distintiva de $x$ e $y$ si se cumple $x\,z \in L \mathrel{\rlap{\hskip .9em/}}\iff y\,z \in L$.
{% endmath %}

{% math definition 2 %}
Sea $L \subseteq \Sigma^\star$ y $x, y \in \Sigma^\star$. Entonces las cadenas $x$ e $y$ son 
indistinguibles respecto al lenguaje $L$ si no existe $z \in \Sigma^\star$ que sea extensión 
distintiva de $x$ e $y$, es decir para toda $z \in \Sigma^\star$ se cumple $x\,z \in L \iff y\,z \in L$.
{% endmath %}

{% math theorem 1 "Myhill-Nerode" %}
Sea $L \subseteq \Sigma^\star$. Entonces el lenguaje $L$ es regular si y solo si 
$\len{ L/\sim_L }$ es finito, donde $\sim_L $ es la relación de equivalencia 
Myhill-Nerode definida como:

  $$x \; \sim_L \; y \iff x, y \text{ son indistinguibles respecto a } L$$ 
  
Además, si $L$ es regular, entonces $\len{ L/\sim_L }$ es el número mínimo de 
estados necesarios para que un AFD reconozca $L$.
{% endmath %}

Aplicamos el teorema de Myhill-Nerode para demostrar que $L$ es regular.

{% math theorem 2 %}
El lenguaje $L$ es regular, y el AFD mínimo que lo reconoce requiere de 7 estados.
{% endmath %}

{% math proof %}
Se construye una cantidad finita de clases de equivalencia según $\sim_{L} $, para esto 
se enumeran las cadenas posibles y se utilizan extensiones distintivas para agruparlas en sus 
respectivas clases:

<div class="table-responsive">
<table class="table borderless">
  <tr>
    <td>1.</td>
    <td>$\{\veps\}$</td>
    <td>$\Longrightarrow$   </td>
    <td>$\{ \texttt{<->}, \texttt{->}, \texttt{-}, \texttt{&}, \vert, \texttt{(}, \texttt{)}, \texttt{a}, ..., \texttt{z}, ␣, ␣␣, ␣␣␣, ... \}$</td>
  </tr>
  <tr>
    <td>2.</td>
    <td>$\{\texttt{<}\}$</td>
    <td>$\Longrightarrow$</td>
    <td>$\{ \texttt{->}  \}$</td>
  </tr>
  <tr>
    <td>3.</td>
    <td>$\{\texttt{<-}\}$</td>
    <td>$\Longrightarrow$</td>
    <td>$\{ \texttt{>}  \}$</td>
  </tr>
  <tr>
    <td>4.</td>
    <td>$\{\texttt{-}\}$</td>
    <td>$\Longrightarrow$</td>
    <td>$\{ \veps, \texttt{>} \}$</td>
  </tr>
  <tr>
    <td>5.</td>
    <td>$\{\texttt{<->}, \texttt{->}, \texttt{&}, \vert, \texttt{(}, \texttt{)}, \texttt{a}, ..., \texttt{z}\}$</td>
    <td>$\Longrightarrow$</td>
    <td>$\{ \veps\}$</td>
  </tr>    
  <tr>
    <td>6.</td>
    <td>$L(␣)^+$</td>
    <td>$\Longrightarrow$</td>
    <td>$\{ \veps, ␣, ␣␣, ␣␣␣, ... \}$</td>
  </tr> 
  <tr>
    <td>7.</td>
    <td>$\overline{L} - \{\veps\}$</td>
    <td>$\Longrightarrow$</td>
    <td>$\Sigma^\star$</td>
  </tr>    
</table>
</div>

Observamos que las 7 clases son completas, al abarcar todas las cadenas de $\Sigma^\star$, y 
disjuntas ya que toda cadena pertenece a una única clase:

\$$\Sigma^\star = \{\veps\} \cup \{\texttt{<}\} \cup \{\texttt{<-}\} \cup \{\texttt{-}\} \cup \{\texttt{<->}, \texttt{->}, \texttt{&}, \vert, \texttt{(}, \texttt{)}, \texttt{a}, ..., \texttt{z}\} \cup L(␣)^+ \cup (\overline{L} - \{\veps\})$$

\$$L = \{\texttt{-}\} \cup \{\texttt{<->}, \texttt{->}, \texttt{&}, \vert, \texttt{(}, \texttt{)}, \texttt{a}, ..., \texttt{z}\} \cup L(␣)^+$$

Por lo tanto $L$ es regular y se necesita un AFD con al menos 7 estados para reconocerlo.
{% endmath %}

### Autómata Finito Determinista  
Construimos un Autómata Finito Determinista (AFD) para reconocer el lenguaje regular descrito 
por la expresión regular \eqref{er:1.1}.

Método:
1. A partir de \eqref{er:1.1} se obtiene un Autómata Finito No Determinista con 
   transiciones $\veps$ (AFN-e)
2. Quitar las transiciones $\veps$ del AFN-e para obtener un AFN
3. Convertir el AFN a un AFD
4. Minimizar AFD
    
#### De Expresión regular a AFN-e     
Aplicamos el algoritmo *Thompson-McNaughton-Yamada* sobre \eqref{er:1.1} y obtenemos el AFN-e, 
llamemosle $M_1$, representado por el siguiente diagrama de estados:

  {% img afn-e.png | {"width":"839"} %}
  
Formalmente $M_1=(Q,\Sigma,\delta,s,F)$ con:

* \$$Q=\{ q_0, q_1, q_2, \dots, q_{36} \}$$
* \$$\Sigma=\{ \texttt{<}, \texttt{>}, \texttt{-}, \texttt{&}, \vert, \texttt{(}, \texttt{)}, ␣, \texttt{a}, \texttt{b}, \texttt{c}, \dots, \texttt{z} \}$$
* $s=q_0$ es el estado inicial.
* \$$F=\{ q_{36} \}$$
* \$$\delta : Q \times (\Sigma \cup \{ \veps \}) \to 2^Q$$  
  Tabla de transiciones para los primeros 8 estados:  
  <div class="table-responsive text-center">
  <table class="table trans">
    <thead class="thead-light">
      <tr>
        <th>$\delta$</th>
        <th>$\texttt{<}$</th>
        <th>$\texttt{-}$</th>
        <th>$\texttt{>}$</th>
        <th>$\texttt{&}$</th>
        <th>$\texttt{|}$</th>
        <th>$[\texttt{a}-\texttt{z}]$</th>
        <th>$\texttt{(}$</th>
        <th>$\texttt{)}$</th>
        <th>␣</th>
        <th>$\veps$</th>
      </tr>
    </thead>
    <tr>
      <td>$\rightarrow q_0$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\{ q_1, q_5 \}$</td>
    </tr>
    <tr>
      <td>$q_1$</td>
      <td>$\{ q_2 \}$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
    </tr>
    <tr>
      <td>$q_2$</td>
      <td>$\varnothing$</td>
      <td>$\{ q_3 \}$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
    </tr>
    <tr>
      <td>$q_3$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\{ q_4 \}$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
    </tr>
    <tr>
      <td>$q_4$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\{ q_{36} \}$</td>
    </tr>
    <tr>
      <td>$q_5$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\{ q_6, q_9 \}$</td>
    </tr>
    <tr>
      <td>$q_6$</td>
      <td>$\varnothing$</td>
      <td>$\{ q_7 \}$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
    </tr>
    <tr>
      <td>$q_7$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\{ q_8 \}$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
    </tr>
    <tr>
      <td>$q_8$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\{ q_{35} \}$</td>
    </tr>
    <tr>
      <td>$\vdots$</td>
      <td>$\vdots$</td>
      <td>$\vdots$</td>
      <td>$\vdots$</td>
      <td>$\vdots$</td>
      <td>$\vdots$</td>
      <td>$\vdots$</td>
      <td>$\vdots$</td>
      <td>$\vdots$</td>
      <td>$\vdots$</td>
      <td>$\vdots$</td>
    </tr>
    <tr>
      <td>$q_{35}$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\{ q_{36} \}$</td>
    </tr>
    <tr>
      <td>$\text{*} q_{36}$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
    </tr>
  </table>
  </div>

##### Computación en AFN-e
Sea $w \in \Sigma^\star$ y $q \in Q$. Entonces $\hat{\delta}$ es la función de transición 
generalizada que computa el conjunto de el conjunto de los estados resultantes de ejecutar 
un AFN-e con la configuración inicial $(q, w)$:

  $$
  \begin{aligned}
    \hat{\delta} & : Q \times \Sigma^\star \to 2^Q                                                                      & \\
    \hat{\delta} & (q,\veps)      = C_\veps(q)                                                                          & \\
    \hat{\delta} & (q, x \cdot v) = C_\veps \left( \bigcup\limits_{r \;\in\; \hat{\delta}(q,v) }^{} \delta(r,x) \right) &
  \end{aligned}
  $$

donde:
* $q \in Q$, $v \in \Sigma^\star$ y $x \in \Sigma$.
* $C_\veps(q)$ es la clausura respecto de $\veps$ para el estado $q$, esto es el conjunto
  de todos los estados alcanzables desde $q$ usando únicamente transiciones $\veps$.
* Sea $Q$ un conjunto de estados, $C_\veps(Q) = \bigcup\limits_{q \; \in \; Q}^{} C_\veps(q)$ 

En términos de $\hat{\delta}$, el lenguaje reconocido por $M_1$ es: 

  $$\mathcal{L}(M_1) = \{ w \ \mid \ \hat{\delta}(q_0,w) \cap F \neq \varnothing \}$$

Las $C_\veps$ para los estados de $M_1$:

$$\quad C_\veps(q_0)= \{ q_0, q_1, q_5, q_6, q_9, q_{10}, q_{12}, q_{13}, q_{15}, q_{16}, q_{18}, q_{19}, q_{21}, q_{22}, q_{24}, q_{25}, q_{27} \}$$  
$$\quad C_\veps(q_1)= \{ q_1 \}$$  
$$\quad C_\veps(q_2)= \{ q_2 \}$$  
$$\quad C_\veps(q_3)= \{ q_3 \}$$  
$$\quad C_\veps(q_4)= \{ q_4, q_{36} \}$$  
$$\quad C_\veps(q_5)= \{ q_5, q_6, q_9, q_{10}, q_{12}, q_{13}, q_{15}, q_{16}, q_{18}, q_{19}, q_{21}, q_{22}, q_{24}, q_{25}, q_{27} \}$$  
$$\quad C_\veps(q_6)= \{ q_6 \}$$  
$$\quad C_\veps(q_7)= \{ q_7 \}$$  
$$\quad C_\veps(q_8)= \{ q_8, q_{35}, q_{36} \}$$  
$\quad \vdots$  
$$\quad C_\veps(q_{35})= \{ q_{35}, q_{36} \}$$  
$$\quad C_\veps(q_{36})= \{ q_{36} \}$$

Ejemplos de cómputo en $M_1$:
    
{% math example 1 %}
Sea $w=\texttt{->}$, verifiquemos que $w$ es un lexema válido. Aplicamos $\hat{\delta}$ 
sobre $(q_0, \texttt{->})$:

$$
\begin{aligned}
  \hat{\delta}(q_0, \veps) 
    &= C_\veps(q_{0})                                                       & \\
    &= \{ q_0, q_1, q_5, q_6, q_9, q_{10}, q_{12}, q_{13}, q_{15}, q_{16}, 
          q_{18}, q_{19}, q_{21}, q_{22}, q_{24}, q_{25}, q_{27} \}         &
\end{aligned}
$$  
$$
\begin{aligned}
  \hat{\delta}(q_0, \texttt{-}) 
    &=     C_\veps \left( \bigcup\limits_{r \; \in \; \hat{\delta}(q_0,\veps) }^{} \delta(r,\texttt{-}) \right)              & \\ 
    &=     C_\veps( \delta (q_0,\texttt{-}) \cup \delta (q_1,\texttt{-}) \cup \delta (q_5,\texttt{-}) \cup \delta (q_6,\texttt{-}) \cup \delta (q_9,\texttt{-}) \cup \delta (q_{10},\texttt{-})       & \\
    & \cup \delta (q_{12},\texttt{-}) \cup \delta (q_{13},\texttt{-}) \cup \delta (q_{15},\texttt{-}) \cup \delta (q_{16},\texttt{-}) \cup \delta (q_{18},\texttt{-}) \cup \delta (q_{19},\texttt{-}) & \\
    & \cup \delta (q_{21},\texttt{-}) \cup \delta (q_{22},\texttt{-}) \cup \delta (q_{24},\texttt{-}) \cup \delta (q_{25},\texttt{-}) \cup \delta (q_{27},\texttt{-}))                                & \\
    &=     C_\veps( \varnothing \cup \varnothing \cup \varnothing \cup \{ q_7 \} \cup \varnothing \cup ... \cup \varnothing) & \\
    &=     C_\veps( \{ q_7 \})   & \\
    &=     \{ q_7 \}             &
\end{aligned}
$$  
$$
\begin{aligned}
  \hat{\delta}(q_0, \texttt{->}) 
    &= C_\veps \left( \bigcup\limits_{r \; \in \; \hat{\delta}(q_0,\texttt{-}) }^{} \delta(r,\texttt{>}) \right)  & \\
    &= C_\veps( \delta (q_7,\texttt{>}) )                                                                         & \\
    &= C_\veps( \{ q_8 \} )                                                                                       & \\
    &= \{ q_8, q_{35}, q_{36} \}                                                                                  &
\end{aligned}
$$
  
Al menos $q_{36} \in F$, entonces $M_1$ acepta $w$ y $w\in\mathcal{L}(M_1)$. 
Por lo tanto, $w$ es válido.
{% endmath %}    
    
{% math example 2 %}
Sea $w=\texttt{<-}$, verifiquemos que $w$ no es un lexema válido. Aplicamos $\hat{\delta}$ 
sobre $(q_0, \texttt{<-})$:

$$
\begin{aligned}
  \hat{\delta}(q_0, \veps) 
    &= C_\veps(q_{0})                                                       & \\
    &= \{ q_0, q_1, q_5, q_6, q_9, q_{10}, q_{12}, q_{13}, q_{15}, q_{16}, 
          q_{18}, q_{19}, q_{21}, q_{22}, q_{24}, q_{25}, q_{27} \}         &
\end{aligned}
$$  
$$
\begin{aligned}
  \hat{\delta}(q_0, \texttt{<}) 
    &=     C_\veps \left( \bigcup\limits_{r \; \in \; \hat{\delta}(q_0,\veps) }^{} \delta(r,\texttt{<}) \right) & \\
    &=     C_\veps( \delta (q_0,\texttt{<}) \cup \delta (q_1,\texttt{<}) \cup \delta (q_5,\texttt{<}) \cup \delta (q_6,\texttt{<}) \cup \delta (q_9,\texttt{<}) \cup \delta (q_{10},\texttt{<}) & \\
    & \cup \delta (q_{12},\texttt{<}) \cup \delta (q_{13},\texttt{<}) \cup \delta (q_{15},\texttt{<}) \cup \delta (q_{16},\texttt{<}) \cup \delta (q_{18},\texttt{<}) \cup \delta (q_{19},\texttt{<}) & \\
    & \cup \delta (q_{21},\texttt{<}) \cup \delta (q_{22},\texttt{<}) \cup \delta (q_{24},\texttt{<}) \cup \delta (q_{25},\texttt{<}) \cup \delta (q_{27},\texttt{<})) & \\
    &=     C_\veps( \varnothing \cup \{ q_2 \} \cup \varnothing \cup ... \cup \varnothing) & \\
    &=     C_\veps( \{ q_2 \}) & \\
    &=     \{ q_2 \} &
\end{aligned}
$$  
$$
\begin{aligned}
  \hat{\delta}(q_0, \texttt{<-}) 
    &= C_\veps \left( \bigcup\limits_{r \; \in \; \hat{\delta}(q_0,\texttt{<}) }^{} \delta(r,\texttt{-}) \right) & \\
    &= C_\veps( \delta (q_2,\texttt{-}) )                                                                        & \\
    &= C_\veps( \{ q_3 \} )                                                                                      & \\
    &= \{ q_3 \}                                                                                                 &
\end{aligned}
$$
  
Tenemos $q_{3} \not\in F$, entonces $M_1$ rechaza $w$ y $w\not\in\mathcal{L}(M_1)$. 
Por lo tanto, $w$ no es válido.
{% endmath %}      

#### De AFN-e a AFN 
Se aplica el método *Backward $\veps$-removal* sobre el diagrama de transiciones del AFN-e $M_1$ 
para quitar las transiciones $\veps$. Adicionalmente, como un primer paso de minimización, se 
remueven los estados inalcanzables desde $q_0$. El resultado es el AFN $M_2$:

  {% img afn.png | {"width":"386"} %}
    
Formalmente $M_2=(Q, \Sigma, \delta, s, F)$ con:

* \$$Q=\{ q_0, q_1, q_2, ..., q_{12} \}$$
* \$$\Sigma=\{ \texttt{<}, \texttt{>}, \texttt{-}, \texttt{&}, \vert, \texttt{(}, \texttt{)}, ␣, \texttt{a}, \texttt{b}, \texttt{c}, ..., \texttt{z} \}$$
* $s=q_0$ es el estado inicial.
* \$$F=\{ q_{3}, q_{5}, q_{6}, q_{7}, q_{8}, q_{9}, q_{10}, q_{11}, q_{12} \}$$
* $\delta : Q \times \Sigma \to 2^Q$  
  Tabla de transiciones:
  <div class="table-responsive text-center">
  <table class="table trans">
    <thead class="thead-light">
      <tr>
        <th>$\delta$</th>
        <th>$\texttt{<}$</th>
        <th>$\texttt{-}$</th>
        <th>$\texttt{>}$</th>
        <th>$\texttt{&}$</th>
        <th>$\texttt{|}$</th>
        <th>$[\texttt{a}-\texttt{z}]$</th>
        <th>$\texttt{(}$</th>
        <th>$\texttt{)}$</th>
        <th>$␣$</th>
      </tr>
    </thead>  
    <tr>
      <td>$\rightarrow q_0$</td>
      <td>$\{ q_1 \}$</td>
      <td>$\{ q_4, q_6 \}$</td>
      <td>$\varnothing$</td>
      <td>$\{ q_7 \}$</td>
      <td>$\{ q_8 \}$</td>
      <td>$\{ q_9 \}$</td>
      <td>$\{ q_{10} \}$</td>
      <td>$\{ q_{11} \}$</td>
      <td>$\{ q_{12} \}$</td>
    </tr>
    <tr>
      <td>$q_1$</td>
      <td>$\varnothing$</td>
      <td>$\{ q_2 \}$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
    </tr>
    <tr>
      <td>$q_2$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\{ q_3 \}$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
    </tr>
    <tr>
      <td>$\text{*} q_3$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
    </tr>
    <tr>
      <td>$q_4$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\{ q_5 \}$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
    </tr>
    <tr>
      <td>$\text{*} q_5$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
    </tr>
    <tr>
      <td>$\text{*} q_6$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
    </tr>
    <tr>
      <td>$\text{*} q_7$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
    </tr>
    <tr>
      <td>$\text{*} q_8$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
    </tr>
    <tr>
      <td>$\text{*} q_9$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
    </tr>
    <tr>
      <td>$\text{*} q_{10}$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
    </tr>
    <tr>
      <td>$\text{*} q_{11}$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
    </tr>
    <tr>
      <td>$\text{*} q_{12}$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\varnothing$</td>
      <td>$\{ q_{12} \}$</td>
    </tr>
  </table>
  </div>
    
Ahora, la causa de no-determinismo está en $$\delta (q_0,\texttt{-}) = \{ q_4, q_6 \}$$.
    
##### Computación en AFN
Sea $w \in \Sigma^\star$ y $q \in Q$. Entonces $\hat{\delta}$ es la función de transición 
generalizada que computa el conjunto de todos los estados posibles al ejecutar un AFN con la 
configuración inicial $(q, w)$:

  $$
  \begin{aligned}
    \hat{\delta} & : Q \times \Sigma^\star \to 2^Q                                               & \\
    \hat{\delta} & (q,\veps)      = \{ q \}                                                      & \\
    \hat{\delta} & (q, x \cdot v) = \bigcup\limits_{r \;\in\; \hat{\delta}(q,v) }^{} \delta(r,x) &
  \end{aligned}
  $$
  
donde $q \in Q$, $v \in \Sigma^\star$ y $x \in \Sigma$.  
  
En términos de $\hat{\delta}$, el lenguaje reconocido por $M_2$ es:

  $$\mathcal{L}(M_2) = \{ w \ \mid \ \hat{\delta}(q_0,w) \cap F \neq \varnothing \}$$
    
Ejemplos de cómputo en $M_2$:
    
{% math example 3 %}
Sea $w=\texttt{->}$, verifiquemos que $w$ es un lexema válido. Aplicamos $\hat{\delta}$ 
sobre $(q_0, \texttt{->})$:

$$\hat{\delta}(q_0, \veps) = \{ q_0 \}$$  
$$
\begin{aligned}
  \hat{\delta}(q_0, \texttt{-})  
    &= \bigcup\limits_{r \; \in \; \hat{\delta}(q_0,\veps) }^{} \delta(r,\texttt{-})   & \\
    &= \delta (q_0,\texttt{-})                                                         & \\
    &= \{ q_4, q_6 \}                                                                  &  
\end{aligned}
$$  
$$
\begin{aligned}
  \hat{\delta}(q_0, \texttt{->})  
    &= \bigcup\limits_{r \; \in \; \hat{\delta}(q_0,\texttt{-}) }^{} \delta(r,\texttt{>})  & \\
    &= \delta (q_4,\texttt{>}) \cup \delta (q_6,\texttt{>})                                & \\
    &= \{ q_5 \} \cup \varnothing                                                          & \\ 
    &= \{ q_5 \}                                                                           &
\end{aligned}
$$

Tenemos $q_{5} \in F$, entonces $M_2$ acepta $w$ y $w\in\mathcal{L}(M_2)$. 
Por lo tanto, $w$ es válido.
{% endmath %}
    
{% math example 4 %}
Sea $w=\texttt{<-}$, verifiquemos que $w$ no es un lexema válido. Aplicamos $\hat{\delta}$ 
sobre $(q_0, \texttt{<-})$: 

$$\hat{\delta}(q_0, \veps) = \{ q_0 \}$$  
$$
\begin{aligned}
  \hat{\delta}(q_0, \texttt{<})  
    &= \bigcup\limits_{r \; \in \; \hat{\delta}(q_0,\veps) }^{} \delta(r,\texttt{<})   & \\
    &= \delta (q_0,\texttt{<})                                                         & \\
    &= \{ q_1 \}                                                                       &  
\end{aligned}
$$  
$$
\begin{aligned}
  \hat{\delta}(q_0, \texttt{<-})  
    &= \bigcup\limits_{r \; \in \; \hat{\delta}(q_0,\texttt{<}) }^{} \delta(r,\texttt{-})  & \\
    &= \delta (q_1,\texttt{-})                                                             & \\
    &= \{ q_2 \}                                                                           &  
\end{aligned}
$$

Tenemos $q_{2} \not\in F$, entonces $M_2$ no acepta $w$ y $w\not\in\mathcal{L}(M_2)$. 
Por lo tanto, $w$ no es válido.  
{% endmath %}

#### De AFN a AFD
Se aplica el algoritmo de Construcción de Subconjuntos para obtener el AFD $M_3$ a partir de 
el AFN $M_2$:
    
   {% img afd.png | {"width":"380"} %}  
    
Formalmente $M_3=(Q, \Sigma, \delta, s, F)$ con:

* \$$Q=\{ q_0, q_1, q_2, \dots, q_{11} \}$$
* \$$\Sigma=\{ \texttt{<}, \texttt{>}, \texttt{-}, \texttt{&}, \vert, \texttt{(}, \texttt{)}, ␣, \texttt{a}, \texttt{b}, \texttt{c}, \dots, \texttt{z} \}$$
* $s=q_0$ es el estado inicial.
* \$$F=\{ q_{3}, q_{4}, q_{5}, q_{6}, q_{7}, q_{8}, q_{9}, q_{10}, q_{11} \}$$
* $\delta : Q \times \Sigma \to Q$  
  Tabla de transiciones:  
  <div class="table-responsive text-center">
  <table class="table trans">
    <thead class="thead-light">
      <tr>
        <th>$\delta$</th>
        <th>$\texttt{<}$</th>
        <th>$\texttt{-}$</th>
        <th>$\texttt{>}$</th>
        <th>$\texttt{&}$</th>
        <th>$\texttt{|}$</th>
        <th>$[\texttt{a}-\texttt{z}]$</th>
        <th>$\texttt{(}$</th>
        <th>$\texttt{)}$</th>
        <th>␣</th>
      </tr>
    </thead>  
    <tr>
      <td>$\rightarrow q_0$</td>
      <td>$ q_1 $</td>
      <td>$ q_4 $</td>
      <td>$\emptyset$</td>
      <td>$ q_6 $</td>
      <td>$ q_7 $</td>
      <td>$ q_8 $</td>
      <td>$ q_{9} $</td>
      <td>$ q_{10} $</td>
      <td>$ q_{11} $</td>
    </tr>
    <tr>
      <td>$q_1$</td>
      <td>$\emptyset$</td>
      <td>$ q_2 $</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
    </tr>
    <tr>
      <td>$q_2$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$ q_3 $</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
    </tr>
    <tr>
      <td>$\text{*} q_3$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
    </tr>
    <tr>
      <td>$\text{*} q_4$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$ q_5 $</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
    </tr>
    <tr>
      <td>$\text{*} q_5$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
    </tr>
    <tr>
      <td>$\text{*} q_6$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
    </tr>
    <tr>
      <td>$\text{*} q_7$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
    </tr>
    <tr>
      <td>$\text{*} q_8$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
    </tr>
    <tr>
      <td>$\text{*} q_9$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
    </tr>
    <tr>
      <td>$\text{*} q_{10}$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
    </tr>
    <tr>
      <td>$\text{*} q_{11}$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$q_{11}$</td>
    </tr>
  </table>
  </div>   
  Donde $\emptyset$ denota el estado muerto (estado trampa).

##### Computación en AFD
Sea $w \in \Sigma^\star$ y $q \in Q$, $\hat{\delta}$ es la función de transición generalizada 
que computa el estado final al ejecutar un AFD con la configuración inicial $(q, w)$:

  $$
  \begin{aligned} 
    \hat{\delta} & : Q \times \Sigma^\star \rightarrow Q         &  \\
    \hat{\delta} & (q,\veps)      = q                            &  \\
    \hat{\delta} & (q, x \cdot v) = \delta(\hat{\delta}(q,v),x)  &
  \end{aligned}
  $$
  
donde $q \in Q$, $v \in \Sigma^\star$ y $x \in \Sigma$.

En términos de $\hat{\delta}$, el lenguaje reconocido por $M_3$ es:
 
  $$\mathcal{L}(M_3) = \{ w \ \mid \ \hat{\delta}(q_0,w) \in F \}$$
          
Ejemplos de cómputo en $M_3$:
  
{% math example 5 %} 
Sea $w=\texttt{->}$, verifiquemos que $w$ es un lexema válido. Aplicamos $\hat{\delta}$ 
sobre $(q_0, \texttt{->})$: 

$$
\begin{aligned}
  \hat{\delta}(q_0, \texttt{->})
    &= \delta(\hat{\delta}(q_0,\texttt{-}),\texttt{>})                  & \\
    &= \delta(\delta(\hat{\delta}(q_0, \veps), \texttt{-}),\texttt{>})  & \\
    &= \delta(\delta(q_0,\texttt{-}),\texttt{>})                        & \\
    &= \delta(q_4,\texttt{>})                                           & \\
    &= q_5
\end{aligned}
$$  

Tenemos $q_5 \in F$, entonces $M_3$ acepta $w$ y $w\in\mathcal{L}(M_3)$. 
Por lo tanto, $w$ es válido.
{% endmath %}  

{% math example 6 %} 
Sea $w=\texttt{<-}$, verifiquemos que $w$ no es un lexema válido. Aplicamos $\hat{\delta}$ 
sobre $(q_0, \texttt{<-})$: 

$$
\begin{aligned}
  \hat{\delta}(q_0, \texttt{<-})
    &= \delta(\hat{\delta}(q_0,\texttt{<}),\texttt{-})                  & \\
    &= \delta(\delta(\hat{\delta}(q_0, \veps), \texttt{<}),\texttt{-})  & \\
    &= \delta(\delta(q_0,\texttt{<}),\texttt{-})                        & \\
    &= \delta(q_1,\texttt{-})                                           & \\
    &= q_2
\end{aligned}
$$  
  
Tenemos $q_{2} \not\in F$, entonces $M_3$ no acepta $w$ y $w\not\in\mathcal{L}(M_3)$. 
Por lo tanto, $w$ no es válido.
{% endmath %}   

  
#### Minimización de AFD         
De acuerdo con el [teorema 2](#theorem_2), el AFD mínimo para reconocer $L$ tendría 7 estados, 
pero el AFD $M_3$ obtenido anteriormente tiene 11 estados por lo que no es mínimo.
          
Minimizar $M_3$ resulta en el siguiente AFD mínimo con 7 estados (se omite el estado muerto):

  {% img afd-min-1.png | {"width":"260"} %}  
          
Sin embargo, con el propósito de utilizar el AFD como base para crear un Analizador Léxico, el 
proceso de minimización no debe fusionar aquellos estados finales que permiten clasificar diferentes 
categorías léxicas. Por ejemplo, el AFD anterior no permite diferenciar un operador lógico de 
una variable proposicional porque ambos son reconocidos en el mismo estado final $q_3$. Por este 
motivo preferimos el siguiente AFD $M_4$ con 9 estados:
          
  {% img afd-min-2.png | {"width":"260"} %}          

Formalmente $M_4=(Q, \Sigma, \delta, s, F)$ con:

* \$$Q=\{ q_0, q_1, q_2, q_3, q_4, q_5, q_6, q_7 \}$$
* \$$\Sigma=\{ \texttt{<}, \texttt{>}, \texttt{-}, \texttt{&}, \vert, \texttt{(}, \texttt{)}, ␣, \texttt{a}, \texttt{b}, \texttt{c}, \dots, \texttt{z} \}$$
* $s=q_0$ es el estado inicial.
* \$$F=\{ q_3, q_4, q_5, q_6, q_7 \}$$
* $\delta : Q \times \Sigma \to Q$  
  Tabla de transiciones:  
  <div class="table-responsive text-center">
  <table class="table trans">
    <thead class="thead-light">
      <tr>
        <th>$\delta$</th>
        <th>$\texttt{<}$</th>
        <th>$\texttt{-}$</th>
        <th>$\texttt{>}$</th>
        <th>$\texttt{&}$</th>
        <th>$\texttt{|}$</th>
        <th>$[\texttt{a}-\texttt{z}]$</th>
        <th>$\texttt{(}$</th>
        <th>$\texttt{)}$</th>
        <th>␣</th>
      </tr>
    </thead>  
    <tr>
      <td>$\rightarrow q_0$</td>
      <td>$ q_1 $</td>
      <td>$ q_4 $</td>
      <td>$\emptyset$</td>
      <td>$ q_3 $</td>
      <td>$ q_3 $</td>
      <td>$ q_5 $</td>
      <td>$ q_6 $</td>
      <td>$ q_6 $</td>
      <td>$ q_7 $</td>
    </tr>
    <tr>
      <td>$q_1$</td>
      <td>$\emptyset$</td>
      <td>$ q_2 $</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
    </tr>
    <tr>
      <td>$q_2$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$ q_3 $</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
    </tr>
    <tr>
      <td>$\text{*} q_3$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
    </tr>
    <tr>
      <td>$\text{*} q_4$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$ q_3 $</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
    </tr>
    <tr>
      <td>$\text{*} q_5$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
    </tr>
    <tr>
      <td>$\text{*} q_6$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
    </tr>
    <tr>
      <td>$\text{*} q_7$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$\emptyset$</td>
      <td>$ q_7 $</td>
    </tr>
  </table>
  </div>  
  Donde $\emptyset$ denota el estado muerto (estado trampa).
      
#### Verificar AFD
Asumiendo que \eqref{er:1.1} describe correctamente $L$, podemos a modo de verificación convertir 
$M_4$ a una expresión regular y ver que esta sea equivalente a \eqref{er:1.1}. En ese caso 
$\mathcal{L}(M_4) = L$.

**Método algebraico**
                
{% math definition 3 %}
Sea $M=(Q,\Sigma,\delta,s,F)$ un AFD/AFN tal que $Q=\{ q_1,q_2,...,q_n \}$. El sistema 
de ecuaciones asociado a $M$ tiene $n$ incógnitas $X_1,X_2,...,X_n$ y $n$ ecuaciones, una 
por cada $q_i$, de la forma:

  $$X_i \ = \ \sum_{q_j \, \in \, \delta(q_i,x)} x\,X_j 
              \ + \ \begin{cases} \veps     &\text{si } \ q_i\in F     \\ 
                                  \emptyset &\text{si } \ q_i\not\in F 
                    \end{cases} $$
                  
{% endmath %}                

Sistema de ecuaciones para $M_4$:

  $$
  \left\{\begin{aligned}
    X_0 \ &= \ \texttt{<}\,X_1 \,+\, \texttt{&}\,X_3 \,+\, \texttt{|}\,X_3 \,+\, \texttt{-}\,X_4 
                               \,+\, [\texttt{a}-\texttt{z}]\,X_5 \,+\, \texttt{(}\,X_6 
                               \,+\, \texttt{)}\,X_6 \,+\, ␣\,X_7                                & (1) \\ 
    X_1 \ &= \ \texttt{-}\,X_2                                                                    & (2) \\ 
    X_2 \ &= \ \texttt{>}\,X_3                                                                    & (3) \\
    X_3 \ &= \ \veps                                                                              & (4) \\
    X_4 \ &= \ \texttt{>}\,X_3 \,+\, \veps                                                        & (5) \\
    X_5 \ &= \ \veps                                                                              & (6) \\
    X_6 \ &= \ \veps                                                                              & (7) \\
    X_7 \ &= \ ␣\,X_7 \,+\, \veps                                                                 & (8)
  \end{aligned}\right.
  $$

Se resuelve el sistema usando el Lema de Arden y propiedades elementales de las 
operaciones $\cup$, $\cdot$ y $\star$ sobre lenguajes.

{% math lemma 1 Arden %}
Sean $X,A,B\subseteq\Sigma^\star$ con $\veps\not\in A$. Entonces:
 
  $$X \ = \ A \cdot X \cup B \ \ \iff \ \ X \ = \ A^\star \cdot B$$ 

{% endmath %}

Por lema de Arden en $(8)$:    $X_7 \,=\, ␣\,X_7 \,+\, \veps \,=\, ␣^\star\,\veps \,=\, ␣^\star$  
Sustitución de $(4)$ en $(5)$: $X_4 \,=\, \texttt{>}\,X_3 \,+\, \veps \,=\, \texttt{>} \veps \,+\, \veps \,=\, \texttt{>} \,+\, \veps $  
Sustitución de $(4)$ en $(3)$: $X_2 \,=\, \texttt{>}\,X_3 \,=\, \texttt{>}\,\veps \,=\, \texttt{>}$  
Sustitución de $(3)$ en $(2)$: $X_1 \,=\, \texttt{-}\,X_2 \,=\, \texttt{->}$  

Finalmente:

  $$
  \begin{aligned}
    X_0 \ &= \ \texttt{<}\,X_1 \,+\, (\texttt{&} \,+\, \texttt{|})\,X_3 \,+\, \texttt{-}\,X_4 \,+\, [\texttt{a}-\texttt{z}] \,+\, (\texttt{(} \,+\, \texttt{)})\,X_6 \,+\, ␣\,X_7 & \\ 
        \ &= \ \texttt{<->} \,+\, (\texttt{&} \,+\, \texttt{|})\veps \,+\, \texttt{-}\;(\texttt{>} \,+\, \veps) \,+\, [\texttt{a}-\texttt{z}]\veps \,+\, (\texttt{(} \,+\, \texttt{)})\veps \,+\, ␣\,␣^\star & \\
        \ &= \ \texttt{<->} \,+\, \texttt{&} \,+\, \texttt{|} \,+\, \texttt{->} \,+\, \texttt{-} \veps \,+\, [\texttt{a}-\texttt{z}] \,+\, \texttt{(} \,+\, \texttt{)} \,+\, ␣\,␣^\star & \\
        \ &= \ \texttt{<->} \,+\, \texttt{->} \,+\, \texttt{&} \,+\, \texttt{|} \,+\, \texttt{-} \,+\, [\texttt{a}-\texttt{z}] \,+\, \texttt{(} \,+\, \texttt{)} \,+\, ␣^+ &
  \end{aligned}
  $$

Se obtiene la expresión regular original \eqref{er:1.1}, por lo tanto $\mathcal{L}(M_4) = L$.
           
### Analizador Léxico
El Analizador Léxico (AL) es una máquina similar al AFD salvo por dos aspectos:

1. No intenta reconocer la entrada sino segmentarla en una secuencia de componentes léxicos 
   (tokens), realizando para cada uno de ellos determinadas acciones asociadas.
2. Opera repetidamente sobre la entrada, comenzando siempre desde el estado inicial pero 
   consumiendo la entrada desde una posición diferente. Desde cada posición utiliza una 
   estrategia *greedy*: intenta obtener el prefijo más largo que pertenezca a alguna 
   categoría léxica.
 
{% math example 7 %}
Para la entrada $\texttt{p}␣\texttt{&}␣\texttt{(q->r)}$, la secuencia de tokens es:

  $$\texttt{var}, \texttt{ws}, \texttt{op}, \texttt{ws}, \texttt{punct}, 
    \texttt{var}, \texttt{op}, \texttt{var}, \texttt{punct}
  $$
    
{% endmath %}
                
En esta sección construimos $AL_L$: el analizador léxico para el lenguaje $L$ utilizando como 
base el AFD $M_4$ obtenido anteriormente.
  
#### Interfaz AL
El AL provee al menos dos funciones:

* nextToken: función que procesa la entrada en busca del siguiente componente léxico (token) 
  y lo retorna.
* lastToken: función que retorna el último token reconocido. No afecta la entrada.

#### Flujo de entrada
El AL asume que tiene a su disposición los siguientes servicios del flujo de entrada:
  
* nextChar: función que lee el siguiente carácter de la entrada y lo retorna.
* moveBack: procedimiento que retrocede en la lectura de la entrada una cantidad determinada 
  de posiciones, o equivalentemente que devuelve a la entrada una sub-cadena leída previamente.

El fin de la entrada puede estar marcado por un carácter especial o no, dependiendo de cual 
sea el origen del flujo de entrada. Para abstraer el AL de este detalle se hace explícito el 
fin de la entrada a través del símbolo <span>$</span> para el cual el AL retorna la categoría 
especial $\text{eof}$. De esta manera, el procesamiento de la entrada toma la siguiente forma:

{% pseudocode %}
  \STATE AL $ := $ AL($input$)
  \STATE $t := $ \CALL{AL.nextToken}{} 
  \WHILE{$t \neq $ eof}      
      \STATE ...
      \STATE $t := $ \CALL{AL.nextToken}{} 
  \ENDWHILE
{% endpseudocode %}
                
Esto significa agregar al AFD $M_4$ el estado final $q_8$ y la transición $$\delta (q_0,\$) = q_8$$.

#### Acciones y atributos
Asignamos a cada categoría léxica acciones y atributos.
  
<div class="table-responsive">
<table class="table">
  <thead class="thead-light text-center">
    <tr>
      <th>Categoría</th>
      <th>Acciones</th>
      <th>Atributos</th>
    </tr>
  </thead>  
  <tr>
    <td>$\text{op}$</td>
    <td>Emitir</td>
    <td></td>
  </tr>
  <tr>
    <td>$\text{var}$</td>
    <td>Emitir</td>
    <td>Lexema</td>
  </tr>
  <tr>
    <td>$\text{punct}$</td>
    <td>Emitir</td>
    <td></td>
  </tr>
  <tr>
    <td>$\text{ws}$</td>
    <td>Omitir <b>*</b></td>
    <td></td>
  </tr>
  <tr>
    <td>$\text{eof}$</td>
    <td>Emitir</td>
    <td></td>
  </tr>
</table>
</div>

**\*** Luego de omitir un token es necesario reiniciar el AL para continuar procesando la entrada.  
                
#### Implementación AL
Consideramos dos posibles implementaciones del AL:

1. Mediante tablas: se implementa la lógica de un AL genérico y luego se codifica el AL concreto 
   en tablas independientes de la lógica. Es la opción más mantenible.
2. Mediante control de flujo: se implementa código que simula directamente el funcionamiento 
   del AL. Es la opción más eficiente.

##### Mediante tablas               
Para el caso general, se mantienen 3 tablas:

* Tabla de movimientos (**M**): es la tabla de estados del AFD que reconoce el lenguaje.
* Tabla de estados finales (**F**): contiene para cada estado un valor booleano que indica si 
  es final o no.
* Tabla de acciones (**A**): contiene para cada estado acciones asociadas.

En particular para $AL_{L}$, las acciones se reducen a emitir u omitir el token 
correspondiente a una categoría léxica. Adicionalmente, de acuerdo con la asignación previa de 
acciones y atributos, al emitir la categoría $\texttt{var}$ se debe incluir el lexema leído 
como atributo.
  
{% pseudocode 1 %}
  \STATE M $ = $ Tabla de estados del AFD \uppercase{$M_4$} (incluyendo estado/símbolo para la categoría $\text{eof}$)
  \STATE F $ = $ [false, false, false, true, true, true, true, true, true]
  \STATE A $ = $ [$NULL$, $NULL$, $NULL$, op, op, var, punct, ws, eof]
  \STATE
  \FUNCTION{nextToken}{}
      \STATE $q := q_0 \qquad\;$            \COMMENT{estado actual}
      \STATE $fq := \varnothing \qquad$     \COMMENT{último estado final alcanzado}
      \STATE $l := \varepsilon \qquad\;\;$  \COMMENT{cadena actual}
      \STATE $fl := \varepsilon \qquad$     \COMMENT{último lexema leído}
      \WHILE{\TRUE}      
          \STATE $c := $ \CALL{nextChar}{} 
          \STATE $l := l \cdot c$

          \IF{\CALL{delta}{$q, c$} $ \neq \varnothing$}
              \STATE $q := $ \CALL{delta}{$q, c$}
              \IF{F$[q] = $ \TRUE}
                  \STATE $fq := q$
                  \STATE $fl := l$
              \ENDIF
          \ELSE
              \IF{$fq \neq \varnothing$}
                  \STATE \CALL{moveBack}{$l \div fl$}
                  \STATE $t := $ \CALL{execute}{A$[fq], fl$}
                  \IF{$t = NULL$}                              \COMMENT{ omitir token}
                      \STATE $q := q_0$
                      \STATE $fq := \varnothing$
                      \STATE $l, fl := \varepsilon$
                  \ELSE                                        \COMMENT{ emitir token}     
                      \RETURN t                             
                  \ENDIF
              \ELSE                
                  \STATE \textbf{raise} "Error - No se esperaba: " $ \cdot\; c$
              \ENDIF            
          \ENDIF 
      \ENDWHILE      
  \ENDFUNCTION
{% endpseudocode %}

donde $l \div fl$ denota el resultado de extraer el prefijo $fl$ de la cadena $l$.

##### Mediante control de flujo
Para el caso general, la estructura global del AL es un ciclo que consume en cada iteración 
un caracter de la entrada y ejecuta el código asociado al estado actual: 

{% pseudocode %}                
  \FUNCTION{nextToken}{}
      \STATE $q := q_0$
      \STATE $fq := \varnothing$
      \STATE $l, fl := \varepsilon$
      \WHILE{\TRUE}      
          \STATE $c := $ \CALL{nextChar}{} 
          \STATE $l := l \cdot c$
       
          \STATE \textbf{case} $q$ \textbf{of}
          \STATE $\quad q_0: \quad$ \COMMENT{ código asociado a $q_0$}
          \STATE $\quad q_1: \quad$ \COMMENT{ código asociado a $q_1$}
          \STATE $\quad$ ...
          \STATE $\quad q_n: \quad$ \COMMENT{ código asociado a $q_n$} 
      \ENDWHILE      
  \ENDFUNCTION                  
{% endpseudocode %}  
            
El código asociado al estado actual depende de si el estado es final o no, de las acciones 
asociadas, y de la complejidad del propio autómata.

Código para un estado $q_i$ no final:

{% pseudocode %}                
  \STATE \textbf{case} $c$ \textbf{of}
  \STATE $\quad x_1: \quad q := \delta (q,x_1)$
  \STATE $\quad x_2: \quad q := \delta (q,x_2)$
  \STATE $\quad$ ...
  \STATE $\quad x_k: \quad q := \delta (q,x_k)$   
  \STATE $\quad otro:$
  \STATE $\qquad$ \textbf{if} $fq \neq \varnothing$ \textbf{then}
  \STATE $\qquad\quad$ \CALL{moveBack}{$l \div fl$}
  \STATE $\qquad\quad$ \textbf{return} $token$
  \STATE $\qquad$ \textbf{else}
  \STATE $\qquad\quad$ \textbf{raise} "Error - No se esperaba: " $ \cdot\; c$             
{% endpseudocode %}
             
Código para un estado $q_i$ final:
      
{% pseudocode %}
  \STATE $fq := q_i$
  \STATE $fl := l / c$
  \STATE \textbf{case} $c$ \textbf{of}
  \STATE $\quad x_1: \quad q := \delta (q,x_1)$
  \STATE $\quad x_2: \quad q := \delta (q,x_2)$
  \STATE $\quad$ ...
  \STATE $\quad x_k: \quad q := \delta (q,x_k)$   
  \STATE $\quad otro:$
  \STATE $\qquad$ \CALL{moveBack}{$c$}
  \STATE $\qquad$ \COMMENT{acciones de $q_i$}
  \STATE $\qquad$ \COMMENT{si las acciones incluyen omitir}
  \STATE $\qquad\quad q := q_0$
  \STATE $\qquad\quad fq := \varnothing$
  \STATE $\qquad\quad l, fl := \varepsilon$
  \STATE $\qquad$ \COMMENT{si no incluyen omitir}
  \STATE $\qquad\quad$ \textbf{return} $token$ 
{% endpseudocode %}    
              
donde $l / c$ denota el resultado de extraer el caracter final $c$ de la cadena $l$.
                
En particular para $AL_{L}$, las transiciones son codificadas de acuerdo con el AFD $M_4$ 
(incluyendo estado/símbolo para la categoría $\text{eof}$). Además, no es necesario 
mantener el último estado final alcanzado, esto simplifica la implementación.

{% pseudocode 2 %}
  \FUNCTION{nextToken}{}
      \STATE $q := q_0$
      \STATE $l, fl := \varepsilon$
      \WHILE{\TRUE}      
          \STATE $c := $ \CALL{nextChar}{} 
          \STATE $l := l \cdot c$
       
          \STATE \textbf{case} $q$ \textbf{of}
          \STATE $\quad q_0:$
              \STATE $\qquad$ \textbf{case} $c$ \textbf{of}
              \STATE $\qquad\quad$ \texttt{>} $: \quad q := 1$
              \STATE $\qquad\quad$ \texttt{-} $: \quad q := 4$
              \STATE $\qquad\quad$ \texttt{\&} $: \quad q := 3$
              \STATE $\qquad\quad$ \texttt{|}$: \quad q := 3$
              \STATE $\qquad\quad$ \texttt{a}: \texttt{b}: ... \texttt{z}:$ \quad q := 5$
              \STATE $\qquad\quad$ \texttt{(}$: \quad q := 6$
              \STATE $\qquad\quad$ \texttt{)}$: \quad q := 6$
              \STATE $\qquad\quad$ \texttt{␣}$: \quad q := 7$
              \STATE $\qquad\quad$ \texttt{\$}$: \quad q := 8$
              \STATE $\qquad\quad otro:$
              \STATE $\qquad\qquad$ \textbf{raise} "Error - No se esperaba: " $ \cdot\; c$   
          \STATE $\quad q_1:$
              \STATE $\qquad$ \textbf{case} $c$ \textbf{of}
              \STATE $\qquad\quad$ \texttt{-} $: \quad q :=2$
              \STATE $\qquad\quad otro:$
              \STATE $\qquad\qquad$ \textbf{raise} "Error - No se esperaba: " $ \cdot\; c$ 
          \STATE $\quad q_2:$
              \STATE $\qquad$ \textbf{case} $c$ \textbf{of}
              \STATE $\qquad\quad$ \texttt{>} $: \quad q := 3$
              \STATE $\qquad\quad otro:$
              \STATE $\qquad\qquad$ \textbf{raise} "Error - No se esperaba: " $ \cdot\; c$
          \STATE $\quad q_3:$
              \STATE $\qquad$ \CALL{moveBack}{$c$}
              \STATE $\qquad$ \textbf{return} \lowercase{OP}
          \STATE $\quad q_4:$
              \STATE $\qquad$ \textbf{case} $c$ \textbf{of}
              \STATE $\qquad\quad$ \texttt{>} $: \quad q := 3$
              \STATE $\qquad\quad otro:$
              \STATE $\qquad\qquad$ \CALL{moveBack}{$c$}
              \STATE $\qquad\qquad$ \textbf{return} \lowercase{OP}
          \STATE $\quad q_5:$
              \STATE $\qquad fl := l / c$
              \STATE $\qquad$ \CALL{moveBack}{$c$}
              \STATE $\qquad$ \textbf{return} \lowercase{VAR}($fl$)
          \STATE $\quad q_6:$
              \STATE $\qquad$ \CALL{moveBack}{$c$}
              \STATE $\qquad$ \textbf{return} \lowercase{PUNCT}
          \STATE $\quad q_7:$
              \STATE $\qquad$ \textbf{case} $c$ \textbf{of}
              \STATE $\qquad\quad$ \texttt{␣} $: \quad q := 7$
              \STATE $\qquad\quad otro:$
              \STATE $\qquad\qquad$ \CALL{moveBack}{$c$}
              \STATE $\qquad\qquad q := q_0$
              \STATE $\qquad\qquad l, fl := \varepsilon$
          \STATE $\quad q_8:$
              \STATE $\qquad$ \CALL{moveBack}{$c$}
              \STATE $\qquad$ \textbf{return} \lowercase{EOF}
      \ENDWHILE      
  \ENDFUNCTION    
{% endpseudocode %}  

## Relacionados
1. [Autómatas finitos - Implementación]({% link _notas/af-equivalencia-afd-afn.md %})
2. [Autómatas finitos - Equivalencia AFD-AFN]({% link _notas/af-implementacion.md %})
3. [Lema de Arden]({% link _notas/lema-arden.md %})

## Bibliografía
{% bibliography -q
   @*[key=Aho-Lam-Sethi-Ullman2006,
   || key=Hopcroft-Motwani-Ullman2000] 
%}