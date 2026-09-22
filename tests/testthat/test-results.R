test_that("the simulation separates the three mechanisms", {
  summary <- readr::read_csv(
    project_file("results", "simulation_summary.csv"),
    show_col_types = FALSE
  )
  estimate <- function(scenario_name, metric_name) {
    summary |>
      dplyr::filter(scenario == scenario_name, metric == metric_name) |>
      dplyr::pull(mean)
  }
  expect_gt(estimate("crystallization_only", "observed_homogenization"), .1)
  expect_lt(abs(estimate("crystallization_only", "latent_homogenization")), .03)
  expect_gt(estimate("crystallization_only", "observed_icc_change"), 0)
  expect_lt(estimate("crystallization_only", "observed_group_mean_variance_change"), 0)
  expect_gt(estimate("convergence_only", "latent_homogenization"), .2)
  expect_gt(estimate("divergence_only", "latent_between_change"), .1)
})
