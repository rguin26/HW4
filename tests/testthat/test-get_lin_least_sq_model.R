test_that("x and/or y is not numeric", {
  x1 <- c("2", "g", 4, 2, 9)
  y1 <- 10:14
  expect_error(get_lin_least_sq_model(x1, y1))
  x2 <- c("2", "g", 4, "l", "9")
  y2 <- c(1, "t", "7", "e", "10")
  expect_error(get_lin_least_sq_model(x2, y2))
  x3 <- c(0, 6, 3, 2, 5)
  y3 <- c(1, "t", "7", "e", "10")
  expect_error(get_lin_least_sq_model(x3, y3))
})

test_that("x and y do not have matching number of instances", {
  x1 <- 2:5
  y1 <- 10:17
  expect_error(get_lin_least_sq_model(x1, y1))
  x2 <- matrix(sample(1000, 30*5, replace=FALSE), ncol = 5)
  y2 <- sample(100, 28, replace=TRUE)
  expect_error(get_lin_least_sq_model(x2, y2))
  x3 <- data.frame(matrix(sample(1000, 33*5, replace=FALSE), ncol = 5))
  y3 <- sample(100, 30, replace=TRUE)
  expect_error(get_lin_least_sq_model(x3, y3))
})

test_that("OLS with x as a vector", {
  x <- sample(100, 30, replace=FALSE)
  y <- sample(100, 30, replace=TRUE)
  temp_data <- data.frame(x, y)
  model <- lm(y ~ ., temp_data)
  ols_result <- get_lin_least_sq_model(x, y)
  temp_sum <- sum(abs(model$coefficients - ols_result$beta) < 0.00001)
  expect_equal(temp_sum, length(ols_result$beta))
  temp_sum <- sum(abs(model$fitted.values - ols_result$fitted_values) < 0.00001)
  expect_equal(temp_sum, length(ols_result$fitted_values))
  temp_sum <- sum(abs(model$residuals - ols_result$residuals) < 0.00001)
  expect_equal(temp_sum, length(ols_result$residuals))
})

test_that("OLS with x as a vector, no intercept - timing", {
  x <- sample(100, 30, replace=FALSE)
  y <- sample(100, 30, replace=TRUE)
  temp_data <- data.frame(x, y)
  time1 <- bench::system_time({
    model <- lm(y ~ ., temp_data)
    model$coefficients
  })
  time2 <- bench::system_time({
    ols_result <- get_lin_least_sq_model(x, y)
    ols_result$beta
  })
  expect_true(time2[2] < time1[2])
})

test_that("WLS with x as a vector", {
  x <- sample(300, 50, replace=FALSE)
  y <- sample(900, 50, replace=TRUE)
  temp_data <- data.frame(x, y)
  model <- lm(y ~ ., temp_data)
  wt <- 1 / lm(abs(model$residuals) ~ model$fitted.values)$fitted.values^2
  model_weighted <- lm(y ~ ., temp_data, weights = wt)
  wls_result <- get_lin_least_sq_model(x, y, weighted = TRUE)
  temp_sum <- sum(abs(model_weighted$coefficients - wls_result$beta) < 0.00001)
  expect_equal(temp_sum, length(wls_result$beta))
  temp_sum <- sum(abs(model_weighted$fitted.values - wls_result$fitted_values) < 0.00001)
  expect_equal(temp_sum, length(wls_result$fitted_values))
  temp_sum <- sum(abs(model_weighted$residuals - wls_result$residuals) < 0.00001)
  expect_equal(temp_sum, length(wls_result$residuals))
})

test_that("OLS with x as a vector, no intercept - timing", {
  x <- sample(300, 50, replace=FALSE)
  y <- sample(900, 50, replace=TRUE)
  temp_data <- data.frame(x, y)
  time1 <- bench::system_time({
    model <- lm(y ~ ., temp_data)
    wt <- 1 / lm(abs(model$residuals) ~ model$fitted.values)$fitted.values^2
    model_weighted <- lm(y ~ ., temp_data, weights = wt)
    model_weighted$coefficients
  })
  time2 <- bench::system_time({
    wls_result <- get_lin_least_sq_model(x, y, weighted = TRUE)
    wls_result$beta
  })
  expect_true(time2[2] < time1[2])
})

test_that("OLS with x as a vector, no intercept", {
  x <- sample(200, 60, replace=FALSE)
  y <- sample(400, 60, replace=TRUE)
  temp_data <- data.frame(x, y)
  model <- lm(y ~ . - 1, temp_data)
  ols_result <- get_lin_least_sq_model(x, y, intercept = FALSE)
  temp_sum <- sum(abs(model$coefficients - ols_result$beta) < 0.00001)
  expect_equal(temp_sum, length(ols_result$beta))
  temp_sum <- sum(abs(model$fitted.values - ols_result$fitted_values) < 0.00001)
  expect_equal(temp_sum, length(ols_result$fitted_values))
  temp_sum <- sum(abs(model$residuals - ols_result$residuals) < 0.00001)
  expect_equal(temp_sum, length(ols_result$residuals))
})

test_that("OLS with x as a vector, no intercept - timing", {
  x <- sample(200, 60, replace=FALSE)
  y <- sample(400, 60, replace=TRUE)
  temp_data <- data.frame(x, y)
  time1 <- bench::system_time({
    model <- lm(y ~ . - 1, temp_data)
    model$coefficients
  })
  time2 <- bench::system_time({
    ols_result <- get_lin_least_sq_model(x, y, intercept = FALSE)
    ols_result$beta
  })
  expect_true(time2[2] < time1[2])
})

test_that("WLS with x as a vector, no intercept", {
  x <- sample(500, 100, replace=FALSE)
  y <- sample(800, 100, replace=TRUE)
  temp_data <- data.frame(x, y)
  model <- lm(y ~ . - 1, temp_data)
  wt <- 1 / lm(abs(model$residuals) ~ model$fitted.values)$fitted.values^2
  model_weighted <- lm(y ~ . - 1, temp_data, weights = wt)
  wls_result <- get_lin_least_sq_model(x, y, intercept = FALSE, weighted = TRUE)
  temp_sum <- sum(abs(model_weighted$coefficients - wls_result$beta) < 0.00001)
  expect_equal(temp_sum, length(wls_result$beta))
  temp_sum <- sum(abs(model_weighted$fitted.values - wls_result$fitted_values) < 0.00001)
  expect_equal(temp_sum, length(wls_result$fitted_values))
  temp_sum <- sum(abs(model_weighted$residuals - wls_result$residuals) < 0.00001)
  expect_equal(temp_sum, length(wls_result$residuals))
})

test_that("WLS with x as a vector, no intercept - timing", {
  x <- sample(500, 100, replace=FALSE)
  y <- sample(800, 100, replace=TRUE)
  temp_data <- data.frame(x, y)
  time1 <- bench::system_time({
    model <- lm(y ~ . - 1, temp_data)
    wt <- 1 / lm(abs(model$residuals) ~ model$fitted.values)$fitted.values^2
    model_weighted <- lm(y ~ . - 1, temp_data, weights = wt)
    model_weighted$coefficients
  })
  time2 <- bench::system_time({
    wls_result <- get_lin_least_sq_model(x, y, intercept = FALSE, weighted = TRUE)
    wls_result$beta
  })
  expect_true(time2[2] < time1[2])
})

test_that("OLS with x as a matrix", {
  x <- matrix(sample(1000, 30*5, replace=FALSE), ncol = 5)
  y <- sample(100, 30, replace=TRUE)
  temp_data <- data.frame(x, y)
  model <- lm(y ~ ., temp_data)
  ols_result <- get_lin_least_sq_model(x, y)
  temp_sum <- sum(abs(model$coefficients - ols_result$beta) < 0.00001)
  expect_equal(temp_sum, length(ols_result$beta))
  temp_sum <- sum(abs(model$fitted.values - ols_result$fitted_values) < 0.00001)
  expect_equal(temp_sum, length(ols_result$fitted_values))
  temp_sum <- sum(abs(model$residuals - ols_result$residuals) < 0.00001)
  expect_equal(temp_sum, length(ols_result$residuals))
})

test_that("OLS with x as a matrix - timing", {
  x <- matrix(sample(1000, 30*5, replace=FALSE), ncol = 5)
  y <- sample(100, 30, replace=TRUE)
  temp_data <- data.frame(x, y)
  time1 <- bench::system_time({
    model <- lm(y ~ ., temp_data)
    model$coefficients
  })
  time2 <- bench::system_time({
    ols_result <- get_lin_least_sq_model(x, y)
    ols_result$beta
  })
  expect_true(time2[2] < time1[2])
})

test_that("WLS with x as a matrix", {
  x <- matrix(sample(1000, 50*4, replace=FALSE), ncol = 4)
  y <- sample(900, 50, replace=TRUE)
  temp_data <- data.frame(x, y)
  model <- lm(y ~ ., temp_data)
  wt <- 1 / lm(abs(model$residuals) ~ model$fitted.values)$fitted.values^2
  model_weighted <- lm(y ~ ., temp_data, weights = wt)
  wls_result <- get_lin_least_sq_model(x, y, weighted = TRUE)
  temp_sum <- sum(abs(model_weighted$coefficients - wls_result$beta) < 0.00001)
  expect_equal(temp_sum, length(wls_result$beta))
  temp_sum <- sum(abs(model_weighted$fitted.values - wls_result$fitted_values) < 0.00001)
  expect_equal(temp_sum, length(wls_result$fitted_values))
  temp_sum <- sum(abs(model_weighted$residuals - wls_result$residuals) < 0.00001)
  expect_equal(temp_sum, length(wls_result$residuals))
})

test_that("WLS with x as a matrix - timing", {
  x <- matrix(sample(1000, 60*5, replace=FALSE), ncol = 5)
  y <- sample(400, 60, replace=TRUE)
  temp_data <- data.frame(x, y)
  time1 <- bench::system_time({
    model <- lm(y ~ ., temp_data)
    wt <- 1 / lm(abs(model$residuals) ~ model$fitted.values)$fitted.values^2
    model_weighted <- lm(y ~ ., temp_data, weights = wt)
    model_weighted$coefficients
  })
  time2 <- bench::system_time({
    wls_result <- get_lin_least_sq_model(x, y, weighted = TRUE)
    wls_result$beta
  })
  expect_true(time2[2] < time1[2])
})

test_that("OLS with x as a matrix, no intercept", {
  x <- matrix(sample(1000, 60*5, replace=FALSE), ncol = 5)
  y <- sample(400, 60, replace=TRUE)
  temp_data <- data.frame(x, y)
  model <- lm(y ~ . - 1, temp_data)
  ols_result <- get_lin_least_sq_model(x, y, intercept = FALSE)
  temp_sum <- sum(abs(model$coefficients - ols_result$beta) < 0.00001)
  expect_equal(temp_sum, length(ols_result$beta))
  temp_sum <- sum(abs(model$fitted.values - ols_result$fitted_values) < 0.00001)
  expect_equal(temp_sum, length(ols_result$fitted_values))
  temp_sum <- sum(abs(model$residuals - ols_result$residuals) < 0.00001)
  expect_equal(temp_sum, length(ols_result$residuals))
})

test_that("OLS with x as a matrix, no intercept - timing", {
  x <- matrix(sample(1000, 60*5, replace=FALSE), ncol = 5)
  y <- sample(400, 60, replace=TRUE)
  temp_data <- data.frame(x, y)
  time1 <- bench::system_time({
    model <- lm(y ~ . - 1, temp_data)
    model$coefficients
  })
  time2 <- bench::system_time({
    ols_result <- get_lin_least_sq_model(x, y, intercept = FALSE)
    ols_result$beta
  })
  expect_true(time2[2] < time1[2])
})

test_that("WLS with x as a matrix, no intercept", {
  x <- matrix(sample(1000, 100*3, replace=FALSE), ncol = 3)
  y <- sample(800, 100, replace=TRUE)
  temp_data <- data.frame(x, y)
  model <- lm(y ~ . - 1, temp_data)
  wt <- 1 / lm(abs(model$residuals) ~ model$fitted.values)$fitted.values^2
  model_weighted <- lm(y ~ . - 1, temp_data, weights = wt)
  wls_result <- get_lin_least_sq_model(x, y, intercept = FALSE, weighted = TRUE)
  temp_sum <- sum(abs(model_weighted$coefficients - wls_result$beta) < 0.00001)
  expect_equal(temp_sum, length(wls_result$beta))
  temp_sum <- sum(abs(model_weighted$fitted.values - wls_result$fitted_values) < 0.00001)
  expect_equal(temp_sum, length(wls_result$fitted_values))
  temp_sum <- sum(abs(model_weighted$residuals - wls_result$residuals) < 0.00001)
  expect_equal(temp_sum, length(wls_result$residuals))
})

test_that("WLS with x as a matrix, no intercept - timing", {
  x <- matrix(sample(1000, 100*3, replace=FALSE), ncol = 3)
  y <- sample(800, 100, replace=TRUE)
  temp_data <- data.frame(x, y)
  time1 <- bench::system_time({
    model <- lm(y ~ . - 1, temp_data)
    wt <- 1 / lm(abs(model$residuals) ~ model$fitted.values)$fitted.values^2
    model_weighted <- lm(y ~ . - 1, temp_data, weights = wt)
    model_weighted$coefficients
  })
  time2 <- bench::system_time({
    wls_result <- get_lin_least_sq_model(x, y, intercept = FALSE, weighted = TRUE)
    wls_result$beta
  })
  expect_true(time2[2] < time1[2])
})

test_that("OLS with x as a data frame", {
  temp_data <- data.frame(
    hours=c(1, 1, 2, 2, 2, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 8),
    age=c(3, 6, 7, 2, 4, 5, 6, 3, 4, 5, 2, 2, 4, 5, 9, 8),
    weight=c(23, 12, 31, 24, 56, 23, 12, 23, 34, 35, 36, 14, 23, 11, 13, 56),
    score=c(48, 78, 72, 70, 66, 92, 93, 75, 75, 80, 95, 97, 90, 96, 99, 99)
  )
  x <- temp_data
  x$score <- NULL
  y <- temp_data$score
  model <- lm(score ~ ., temp_data)
  ols_result <- get_lin_least_sq_model(x, y)
  temp_sum <- sum(abs(model$coefficients - ols_result$beta) < 0.00001)
  expect_equal(temp_sum, length(ols_result$beta))
  temp_sum <- sum(abs(model$fitted.values - ols_result$fitted_values) < 0.00001)
  expect_equal(temp_sum, length(ols_result$fitted_values))
  temp_sum <- sum(abs(model$residuals - ols_result$residuals) < 0.00001)
  expect_equal(temp_sum, length(ols_result$residuals))
})

test_that("OLS with x as a data frame - timing", {
  temp_data <- data.frame(
    hours=c(1, 1, 2, 2, 2, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 8),
    age=c(3, 6, 7, 2, 4, 5, 6, 3, 4, 5, 2, 2, 4, 5, 9, 8),
    weight=c(23, 12, 31, 24, 56, 23, 12, 23, 34, 35, 36, 14, 23, 11, 13, 56),
    score=c(48, 78, 72, 70, 66, 92, 93, 75, 75, 80, 95, 97, 90, 96, 99, 99)
  )
  x <- temp_data
  x$score <- NULL
  y <- temp_data$score
  time1 <- bench::system_time({
    model <- lm(score ~ ., temp_data)
    model_weighted$coefficients
  })
  time2 <- bench::system_time({
    ols_result <- get_lin_least_sq_model(x, y)
    ols_result$beta
  })
  expect_true(time2[2] < time1[2])
})

test_that("WLS with x as a data frame", {
  temp_data <- data.frame(
    hours=c(1, 1, 2, 2, 2, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 8),
    age=c(3, 6, 7, 2, 4, 5, 6, 3, 4, 5, 2, 2, 4, 5, 9, 8),
    weight=c(23, 12, 31, 24, 56, 23, 12, 23, 34, 35, 36, 14, 23, 11, 13, 56),
    score=c(48, 78, 72, 70, 66, 92, 93, 75, 75, 80, 95, 97, 90, 96, 99, 99)
  )
  x <- temp_data
  x$score <- NULL
  y <- temp_data$score
  model <- lm(score ~ ., temp_data)
  wt <- 1 / lm(abs(model$residuals) ~ model$fitted.values)$fitted.values^2
  model_weighted <- lm(score ~ ., temp_data, weights = wt)
  wls_result <- get_lin_least_sq_model(x, y, weighted = TRUE)
  temp_sum <- sum(abs(model_weighted$coefficients - wls_result$beta) < 0.00001)
  expect_equal(temp_sum, length(wls_result$beta))
  temp_sum <- sum(abs(model_weighted$fitted.values - wls_result$fitted_values) < 0.00001)
  expect_equal(temp_sum, length(wls_result$fitted_values))
  temp_sum <- sum(abs(model_weighted$residuals - wls_result$residuals) < 0.00001)
  expect_equal(temp_sum, length(wls_result$residuals))
})

test_that("WLS with x as a data frame - timing", {
  temp_data <- data.frame(
    hours=c(1, 1, 2, 2, 2, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 8),
    age=c(3, 6, 7, 2, 4, 5, 6, 3, 4, 5, 2, 2, 4, 5, 9, 8),
    weight=c(23, 12, 31, 24, 56, 23, 12, 23, 34, 35, 36, 14, 23, 11, 13, 56),
    score=c(48, 78, 72, 70, 66, 92, 93, 75, 75, 80, 95, 97, 90, 96, 99, 99)
  )
  x <- temp_data
  x$score <- NULL
  y <- temp_data$score
  time1 <- bench::system_time({
    model <- lm(score ~ ., temp_data)
    wt <- 1 / lm(abs(model$residuals) ~ model$fitted.values)$fitted.values^2
    model_weighted <- lm(score ~ ., temp_data, weights = wt)
    model_weighted$coefficients
  })
  time2 <- bench::system_time({
    wls_result <- get_lin_least_sq_model(x, y, weighted = TRUE)
    wls_result$beta
  })
  expect_true(time2[2] < time1[2])
})

test_that("OLS with x as a data frame, no intercept", {
  temp_data <- data.frame(
    hours=c(1, 1, 2, 2, 2, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 8),
    age=c(3, 6, 7, 2, 4, 5, 6, 3, 4, 5, 2, 2, 4, 5, 9, 8),
    weight=c(23, 12, 31, 24, 56, 23, 12, 23, 34, 35, 36, 14, 23, 11, 13, 56),
    score=c(48, 78, 72, 70, 66, 92, 93, 75, 75, 80, 95, 97, 90, 96, 99, 99)
  )
  x <- temp_data
  x$score <- NULL
  y <- temp_data$score
  model <- lm(score ~ . - 1, temp_data)
  ols_result <- get_lin_least_sq_model(x, y, intercept = FALSE)
  temp_sum <- sum(abs(model$coefficients - ols_result$beta) < 0.00001)
  expect_equal(temp_sum, length(ols_result$beta))
  temp_sum <- sum(abs(model$fitted.values - ols_result$fitted_values) < 0.00001)
  expect_equal(temp_sum, length(ols_result$fitted_values))
  temp_sum <- sum(abs(model$residuals - ols_result$residuals) < 0.00001)
  expect_equal(temp_sum, length(ols_result$residuals))
})

test_that("OLS with x as a data frame, no intercept - timing", {
  temp_data <- data.frame(
    hours=c(1, 1, 2, 2, 2, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 8),
    age=c(3, 6, 7, 2, 4, 5, 6, 3, 4, 5, 2, 2, 4, 5, 9, 8),
    weight=c(23, 12, 31, 24, 56, 23, 12, 23, 34, 35, 36, 14, 23, 11, 13, 56),
    score=c(48, 78, 72, 70, 66, 92, 93, 75, 75, 80, 95, 97, 90, 96, 99, 99)
  )
  x <- temp_data
  x$score <- NULL
  y <- temp_data$score
  time1 <- bench::system_time({
    model <- lm(score ~ . - 1, temp_data)
    model$coefficients
  })
  time2 <- bench::system_time({
    ols_result <- get_lin_least_sq_model(x, y, intercept = FALSE)
    ols_result$beta
  })
  expect_true(time2[2] < time1[2])
})

test_that("WLS with x as a data frame, no intercept", {
  temp_data <- data.frame(
    hours=c(1, 1, 2, 2, 2, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 8),
    age=c(3, 6, 7, 2, 4, 5, 6, 3, 4, 5, 2, 2, 4, 5, 9, 8),
    weight=c(23, 12, 31, 24, 56, 23, 12, 23, 34, 35, 36, 14, 23, 11, 13, 56),
    score=c(48, 78, 72, 70, 66, 92, 93, 75, 75, 80, 95, 97, 90, 96, 99, 99)
  )
  x <- temp_data
  x$score <- NULL
  y <- temp_data$score
  model <- lm(score ~ . - 1, temp_data)
  wt <- 1 / lm(abs(model$residuals) ~ model$fitted.values)$fitted.values^2
  model_weighted <- lm(score ~ . - 1, temp_data, weights = wt)
  wls_result <- get_lin_least_sq_model(x, y, intercept = FALSE, weighted = TRUE)
  temp_sum <- sum(abs(model_weighted$coefficients - wls_result$beta) < 0.00001)
  expect_equal(temp_sum, length(wls_result$beta))
  temp_sum <- sum(abs(model_weighted$fitted.values - wls_result$fitted_values) < 0.00001)
  expect_equal(temp_sum, length(wls_result$fitted_values))
  temp_sum <- sum(abs(model_weighted$residuals - wls_result$residuals) < 0.00001)
  expect_equal(temp_sum, length(wls_result$residuals))
})

test_that("WLS with x as a data frame, no intercept - timing", {
  temp_data <- data.frame(
    hours=c(1, 1, 2, 2, 2, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 8),
    age=c(3, 6, 7, 2, 4, 5, 6, 3, 4, 5, 2, 2, 4, 5, 9, 8),
    weight=c(23, 12, 31, 24, 56, 23, 12, 23, 34, 35, 36, 14, 23, 11, 13, 56),
    score=c(48, 78, 72, 70, 66, 92, 93, 75, 75, 80, 95, 97, 90, 96, 99, 99)
  )
  x <- temp_data
  x$score <- NULL
  y <- temp_data$score
  time1 <- bench::system_time({
    model <- lm(score ~ . - 1, temp_data)
    wt <- 1 / lm(abs(model$residuals) ~ model$fitted.values)$fitted.values^2
    model_weighted <- lm(score ~ . - 1, temp_data, weights = wt)
    model_weighted$coefficients
  })
  time2 <- bench::system_time({
    wls_result <- get_lin_least_sq_model(x, y, intercept = FALSE, weighted = TRUE)
    wls_result$beta
  })
  expect_true(time2[2] < time1[2])
})
