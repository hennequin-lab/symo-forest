+++
id = "38beecad"
title = "Test vectors, block functional calculus, and width transport — trailhead"
created = 2026-11-12T09:21:46Z
updated = 2026-11-12T09:21:46Z
tags = ["meta", "scale", "algebra"]
aliases = ["scale trailhead", "computation trailhead", "transport trailhead"]
+++

# Test vectors, block functional calculus, and width transport — trailhead

From [[e176661b|the compile-time projection solve]], an orbit average $bold(S) = cal(R)_2(bold(u), bold(v)) in cal(C)(W_R, W_L)$ is produced as a list of **factor coordinates** $bold(c) = (bold(C)_1, dots, bold(C)_d)$ in the diagram basis ${bold(T)_1, dots, bold(T)_d}$. From [[46af9ff5|the Wedderburn theorem]], $bold(S)$ is algebraically isomorphic to a tuple of width-independent **Wedderburn blocks** $(bold(B)_lambda)_lambda$.

This trail constructs the exact linear dictionary $bold(Phi)_n : bold(c) mapsto (bold(B)_lambda)_lambda$ connecting these two representations via **canonical test vectors**, proves the **block functional calculus** for analytic and spectral matrix functions $f(bold(S))$, and defines **width transport** $tau_(n -> n') = bold(Phi)_(n')^(-1) compose bold(Phi)_n$ across permuted dimensions.

## Notes in this trail

- [[790ac25a|Factor coordinates are width-dependent; Wedderburn blocks are width-independent]] — why diagram coefficients $bold(c)$ are coordinates in an $n$-dependent basis whereas the matrices $bold(B)_lambda$ are the size-free operator representation.
- [[0c051391|Canonical test vectors and the pairing theorem]] — definition of test vectors $bold(z)_(lambda a) = bold(e)_lambda ⊗ bold(m)_a$ sharing a fixed unit internal vector $bold(e)_lambda in cal(S)_lambda$, and proof that $⟨bold(z)_(lambda a)^L, bold(S) bold(z)_(mu b)^R⟩ = delta_(lambda mu)(bold(G)_lambda bold(B)_lambda)_(a b)$.
- [[7ee7cea7|Explicit canonical test vectors for k = 1 and k = 2]] — the concrete orthonormal witnesses in `Kind.test_vectors` ($2$ vectors in $RR^n$ for $k = 1$; $7$ matrices in $RR^(n times n)$ for $k = 2$), their norms, and their orthogonality proofs.
- [[f914d5ad|The compile-time dictionary between factor coordinates and Wedderburn blocks]] — the pairing table $bold(P)_((lambda a b), k) = ⟨bold(z)_(lambda a)^L, bold(T)_k bold(z)_(lambda b)^R⟩$ (`Blocks.table`) and its pseudoinverse $bold(P)^dagger$ (`Blocks.inverse`), which convert factors to blocks and back at runtime with zero operator probing.
- [[93e6cfab|Block functional calculus and the four-step round trip]] — proof that $f(bold(S)) = ⊕_lambda (bold(I)_(cal(S)_lambda) ⊗ f(bold(B)_lambda))$ for analytic and spectral functions $f$, preservation of isotropic shifts $bold(S) + gamma bold(I)_W$ in orthonormal copy bases, and the $sum_lambda O((m_lambda f)^3)$ four-step algorithm.
- [[be071dc0|Transporting invariant operators across widths]] — definition of $tau_(n -> n') = bold(Phi)_(n')^(-1) compose bold(Phi)_n$, proof that transport preserves blocks, distinct eigenvalues, and analytic functions, and exact formulas for multiplicity-dependent quantities ($op("tr")$, $det$, $op("rank")$, $norm(dot)_F$).
- [[3862bdb6|Why evaluating fixed factor coordinates at a surrogate width changes the operator]] — quantitative comparison showing why holding diagram coordinates $bold(c)$ fixed while changing $n$ alters the blocks $bold(B)_lambda$ and shifts the spectrum for $k >= 2$.

The realization of these algorithms in OCaml is described in [[07ef8651|The symo compiler and orbit architecture]]. Return to the [[index|map of the vault]].
