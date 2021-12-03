#' @name lin_least_squares_train_test
#' @aliases lin_least_squares_train_test
#' @title lin_least_squares_train_test
#'
#' @description
#' Performs linear regression using ordinary least squares (OLS) or weighted
#' least squares (WLS), with either an intercept included or not, for only a
#' portion of the total number of instances provided. The remaining instances
#' are set aside for testing. This works with both simple and multiple linear
#' regression. It calculates the beta coefficients of the least squares linear
#' regression equation that is generated with the training set, and then it
#' passes the testing set instances to generate predictions of that data which
#' was previously unknown during the model training stage.
#'
#' @usage lin_least_squares_train_test(x, y, intercept = TRUE, weighted = FALSE, train_set_prop = 0.8)
#'
#' @param x matrix, dataframe, or vector of all predictor/predictors and
#' its/their respective values
#' @param y vector of target values from the matrix of known predictor values
#' @param intercept TRUE by default, it computes the beta coefficients with an
#' intercept included; if it is set to FALSE, then no intercept is used
#' @param weighted FALSE by default, it computes the beta coefficients using
#' ordinary least squares (OLS); if it is set to TRUE, then the beta
#' coefficients are calculated using weighted least squares (WLS)
#' @param train_set_prop set to 0.8 by default, it randomly selects this
#' proportion of instances from x and y, of identical indexes, to use for
#' training the linear least squares model, and then it uses the remaining
#' instances of x and y for testing the model
#'
#' @details works only with numeric data
#'
#' @return A list of objects, including calculations of the estimates for the
#' beta coefficients for each predictor, along with residuals and model
#' evaluation metrics for both the training and testing sets
#' \itemize{
#'   \item beta - vector of beta coefficients generated using the training
#'   subset of the initial data with values corresponding to their respective
#'   column in x, and starting with (intercept) if intercept = TRUE
#'   \item training_fitted_values - vector consisting of the training fitted
#'   values of the training subset of x used to build the model, calculated
#'   simply as the model's prediction value for each instance in the training
#'   subset
#'   \item training_residuals - vector consisting of the residuals of each
#'   instance in the training subset of x, calculated as the training fitted
#'   value minus the actual value for each instance in the training subset of x
#'   \item training_model_eval_metrics - vector consisting of the training
#'   subset's evaluation metrics of the model, including sum of squared errors
#'   (SSE), mean squared error (MSE), root mean squared error (RMSE), mean
#'   absolute error (MAE), r-squared, and adjusted r-squared
#'   \item testing_fitted_values - vector consisting of the testing fitted
#'   values of the testing subset of x, calculated simply as the model's
#'   prediction value for each instance in the testing subset
#'   \item testing_residuals - vector consisting of the residuals of each
#'   instance in the testing subset of x, calculated as the testing fitted value
#'   minus the actual value for each instance in the testing subset of x
#'   \item testing_model_eval_metrics - vector consisting of the testing
#'   subset's evaluation metrics of the model, including sum of squared errors
#'   (SSE), mean squared error (MSE), root mean squared error (RMSE), mean
#'   absolute error (MAE), r-squared, and adjusted r-squared
#' }
#'
#' @export
#'
#' @examples
#' # Example 1
#' x <- data.frame(matrix(sample(100000, 200*5, replace=TRUE), ncol = 5))
#' y <- sample(100, 200, replace=TRUE)
#' model_stats <- lin_least_squares_train_test(x, y)
#' model_stats$beta
#' model_stats$training_model_eval_metrics
#' model_stats$testing_model_eval_metrics
#'

## If the `Rcpp` library is not yet installed, uncomment and run the command below to install it
# install.packages("Rcpp")
library(Rcpp)

####################
# Primary function #
lin_least_squares_train_test <- function(x, y, intercept = TRUE, weighted = FALSE, train_set_prop = 0.8) {
  x <- preprocess_data(x)
  if (is.numeric(y) == FALSE) {
    stop("non-numeric values detected in y")
  }
  num_features <- ncol(x)
  smp_size <- floor(train_set_prop * nrow(x))
  train_ind <- sample(seq_len(nrow(x)), size = smp_size)
  train_x <- x[train_ind,]
  train_y <- y[train_ind]
  test_x <- x[-train_ind,]
  test_y <- y[-train_ind]
  trained_model <- get_lin_least_sq_model(train_x, train_y)
  if (intercept == TRUE) {
    test_x <- cbind("(intercept)"=rep(1, length(test_x[,1])), test_x)
  }
  test_fitted_values <- get_fitted_values(trained_model$beta, test_x)
  test_fitted_values <- test_fitted_values[,1]
  test_residuals <- get_residuals(test_fitted_values, test_y)
  test_r_sq <- get_sse_and_r_squared(test_residuals, test_y, ncol(x), length(test_y))
  testing_model_eval_metrics = c(
    "testing_SSE" = test_r_sq$SSE,
    "testing_MSE" = test_r_sq$SSE / (length(test_y) - num_features - 1),
    "testing_RMSE" = sqrt(test_r_sq$SSE / (length(test_y) - num_features - 1)),
    "testing_MAE" = sum(abs(test_residuals)) / (length(test_y) - num_features - 1),
    "testing_r_squared" = test_r_sq$r_squared,
    "testing_adjusted_r_squared" = test_r_sq$adjusted_r_squared
  )
  return(list("beta" = trained_model$beta,
              "training_fitted_values" = trained_model$fitted_values,
              "training_residuals" = trained_model$residuals,
              "training_model_eval_metrics" = trained_model$model_eval_metrics,
              "testing_fitted_values" = test_fitted_values,
              "testing_residuals" = test_residuals,
              "testing_model_eval_metrics" = testing_model_eval_metrics))
}

####################
# Helper functions #
preprocess_data <- function(x) {
  if (is.matrix(x) == FALSE) {
    if (is.data.frame(x) == TRUE) {
      x <- data.matrix(x)
    } else {
      x <- matrix(x, ncol = 1, nrow = length(x))
    }
  }
  if (is.numeric(x) == FALSE) {
    stop("non-numeric values detected in x")
  }
  return (x)
}

get_fitted_values <- function(beta, x) {
  if ((length(beta) < ncol(x)) | (length(beta) > (ncol(x) + 1))) {
    stop("the number of columns in x must be equal to or 1 greater than the number of elements in beta")
  }
  if ((ncol(x) + 1) == length(beta)) {
    x <- cbind(rep(1, length(x[,1])), x)
  }
  fitted_values <- x %*% beta
  return(fitted_values)
}

cppFunction('
  NumericVector get_residuals(const NumericVector fitted_values, const NumericVector y){
    if (fitted_values.length() != y.length()) stop ("vectors must be of same length");
    return y - fitted_values;
  }
')

get_sse_and_r_squared <- function(residuals, y, num_features, n, weights = NULL) {
  r_squared <- 0
  adjusted_r_squared <- 0
  sse <- 0
  sst <- 0
  if (is.null(weights)) {
    sse <- sum(residuals^2)
    sst <- sum((y - mean(y))^2)
  } else {
    sse <- sum(weights * residuals^2)
    sst <- sum(weights * (y - weighted.mean(y, weights))^2)
  }
  r_squared <- 1 - (sse / sst)
  adjusted_r_squared <- 1 - (((1 - r_squared) * (n - 1)) / (n - num_features - 1))
  return(list("SSE" = sse,
              "r_squared" = r_squared,
              "adjusted_r_squared" = adjusted_r_squared))
}

get_ols_lin_model <- function(x, y, num_features, n) {
  xTx_inv <- solve(t(x) %*% x)
  xTy <- t(x) %*% y
  beta <- xTx_inv %*% xTy
  beta <- beta[,1]
  fitted_values <- get_fitted_values(beta, x)
  residuals <- get_residuals(fitted_values, y)
  r_sq <- get_sse_and_r_squared(residuals, y, num_features, n)
  return(list("beta" = beta,
              "fitted_values" = fitted_values[,1],
              "residuals" = residuals,
              "model_eval_metrics" = c(
                "SSE" = r_sq$SSE,
                "MSE" = r_sq$SSE / (n - num_features - 1),
                "RMSE" = sqrt(r_sq$SSE / (n - num_features - 1)),
                "MAE" = sum(abs(residuals)) / (n - num_features - 1),
                "r_squared" = r_sq$r_squared,
                "adjusted_r_squared" = r_sq$adjusted_r_squared)))
}

get_wls_lin_model <- function(x, y, num_features, n) {
  beta <- get_ols_lin_model(x, y, num_features, n)$beta
  fitted_values <- get_fitted_values(beta, x)
  abs_residuals <- abs(get_residuals(fitted_values, y))
  fitted_values <- cbind(rep(1, length(fitted_values)), fitted_values)
  fitted_valuesTfitted_values_inv <- solve(t(fitted_values) %*% fitted_values)
  fitted_valuesTabs_residuals <- t(fitted_values) %*% abs_residuals
  beta_resid <- fitted_valuesTfitted_values_inv %*% fitted_valuesTabs_residuals
  new_fitted_values <- (fitted_values %*% beta_resid)^2
  wt <- 1 / new_fitted_values
  weights <- matrix(0, ncol = length(y), nrow = length(y))
  diag(weights) <- wt
  xTx_inv_weighted <- solve(t(x) %*% weights %*% x)
  xTy_weighted <- t(x) %*% weights %*% y
  beta <- xTx_inv_weighted %*% xTy_weighted
  beta <- beta[,1]
  fitted_values <- get_fitted_values(beta, x)
  residuals <- get_residuals(fitted_values, y)
  r_sq <- get_sse_and_r_squared(residuals, y, num_features, n, weights = wt)
  return(list("beta" = beta,
              "fitted_values" = fitted_values[,1],
              "residuals" = residuals,
              "model_eval_metrics" = c(
                "SSE" = r_sq$SSE,
                "MSE" = r_sq$SSE / (n - num_features - 1),
                "RMSE" = sqrt(r_sq$SSE / (n - num_features - 1)),
                "MAE" = sum(abs(residuals)) / (n - num_features - 1),
                "r_squared" = r_sq$r_squared,
                "adjusted_r_squared" = r_sq$adjusted_r_squared)))
}

get_lin_least_sq_model <- function(x, y, intercept = TRUE, weighted = FALSE) {
  x <- preprocess_data(x)
  if (is.numeric(y) == FALSE) {
    stop("non-numeric values detected in y")
  }
  if (length(x[,1]) != length(y)) {
    stop("the number of instances in y is not equal to that of the predictor variables")
  }
  num_features <- ncol(x)
  n <- length(y)
  if (intercept == TRUE) {
    x <- cbind("(intercept)"=rep(1, length(x[,1])), x)
  }
  if (weighted == FALSE) {
    return(get_ols_lin_model(x, y, num_features, n))
  } else {
    return(get_wls_lin_model(x, y, num_features, n))
  }
}
