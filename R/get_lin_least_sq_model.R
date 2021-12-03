#' @name get_lin_least_sq_model
#' @aliases get_lin_least_sq_model
#' @title get_lin_least_sq_model
#'
#' @description
#' Performs linear regression using ordinary least squares (OLS) or weighted
#' least squares (WLS), with either an intercept included or not. This works
#' with both simple and multiple lienar regression. It calculates and returns
#' the beta coefficients of the least squares linear regression equation,
#' residuals, as well as model evaluation metrics including sum of squared
#' errors (SSE), mean squared error (MSE), root mean squared error (RMSE), mean
#' absolute error (MAE), r-squared, and adjusted r-squared
#'
#' @usage get_lin_least_sq_model(x, y, intercept = TRUE, weighted = FALSE)
#'
#' @param x matrix, dataframe, or vector of all predictor/predictors and
#' its/their respective values
#' @param y vector of target values from the matrix of known predictor values
#' @param intercept TRUE by default, it computes the beta coefficients with an
#' intercept included; if it is set to FALSE, then no intercept is used
#' @param weighted FALSE by default, it computes the beta coefficients using
#' ordinary least squares (OLS); if it is set to TRUE, then the beta
#' coefficients are calculated using weighted least squares (WLS)
#'
#' @details works only with numeric data
#'
#' @return A list of objects, including calculations of the estimates for the
#' beta coefficients for each predictor, along with residuals and model
#' evaluation metrics
#' \itemize{
#'   \item beta - vector of beta coefficients, with values corresponding to
#'   their respective column in x, and starting with (intercept) if
#'   intercept = TRUE
#'   \item fitted_values - vector consisting of the fitted values of the data,
#'   x, used to build the model, calculated simply as the model's prediction
#'   value for each instance in x
#'   \item residuals - vector consisting of the residuals of each instance in x,
#'   calculated as the fitted value minus the actual value for each instance in
#'   x
#'   \item model_eval_metrics - vector consisting of evaluation metrics of the
#'   model, including sum of squared errors (SSE), mean squared error (MSE),
#'   root mean squared error (RMSE), mean absolute error (MAE), r-squared, and
#'   adjusted r-squared
#' }
#'
#' @examples
#' # Example 1
#' x <- sample(100, 30, replace=FALSE)
#' y <- sample(100, 30, replace=TRUE)
#' ols_result <- get_lin_least_sq_model(x, y)
#' wls_result <- get_lin_least_sq_model(x, y, weighted = TRUE)
#' ols_result_no_intercept <- get_lin_least_sq_model(x, y, intercept = FALSE)
#' wls_result_no_intercept <- get_lin_least_sq_model(x, y, intercept = FALSE, weighted = TRUE)
#'
#' # Example 2
#' x <- matrix(sample(1000, 30*5, replace=FALSE), ncol = 5)
#' y <- sample(100, 30, replace=TRUE)
#' ols_result <- get_lin_least_sq_model(x, y)
#' wls_result <- get_lin_least_sq_model(x, y, weighted = TRUE)
#' ols_result_no_intercept <- get_lin_least_sq_model(x, y, intercept = FALSE)
#' wls_result_no_intercept <- get_lin_least_sq_model(x, y, intercept = FALSE, weighted = TRUE)
#'
#' # Example 3
#' temp_data <- data.frame(
#'   hours=c(1, 1, 2, 2, 2, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 8),
#'   age=c(3, 6, 7, 2, 4, 5, 6, 3, 4, 5, 2, 2, 4, 5, 9, 8),
#'   weight=c(23, 12, 31, 24, 56, 23, 12, 23, 34, 35, 36, 14, 23, 11, 13, 56),
#'   score=c(48, 78, 72, 70, 66, 92, 93, 75, 75, 80, 95, 97, 90, 96, 99, 99)
#' )
#' x <- temp_data
#' x$score <- NULL
#' y <- temp_data$score
#' ols_result <- get_lin_least_sq_model(x, y)
#' wls_result <- get_lin_least_sq_model(x, y, weighted = TRUE)
#' ols_result_no_intercept <- get_lin_least_sq_model(x, y, intercept = FALSE)
#' wls_result_no_intercept <- get_lin_least_sq_model(x, y, intercept = FALSE, weighted = TRUE)
#'
#' #'@export
#'

## If the `Rcpp` library is not yet installed, uncomment and run the command below to install it
# install.packages("Rcpp")
library(Rcpp)

####################
# Primary function #
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
