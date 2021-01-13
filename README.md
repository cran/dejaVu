# dejaVu

[![Build Status](https://travis-ci.org/jwb133/dejaVu.svg?branch=master)](https://travis-ci.org/jwb133/dejaVu)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/dejaVu)](https://cran.r-project.org/package=dejaVu)
[![CRAN RStudio mirror downloads](https://cranlogs.r-pkg.org/badges/dejaVu)](https://cran.r-project.org/package=dejaVu)
[![CRAN RStudio mirror downloads](https://cranlogs.r-pkg.org/badges/grand-total/dejaVu)](https://cran.r-project.org/package=dejaVu)


Multiple Imputation for Recurrent Event Endpoints in Clinical Trials

The dejaVu package performs multiple imputation on recurrent event data sets,
following the approach described by [Keene et al](https://doi.org/10.1002/pst.1624). The 
package can be used to perform multiple imputation of an existing study dataset 
where some patients dropped out. Imputation can be performed either assuming 
dropout is at random (missing at random) or assuming a specific non-random dropout 
mechanism (missing not at random). The package can also be used to simulate 
recurrent event datasets, in order to evaluate the impact of dropout and the 
properties of multiple imputation based analyses. Finally, the imputed data sets 
can be analysed and their results combined using Rubin’s rules.

## Contributors

Bartlett, Jonathan (maintainer); Burkoff, Nikolas; Metcalfe, Paul; Ruau, David;

## Installation

To install the development version from GitHub:
```R
install.packages("devtools")
# We spent a lot of time developing the vignettes. We recommend reading them but 
# building them from source takes some time
devtools::install_github("jwb133/dejaVu", 
                         build_vignettes = TRUE)
```
