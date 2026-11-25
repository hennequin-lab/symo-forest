+++
id = "7ee7cea7"
title = "Explicit canonical test vectors for k = 1 and k = 2"
created = 2026-11-12T09:21:46Z
updated = 2026-11-12T09:21:46Z
tags = ["algebra", "scale"]
aliases = ["Helmert vector", "z_parallel", "z_perp", "two test vectors", "seven test vectors"]
+++

# Explicit canonical test vectors for k = 1 and k = 2

The function `Kind.test_vectors ~k ~n` in `murder/packages/symo/lib/kind.ml` constructs the explicit [[0c051391|canonical test vectors]] $bold(z)_(lambda a) in RR^(n^k)$ for $k in {0, 1, 2}$ in [[b50cfe81|the stable range]] $n >= 2k$. Every vector is built from a fixed unit internal vector $bold(e)_lambda in cal(S)_lambda$ and normalized to unit Euclidean/Frobenius norm, with mutually orthogonal copies so that the copy Gram matrix is the identity: $bold(G)_lambda = bold(I)_(m_lambda)$.

Throughout, let $bold(1)_n = (1, dots, 1)^top in RR^n$ be the all-ones vector, $bold(J)_n = bold(1)_n bold(1)_n^top in RR^(n times n)$ the all-ones matrix, and
```typst
bold(h) = 1 / sqrt(2) (1, -1, 0, dots, 0)^top in RR^n
```
the first **Helmert vector** — a canonical unit vector in the standard Specht module $cal(S)_([1]) = bold(1)_n^perp$ ($|bold(h)|_2 = 1$, $bold(1)_n^top bold(h) = 0$).

## 1. Case $k = 1$: two vectors in $RR^n$ ($n >= 2$)

For $V = RR^n = cal(S)_emptyset ⊕ cal(S)_([1])$, each kind has multiplicity $m_lambda = 1$:

| kind $lambda$ | copy $a$ | unnormalized vector | norm | normalized test vector $bold(z)_(lambda, a) in RR^n$ |
| --- | --- | --- | --- | --- |
| `[]` ($emptyset$) | $0$ | $bold(1)_n$ | $sqrt(n)$ | $bold(z)_(emptyset, 0) = frac(1, sqrt(n)) bold(1)_n$ |
| `[1]` | $0$ | $bold(h)$ | $1$ | $bold(z)_([1], 0) = bold(h)$ |

Because $bold(Pi) bold(z)_(emptyset, 0) = bold(z)_(emptyset, 0)$, $bold(Pi)_perp bold(z)_(emptyset, 0) = bold(0)$ and $bold(Pi) bold(z)_([1], 0) = bold(0)$, $bold(Pi)_perp bold(z)_([1], 0) = bold(z)_([1], 0)$, applying $bold(S) = bold(Pi) ⊗ bold(B)_emptyset + bold(Pi)_perp ⊗ bold(B)_([1])$ to $bold(z)_(lambda, 0) ⊗ bold(w)$ ($bold(w) in RR^f$) immediately isolates each block:
```typst
bold(S)(bold(z)_(emptyset, 0) ⊗ bold(w)) = bold(z)_(emptyset, 0) ⊗ (bold(B)_emptyset bold(w)),
quad quad
bold(S)(bold(z)_([1], 0) ⊗ bold(w)) = bold(z)_([1], 0) ⊗ (bold(B)_([1]) bold(w)).
```

## 2. Case $k = 2$: seven matrices in $RR^(n times n)$ ($n >= 4$)

For $V^(⊗2) ≅ RR^(n times n)$, [[35cc480f|the isotypic decomposition]] has four kinds $emptyset, [1], [2], [1,1]$ with multiplicities $m_emptyset = 2, m_([1]) = 3, m_([2]) = 1, m_([1,1]) = 1$ ($2 + 3 + 1 + 1 = 7$ test vectors):

| kind $lambda$ | copy $a$ | unnormalized matrix $bold(U)_(lambda, a) in RR^(n times n)$ | Frobenius norm $|bold(U)_(lambda, a)|_F$ | isotypic subspace in $V ⊗ V$ |
| --- | --- | --- | --- | --- |
| `[]` ($emptyset$) | $0$ | $frac(1, n) bold(J)_n = bold(Pi)$ | $1$ | $cal(S)_emptyset ⊗ cal(S)_emptyset$ |
| `[]` ($emptyset$) | $1$ | $bold(I)_n - frac(1, n) bold(J)_n = bold(Pi)_perp$ | $sqrt(n - 1)$ | trivial copy inside $op("Sym")^2(cal(S)_([1]))$ |
| `[1]` | $0$ | $bold(h) bold(1)_n^top$ | $sqrt(n)$ | $cal(S)_([1]) ⊗ cal(S)_emptyset$ (row differences) |
| `[1]` | $1$ | $bold(1)_n bold(h)^top$ | $sqrt(n)$ | $cal(S)_emptyset ⊗ cal(S)_([1])$ (column differences) |
| `[1]` | $2$ | $op("Diag")(bold(h)) - frac(1, n)(bold(h) bold(1)_n^top + bold(1)_n bold(h)^top)$ | $sqrt(1 - 2 slash n)$ | diagonal copy inside $op("Sym")^2(cal(S)_([1]))$ |
| `[2]` | $0$ | 4-cycle matrix $bold(C)_4$ (below) | $sqrt(8) = 2sqrt(2)$ | $cal(S)_([2]) subset op("Sym")^2(cal(S)_([1]))$ |
| `[1; 1]` | $0$ | $bold(E)_(0 1) - bold(E)_(1 0)$ | $sqrt(2)$ | $cal(S)_([1,1]) = Lambda^2(cal(S)_([1]))$ |

Here $bold(E)_(i j) in RR^(n times n)$ denotes the elementary matrix with $1$ at $(i, j)$ ($0$-indexed) and $0$ elsewhere, and the **4-cycle matrix** $bold(C)_4$ (`Kind.s_vector`, requiring $n >= 4$) has non-zero entries on the upper-left $4 times 4$ corner:
```typst
(bold(C)_4)_(0..3, 0..3) = mat(
  0, +1, 0, -1;
  +1, 0, -1, 0;
  0, -1, 0, +1;
  -1, 0, +1, 0
),
```
and zeros in all rows and columns $i, j >= 4$.

## Verification of carrier membership and copy orthonormality

1. **Same internal vector across copies.** All three copies of the standard kind $lambda = [1]$ are embeddings of the *same* unit Helmert vector $bold(h) in cal(S)_([1])$, as required by [[0c051391|the pairing theorem]].
2. **Orthogonality of the two trivial copies ($lambda = emptyset$).** Because $bold(Pi) bold(Pi)_perp = bold(0)$, $⟨bold(U)_(emptyset, 0), bold(U)_(emptyset, 1)⟩_F = op("tr")(bold(Pi) bold(Pi)_perp) = 0$, so $bold(G)_emptyset = bold(I)_2$.
3. **Orthogonality and projection of the three standard copies ($lambda = [1]$).** First, $⟨bold(h) bold(1)_n^top, bold(1)_n bold(h)^top⟩_F = (bold(1)_n^top bold(h))^2 = 0$ because $bold(h) in bold(1)_n^perp$. For the third copy, the raw diagonal embedding $op("Diag")(bold(h))$ is *not* orthogonal to the first two copies: $⟨op("Diag")(bold(h)), bold(h) bold(1)_n^top⟩_F = sum_i h_i^2 = |bold(h)|_2^2 = 1$. Subtracting its orthogonal projections onto $bold(h) bold(1)_n^top$ and $bold(1)_n bold(h)^top$ (each of squared norm $n$) yields `Kind.diagonal_part`:
   ```typst
   bold(U)_([1], 2) = op("Diag")(bold(h)) - 1/n (bold(h) bold(1)_n^top + bold(1)_n bold(h)^top),
   ```
   which has zero row sums and zero column sums (hence lies in $cal(S)_([1]) ⊗ cal(S)_([1])$), is orthogonal to both $bold(h) bold(1)_n^top$ and $bold(1)_n bold(h)^top$, and has squared Frobenius norm
   ```typst
   |bold(U)_([1], 2)|_F^2 = |op("Diag")(bold(h))|_F^2 - 1/n^2 |bold(h) bold(1)_n^top + bold(1)_n bold(h)^top|_F^2 = 1 - 2/n > 0 quad (n >= 4).
   ```
   Dividing by $sqrt(1 - 2/n)$ produces an orthonormal triple ${bold(z)_([1], 0), bold(z)_([1], 1), bold(z)_([1], 2)}$, so $bold(G)_([1]) = bold(I)_3$.
4. **Membership of $bold(C)_4$ in $cal(S)_([2])$ and $bold(E)_(0 1) - bold(E)_(1 0)$ in $cal(S)_([1,1])$.** The 4-cycle matrix $bold(C)_4$ is symmetric, has zero diagonal (so it is orthogonal to every diagonal matrix and hence to $cal(S)_emptyset$ and $bold(U)_([1], 2)$), and has zero row and column sums (so it lies in $op("Sym")^2(cal(S)_([1]))$ and is orthogonal to $bold(U)_([1], 0)$ and $bold(U)_([1], 1)$); therefore $bold(C)_4 in cal(S)_([2])$. Similarly, $bold(E)_(0 1) - bold(E)_(1 0)$ is skew-symmetric and has row and column sums equal to $(+1, -1, 0, dots, 0)^top = sqrt(2) bold(h)$ before projection; applying `Kind.project_antisymmetric` removes the $(bold(1)_n and bold(y))$ component in $(cal(S)_emptyset ⊗ cal(S)_([1])) ⊖ (cal(S)_([1]) ⊗ cal(S)_emptyset)$ to project cleanly onto $Lambda^2(cal(S)_([1])) = cal(S)_([1,1])$.
