% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Movement_CSB.R
\name{CSB}
\alias{CSB}
\title{Create a CSB movement model object}
\usage{
CSB(dates, pars = numeric(2), varPars = numeric(2),
  nauticalStates = FALSE, timeunit = "hours")
}
\arguments{
\item{dates}{Vector of distinct and increasing POSIXct dates}

\item{pars}{Vector of movement parameters: \\eqn{log(\\beta)}, \\eqn{\\gamma}}

\item{varPars}{Vector of movement variance parameters: \\eqn{log(\\sigma_{S})}, \\eqn{log(\\sigma_{B})}}

\item{nauticalStates}{Should latent states be transformed from longitude/latitude to nautical miles?}

\item{timeunit}{timeunit used for calculating time steps.}
}
\value{
A CSB object
}
\description{
Create a CSB movement model object
}
\examples{
d <- subadult_ringed_seal
mov <- argosTrack:::CSB(unique(as.POSIXct(d$date,tz="GMT")))
}
\seealso{
\code{\link{CSB-class}}
}
\author{
Christoffer Moesgaard Albertsen
}
