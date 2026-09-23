# Steadier, not closer

Deliberation can make observed opinions look more homogeneous for two different
reasons: people may truly move closer together, or repeated answers may become
less noisy. This repository proves which variance statistics confound those
mechanisms and supplies a simulation that separates:

1. true within-group convergence;
2. true between-group divergence; and
3. crystallization, defined as a treatment-caused reduction in measurement-error
   variance.

The deliberately droll name is the central warning: a group can look closer
because its answers became steadier.

The motivating Distortions author manuscript is preserved with provenance in
[`references/README.md`](references/README.md).
The accompanying [`references/NUMBER_CHECK.md`](references/NUMBER_CHECK.md)
separates published counts from corrected replication counts.

## Main result

For a normalized composite score `S_it = eta_it + u_it`, the expected change in
within-group observed variance is

```text
E[W_2(S) - W_1(S)] = W_2(eta) - W_1(eta) + omega_2 - omega_1.
```

Thus lower measurement error at T2 creates apparent homogenization even with no
true convergence. It also raises an ICC or a between/within ratio when true
components are fixed. But it cannot, under classical independent error, create
an increase in the absolute variance of observed group means; that variance
falls by `(omega_2 - omega_1) / n_g`. This boundary condition is important for
interpreting claims of between-group divergence.

The formal statements and proofs are in [`paper/proof.pdf`](paper/proof.pdf).
The empirical-design contract is in [`docs/design.md`](docs/design.md).

## Empirical data dependency

The proof and simulation do not require the Cor-Sood data. The empirical
reanalysis does. The separate
[`dp-knowledge-linkage`](https://github.com/soodoku/dp-knowledge-linkage)
repository supplies a validated knowledge–attitude panel for six polls: 1,661
respondents and 43 poll-specific attitude indices. It links only respondents
whose public row order reproduces the deposited T1/T2 knowledge scores and
gender. The older archive still lacks the control-arm and session-roster fields
needed for the full causal multiple-membership model.

## Reproduce

```sh
Rscript -e 'renv::restore()'
make ci
```

The simulation uses `lme4::lmer()` rather than a custom variance-component
estimator. Data manipulation uses the tidyverse and input/output assumptions are
checked with `assertr`. Tables are rendered with `knitr` and `kableExtra`.

## Status

This first release proves the measurement-error decomposition and validates the
observable implications in simulation. It does not claim to have fitted the full
latent partially nested multiple-membership model to a Deliberative Poll. That
requires an audited item/group/control data contract first.
