---
layout: post
title: "Project Euler - Problema 1: Múltiplos de 3 y 5"
categories: [Matematica, Programacion]
toc: true
---
{% include fragments/pseudocode.html %}
{% include fragments/katex.html %}


## Letra del problema
> If we list all the natural numbers below 10 that are multiples of 3 or 5, we get 3, 5, 6 and 9. The sum of these multiples is 23.
> Find the sum of all the multiples of 3 or 5 below 1000.

## Soluciones

### Método 1 - Aritmética modular
<div class="definition" data-number="1">
Sean $a, b \in \mathbb{Z}$ y $a \neq 0$. Entonces $a$ divide $b$ (denotado por $a \mid b$) si 
existe $c \in \mathbb{Z}$ tal que $b = a\,c$. Cuando $a \mid b$ decimos que $a$ es un factor 
o divisor de $b$ y que $b$ es múltiplo de $a$
</div>

Por la definición precedente, si $b = a\,c \ $ y $ \ \frac ba = c$ entonces $b$ es *múltiplo* de $a$ 
si contiene a $a$ un número entero de veces determinado por $c$. Esto es decir que el resto de 
la división euclidiana $\frac ba$ es $0$, lo cual se puede verificar comprobando que $b \bmod a = 0$.

Entonces una solución posible es sumar cada $x \in [0...n)$ tal que $x \bmod 3 = 0$ o $x \bmod 5 = 0$.

<div id="algorithm1-pe1" class="algorithm-pscode">
\begin{algorithm}
\caption{}
\begin{algorithmic}
\FUNCTION{pe1}{$n$}
    \STATE $r := 0$
    \FOR{$x := 0$ \TO $n-1$}
        \IF{$x \; mod \; 3 = 0$ \OR $x \; mod \; 5 = 0$}
            \STATE $r := r + x$
        \ENDIF
    \ENDFOR
    \RETURN $r$
\ENDFUNCTION
\end{algorithmic}
\end{algorithm}
</div>
<script>
var parentEl = document.getElementById("algorithm1-pe1");
var code = parentEl.textContent;
parentEl.innerHTML = '';
pseudocode.render(code, parentEl, pscode_config);
</script>

**Complejidad**  
$\text{PE1}(n) \in \Theta (n)$.

### Método 2 - Suma de sucesiones
{: #metodo_2}
Los multiplos de 3 se pueden expresar mediante una sucesión, y esta se puede sumar hasta donde
sea necesario. Un razonamiento análogo se puede realizar con los múltiplos de 5. Ambos resultados 
se deben suman para obtener el total, pero siguiendo el principio de inclusión-exclusión hay que 
considerar los múltiplos en común para 3 y 5, por lo que la suma de estos se debe restar del total.

##### Suma de múltiplos de $k$ en $[0...n)$
Sea $(x_n)$ la sucesión de múltiplos de $k$:

  $$(x_n) = 1\;k, \ 2\;k, \ 3\;k, \ 4\;k, \ 5\;k, \ ... $$ 

Esta es una progresión aritmética con diferencia $k$, donde el término general está dado por:

  $$x_{n} = x_{1}+(n-1)k    \label{eq2.1}\tag{2.1}$$

La suma de los términos de una progresión aritmética está dada por:

  $$\sum_{i=1}^{n}x_{i} = \frac{n(x_{1}+x_{n})}{2}$$ 

Donde $n$ es la cantidad de términos, $x_{1}$ es el término inicial y $x_{n}$ es el término final.

La cantidad de múltiplos de $k$ que hay en el intervalo $[0...n)$ es: 

  $$\floor{\frac{n-1}{k}}    \label{form2.2}\tag{2.2}$$ 

Por lo tanto, para sumar los múltiplos de $k$ en el intervalo $[0...n)$:

  $$\sum_{i=1}^{c}x_{i} = \frac{c(x_{1} + x_{c})}{2} 
      \quad \text{donde} \ \ c = \floor{\frac{n-1}{k}}   \label{eq2.3}\tag{2.3}$$

##### Suma de múltiplos de 3 en $[0...1000)$
Sea $(a_n)$ la sucesión de múltiplos de 3:

  $$(a_n) = 3, \ 6, \ 9, \ 12, \ 15, \ 18, \ ...$$

Usando \ref{form2.2} se obtiene la cantidad de múltiplos de 3 en el intervalo $[0...1000)$: 

  $$\floor{\frac{1000-1}{3}} = \floor{\frac{999}{3}} = 333$$

Usando \ref{eq2.1} se obtiene el término final de $(a_n)$: 

  $$a_{333} = 3+(333-1)3 = 999$$

Finalmente, usando \ref{eq2.3} se obtiene la suma de los múltiplos de 3 en el intervalo $[0...1000)$:

  $$\sum_{i=1}^{333}a_{i} = \frac{333(3+999)}{2} = 166833    \label{sum2.1}\tag{2.1}$$

##### Suma de múltiplos de 5 en $[0...1000)$
Sea $(b_n)$ la sucesión de múltiplos de 5:

  $$\sum_{i=1}^{199}b_{i} = \frac{199(5+995)}{2} = 99500    \label{sum2.2}\tag{2.2}$$

##### Suma de múltiplos en común para 3 y 5 en $[0...1000)$ 
{: #multiplos_en_comun}
<div class="lemma" data-number="1">
Sean $a, b \in \mathbb{Z}$ y $a \neq 0$. Si $a \mid b$ entonces $a \mid c\,b$ para 
cualquier $c \in \mathbb{Z}$
</div>

Por el lema 1, si $3 \mid 15$ y $5 \mid 15$, entonces 3 y 5 dividen también a los múltiplos de 15.

Como 3 y 5 tienen algunos múltiplos en común, donde 15 es el primero de ellos, si se suman los 
resultados parciales obtenidos anteriormente se sumarían múltiplos repetidos.

Sea $(c_n)$ la sucesión de múltiplos de 15:

  $$\sum_{i=1}^{66}c_{i} = \frac{66(15+990)}{2} = 33165    \label{sum2.3}\tag{2.3}$$ 

De acuerdo al principio de inclusión-exclusión este resultado se debe restar del total 
para descontar los repetidos.

##### Resultado final
Usando las sumas \ref{sum2.1}, \ref{sum2.2} y \ref{sum2.3} el resultado final es:

  $$\sum_{i=1}^{333}a_{i} + \sum_{i=1}^{199}b_{i} - \sum_{i=1}^{66}c_{i} = 166833 + 99500 \, - 33165 = 233168$$

<div id="algorithm2-pe1" class="algorithm-pscode">
\begin{algorithm}
\caption{}
\begin{algorithmic}
\FUNCTION{pe1}{$n$}
    \STATE $m3Sum := $ \CALL{sumMultiples}{$n, 3$}
    \STATE $m5Sum := $ \CALL{sumMultiples}{$n, 5$}
    \STATE $m15Sum := $ \CALL{sumMultiples}{$n, 15$}
    \RETURN $m3Sum+m5Sum-m15Sum$
\ENDFUNCTION
\STATE
\FUNCTION{sumMultiples}{$n, k$}
    \STATE $c := floor((n-1)/k)$
    \STATE $x1 := K$
    \STATE $xc := x1 + (c-1)*k$
    \RETURN $(c \times (x1 + xc))/2$
\ENDFUNCTION
\end{algorithmic}
\end{algorithm}
</div>
<script>
var parentEl = document.getElementById("algorithm2-pe1");
var code = parentEl.textContent;
parentEl.innerHTML = '';
pseudocode.render(code, parentEl, pscode_config);
</script>

**Complejidad**  
$\text{PE1}(n) \in \Theta (1)$.

### Método 3 - Suma de sucesiones, otro camino
Este es similar al [método 2](#metodo_2), pero por un camino que involucra 
menos operaciones aritméticas.

##### Suma de múltiplos de $k$ en $[0...n)$
Sea $(x_n)$ la sucesión de múltiplos de $k$:

  $$(x_n) = 1\;k, \ 2\;k, \ 3\;k, \ 4\;k, \ 5\;k, \ ...$$

Esta sucesión es generada por la recurrencia:

  $$\left\{\begin{aligned}
    & x_{1} = k           \\
    & x_{n} = x_{n-1} + k
  \end{aligned}\right.$$

La forma cerrada para esta recurrencia es: $x_{n} = k\,n$

La suma de términos de la sucesión se puede realizar de la siguiente manera: [^sum_nats]

  $$\sum_{i=1}^{n}x_{i} = \sum_{i=1}^{n}k\,i = k\,\sum_{i=1}^{n}i = k\frac{n(n+1)}{2}$$ 

Donde $n$ es la cantidad de términos.

La cantidad de múltiplos de $k$ que hay en el intervalo $[0...n)$ es: 

  $$\floor{\frac{n-1}{k}}   \label{form3.1}\tag{3.1}$$ 

Por lo tanto, para sumar los múltiplos de $k$ en el intervalo $[0...n)$:

  $$\sum_{i=1}^{c}x_{i} = k\frac{c(c+1)}{2} 
       \quad \text{donde} \ \ c = \floor{\frac{n-1}{k}}   \label{eq3.2}\tag{3.2}$$

##### Suma de múltiplos de 3 en $[0...1000)$
Sea $(a_n)$ la sucesión de múltiplos de 3:

  $$(a_n) = 3, \ 6, \ 9, \ 12, \ 15, \ 18, \ ...$$

Usando \ref{form3.1} se obtiene la cantidad de múltiplos de 3 en el intervalo $[0...1000)$: 

  $$\floor{\frac{1000-1}{3}} = \floor{\frac{999}{3}} = 333$$

Finalmente, usando \ref{eq3.2} se obtiene la suma de los múltiplos de 3 en el intervalo $[0...1000)$:

  $$\sum_{i=1}^{333}a_{i} = 3\frac{333(333+1)}{2} = 166833   \label{sum3.1}\tag{3.1}$$

##### Suma de múltiplos de 5 en $[0...1000)$
Sea $(b_n)$ la sucesión de múltiplos de 5:

  $$\sum_{i=1}^{199}b_{i} = 5\frac{199(199+1)}{2} = 99500   \label{sum3.2}\tag{3.2}$$

##### Suma de múltiplos en común para 3 y 5 en $[0...1000)$
Al igual que en el [método 2](#metodo_2), hay que restar múltiplos repetidos. 

Sea $(c_n)$ la sucesión de múltiplos de 15:

  $$\sum_{i=1}^{66}c_{i} = 15\frac{66(66+1)}{2} = 33165   \label{sum3.3}\tag{3.3}$$ 

De acuerdo al principio de inclusión-exclusión este resultado se debe restar del total 
para descontar los repetidos.

##### Resultado final
Usando las sumas \ref{sum3.1}, \ref{sum3.2} y \ref{sum3.3} el resultado final es:

  $$\sum_{i=1}^{333}a_{i} + \sum_{i=1}^{199}b_{i} - \sum_{i=1}^{66}c_{i} = 166833 + 99500\: - 33165 = 233168$$

<div id="algorithm3-pe1" class="algorithm-pscode">
\begin{algorithm}
\caption{}
\begin{algorithmic}
\FUNCTION{pe1}{$n$}
    \STATE $m3Sum :=$ \CALL{sumMultiples}{$n, 3$}   
    \STATE $m5Sum :=$ \CALL{sumMultiples}{$n, 5$}    
    \STATE $m15Sum :=$ \CALL{sumMultiples}{$n, 15$}    
    \RETURN $m3Sum+m5Sum-m15Sum$
\ENDFUNCTION
\STATE
\FUNCTION{sumMultiples}{$n, k$}
    \STATE $c := floor((n-1)/k)$
    \RETURN $k \times ((c \times (c + 1))/2)$
\ENDFUNCTION
\end{algorithmic}
\end{algorithm}
</div>
<script>
var parentEl = document.getElementById("algorithm3-pe1");
var code = parentEl.textContent;
parentEl.innerHTML = '';
pseudocode.render(code, parentEl, pscode_config);
</script>

**Complejidad**  
$\text{PE1}(n) \in \Theta (1)$, al igual que en el método 2. Pero en este caso hay
menos operaciones aritméticas.


## Referencias
* [^sum_nats]: La suma de los $n$ primeros naturales: $\sum_{i=1}^{n}i=\frac{n(n+1)}{2}$.
{:footnotes}