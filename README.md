# HW4

<!-- badges: start -->
[![R-CMD-check](https://github.com/rguin26/HW4/workflows/R-CMD-check/badge.svg)](https://github.com/rguin26/HW4/actions)

[![codecov](https://codecov.io/gh/rguin26/HW4/branch/main/graph/badge.svg?token=KQI6EF8TYN)](https://codecov.io/gh/rguin26/HW4)
[![Travis build status](https://travis-ci.com/rguin26/HW4.svg?branch=main)](https://travis-ci.com/rguin26/HW4)
[![Codecov test coverage](https://codecov.io/gh/rguin26/HW4/branch/main/graph/badge.svg)](https://codecov.io/gh/rguin26/HW4?branch=main)
<!-- badges: end -->

## Overview:
This package provides functions for linear least squares regression. It performs both ordinary least squares (OLS) and weighted least squares (WLS), and an option for including an intercept is provided for generating estimates of the beta coefficients, with an intercept included by default. The primary functions for users to utilize in this package are:
  - `get_lin_least_sq_model`
  - `lin_least_squares_train_test`

In general, the method of OLS assumes that there is constant variance in the errors (which is called **homoscedasticity**). The method of WLS can be used when the OLS assumption of constant variance in the errors is violated (which is called **heteroscedasticity**). WLS is particularly ideal for use when there exist outliers in the data. The functions in this package allow a user to specify whether he/she wants to generate a linear least squares model using OLS or WLS. Hence WLS is performed when specified.

The functions only work with numeric data, and error warnings are thrown if any non-numeric data is detected. Errors are also thrown if the size of vectors of predictor variables do not match the size of the vector of target values.

The methods perform linear least squares using the following known formulas for calculating the Beta coefficients of each method:
  - OLS: <img src="https://render.githubusercontent.com/render/math?math=\hat{\beta} = (X^{T}X)^{-1}X^{T}y">
  - WLS: <img src="https://render.githubusercontent.com/render/math?math=\hat{\beta} = (X^{T}WX)^{-1}X^{T}Wy"> (more info about how the weights are calculated: https://online.stat.psu.edu/stat501/lesson/13/13.1)

## Functions:

### get_lin_least_sq_model
The `get_lin_least_sq_model` method is used in the following way: `get_lin_least_sq_model(x, y, intercept = TRUE, weighted = FALSE)`
  - `x` is a matrix, dataframe, or vector of all predictor/predictors and its/their respective values
  - `y` is a vector of target values from the matrix of known predictor values
  - `intercept` is TRUE by default, and it computes the beta coefficients with an intercept included; if it is set to FALSE, then no intercept is used
  - `weighted` is FALSE by default, and it computes the beta coefficients using ordinary least squares (OLS); if it is set to TRUE, then the beta coefficients are calculated using weighted least squares (WLS)

This method returns a list of objects related to the linear least squares method used with the data passed in to it. It is most ideal for viewing the beta coefficients of each predictor in `x` to see how it impacts the average change of the target variable, `y`, for every unit increase in the predictor's value. Also, this method allows a user to view how well a linear least squares regression model was fit given the residuals and evaluation metrics.

The list object returned by this method includes calculations of the estimates for the beta coefficients for each predictor, along with residuals and model evaluation metrics. The specific objects are explained below:
  - `beta`: a vector of beta coefficients, with values corresponding to their respective column in `x`, and starting with (intercept) if `intercept = TRUE`
  - `fitted_values`: vector consisting of the fitted values of the data, `x`, used to build the model, calculated simply as the model's prediction value for each instance in `x`
  - `residuals`: vector consisting of the residuals of each instance in `x`, calculated as the fitted value minus the actual value for each instance in `x`
  - `model_eval_metrics`: vector consisting of evaluation metrics of the model, including sum of squared errors (SSE), mean squared error (MSE), root mean squared error (RMSE), mean absolute error (MAE), r-squared, and adjusted r-squared

### lin_least_squares_train_test
The `lin_least_squares_train_test` method is used in the following way: `lin_least_squares_train_test(x, y, intercept = TRUE, weighted = FALSE, train_set_prop = 0.8)`
  - `x` is a matrix, dataframe, or vector of all predictor/predictors and its/their respective values
  - `y` is a vector of target values from the matrix of known predictor values
  - `intercept` is TRUE by default, and it computes the beta coefficients with an intercept included; if it is set to FALSE, then no intercept is used
  - `weighted` is FALSE by default, and it computes the beta coefficients using ordinary least squares (OLS); if it is set to TRUE, then the beta coefficients are calculated using weighted least squares (WLS)
  - `train_set_prop` is set to 0.8 by default, and it randomly selects this proportion of instances from `x` and `y`, of identical indexes, to use for training the linear least squares model, and then it uses the remaining instances of `x` and `y` for testing the model

This particular method works similarly to the `get_lin_least_sq_model` method, only it divides the data passed in to it into two subsets. One of the subsets is used for training the model, in other words it generates the beta coefficients assosciated with that specific subset of the original data. The other subset is then used to test the model, as it is previously unseen data which was not used for creating the model. The method is most ideal for viewing the beta coefficients of each predictor in the training subset of `x` and `y`, and then evaluating how well it predicts unseen data. This method returns a list of objects related to the linear least squares method used with the training and testing subsets of the data passed in to it. 

The list object returned by this method includes calculations of the estimates for the beta coefficients for each predictor, when trained with the training subset, along with residuals and model evaluation metrics of both the training and testing subsets. The specific objects are explained below:
  - `beta`: a vector of beta coefficients generated using the training subset of the initial data with values corresponding to their respective column in `x`, and starting with (intercept) if `intercept = TRUE`
  - `training_fitted_values`: a vector consisting of the training fitted values of the training subset of `x` used to build the model, calculated simply as the model's prediction value for each instance in the training subset
  - `training_residuals`: a vector consisting of the residuals of each instance in the training subset of `x`, calculated as the training fitted value minus the actual value for each instance in the training subset of `x`
  - `training_model_eval_metrics`: a vector consisting of the training subset's evaluation metrics of the model, including sum of squared errors (SSE), mean squared error (MSE), root mean squared error (RMSE), mean absolute error (MAE), r-squared, and adjusted r-squared
  - `testing_fitted_values`: a vector consisting of the testing fitted values of the testing subset of `x`, calculated simply as the model's prediction value for each instance in the testing subset
  - `testing_residuals`: a vector consisting of the residuals of each instance in the testing subset of `x`, calculated as the testing fitted value minus the actual value for each instance in the testing subset of `x`
  - `testing_model_eval_metrics`: vector consisting of the testing subset's evaluation metrics of the model, including sum of squared errors (SSE), mean squared error (MSE), root mean squared error (RMSE), mean absolute error (MAE), r-squared, and adjusted r-squared

## Installation:

To install and load this specific GitHub R package, library `devtools` needs to be installed first. The following script should help to get this R package installed and loaded successfully:

```
# Install "devtools" first if it is not already installed
install.packages("devtools")

# Once the "devtools" package has been properly installed, load it
library("devtools")

# Install this package
install_github("rguin26/HW4")

# Finally, load the package, and one should be able to use all the primary functions and view their documentation/help pages
library(HW4)
```

## Usage:

The primary functions of this package can be used with real data or synthetic data. Provided below are some basic examples, using randomly selected data, about how these functions can be properly used. As mentioned before, `x` can be either a vector (for simple linear regression), a matrix, or a dataframe, and the different examples for the `get_lin_least_sq_model` function point that out. Also, one can get results for any of the possible cases:
  - OLS
  - WLS
  - OLS, no intercept
  - WLS, no intercept

To view the specific features of the list object returned for each case, use the `$` symbol to access each of the different features, e.g. "beta", "fitted_values", etc.

Note: all data, `x` and `y`, has to be prepared beforehand, prior to passing them into either the `get_lin_least_sq_model` or the `lin_least_squares_train_test` function.

```
# Example 1 - get_lin_least_sq_model
x <- sample(100, 30, replace=FALSE)
y <- sample(100, 30, replace=TRUE)
ols_result <- get_lin_least_sq_model(x, y)
wls_result <- get_lin_least_sq_model(x, y, weighted = TRUE)
ols_result_no_intercept <- get_lin_least_sq_model(x, y, intercept = FALSE)
wls_result_no_intercept <- get_lin_least_sq_model(x, y, intercept = FALSE, weighted = TRUE)


# Example 2 - get_lin_least_sq_model
x <- matrix(sample(1000, 30*5, replace=FALSE), ncol = 5)
y <- sample(100, 30, replace=TRUE)
ols_result <- get_lin_least_sq_model(x, y)
wls_result <- get_lin_least_sq_model(x, y, weighted = TRUE)
ols_result_no_intercept <- get_lin_least_sq_model(x, y, intercept = FALSE)
wls_result_no_intercept <- get_lin_least_sq_model(x, y, intercept = FALSE, weighted = TRUE)


# Example 3 - get_lin_least_sq_model
temp_data <- data.frame(
  hours=c(1, 1, 2, 2, 2, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 8),
  age=c(3, 6, 7, 2, 4, 5, 6, 3, 4, 5, 2, 2, 4, 5, 9, 8),
  weight=c(23, 12, 31, 24, 56, 23, 12, 23, 34, 35, 36, 14, 23, 11, 13, 56),
  score=c(48, 78, 72, 70, 66, 92, 93, 75, 75, 80, 95, 97, 90, 96, 99, 99)
)
x <- temp_data
x$score <- NULL
y <- temp_data$score
ols_result <- get_lin_least_sq_model(x, y)
wls_result <- get_lin_least_sq_model(x, y, weighted = TRUE)
ols_result_no_intercept <- get_lin_least_sq_model(x, y, intercept = FALSE)
wls_result_no_intercept <- get_lin_least_sq_model(x, y, intercept = FALSE, weighted = TRUE)


# Example - lin_least_squares_train_test
x <- data.frame(matrix(sample(100000, 200*5, replace=TRUE), ncol = 5))
y <- sample(100, 200, replace=TRUE)
model_stats <- lin_least_squares_train_test(x, y)
model_stats$beta
model_stats$training_model_eval_metrics
model_stats$testing_model_eval_metrics
```
