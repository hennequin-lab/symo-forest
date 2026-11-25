+++
id = "b2ecabc3"
title = "Hidden-unit permutations act by Kronecker products on parameter tensors"
created = 2026-11-12T09:21:46Z
updated = 2026-11-12T09:21:46Z
tags = ["symmetry"]
aliases = ["unit permutation", "hidden unit symmetry", "permutation symmetry"]
+++

# Hidden-unit permutations act by Kronecker products on parameter tensors

Consider a two-layer feedforward network mapping an input $bold(x) in RR^(d_"in")$ to an output $bold(y) in RR^(d_"out")$ through $n$ hidden units:
```typst
bold(y) = bold(W)_2 phi(bold(W)_1 bold(x) + bold(b)_1) + bold(b)_2,
```
where $bold(W)_1 in RR^(n times d_"in")$, $bold(b)_1 in RR^n$, $bold(W)_2 in RR^(d_"out" times n)$, $bold(b)_2 in RR^(d_"out")$, and $phi : RR -> RR$ is applied coordinatewise to vectors in $RR^n$.

Let $sigma in cal(S)_n$ be a permutation of ${1, dots, n}$ and let $bold(P)_sigma in {0, 1}^(n times n)$ be its permutation matrix, with entries $(bold(P)_sigma)_(i j) = delta_(i, sigma(j))$. Because $bold(P)_sigma$ is orthogonal ($bold(P)_sigma^top bold(P)_sigma = bold(I)_n$) and $phi$ acts coordinatewise, $phi$ commutes with $bold(P)_sigma$: for every vector $bold(z) in RR^n$,
```typst
(phi(bold(P)_sigma bold(z)))_i = phi((bold(P)_sigma bold(z))_i) = phi(z_(sigma^(-1)(i))) = (bold(P)_sigma phi(bold(z)))_i.
```
Consequently, transforming the parameters simultaneously by
```typst
(bold(W)_1, bold(b)_1, bold(W)_2, bold(b)_2) mapsto (bold(P)_sigma bold(W)_1, bold(P)_sigma bold(b)_1, bold(W)_2 bold(P)_sigma^top, bold(b)_2)
```
leaves the output unchanged for every input $bold(x) in RR^(d_"in")$:
```typst
(bold(W)_2 bold(P)_sigma^top) phi(bold(P)_sigma bold(W)_1 bold(x) + bold(P)_sigma bold(b)_1) + bold(b)_2
= bold(W)_2 bold(P)_sigma^top bold(P)_sigma phi(bold(W)_1 bold(x) + bold(b)_1) + bold(b)_2
= bold(y).
```
This identity is exact for any elementwise activation $phi$ (`tanh`, ReLU, GELU, sigmoid) and generates an orbit of up to $|cal(S)_n| = n!$ distinct parameter settings computing the identical function.

## Kronecker form on vectorized leaves

To treat linear operators on parameter tensors uniformly, vectorize each parameter leaf by stacking its axes. Under the standard identity $op("vec")(bold(A) bold(X) bold(B)^top) = (bold(B) ⊗ bold(A)) op("vec")(bold(X))$ (or, upon reordering tensor factors so that the permuted axes come first and the untouched *free* axes come second), each parameter leaf $W_i$ decomposes as a tensor product
```typst
W_i ≅ V^(⊗k_i) ⊗ F_i,
```
where:
- $V = RR^n$ carries the defining permutation representation $sigma mapsto bold(P)_sigma$ of $cal(S)_n$,
- $k_i in NN$ is the number of axes of leaf $i$ transformed by $cal(S)_n$, and
- $F_i = RR^(f_i)$ is the tensor product of all remaining axes of leaf $i$ that $cal(S)_n$ leaves fixed (with total free dimension $f_i = dim F_i$).

On leaf $i$, the permutation $sigma in cal(S)_n$ acts by the Kronecker product
```typst
rho_i (sigma) = bold(P)_sigma^(⊗k_i) ⊗ bold(I)_(F_i).
```
In the two-layer network above:
- For $bold(W)_1 in RR^(n times d_"in")$: $k_1 = 1$ (rows permuted) and $F_1 = RR^(d_"in")$ ($f_1 = d_"in"$).
- For $bold(b)_1 in RR^n$: $k_2 = 1$ and $F_2 = RR$ ($f_2 = 1$).
- For $bold(W)_2 in RR^(d_"out" times n)$: $k_3 = 1$ (columns permuted) and $F_3 = RR^(d_"out")$ ($f_3 = d_"out"$).
- For $bold(b)_2 in RR^(d_"out")$: $k_4 = 0$ (no permuted axes) and $F_4 = RR^(d_"out")$ ($f_4 = d_"out"$).

When a single group permutes both the rows and the columns of a square matrix $bold(W) in RR^(n times n)$ — as in [[c35dde47|a vanilla recurrent network]] where $bold(W) mapsto bold(P)_sigma bold(W) bold(P)_sigma^top$ — that leaf has $k = 2$ and $f = 1$, so $rho(sigma) = bold(P)_sigma ⊗ bold(P)_sigma$. The factorization $rho_i (sigma) = bold(P)_sigma^(⊗k_i) ⊗ bold(I)_(F_i)$ separates the group action on $V^(⊗k_i)$ from the trivial action on $F_i$, which is the structural premise of [[46af9ff5|the Wedderburn decomposition]] and [[dc31c6c2|declarative symmetry specifications in symo]].
