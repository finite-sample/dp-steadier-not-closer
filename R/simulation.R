project_file <- function(...) {
  file.path(rprojroot::find_root(rprojroot::has_file("DESCRIPTION")), ...)
}

scenario_grid <- tibble::tribble(
  ~scenario, ~gamma, ~between_multiplier, ~error_sd_t1, ~error_sd_t2,
  "crystallization_only", 0.0, 1.0, 1.0, 0.4,
  "convergence_only", 0.3, 1.0, 0.7, 0.7,
  "divergence_only", 0.0, 1.7, 0.7, 0.7,
  "all_three", 0.3, 1.7, 1.0, 0.4
)

simulate_panel <- function(
  gamma,
  between_multiplier,
  error_sd_t1,
  error_sd_t2,
  seed,
  groups = 30L,
  people_per_group = 25L,
  items = 5L,
  between_sd = 0.35,
  within_sd = 1
) {
  set.seed(seed)
  group_effects <- tibble::tibble(
    group = factor(seq_len(groups)),
    group_effect = stats::rnorm(groups, sd = between_sd)
  )
  people <- tidyr::crossing(
    group = factor(seq_len(groups)),
    person_in_group = seq_len(people_per_group)
  ) |>
    dplyr::left_join(group_effects, by = "group", relationship = "many-to-one") |>
    dplyr::mutate(
      person = dplyr::row_number(),
      deviation = stats::rnorm(dplyr::n(), sd = within_sd),
      latent_t1 = group_effect + deviation,
      latent_t2 = between_multiplier * group_effect + (1 - gamma) * deviation
    )

  people |>
    dplyr::select(person, group, latent_t1, latent_t2) |>
    tidyr::pivot_longer(
      cols = dplyr::starts_with("latent_"),
      names_to = "wave",
      names_prefix = "latent_",
      values_to = "latent"
    ) |>
    tidyr::crossing(item = seq_len(items)) |>
    dplyr::mutate(
      error_sd = dplyr::if_else(wave == "t1", error_sd_t1, error_sd_t2),
      response = latent + stats::rnorm(dplyr::n(), sd = error_sd)
    ) |>
    dplyr::group_by(person, group, wave) |>
    dplyr::summarise(
      latent = dplyr::first(latent),
      score = mean(response),
      .groups = "drop"
    )
}

variance_components <- function(data, outcome, wave) {
  wave_data <- dplyr::filter(data, .data$wave == .env$wave)
  model <- lme4::lmer(
    stats::reformulate("(1 | group)", response = outcome),
    data = wave_data,
    REML = TRUE
  )
  components <- as.data.frame(lme4::VarCorr(model))
  between <- dplyr::filter(components, components$grp == "group")$vcov
  within <- dplyr::filter(components, components$grp == "Residual")$vcov
  tibble::tibble(
    between = between,
    within = within,
    icc = between / (between + within)
  )
}

summarize_simulation <- function(data, scenario, simulation) {
  components <- tidyr::crossing(
    outcome = c("latent", "score"),
    wave = c("t1", "t2")
  ) |>
    dplyr::mutate(
      fit = purrr::map2(outcome, wave, ~ variance_components(data, .x, .y))
    ) |>
    tidyr::unnest(fit)

  wide <- components |>
    tidyr::pivot_wider(
      names_from = c(outcome, wave),
      values_from = c(between, within, icc),
      names_glue = "{outcome}_{.value}_{wave}"
    )

  group_mean_variance <- data |>
    dplyr::group_by(wave, group) |>
    dplyr::summarise(group_mean = mean(score), .groups = "drop") |>
    dplyr::summarise(group_mean_variance = stats::var(group_mean), .by = wave) |>
    tidyr::pivot_wider(
      names_from = wave,
      values_from = group_mean_variance,
      names_prefix = "group_mean_variance_"
    )

  dplyr::bind_cols(wide, group_mean_variance) |>
    dplyr::transmute(
      scenario = scenario,
      simulation = simulation,
      observed_homogenization = 1 - score_within_t2 / score_within_t1,
      latent_homogenization = 1 - latent_within_t2 / latent_within_t1,
      observed_between_change = score_between_t2 - score_between_t1,
      latent_between_change = latent_between_t2 - latent_between_t1,
      observed_group_mean_variance_change =
        group_mean_variance_t2 - group_mean_variance_t1,
      observed_icc_change = score_icc_t2 - score_icc_t1,
      latent_icc_change = latent_icc_t2 - latent_icc_t1
    )
}

run_scenario <- function(
  scenario,
  gamma,
  between_multiplier,
  error_sd_t1,
  error_sd_t2,
  simulations = 200L,
  seed = 20260922L
) {
  seq_len(simulations) |>
    purrr::map(function(simulation) {
      data <- simulate_panel(
        gamma = gamma,
        between_multiplier = between_multiplier,
        error_sd_t1 = error_sd_t1,
        error_sd_t2 = error_sd_t2,
        seed = seed + simulation
      )
      summarize_simulation(data, scenario, simulation)
    }) |>
    purrr::list_rbind()
}
