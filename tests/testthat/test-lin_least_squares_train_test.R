test_that("training subset, by using seed, matches - OLS", {
  seed = 100
  x <- data.frame(matrix(sample(100000, 200*5, replace=TRUE), ncol = 5))
  y <- sample(100, 200, replace=TRUE)
  smp_size <- floor(0.8 * nrow(x))
  set.seed(seed)
  train_ind <- sample(seq_len(nrow(x)), size = smp_size)
  train_x <- x[train_ind,]
  train_y <- y[train_ind]
  temp_data <- data.frame(train_x, train_y)
  model <- lm(train_y ~ ., temp_data)
  set.seed(seed)
  model_stats <- lin_least_squares_train_test(x, y)
  expect_lte(abs(model$coefficients - model_stats$beta), 0.00001)
  expect_lte(abs(model$residuals - model_stats$training_residuals), 0.00001)
  expect_lte(abs(model$fitted.values - model_stats$training_fitted_values), 0.00001)
})

test_that("training subset, by using seed, matches - WLS", {
  seed = 50
  x <- data.frame(matrix(sample(100000, 150*4, replace=TRUE), ncol = 4))
  y <- sample(100, 150, replace=TRUE)
  smp_size <- floor(0.7 * nrow(x))
  set.seed(seed)
  train_ind <- sample(seq_len(nrow(x)), size = smp_size)
  train_x <- x[train_ind,]
  train_y <- y[train_ind]
  temp_data <- data.frame(train_x, train_y)
  model <- lm(train_y ~ ., temp_data)
  wt <- 1 / lm(abs(model$residuals) ~ model$fitted.values)$fitted.values^2
  model_weighted <- lm(y ~ ., temp_data, weights = wt)
  set.seed(seed)
  model_stats <- lin_least_squares_train_test(x, y, weighted = TRUE, train_set_prop = 0.7)
  expect_lte(abs(model$coefficients - model_stats$beta), 0.00001)
  expect_lte(abs(model$residuals - model_stats$training_residuals), 0.00001)
  expect_lte(abs(model$fitted.values - model_stats$training_fitted_values), 0.00001)
})
