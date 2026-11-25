# Orbit averages and the commutant algebra — a symo forest

An [EG](https://github.com/hennequin-lab/eg) vault of 40 atomic notes on
weight-space permutation symmetries, exact orbit projections, the partition and
commutant algebras, the Wedderburn isotypic decomposition, canonical test
vectors, block functional calculus, and width transport — the algebraic
foundation of Artemev et al., *Exploiting weight-space symmetries for
approximating curvature* (ICML 2026) and its OCaml implementation `symo`
(`murder/packages/symo`).

Published at <https://hennequin-lab.github.io/symo-forest/>.

## Usage

Preview the vault with live rebuilds:

```sh
eg serve --vault .
```

or validate and build the static site:

```sh
eg check --vault .
eg build --vault .
```

Start at **Orbit averages and the commutant algebra — map of the vault**
(`54900ffe`).

## Publishing

<https://hennequin-lab.github.io/symo-forest/> is a GitHub Pages project site
served under `/symo-forest/`. `.eg/config.toml` sets `base_url = "/symo-forest/"`,
which `eg build` uses for all internal URLs, and on every push to `main`
`.github/workflows/pages.yml` deploys the committed `site/` directory.

## Structure of the forest

One map note and six trails:

1. **Weight-space symmetries and orbit projections** (`9a072006`) — Kronecker
   actions on parameter leaves, orthogonal representations, $cal(S)_n$ and
   $cal(B)_n$, gradient equivariance, and $cal(R)_1, cal(R)_2$ as orthogonal
   projections.
2. **The commutant and partition algebra** (`756b0592`) — permutation moments,
   equality patterns, the $3 times 4$ worked example, the $\Pi / \Pi_\perp$
   mean–covariance decomposition, partial-partition diagram terms, Bell
   numbers, the symbolic Gram matrix on the partition lattice, compile-time
   Cholesky projection, and the $\Lambda^2 W \otimes \Lambda^2 F$ completeness
   condition for symmetric bundling.
3. **Multi-leaf parameter trees and recurrent mosaics** (`d8c20588`) —
   cross-leaf intertwiners, crossing groups $cal(G)_h \times cal(G)_z$ in an
   MLP-step RNN, and two-sided conjugation $W \mapsto Q W Q^\top$ in vanilla
   and gated RNNs.
4. **Wedderburn decomposition and isotypic blocks** (`e2dee3bd`) — the Specht
   decomposition of $V^{\otimes k}$ ($15 = 2^2 + 3^2 + 1^2 + 1^2$), Schur's
   lemma, semisimplicity of the partition algebra and the stable range
   $n \ge 2k$, product kinds across multiple groups, and block assembly over
   parameter trees.
5. **Test vectors, block functional calculus, and width transport**
   (`38beecad`) — width-dependent factor coordinates versus width-independent
   Wedderburn blocks, canonical test vectors and the pairing theorem, explicit
   $k = 1, 2$ witnesses, the compile-time dictionary $P$ and $P^\dagger$,
   block functional calculus, width transport $\tau_{n \to n'}$, and why naive
   surrogate evaluation distorts the spectrum for $k \ge 2$.
6. **The `symo` compiler and orbit architecture** (`07ef8651`) — declarative
   `Symmetry.spec` parameter trees, einsum and pairwise Kronecker tie
   compilation, module correspondence, and algebraic verification suites.
