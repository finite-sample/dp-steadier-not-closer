source("R/simulation.R")

results <- purrr::pmap(scenario_grid, run_scenario) |>
  purrr::list_rbind()

metric_labels <- c(
  observed_homogenization = "Observed within-group homogenization",
  latent_homogenization = "True within-group homogenization",
  observed_between_change = "Observed between-component change",
  latent_between_change = "True between-component change",
  observed_group_mean_variance_change = "Raw group-mean variance change",
  observed_icc_change = "Observed ICC change",
  latent_icc_change = "True ICC change"
)

summary <- results |>
  tidyr::pivot_longer(
    cols = -c(scenario, simulation),
    names_to = "metric",
    values_to = "estimate"
  ) |>
  dplyr::mutate(metric_label = metric_labels[metric]) |>
  dplyr::summarise(
    mean = mean(estimate),
    q025 = stats::quantile(estimate, .025),
    q975 = stats::quantile(estimate, .975),
    .by = c(scenario, metric, metric_label)
  )

dir.create(project_file("results"), recursive = TRUE, showWarnings = FALSE)
readr::write_csv(results, project_file("results", "simulation_replicates.csv"))
readr::write_csv(summary, project_file("results", "simulation_summary.csv"))
