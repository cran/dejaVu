% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/common.R
\name{subjectsPerArm}
\alias{subjectsPerArm}
\title{S3 generic to output the number of subjects in each arm for a given object}
\usage{
subjectsPerArm(x)
}
\arguments{
\item{x}{The object}
}
\value{
A vector of the number of subjects in each arm
}
\description{
S3 generic to output the number of subjects in each arm for a given object
}
\examples{
sim <- SimulateComplete(study.time=365,number.subjects=50,
event.rates=c(0.01,0.005),dispersions=0.25)
subjectsPerArm(sim)
}
