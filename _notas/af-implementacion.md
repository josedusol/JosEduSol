---
categories: [Autómatas, Teoría de la Computación]
layout: page-note
published: true
tags: [AFD, AFN, AFN-e]
title: "Autómatas finitos - Implementación"
toc: true
---
{% include fragments/pseudocode.html %}

Implementaciones para la simulación de autómatas finitos en su forma determinista y no determinista.  

## Determinismo
{% math definition 1.1 AFD %}
Un Autómata Finito determinista (AFD) es una quíntupla $(Q,\Sigma,\delta,s,F)$ donde:

1. $Q$ es un conjunto finito de estados.
2. $\Sigma$ es un alfabeto finito.
3. $\delta : Q \times \Sigma \to Q$ es la función (total) de transición.
4. $s \in Q$ es el estado inicial.
5. $F \subseteq Q$ es el conjunto de estados finales (de aceptación). 
{% endmath %}

{% math definition 1.2 "Computación en AFD" %}
Sea $M$ un AFD y $(q, w) \in Q\times\Sigma^\star$. Entonces se define la función $\hat{\delta}$ 
de transición generalizada que computa el estado resultante de ejecutar $M$ sobre la 
configuración $(q, w)$ tal que:   

  $$
  \begin{aligned} 
    \hat{\delta} & : Q \times \Sigma^\star \rightarrow Q         &  \\
    \hat{\delta} & (q,\veps)      = q                            &  \\
    \hat{\delta} & (q, x \cdot v) = \delta(\hat{\delta}(q,v),x)  &
  \end{aligned}
  $$
  
donde $q \in Q$, $v \in \Sigma^\star$ y $x \in \Sigma$.
{% endmath %}

{% math definition 1.3 "Aceptación en AFD" %}
Sea $M=(Q,\Sigma,\delta,s,F)$ un AFD. Entonces el lenguaje $\mathcal{L}(M)\subseteq\Sigma^\star$ 
aceptado por $M$ se define:  

  $$\mathcal{L}(M) = \{ w \in \Sigma^\star \ \mid \ \hat{\delta}(s,w) \in F \}$$  
  
{% endmath %}

### Implementación
La implementación deriva de $\hat{\delta}$ en la [definición 1.2](#definition_1.2)

{% pseudocode 1 %}
  \PROCEDURE{afd}{$w: $\uppercase{$\Sigma^\star$}}
    \STATE $q := q_0$
    \STATE $w_i := w_0$
    \WHILE{$w_i \neq \varepsilon$}
      \STATE $q := $ \CALL{move}{$q, w_i$}
      \STATE $w_i := w_{i+1}$
    \ENDWHILE
    \IF{$q \in $ F}
      \PRINT \TRUE
    \ELSE
      \PRINT \FALSE
    \ENDIF
  \ENDPROCEDURE
{% endpseudocode %}

El costo de reconocer $w$ es $O(\len{w})$.

## No determinismo
{% math definition 2.1 AFN %}
Un Autómata Finito no determinista (AFN) es una quíntupla $(Q,\Sigma,\delta,s,F)$ donde:
  
1. $Q$ es un conjunto finito de estados.
2. $\Sigma$ es un alfabeto finito.
3. $\delta : Q \times \Sigma \to 2^Q$ es la función de transición.
4. $s \in Q$ es el estado inicial.
5. $F \subseteq Q$ es el conjunto de estados finales (de aceptación).  
{% endmath %}

{% math definition 2.2 "Computación en AFN" %}
Sea $N$ un AFN y $(q,w)\in Q\times\Sigma^\star$. Entonces se define la función $\hat{\delta}$ de 
transición generalizada que computa el conjunto de los estados resultantes de ejecutar $N$ sobre 
la configuración $(q, w)$ tal que:  

  $$
  \begin{aligned}
    \hat{\delta} & : Q \times \Sigma^\star \to 2^Q                                               & \\
    \hat{\delta} & (q,\veps)      = \{ q \}                                                      & \\
    \hat{\delta} & (q, x \cdot v) = \bigcup\limits_{r \;\in\; \hat{\delta}(q,v) }^{} \delta(r,x) &
  \end{aligned}
  $$

donde $q \in Q$, $v \in \Sigma^\star$ y $x \in \Sigma$.
{% endmath %}

{% math definition 2.3 "Aceptación en AFN" %}
Sea $N=(Q,\Sigma,\delta,s,F)$ un AFN. Entonces el lenguaje $\mathcal{L}(N)\subseteq\Sigma^\star$ 
aceptado por $N$ se define:

  $$\mathcal{L}(N) = \{ w \in \Sigma^\star \ \mid \ \hat{\delta}(s,w) \cap F \neq \varnothing \}$$

{% endmath %}

### Implementación

##### Backtracking
{% pseudocode 2 %}
  \PROCEDURE{afn}{$w:$\uppercase{$\Sigma^\star$}}
    \STATE \uppercase{$R$} $:=$ \CALL{afn-rec}{$q_0$, $w_0$}
    \IF{\uppercase{$R \cap F \neq \emptyset$}}
      \PRINT \TRUE
    \ELSE
      \PRINT \FALSE
    \ENDIF
  \ENDPROCEDURE
  \STATE
  \FUNCTION{afn-rec}{$q:$\uppercase{$Q$}, $w_i:$\uppercase{$\Sigma$}}
    \IF{$w_i = \varepsilon$}
      \RETURN $\{ q \}$
    \ELSE
      \STATE \uppercase{$R$} $:= \emptyset$
      \FORALL{$r$ \textbf{in} \uppercase{$Q$}}
        \IF{$r \in $ \CALL{move}{$q$, $w_i$}}
          \STATE \uppercase{$R$} $:=$ \uppercase{$R$} $ \cup\;$\CALL{afn-rec}{$r$, $w_{i+1}$}
        \ENDIF
      \ENDFOR
      \RETURN \uppercase{$R$}
    \ENDIF
  \ENDFUNCTION
{% endpseudocode %}

##### Según $\hat{\delta}$
La implementación deriva de $\hat{\delta}$ en la [definición 2.2](#definition_2.2).

{% pseudocode 3 %}
  \PROCEDURE{afn}{$w:$\uppercase{$\Sigma^\star$}}
    \STATE \uppercase{$R$} $:= \{ q_0 \}$
    \STATE $w_i := w_0$
    \WHILE{$w_i \neq \varepsilon$}
      \STATE \uppercase{$R$} $:=$ \CALL{move-union}{\uppercase{$R$}$, w_i$}
      \STATE $w_i := w_{i+1}$
    \ENDWHILE
    \IF{\uppercase{$R \cap F \neq \emptyset$}}
      \PRINT \TRUE
    \ELSE
      \PRINT \FALSE
    \ENDIF
  \ENDPROCEDURE
  \STATE
  \FUNCTION{move-union}{\uppercase{$R:2^Q$}, $x:$\uppercase{$\Sigma$}}
    \STATE \uppercase{$R^\prime$} $:= \emptyset$
    \FORALL{$r$ \textbf{in} \uppercase{$R$}}
      \STATE \uppercase{$R^\prime$} $:=$ \uppercase{$R^\prime$} $ \cup\;$\CALL{move}{$r, x$}
    \ENDFOR
    \RETURN \uppercase{$R^\prime$}
  \ENDFUNCTION
{% endpseudocode %}

La unión de un máximo de $\len{Q}$ conjuntos con a lo sumo $\len{Q}$ estados tiene un costo 
de $O(\len{Q}^2)$.  

El costo de reconocer $w$ es $O(\len{w}\len{Q}^2)$.

## No determinismo con $\veps$

{% math definition 3.1 AFN %}
Un Autómata Finito no determinista con transiciones $\veps$ (AFN-e) es una quíntupla 
$(Q,\Sigma,\delta,s,F)$ donde:
  
1. $Q$ es un conjunto finito de estados.
2. $\Sigma$ es un alfabeto finito.
3. $$\delta : Q \times (\Sigma \cup \{ \veps \}) \to 2^Q$$ es la función de transición.
4. $s \in Q$ es el estado inicial.
5. $F \subseteq Q$ es el conjunto de estados finales (de aceptación).  
{% endmath %}

{% math definition 3.2 "Computación en AFN-e" %}
Sea $N$ un AFN-e y $(q,w)\in Q\times\Sigma^\star$. Entonces se define la función $\hat{\delta}$ de 
transición generalizada que computa el conjunto de los estados resultantes de ejecutar $N$ sobre 
la configuración $(q, w)$ tal que:  

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
{% endmath %}

{% math definition 3.3 "Aceptación en AFN" %}
Sea $N=(Q,\Sigma,\delta,s,F)$ un AFN-e. Entonces el lenguaje $\mathcal{L}(N)\subseteq\Sigma^\star$ 
aceptado por $N$ se define:

  $$\mathcal{L}(N) = \{ w \in \Sigma^\star \ \mid \ \hat{\delta}(s,w) \cap F \neq \varnothing \}$$

{% endmath %}

### Implementación

404

## Bibliografía
{% bibliography -q
   @*[key=Hopcroft-Motwani-Ullman2000] 
%}
