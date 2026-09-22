source("R/simulation.R")

summary <- readr::read_csv(
  project_file("results", "simulation_summary.csv"),
  show_col_types = FALSE
)
scenario_labels <- c(
  crystallization_only = "Crystallization only",
  convergence_only = "Convergence only",
  divergence_only = "Divergence only",
  all_three = "All three"
)

plot_data <- summary |>
  dplyr::filter(
    metric %in% c(
      "observed_homogenization", "latent_homogenization",
      "observed_between_change", "latent_between_change",
      "observed_icc_change", "latent_icc_change"
    )
  ) |>
  dplyr::mutate(
    scenario = factor(scenario_labels[scenario], levels = unname(scenario_labels)),
    quantity = dplyr::case_when(
      grepl("homogenization", metric) ~ "Within-group homogenization",
      grepl("between", metric) ~ "Absolute between-group variance change",
      TRUE ~ "ICC change"
    ),
    scale = dplyr::if_else(grepl("^observed", metric), "Observed score", "True opinion")
  )

figure <- ggplot2::ggplot(
  plot_data,
  ggplot2::aes(x = mean, y = scenario, colour = scale)
) +
  ggplot2::geom_vline(xintercept = 0, colour = "grey70", linewidth = .4) +
  ggplot2::geom_errorbar(
    ggplot2::aes(xmin = q025, xmax = q975),
    width = 0,
    position = ggplot2::position_dodge(width = .5)
  ) +
  ggplot2::geom_point(position = ggplot2::position_dodge(width = .5)) +
  ggplot2::facet_wrap(~ quantity, scales = "free_x") +
  ggplot2::labs(x = "Mean across simulations (95% simulation interval)", y = NULL, colour = NULL) +
  ggplot2::theme_minimal(base_size = 10) +
  ggplot2::theme(legend.position = "bottom")

dir.create(project_file("figures"), recursive = TRUE, showWarnings = FALSE)
ggplot2::ggsave(
  project_file("figures", "decomposition.pdf"),
  figure,
  width = 9,
  height = 5
)

table_data <- summary |>
  dplyr::filter(
    metric %in% c(
      "observed_homogenization", "latent_homogenization",
      "observed_between_change", "latent_between_change", "observed_icc_change"
    )
  ) |>
  dplyr::mutate(
    Scenario = scenario_labels[scenario],
    Quantity = metric_label,
    Estimate = sprintf("%.3f [%.3f, %.3f]", mean, q025, q975)
  ) |>
  dplyr::select(Scenario, Quantity, Estimate)

dir.create(project_file("reports", "tables"), recursive = TRUE, showWarnings = FALSE)
table_data |>
  knitr::kable(
    format = "html",
    caption = "Simulation decomposition",
    escape = TRUE
  ) |>
  kableExtra::kable_styling(
    bootstrap_options = c("striped", "hover", "condensed"),
    full_width = FALSE
  ) |>
  kableExtra::save_kable(
    project_file("reports", "tables", "simulation-decomposition.html"),
    self_contained = TRUE
  )

latex_table <- knitr::kable(
  table_data,
  format = "latex",
  booktabs = TRUE,
  caption = "Simulation decomposition. Entries are means and 95\\% simulation intervals.",
  label = "simulation-decomposition",
  linesep = ""
)
readr::write_lines(latex_table, project_file("results", "simulation_table.tex"))
