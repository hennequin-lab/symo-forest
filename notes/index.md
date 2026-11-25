+++
id = "index"
title = "Orbit averages and the commutant algebra — map of the vault"
created = 2026-11-12T09:21:46Z
updated = 2026-11-12T09:21:46Z
tags = ["meta"]
aliases = ["54900ffe", "forest map", "orbit averaging overview", "start here"]
+++

# Orbit averages and the commutant algebra — map of the vault

This vault is a self-contained mathematical and algorithmic treatment of **weight-space permutation symmetries, exact orbit averages, and the Wedderburn block coordinates of the commutant algebra**, following the algebraic core of [Artemev et al. (ICML 2026)](https://openreview.net/pdf?id=yiq2tZojBK) and its OCaml implementation [`symo`](https://github.com/hennequin-lab/murder/tree/main/packages/symo) in the [`murder`](https://github.com/hennequin-lab/murder) monorepo.

## The mathematical problem

Let $W = ⊕_(i=1)^L W_i$ be the parameter space of a neural network of total dimension $D = dim W$, and let $cal(G)$ be a finite group acting on $W$ via an [[588b9727|orthogonal representation]] $rho : cal(G) -> O(W)$ such that the network function is invariant: $f(rho(g) bold(w), bold(x)) = f(bold(w), bold(x))$ for all $g in cal(G)$. Typical groups are products of symmetric groups $cal(S)_n$ (or hyperoctahedral groups $cal(B)_n$ of [[2addfd8f|signed permutations]]) relabelling hidden units, recurrent state units, channels, or attention heads.

Given vectors $bold(u), bold(v) in W$ — such as a parameter vector $bold(w)$ or a gradient $bold(g) = nabla cal(L)(bold(w))$, which transforms equivariantly as $nabla cal(L)(rho(g) bold(w)) = rho(g) nabla cal(L)(bold(w))$ ([[6b12a533|gradient equivariance]]) — the **first- and second-order orbit averages** are the exact group expectations
```typst
cal(R)_1 (bold(v)) = bb(E)_(g in cal(G)) [ rho(g) bold(v) ] in W,
quad quad
cal(R)_2 (bold(u), bold(v)) = bb(E)_(g in cal(G)) [ (rho(g) bold(u)) (rho(g) bold(v))^top ] in RR^(D times D).
```
Because $|cal(G)|$ grows factorially with layer width ($n!$), enumerating the group is impossible, and because $D$ is large, materializing the $D times D$ matrix $bold(S) = cal(R)_2(bold(u), bold(v))$ is intractable. The central result of this vault is that **both averages are exact orthogonal projections onto low-dimensional algebraic subspaces, enabling $O(D)$ closed-form projection and width-independent $O(1)$ spectral operations on $bold(S)$**.

## The six-step spine

1. **Orbit averages are orthogonal projections.** By orthogonality of $rho(g)$, $cal(R)_1$ is the Euclidean orthogonal projection onto the invariant subspace $W^(cal(G))$ ([[6226b6f2|first-order projection]]), and the twirl $cal(T)(bold(X)) = bb(E)_(g in cal(G))[rho_L(g) bold(X) rho_R(g)^top]$ — of which $cal(R)_2(bold(u), bold(v)) = cal(T)(bold(u) bold(v)^top)$ is the rank-one case — is the Frobenius-orthogonal projection onto the **commutant** (intertwiner space) $cal(C)(W_R, W_L) = {bold(S) : W_R -> W_L mid(|) bold(S) rho_R(g) = rho_L(g) bold(S)}$ ([[8eb163bd|second-order projection]]).
2. **The commutant is spanned by equality-pattern diagrams.** For $cal(G) = cal(S)_n$ permuting $k_L$ left axes and $k_R$ right axes of dimension $n$, an entry of $bold(S) in cal(C)$ can depend on those $k_L + k_R$ indices only through which subsets of them are equal ([[33d479c5|equality patterns]]). The resulting basis of sparse binary Kronecker-delta tensors $bold(T)_P$ is indexed by set partitions of ${1, dots, k_L + k_R}$ and has dimension equal to the Bell number $B_(k_L + k_R)$ ($B_2 = 2$ for one permuted axis, $B_4 = 15$ for two tied axes), tensored with the free axes $F_L, F_R$ ([[a0bb3d95|diagram terms and Bell numbers]]).
3. **Projection reduces to a symbolic Gram system and einsum contractions.** The inner products $bold(G)_(P Q) = ⟨bold(T)_P, bold(T)_Q⟩_F$ depend only on the join $P or Q$ in the partition lattice and are evaluated symbolically in $O(1)$ time ([[b81e35a1|symbolic Gram matrix]]). Cholesky-factoring $bold(G)$ once at compile time reduces computing the factor coordinates $bold(c)$ of $cal(R)_2(bold(u), bold(v))$ to $O(D)$ einsum contractions $b_k = ⟨bold(T)_k, bold(u) bold(v)^top⟩_F$ followed by two small triangular solves ([[e176661b|compile-time projection solve]]).
4. **Wedderburn decomposition isolates width into carrier multiplicities.** By Schur's lemma, decomposing the permutation tensor power into irreducible Specht modules $V^(⊗k) ≅ ⊕_lambda cal(S)_lambda ⊗ cal(M)_lambda$ forces every operator $bold(S) in cal(C)$ to take the block-diagonal form
   ```typst
   bold(S) = ⊕_lambda (bold(I)_(cal(S)_lambda) ⊗ bold(B)_lambda),
   ```
   where the carrier $cal(S)_lambda$ has dimension $d_lambda (n)$ growing with $n$ (and carries only the identity $bold(I)$), while the **Wedderburn block** $bold(B)_lambda$ has size $(m_lambda^L f_L) times (m_lambda^R f_R)$ completely independent of $n$ ([[35cc480f|isotypic decomposition]], [[46af9ff5|Wedderburn theorem]]).
5. **Canonical test vectors provide an exact compile-time dictionary.** Pairing a single unit internal vector $bold(e)_lambda in cal(S)_lambda$ across an orthonormal basis of copies $bold(m)_a in cal(M)_lambda$ defines $sum_lambda m_lambda$ [[0c051391|canonical test vectors]] $bold(z)_(lambda a) = bold(e)_lambda ⊗ bold(m)_a$ ([[7ee7cea7|2 for $k=1$, 7 for $k=2$]]). The compile-time pairing table $bold(P)_((lambda a b), k) = ⟨bold(z)_(lambda a)^L, bold(T)_k bold(z)_(lambda b)^R⟩$ and its pseudoinverse $bold(P)^dagger$ convert factor coordinates $bold(c)$ to blocks $bold(B)_lambda$ and back by a static matrix multiplication with zero runtime probing ([[f914d5ad|compile-time block dictionary]]).
6. **Analytic functions and width transport operate on the blocks.** Because $(bold(B)_lambda)_lambda mapsto bold(S)$ is an algebra isomorphism in orthonormal bases, any analytic or spectral function satisfies $f(bold(S)) = ⊕_lambda (bold(I)_(cal(S)_lambda) ⊗ f(bold(B)_lambda))$ ([[93e6cfab|block functional calculus]]), and re-encoding the same blocks at another stable width $n' >= 2k$ via $tau_(n -> n') = bold(Phi)_(n')^(-1) compose bold(Phi)_n$ preserves the blocks, distinct spectrum, and functional calculus while rescaling traces and determinants through $d_lambda (n')$ ([[be071dc0|width transport]]).

## The six trails

| trail | entry point | scope |
| --- | --- | --- |
| 1. Symmetries & projections | [[9a072006|Weight-space symmetries and orbit projections]] | Kronecker actions, orthogonality, $cal(S)_n$ and $cal(B)_n$, gradient equivariance, $cal(R)_1$ and $cal(R)_2$ as orthogonal projections |
| 2. Commutant & partition algebra | [[756b0592|The commutant and partition algebra]] | permutation moments, equality patterns, the $3 times 4$ example, $Pi / Pi_perp$ mean–covariance split, diagram terms, Bell numbers, symbolic Gram matrix, symmetric bundling |
| 3. Multi-leaf & recurrent mosaics | [[d8c20588|Multi-leaf parameter trees and recurrent mosaics]] | cross-leaf intertwiners, crossing groups $cal(G)_h times cal(G)_z$ in MLP-step RNNs, two-sided conjugation $bold(W) mapsto bold(Q) bold(W) bold(Q)^top$ in vanilla and gated RNNs |
| 4. Wedderburn & isotypic blocks | [[e2dee3bd|Wedderburn decomposition and isotypic blocks]] | Specht decomposition of $V^(⊗k)$, $15 = 2^2 + 3^2 + 1^2 + 1^2$, Schur's lemma, semisimplicity threshold $n >= 2k$, multi-group product kinds and tree block assembly |
| 5. Test vectors & transport | [[38beecad|Test vectors, block functional calculus, and width transport]] | factors vs blocks, canonical test vectors, the pairing theorem, explicit $k=1,2$ witnesses, compile-time table $bold(P)$, block functional calculus, width transport $tau_(n -> n')$, failure of naive surrogates |
| 6. Compilation in `symo` | [[07ef8651|The symo compiler and orbit architecture]] | declarative `Symmetry.spec` trees, einsum and pairwise Kronecker tie compilation, module correspondence, algebraic test invariants |

 All ten vector Hugin figures illustrating these constructions across MLPs, MLP-step RNNs, vanilla RNNs, and GRUs are collected in [[8f5747b6|Gallery of orbit-average figures]].

## References

- A. Artemev, R. Xia, B. M. Boyd, Y. Yu, F. Dangel, G. Hennequin, A. Bernacchia, [*Exploiting weight-space symmetries for approximating curvature*](https://openreview.net/pdf?id=yiq2tZojBK), ICML 2026.
- T. Halverson, A. Ram, *Partition algebras*, European Journal of Combinatorics 26 (2005), 869–921.
- H. Maron, H. Ben-Hamu, N. Shamir, Y. Lipman, *Invariant and equivariant graph networks*, ICLR 2019.
- Companion note and source code in the [`murder` monorepo](https://github.com/hennequin-lab/murder): [`packages/symo/doc/transport.typ`](https://github.com/hennequin-lab/murder/blob/main/packages/symo/doc/transport.typ) and [`packages/symo/lib/`](https://github.com/hennequin-lab/murder/tree/main/packages/symo/lib).
