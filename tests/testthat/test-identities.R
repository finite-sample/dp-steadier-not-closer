test_that("classical error creates observed homogenization", {
  true_variance <- 1
  error_t1 <- .5
  error_t2 <- .1
  observed <- 1 - (true_variance + error_t2) / (true_variance + error_t1)
  latent <- 1 - true_variance / true_variance
  expect_gt(observed, 0)
  expect_equal(latent, 0)
})

test_that("error reduction cannot raise absolute group-mean variance", {
  true_between <- .2
  true_within <- 1
  group_size <- 20
  error_t1 <- .5
  error_t2 <- .1
  between_t1 <- true_between + (true_within + error_t1) / group_size
  between_t2 <- true_between + (true_within + error_t2) / group_size
  expect_lt(between_t2, between_t1)
})

test_that("error reduction raises an ICC when true components are fixed", {
  between <- .2
  within <- 1
  icc_t1 <- between / (between + within + .5)
  icc_t2 <- between / (between + within + .1)
  expect_gt(icc_t2, icc_t1)
})
