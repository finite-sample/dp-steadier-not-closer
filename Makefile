.PHONY: analysis paper test lint check ci ci-docker clean

analysis:
	Rscript scripts/run_simulation.R
	Rscript scripts/render_outputs.R

paper: analysis
	latexmk -pdf -interaction=nonstopmode -halt-on-error -cd paper/proof.tex

test:
	Rscript -e 'testthat::test_dir("tests/testthat")'

lint:
	Rscript -e 'lintr::lint_dir("R"); lintr::lint_dir("scripts"); lintr::lint_dir("tests")'

check: test lint

ci: paper check

ci-docker:
	docker run --rm -v "$(CURDIR):/work" -w /work rocker/verse:4.6.0 \
		bash -lc 'Rscript -e '\''install.packages(c("remotes", "renv"), repos="https://cloud.r-project.org"); remotes::install_deps(dependencies=TRUE)'\'' && make ci'

clean:
	latexmk -C -cd paper/proof.tex

