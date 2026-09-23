# Design contract

## Primary questions and estimands

The unit is a participant-item response in a Deliberative Poll. The target
population is participants in eligible polls with repeated multi-item attitude
measures, randomized group assignment, and a survey-only control arm. The
treatment is deliberation between T1 and T2. The primary estimands are:

- `tau`: the treated-minus-control effect on mean true opinion change;
- `gamma`: pull toward the assigned group's T1 latent mean;
- `sigma_b^2`: variance of treatment-induced group effects;
- `C = (omega_21 - omega_11) - (omega_20 - omega_10)`: treatment-caused
  crystallization in the normalized composite; and
- arm-specific variance of idiosyncratic true change.

Poll-level estimates target the participant-weighted estimand within a poll.
Any pooled estimate must state whether polls, participants, or inverse posterior
variance receive equal weight.

## Identification assumptions

1. At least three usable indicators measure each construct at each wave. Loadings
   and intercepts are invariant enough to put latent opinion on a common scale.
   Residual variances remain free across wave and arm.
2. Item residuals are conditionally mean zero and locally independent after any
   explicitly modeled same-item longitudinal residual covariance.
3. Treatment assignment is random; group assignment is random within treatment.
   Attrition and item missingness do not depend on unobserved potential outcomes
   after the stated adjustment set.
4. The control arm identifies retest and panel-conditioning changes in error
   variance. Differential error change is attributed to deliberation only under
   exclusion and no-interference assumptions.
5. Group effects are independent of baseline latent opinion under random group
   assignment. Multiple-membership weights are fixed by exposure time rather than
   chosen in response to latent change.

Online polls formed around availability do not identify causal group effects and
belong in a descriptive sensitivity analysis. Single-item outcomes do not identify
wave-specific measurement error from two waves alone; they require a within-wave
repeat, a third wave with additional restrictions, or an external reliability
study.

## Model

For item `k`, participant `i`, wave `t`, and arm `a`:

```text
y_kit = nu_k + lambda_k eta_it + epsilon_kit,
Var(epsilon_kit) = theta_kta.
```

For treated participants:

```text
eta_i2 = eta_i1 + tau + gamma(m_g(i),1 - eta_i1)
          + sum_s w_is b_g(s) + delta_i.
```

Controls have no group-pull or group-effect term. Multiple-membership effects
imply `Cov(Wb) = sigma_b^2 W W'`; fixed groups are one-hot rows of `W`.

## Inference

The full model will be Bayesian. Priors on `sigma_b` must be calibrated in a
simulation spanning the observed number and size distribution of groups. Report
posterior intervals in the original response scale and simulation-based coverage,
bias, RMSE, interval length, and failure rate. A fixed-group two-level SEM is a
cross-software check, not the primary estimator.

Mean-effect analyses remain valid under mean-zero heteroskedastic measurement
error, but uncertainty must reflect partial nesting: treated participants share
groups while controls do not. Variance-component claims require the latent model.

## Falsification and sensitivity checks

- Test loading and intercept invariance before interpreting latent change. If
  full invariance fails, use a predeclared partial-invariance rule and report the
  freed parameters.
- Compare same-item residual correlations across waves with and without them.
- Verify baseline balance at both participant and assigned-group levels.
- Report group counts, size imbalance, reshuffling weights, and leave-one-group-out
  sensitivity for each poll.
- Treat availability-formed groups as a negative-design check for the random-group
  claim.
- Simulate under crystallization only, convergence only, divergence only, all
  three, and violations of invariance and local independence.
- For the knowledge-gain association, model knowledge and opinion measurement
  jointly or propagate first-stage uncertainty; do not regress on plug-in factor
  scores and call the usual second-stage interval complete.

## Data dependency and readiness

Until the source-first build is complete, the empirical reanalysis consumes
the versioned `data/processed/knowledge_attitude_panel.csv` output from
[`dp-knowledge-linkage`](https://github.com/soodoku/dp-knowledge-linkage). Its
current public-data bridge contains six exactly validated polls, 1,661 linked
respondents, 43 poll-specific attitude indices, T1/T2 knowledge scores, T1/T2
attitude responses, and fixed small-group identifiers. The item-level knowledge
responses remain in the companion long table, so a joint knowledge model need
not rely on the composite score.

The durable dependency is [`dp-data`](https://github.com/soodoku/dp-data), not
the linkage repository. Switch only after `dp-data` rebuilds the panel from
audited poll-level sources and documents row, key, item, and derived-value
parity. At that point `dp-knowledge-linkage` can be archived.

This bridge is sufficient to study knowledge–attitude associations and the
fixed-group special case descriptively. It does not by itself identify the full
model: control-arm membership and session-level multiple-membership rosters are
not present in the older public archive. Those fields must be obtained from a
poll-specific deposit or platform export before estimating causal
crystallization or reshuffled-group effects.

## Analysis status

The research questions and some motivating outcomes were known before this
repository existed. This is therefore a versioned design document, not a claim of
prospective preregistration. Any later confirmatory analysis needs a genuinely
sealed holdout or a third-party time-stamped registration before outcome fitting.
