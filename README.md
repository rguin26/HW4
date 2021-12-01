# HW4

<!-- badges: start -->
[![R-CMD-check](https://github.com/rguin26/HW4/workflows/R-CMD-check/badge.svg)](https://github.com/rguin26/HW4/actions)

[![codecov](https://codecov.io/gh/rguin26/HW4/branch/main/graph/badge.svg?token=KQI6EF8TYN)](https://codecov.io/gh/rguin26/HW4)
<!-- badges: end -->

This package provides functions for linear least squares regression. It performs both ordinary least squares (OLS) and weighted least squares (WLS), and an option for including an intercept is provided for generating estimates of the beta coefficients, with an intercept included by default. The primary functions for users to utilize in this package are:
  - `get_lin_least_sq_model`
  - `lin_least_squares_train_test`

The functions only work with numeric data, and error warnings are thrown if any non-numeric data is detected.

The methods perform linear least squares using the following known formulas for calculating the Beta coefficients of each method:
  - OLS: <img src="https://render.githubusercontent.com/render/math?math=\hat{\beta} = (X^{T}X)^{-1}X^{T}y">
  - WLS: <img src="https://render.githubusercontent.com/render/math?math=\hat{\beta} = (X^{T}WX)^{-1}X^{T}Wy"> (more info about how the weights are calculated: https://en.wikipedia.org/wiki/Weighted_least_squares)
