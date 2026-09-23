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
	docker run --rm \
		-e MAKEFLAGS="-e -j1" \
		-e CXXFLAGS="-O0 -g0" \
		-e CXX20FLAGS="-O0 -g0" \
		-e RENV_CONFIG_CACHE_ENABLED=FALSE \
		-e RENV_CONFIG_EXTERNAL_LIBRARIES=/usr/local/lib/R/site-library \
		-e RENV_CONFIG_SYNCHRONIZED_CHECK=FALSE \
		-v "$(CURDIR):/work" -w /work rocker/tidyverse:4.6.0 \
		bash -lc 'apt-get update && apt-get install -y --no-install-recommends cmake curl git latexmk libnlopt-dev texlive-latex-extra texlive-fonts-recommended && Rscript -e '\''install.packages("remotes", repos="https://cloud.r-project.org"); remotes::install_deps(dependencies=TRUE, upgrade="never")'\'' && make ci'

clean:
	latexmk -C -cd paper/proof.tex
