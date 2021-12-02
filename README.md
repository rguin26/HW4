# HW4

<!-- badges: start -->
[![R-CMD-check](https://github.com/rguin26/HW4/workflows/R-CMD-check/badge.svg)](https://github.com/rguin26/HW4/actions)

[![codecov](https://codecov.io/gh/rguin26/HW4/branch/main/graph/badge.svg?token=KQI6EF8TYN)](https://codecov.io/gh/rguin26/HW4)
<!-- badges: end -->

## Overview:
This package provides functions for linear least squares regression. It performs both ordinary least squares (OLS) and weighted least squares (WLS), and an option for including an intercept is provided for generating estimates of the beta coefficients, with an intercept included by default. The primary functions for users to utilize in this package are:
  - `get_lin_least_sq_model`
  - `lin_least_squares_train_test`

The functions only work with numeric data, and error warnings are thrown if any non-numeric data is detected. Errors are also thrown if the size of vectors of predictor variables do not match the size of the vector of target values.

The methods perform linear least squares using the following known formulas for calculating the Beta coefficients of each method:
  - OLS: <img src="https://render.githubusercontent.com/render/math?math=\hat{\beta} = (X^{T}X)^{-1}X^{T}y">
  - WLS: <img src="https://render.githubusercontent.com/render/math?math=\hat{\beta} = (X^{T}WX)^{-1}X^{T}Wy"> (more info about how the weights are calculated: https://online.stat.psu.edu/stat501/lesson/13/13.1)

## Functions:

The `get_lin_least_sq_model` method is used in the following way: `get_lin_least_sq_model(x, y, intercept = TRUE, weighted = FALSE)`
  - `x` is a matrix, dataframe, or vector of all predictor/predictors and its/their respective values
  - `y` is a vector of target values from the matrix of known predictor values
  - `intercept` is TRUE by default, and it computes the beta coefficients with an intercept included; if it is set to FALSE, then no intercept is used
  - `weighted` is FALSE by default, and it computes the beta coefficients using ordinary least squares (OLS); if it is set to TRUE, then the beta coefficients are calculated using weighted least squares (WLS)

This particular method returns a list of objects related to the linear least squares method used with the data passed in to it. It is most ideal for viewing the beta coefficients of each predictor in `x` to see how it impacts the average change of the target variable, `y`, for every unit increase in the predictor's value. Also, this method allows a user to view how well a linear least squares regression model was fit given the residuals and evaluation metrics. The list object returned by this method includes calculations of the estimates for the beta coefficients for each predictor, along with residuals and model evaluation metrics. The specific objects are explained below:
  - `beta`: a vector of beta coefficients, with values corresponding to their respective column in `x`, and starting with (intercept) if `intercept = TRUE`
  - `fitted_values`: vector consisting of the fitted values of the data, `x`, used to build the model, calculated simply as the model's prediction value for each instance in `x`
  - `residuals`: vector consisting of the residuals of each instance in `x`, calculated as the fitted value minus the actual value for each instance in `x`
  - `model_eval_metrics`: vector consisting of evaluation metrics of the model, including sum of squared errors (SSE), mean squared error (MSE), root mean squared error (RMSE), mean absolute error (MAE), r-squared, and adjusted r-squared

## Installation:

To install and load this specific GitHub hosted R package, you need to install and load the library `devtools` first. The following script should help to get this R package installed and loaded successfully:

`# Install "devtools" first if it is not already installed`
`install.packages("devtools")`
``
`# Once the "devtools" package has been properly installed, load it`
`library("devtools")`
``
`# Install this package`
`install_github("rguin26/HW4")`
``
`# Finally, load the package, and you should be able to use all the primary functions and view their documentation/help pages`
`library(HW4)`

## Usage:
