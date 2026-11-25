+++
id = "e2dee3bd"
title = "Wedderburn decomposition and isotypic blocks — trailhead"
created = 2026-11-25T10:14:02Z
updated = 2026-11-25T10:14:02Z
tags = ["meta", "algebra"]
aliases = ["Wedderburn trailhead", "isotypic blocks trailhead"]
+++

# Wedderburn decomposition and isotypic blocks — trailhead

The diagram basis of [[756b0592|the partition algebra]] explains *how many* parameters describe an operator $bold(S) in cal(C)(W_R, W_L)$ ($sum_lambda m_lambda^L m_lambda^R f_L f_R$), and allows $bold(S)$ to be projected from outer products and applied to vectors via einsums. However, diagram tensors do not commute with matrix inversion or spectral functions: multiplying two diagram tensors mixes all $B_(2k)$ patterns.

To diagonalize $bold(S)$, compute analytic matrix functions $f(bold(S))$, or transport $bold(S)$ across widths $n$, we decompose the tensor power $V^(⊗k)$ into irreducible representations of $cal(S)_n$. By Schur's lemma and Wedderburn's structure theorem, $cal(C)(W, W)$ is isomorphic to a direct sum of small matrix algebras — one **Wedderburn block** $bold(B)_lambda$ per isotypic kind $lambda$ — while the action on the width-dependent carrier $cal(S)_lambda$ is forced to be the identity matrix $bold(I)_(cal(S)_lambda)$.

## Notes in this trail

- [[35cc480f|Isotypic decomposition of V^⊗k under the symmetric group]] — derivation of $V^(⊗k) ≅ ⊕_lambda cal(S)_lambda ⊗ cal(M)_lambda$ for $k = 0, 1, 2$ into Specht modules $cal(S)_lambda$, carrier dimensions $d_lambda (n)$, multiplicities $m_lambda in {2, 3, 1, 1}$, and the identities $sum_lambda d_lambda (n) m_lambda = n^k$ and $sum_lambda m_lambda^2 = B_(2k)$.
- [[46af9ff5|Schur's lemma and the Wedderburn decomposition of the commutant]] — proof that every intertwiner $bold(S) in cal(C)(W_R, W_L)$ decomposes uniquely as $bold(S) = ⊕_lambda (bold(I)_(cal(S)_lambda) ⊗ bold(B)_lambda)$, giving an isomorphism of matrix algebras when $W_L = W_R$.
- [[b50cfe81|Semisimplicity of the partition algebra and the stable range n ≥ 2k]] — why the partition algebra $P_k (n)$ is semisimple and its $B_(2k)$ diagram tensors are linearly independent if and only if $n >= 2k$, and what degenerates below this threshold.
- [[a575e53a|Product kinds across multiple groups and block assembly over parameter trees]] — how independent symmetry groups form tuple kinds $bold(lambda) = (lambda^((1)), dots, lambda^((G)))$ with multiplied multiplicities, and how `Orbit.Second_order.blocks_of_factors` assembles per-pair blocks across a parameter tree $W = ⊕_i W_i$.

The explicit conversion between diagram factor coordinates and Wedderburn blocks via canonical test vectors is developed in [[38beecad|Test vectors, block functional calculus, and width transport]]. Return to the [[index|map of the vault]].
