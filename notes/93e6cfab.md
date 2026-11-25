+++
id = "93e6cfab"
title = "Block functional calculus and the four-step round trip"
created = 2026-11-12T09:21:46Z
updated = 2026-11-12T09:21:46Z
tags = ["algebra", "scale"]
aliases = ["functional calculus", "exact block function", "isomorphism argument", "four-step-round-trip"]
+++

# Block functional calculus and the four-step round trip

Let $W = ⊕_(i=1)^L W_i$ be a parameter tree of total dimension $D$, and let $bold(S) in cal(C)(W, W)$ be a square invariant operator with assembled [[a575e53a|Wedderburn blocks]] $bold(B)_lambda in RR^(M_lambda times M_lambda)$ ($M_lambda = sum_(i=1)^L m_(i, lambda) f_i$) in an orthonormal copy-and-free basis:
```typst
bold(S) = ⊕_lambda (bold(I)_(cal(S)_lambda) ⊗ bold(B)_lambda),
quad quad
dim cal(S)_lambda = d_lambda (n).
```
Because $(bold(B)_lambda)_lambda mapsto bold(S)$ is an **isomorphism of $RR$-algebras with transpose** in an orthonormal basis ([[46af9ff5|the Wedderburn theorem]]), every spectral property and every matrix function of $bold(S)$ reduces immediately to the blocks $bold(B)_lambda$.

## Theorem (block functional calculus and spectral decomposition)

Let $bold(S) = ⊕_lambda (bold(I)_(cal(S)_lambda) ⊗ bold(B)_lambda) in cal(C)(W, W)$.
1. **Analytic and spectral functional calculus.** For any function $f$ analytic on a neighborhood of the spectrum of $bold(S)$ — or, when $bold(S) = bold(S)^top$ is symmetric, any function $f : op("spec")(bold(S)) -> RR$ defined via the spectral theorem (such as $x mapsto x^(-1)$, $x mapsto x^(1/2)$, $x mapsto x^(-1/2)$, $x mapsto (x + gamma)^(-1)$, $x mapsto exp(x)$) — the operator $f(bold(S))$ belongs to $cal(C)(W, W)$ and has Wedderburn blocks $f(bold(B)_lambda)$:
   ```typst
   f(bold(S)) = ⊕_lambda (bold(I)_(cal(S)_lambda) ⊗ f(bold(B)_lambda)).
   ```
2. **Eigenvalues and multiplicities.** If $bold(S) = bold(S)^top$, each block $bold(B)_lambda$ is symmetric ($M_lambda times M_lambda$) with eigendecomposition $bold(B)_lambda = sum_(j=1)^(M_lambda) beta_(lambda, j) bold(u)_(lambda, j) bold(u)_(lambda, j)^top$. The eigenvalues of $bold(S)$ are precisely ${beta_(lambda, j)}$, where each block eigenvalue $beta_(lambda, j)$ is repeated with **carrier multiplicity $d_lambda(n)$** (and eigenvectors $bold(e)_(lambda, r) ⊗ bold(u)_(lambda, j)$ for an orthonormal basis ${bold(e)_(lambda, r)}_(r=1)^(d_lambda(n))$ of $cal(S)_lambda$).
3. **Uniform isotropic shifts.** Because the isotypic summands $cal(S)_lambda$ and the copy bases ${bold(m)_a}$ in [[7ee7cea7|the canonical test vectors]] are orthonormal, the identity operator on $W$ decomposes as $bold(I)_W = ⊕_lambda (bold(I)_(cal(S)_lambda) ⊗ bold(I)_(M_lambda))$. Consequently, for any scalar shift $gamma in RR$,
   ```typst
   (bold(S) + gamma bold(I)_W)^(-1) = ⊕_lambda lr((bold(I)_(cal(S)_lambda) ⊗ (bold(B)_lambda + gamma bold(I)_(M_lambda))^(-1))),
   ```
   so a single scalar shift $gamma$ on the ambient space $W$ shifts the spectrum of every block $bold(B)_lambda$ by the same $gamma$.

### Proof

**By power series:** Since $(bold(I)_(cal(S)_lambda) ⊗ bold(B)_lambda)(bold(I)_(cal(S)_lambda) ⊗ bold(B)'_lambda) = bold(I)_(cal(S)_lambda) ⊗ (bold(B)_lambda bold(B)'_lambda)$, induction on $p in NN$ gives $bold(S)^p = ⊕_lambda (bold(I)_(cal(S)_lambda) ⊗ bold(B)_lambda^p)$, and taking convergent power series $sum_(p=0)^oo a_p bold(S)^p$ gives (1).

**By the spectral theorem:** For symmetric $bold(S)$, the vectors ${bold(e)_(lambda, r) ⊗ bold(u)_(lambda, j)}$ form an orthonormal eigenbasis of $W$ because both ${bold(e)_(lambda, r)}$ and ${bold(u)_(lambda, j)}$ are orthonormal in the Euclidean inner product on $W$. Applying $bold(S)$ gives $(bold(I)_(cal(S)_lambda) ⊗ bold(B)_lambda)(bold(e)_(lambda, r) ⊗ bold(u)_(lambda, j)) = beta_(lambda, j)(bold(e)_(lambda, r) ⊗ bold(u)_(lambda, j))$, proving (2). By definition of the spectral functional calculus, $f(bold(S))$ acts on each eigenvector by $f(beta_(lambda, j))$, which reassembles inside each kind $lambda$ to $bold(I)_(cal(S)_lambda) ⊗ f(bold(B)_lambda)$, proving (1) and (3). $square$

## The four-step round-trip algorithm

To compute the factor coordinates $bold(c)'$ of $f(bold(S))$ (and optionally apply $f(bold(S)) bold(v)$ to a vector $bold(v) in W$) from vectors $bold(u)_1, bold(u)_2 in W$:

| step | operation | `symo` primitive | asymptotic cost |
| --- | --- | --- | --- |
| **1. Project** | Estimate factors $bold(c)$ of $bold(S) = cal(R)_2(bold(u)_1, bold(u)_2)$ via einsums and triangular Cholesky solve | `Second_order.factors_of_pair` | $O(D d)$ |
| **2. Decode** | Convert factor coordinates $bold(c)$ to assembled blocks $bold(B)_lambda = bold(G)_lambda^(-1) bold(P) bold(c)$ | `Second_order.blocks_of_factors` | $O(d^2 f^2)$ |
| **3. Spectral $f$** | Eigendecompose each block $bold(B)_lambda = bold(U)_lambda op("Diag")(bold(beta)_lambda) bold(U)_lambda^top$ and form $f(bold(B)_lambda) = bold(U)_lambda op("Diag")(f(bold(beta)_lambda)) bold(U)_lambda^top$ | `Nx.eigh` per kind $lambda$ | $sum_lambda O(M_lambda^3)$ |
| **4. Re-encode** | Convert transformed blocks $f(bold(B)_lambda)$ back to factor coordinates $bold(c)' = bold(P)^dagger f(bold(B))$ (and apply via einsums) | `Second_order.factors_of_blocks`, `Second_order.apply` | $O(d^2 f^2 + D d)$ |

Notice that Step 3 — the only nonlinear, spectral step — has complexity $sum_lambda O(M_lambda^3) = sum_lambda O((sum_i m_(i,lambda) f_i)^3)$ **completely independent of the permuted widths $n$**. For a layer $bold(W) in RR^(1000 times 784)$ ($n = 1000, f = 784, D = 7.84 times 10^5$), dense eigendecomposition of $bold(S)$ would require $D^3 approx 4.8 times 10^(17)$ operations, whereas Step 3 diagonalizes two $784 times 784$ blocks ($2 dot 784^3 approx 9.6 times 10^8$ operations, a $5 times 10^8$-fold reduction). For the recurrent matrix of a vanilla RNN ($k = 2, f = 1, D = n^2$), Step 3 diagonalizes four blocks of sizes $2 times 2, 3 times 3, 1 times 1, 1 times 1$ ($2^3 + 3^3 + 1^3 + 1^3 = 37$ scalar operations) at *any* width $n >= 4$.

![Block functional calculus in action: the eigenvalues of the small Wedderburn blocks $bold(B)_lambda$ (coloured circles, area proportional to carrier multiplicity $d_lambda(n)$) reproduce the full $D times D$ dense eigenspectrum (grey step curve) to machine precision across all three architectures.](figures/wedderburn_spectra_multiplicity.svg)
