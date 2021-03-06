#' A Reference Class for fitting a discrete time first Difference Correlated Random Walk model.
#'
#' The reference class implements a discrete time first Difference Correlated Random Walk (Jonsen et al. 2005). The locations are modelled by
#' \deqn{X_t = X_{t-\Delta} + \gamma T(\phi) (X_t - X_{t-\Delta}) + \epsilon_t}
#' Here, \eqn{\epsilon_t} is zero mean Gaussian noise with covariance \eqn{ \pmatrix{ \sigma_1^2 & \rho\sigma_1\sigma_2 \cr \rho\sigma_1\sigma_2 & \sigma_2^2 }}. \eqn{T(\phi)} is the rotation matrix \eqn{ \pmatrix{ \cos(\phi) & -\sin(\phi) \cr \sin(\phi) & \cos(\phi) }}. \eqn{\gamma} is a scalar.
#' 
#' @seealso \link{Movement-class} \link{DCRW}
#'
#' @family "Movement models"
#'
#'
#' @references
#' Jonsen, I., J. Mills Flemming, and R. Myers. (2005) Robust state-space modeling of animal movement data. Ecology 86, 2874-2880.
#' 
#' @importFrom methods setRefClass new 
#' @exportClass DCRW
setRefClass("DCRW",
                  contains = "Movement",
                  methods = list(
                      copy = function (shallow = FALSE) 
                      {
                          value <- callSuper(shallow = shallow)
                          value
                      },
                      initialize = function(dates,
                                            pars = numeric(3),
                                            varPars = numeric(2),
                                            nauticalStates = FALSE,
                                            timeunit = "hours"
                                            ){
                          "Method to initialize the class. 'dates' is a vector of distinct and equidistant POSIXct dates; 'pars' is vector of the movement parameters: \\eqn{logit_{(0,1)}(\\gamma)}, \\eqn{\\phi}, \\eqn{logit_{(-1,1)}(\\rho)}; 'varPars' is a vector of movement variance parameters: \\eqn{log(\\sigma_{lat})}, \\eqn{log(\\sigma_{lat})}; 'nauticalStates' is a logical value indicating whether the states should be modelled in nautical miles, and 'timeunit' is the time unit to use for calculating time steps."
###############
## Do checks ##
###############
                          
                          if(!(length(timeunit == 1) &&
                               timeunit %in% c("auto", "secs", "mins", 
                                               "hours", "days", "weeks")))
                              stop("timeunit must be one of: 'auto', 'secs', 'mins', 'hours', 'days', 'weeks'.")
                          if(!is.POSIXct(dates))
                              stop("dates must be a POSIXct class.")
                          dt0 <- as.numeric(difftime(tail(dates,-1),
                                                     head(dates,-1),
                                                     units = timeunit))
                          if(!(all(round(dt0,7) == round(dt0[1],7))))
                              stop("Dates must be equidistant.")
                          if(!(length(pars)==3 && is.numvec(pars)))
                              stop("pars must be a numeric vector of length 3.")
                          if(!(length(varPars)==2 && is.numvec(varPars)))
                              stop("varPars must be a numeric vector of length 2.")
                          if(!(length(nauticalStates)==1 && is.logical(nauticalStates)))
                              stop("nauticalStates must be logical.")
                          

################
## initFields ##
################
                          
                          initFields(model = "first Differenced Correlated Random Walk (DCRW)",
                                     dates = dates,
                                     parameters = pars,
                                     varianceParameters = varPars,
                                     mu = matrix(0,2,length(dates)),
                                     vel = matrix(0,0,0),
                                     sdmu = matrix(NA,2,length(dates)),
                                     sdvel = matrix(0,0,0),
                                     nauticalStates = nauticalStates,
                                     vcov = diag(Inf,0),
                                     timeunit = timeunit,
                                     data = list(),
                                     options = list(moveModelCode = 3,
                                                    parnames = c("logit[0,1](gamma)","phi","logit[-1,1](rho)"),
                                                    varparnames = c("log(sigma_lat)","log(sigma_lon)"))
                                     )


                      },
                      simulate = function(x0 = c(0,0)){
                          "Function to simulate from the movement model. The initial states (latitudinal/y-coordinate location and longitudinal/x-coordinate location) must be given. If nauticalStates==TRUE, the result is returned in nautical miles."
                          gamma <- 1/(1+exp(-.self$parameters[1]))
                          rho <- 2/(1+exp(-.self$parameters[3])) - 1.0
                          phi <- .self$parameters[2]
                          cov <- matrix(c(exp(2*.self$varianceParameters[1]),
                                         rho * exp(sum(.self$varianceParameters)),
                                         rho * exp(sum(.self$varianceParameters)),
                                         exp(2*.self$varianceParameters[2])),2,2)
                          R <- matrix(c(cos(phi),sin(phi),-sin(phi),cos(phi)),2,2)
                                      
                          X <- matrix(NA,2,length(.self$dates))
                          X[,1] <- x0
                          mu0 <- X[,1]
                          X[,2] <- rmvnorm(1,
                                           mu = as.vector(mu0),
                                           sigma = cov)
                          for(i in 3:length(.self$dates)){
                              mu0 <- X[,i-1] + gamma * R %*% (X[,i-1] - X[,i-2])
                              X[,i] <- rmvnorm(1,
                                               mu = as.vector(mu0),
                                               sigma = cov)
                          }
                          return(X)
                      },
                      getTMBmap = function(...){
                          "Function to create map list for TMB::MakeADFun. If equaldecay=TRUE, \\eqn{\\gamma_1} and \\eqn{\\gamma_2} are estimated as equal. If equaldecay=TRUE, \\eqn{\\mu_1} and \\eqn{\\mu_2} are estimated as equal. If fixdrift=TRUE, \\eqn{\\mu_1} and \\eqn{\\mu_2} are fixed at the current value."
                          
                          map <- callSuper(...)
                          args <- list(...)
                          mpar <- 1:3
                          doit <- FALSE

                           if("fixrotation" %in% names(args)) ## phi
                              if(args$fixrotation){
                                  mpar[2] <- NA;
                                  doit <- TRUE
                              }
                          if("fixmovecor" %in% names(args)) ## rho
                              if(args$fixmovecor){
                                  mpar[3] <- NA;
                                  doit <- TRUE
                              }

                          if("equalvar" %in% names(args)) ## var
                              if(args$equalvar){
                                  map$logSdState <- factor(c(1,1))
                              }
                          

                          ## Always equal decay
                          ##doit <- TRUE

                          if(doit)
                              map$movePars <- factor(mpar)

                          return(map)
                          
                      }

                  
                  )
                  )



##' Create a DCRW movement model object
##'
##' @param dates Vector of distinct, equidistant, and increasing POSIXct dates
##' @param pars Vector of movement parameters: \\eqn{logit_{(0,1)}(\\gamma)}, \\eqn{\\phi}, \\eqn{logit_{(-1,1)}(\\rho)}
##' @param varPars Vector of movement variance parameters: \\eqn{log(\\sigma_{lat})}, \\eqn{log(\\sigma_{lat})}
##' @param nauticalStates Should latent states be transformed from longitude/latitude to nautical miles?
##' @param timeunit timeunit used for calculating time steps.
##' @return A DCRW object
##' @seealso \code{\link{DCRW-class}}
#' @examples
#' d <- subadult_ringed_seal
#' dates <- unique(as.POSIXct(d$date,tz="GMT"))
#' dseq <- seq(min(dates),max(dates), "day")
#' mov <- DCRW(dseq)
##' @author Christoffer Moesgaard Albertsen
##' @export
DCRW <- function(dates,
                 pars = numeric(3),
                 varPars = numeric(2),
                 nauticalStates = FALSE,
                 timeunit = "hours"){
    new("DCRW",
        dates = dates,
        pars = pars,
        varPars = varPars,
        nauticalStates = nauticalStates,
        timeunit = timeunit)
}
