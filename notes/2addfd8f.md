+++
id = "2addfd8f"
title = "Signed permutations and the hyperoctahedral group"
created = 2026-11-12T09:21:46Z
updated = 2026-11-12T09:21:46Z
tags = ["symmetry", "algebra"]
aliases = ["signed permutations", "sign symmetry", "2^n n!", "hyperoctahedral group"]
+++

# Signed permutations and the hyperoctahedral group

Suppose the elementwise activation function $phi : RR -> RR$ in a hidden layer $bold(y) = bold(W)_2 phi(bold(W)_1 bold(x))$ is odd, meaning $phi(-z) = -phi(z)$ for all $z in RR$ (for example, $phi(z) = tanh(z)$ or $phi(z) = z$). Let $bold(d) in {plus.minus 1}^n$ be a sign vector and let $bold(D)_(bold(d)) = op("Diag")(d_1, dots, d_n)$ be the corresponding diagonal sign matrix. Because $bold(D)_(bold(d))$ is diagonal with entries in ${plus.minus 1}$ and $phi$ is odd,
```typst
phi(bold(D)_(bold(d)) bold(z)) = bold(D)_(bold(d)) phi(bold(z)) quad forall bold(z) in RR^n.
```
Combining sign flips $bold(D)_(bold(d))$ with unit permutations $bold(P)_sigma$ ($sigma in cal(S)_n$) yields the **hyperoctahedral group** (or signed-permutation group)
```typst
cal(B)_n = { bold(A)_(bold(d), sigma) = bold(D)_(bold(d)) bold(P)_sigma mid(|) bold(d) in {plus.minus 1}^n, sigma in cal(S)_n } subset O(n),
```
which is the semidirect product ${plus.minus 1}^n times.r cal(S)_n$ of order $|cal(B)_n| = 2^n n!$. Every element $bold(A) in cal(B)_n$ is a generalized permutation matrix with exactly one non-zero entry $+1$ or $-1$ in each row and column, and satisfies $bold(A)^top bold(A) = bold(I)_n$.

## Annihilation of odd-degree index ties

Enlarging the symmetry group from $cal(S)_n$ to $cal(B)_n$ shrinks the commutant algebra: because $cal(S)_n subset cal(B)_n$, any operator commuting with $cal(B)_n$ must already belong to the $cal(S)_n$-commutant, and must additionally commute with every sign flip $bold(D)_(bold(d))$.

Consider a leaf $bold(C) in RR^(n times f)$ with $k = 1$ permuted axis of dimension $n$ and one free axis of dimension $f$. As shown in [[33d479c5|the equality-pattern basis]], any operator $bold(S)$ in the $cal(S)_n$-commutant has the form
```typst
bold(S)_((m,n),(o,p)) = delta_(m o) bold(F)_(n p) + 1_(m o) bold(G)_(n p),
```
where $m, o in {1, dots, n}$ index the permuted axis and $bold(F), bold(G) in RR^(f times f)$ act on the free axis. Conjugating $bold(S)$ by a sign flip $bold(D)_(bold(d)) ⊗ bold(I)_f$ multiplies the $(m,n),(o,p)$ entry by $d_m d_o$. Invariance under all $bold(d) in {plus.minus 1}^n$ requires
```typst
d_m d_o lr((delta_(m o) bold(F)_(n p) + 1_(m o) bold(G)_(n p))) = delta_(m o) bold(F)_(n p) + 1_(m o) bold(G)_(n p) quad forall bold(d) in {plus.minus 1}^n.
```
On the diagonal ($m = o$), $d_m^2 = (+1)^2 = (-1)^2 = 1$, so the $delta_(m o)$ term is automatically sign-invariant. Off the diagonal ($m != o$, possible whenever $n >= 2$), choosing $d_m = -1$ and $d_o = +1$ gives $-bold(G)_(n p) = bold(G)_(n p)$, forcing $bold(G) = bold(0)$. Equivalently, averaging over $bold(d) ~ op("Unif")({plus.minus 1}^n)$ first uses $bb(E)[d_m d_o] = delta_(m o)$, which projects out the all-ones pattern $1_(m o)$ immediately.

Thus the $cal(B)_n$-commutant for $k = 1$ collapses from two $f times f$ blocks ($2 f^2$ numbers) to a single repeated block:
```typst
bold(S)_((m,n),(o,p)) = delta_(m o) bold(F)_(n p) <==> bold(S) = bold(I)_n ⊗ bold(F),
```
Parameterized by one $f times f$ matrix ($f^2$ numbers). More generally, in the partition algebra on $V^(⊗k)$, invariance under ${plus.minus 1}^n$ retains precisely those set partitions in which every block has *even* cardinality, since $bb(E)_(bold(d))[product_(x in B) d_(i_x)] = 1$ if $|B|$ is even and $0$ if $|B|$ is odd. Compare the three symmetry regimes on the $3 times 4$ matrix in [[57bf40fa|the 3×4 worked example]].

![Comparing panel (b) ($cal(S)_3$, dense off-diagonal blocks $bold(G)$) with panel (c) ($cal(B)_3$, sign-flip invariance annihilates $bold(G) = bold(0)$ leaving the block-diagonal $bold(I)_3 ⊗ bold(F)$).](figures/running_example_3x4.svg)
