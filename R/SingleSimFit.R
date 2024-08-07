##' SingleSimFit object
##'  
##' 
##' A \code{SingleSimFit} object is returned from calling \code{Simfit} with
##' a \code{SingleSim object}. It can be used to both impute data sets or can be summarized 
##' 
##' A \code{\link{summary.SingleSimFit}} method has been implemented
##' 
##' @param singleSim The \code{SingleSim} object to which a model has been fitted
##' @param model The model which has been fitted
##' @param genCoeff.function A function which returns a list of parameters from the model fit(s) which can 
##' be used when performing the gamma imputation. It takes one argument, use.uncertainty (by default is TRUE) which
##' if TRUE stochastically incorporates uncertainty into the parameter estimates in preparation for use with imputation 
##' If a Poisson/quasi-Poisson model was fitted to the \code{SingleSimFit} object
##' then this will be NULL
##' @param equal dispersion whether equal dispersions were used when fitting model(s) to the data
##' @name SingleSimFit.object
NULL


##' summary.SingleSimFit
##' 
##' The summary object for a \code{SingleSimFit} object
##' 
##' A \code{print.summary.SingleSimFit} method has been implemented
##' 
##' @param model.summary The model summary from the fit
##' @param treatment.effect The estimate of treatment effect from the model fit
##' @param CI.limit The confidence interval limit (by default 0.95), call \code{summary(object,CI.limit=x)} to use
##' CI of \code{x} instead.
##' @param CI The confidence interval of the treatment effect
##' @param se Estimate for the standard error of (log) treatment effect 
##' @param dispersion Estimate for the dispersion parameter or numeric(0) if Poisson/quasi-Poisson model used
##' @param rate.estimate Estimate of the event rates from the model a vector c(control arm, treatment arm)         
##' @param pval The p value directly from the model fit (this is for the single model fit only, i.e. not using Rubin's formula)
##' @param datastatus The status of SingleSim object to which the fit was applied
##' @param df The number of degrees of freedom of the model
##' @param dropout The number of dropouts of each arm
##' @param number.subjects The number of subjects in each arm
##' @seealso \code{\link{SingleSimFit.object}}
##' @name summary.SingleSimFit
##' @examples
##' sim <- SimulateComplete(study.time=365,number.subjects=50,
##' event.rates=c(0.01,0.005),dispersions=0.25)
##' fit <- Simfit(sim)
##' summary(fit)

NULL

##' @export
summary.SingleSimFit <- function(object,CI.limit=0.95,...){
  if(!object$equal.dispersion){
    stop("Cannot generate a summary if equal.dispersion is FALSE")
  }  

  if(!.internal.is.finite.number(CI.limit) || CI.limit <= 0 || CI.limit >= 1){
    stop("Invalid argument CI.limit")
  } 
   
  model.summary <- summary(object$model)
  dropout <- summary(object$singleSim)$number.dropouts
  
  retVal <- list(model.summary=model.summary,
                 treatment.effect=exp(model.summary$coefficient[2,1]),
                 CI.limit=CI.limit,
                 CI=exp(model.summary$coefficient[2,1]+ c(-1,1)*qnorm(1-(1-CI.limit)/2)*model.summary$coefficient[2,2]),
                 se=model.summary$coefficient[2,2], 
                 dispersion=1/model.summary$theta, #only if negative binomial
                 rate.estimate=exp(model.summary$coefficient[1,1])*c(1,exp(model.summary$coefficient[2,1])),         
                 pval=model.summary$coefficient[2,4],
                 datastatus=object$singleSim$status,
                 df=object$model$df.residual,
                 dropout=dropout,
                 number.subjects=subjectsPerArm(object))
  
  class(retVal) <- "summary.SingleSimFit"
  retVal
}

##' @export
print.summary.SingleSimFit <- function(x,...){
  cat("Summary for model fit for",x$datastatus,"data set",fill = TRUE)
  cat("Treatment Effect:",x$treatment.effect,fill=TRUE)
  cat("SE (log) treatment effect:",x$se,fill=TRUE)
  cat(x$CI.limit*100,"% CI: [",x$CI[1],", ",x$CI[2],"]", sep="",fill=TRUE)
  cat("Rate Estimates (per arm):",x$rate.estimate,fill=TRUE)
  cat("Negative binomial dispersion model parameter:",if(length(x$dispersion)==0) "NA" else x$dispersion ,fill=TRUE)
  cat("p-value:",x$pval,fill=TRUE)
  cat("Note p-value is associated with this individual data set\n")
}


##' Produce imputed data sets
##' 
##' Given a \code{SingleSimFit} object (with impute.parameters not NULL)
##' and an imputation mechanism,
##' create a collection of imputed data sets 
##' 
##' @param fit A \code{SingleSimFit} object
##' @param impute.mechanism An \code{ImputeMechanism} object
##' @param N The number of data sets to impute
##' @return An \code{ImputeSim} object
##' 
##' @examples 
##' sim <- SimulateComplete(study.time=365,number.subjects=50,
##'     event.rates=c(0.01,0.005),dispersions=0.25)
##' sim.with.MCAR.dropout <- SimulateDropout(sim,
##'     drop.mechanism = ConstantRateDrop(rate = 0.0025))
##' fit <- Simfit(sim.with.MCAR.dropout)
##' imps <- Impute(fit, copy_reference(), 10)
##' 
##' @export
Impute <- function(fit,impute.mechanism,N){
  validateImputeArguments(fit,impute.mechanism,N)

  retVal <- list(singleSim=fit$singleSim,
                 impute.mechanism=impute.mechanism,
                 imputed.values=replicate(n=N, impute.mechanism$impute(fit),simplify="list"))
  retVal$dropout <- summary(fit$singleSim)$number.dropouts
  class(retVal) <- "ImputeSim"
  return(retVal)
}

##' @export
subjectsPerArm.SingleSimFit <- function(x){
  subjectsPerArm(x$singleSim)
}

# check the arguments to Impute function are valid
validateImputeArguments <- function(fit,impute.mechanism,N){
  
  if(inherits(fit,"SingleSimFit")==FALSE){
    stop("Invalid fit argument, must be of class SingleSimFit")
  }
  
 if(is.null(fit$genCoeff.function)){
    stop("Cannot impute using this SingleSimFit object (a negative binomial model was not fit)")
  }
  
  if(inherits(impute.mechanism,"ImputeMechanism")==FALSE){
    stop("Invalid impute.mechanism argument, must one of class ImputeMechanism")
  }
  
  if(!.internal.is.finite.number(N) || N <= 0 || !.internal.is.wholenumber(N)){
    stop("Invalid argument N, must be positive integer")
  }
  
  
  if(!all(impute.mechanism$cols.needed %in% colnames(fit$singleSim$data))){
    stop("This impute mechanism requires ",paste(impute.mechanism$cols.needed,collapse=", "),
         "as column names in the simulated data frame")
  }
}
