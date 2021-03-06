#' Defunct functions in the argosTrack package
#' 
#' These functions are provided to guide users from old versions of the package to the new functionality.
#' @rdname argosTrack-defunct
#' @name argosTrack-defunct
#' @param ... Not used
#' @aliases argosTrack
#' @docType package
#' @return Nothing 
#' @section argosTrack function:
#' The argosTrack function is replaced by a combination of functions. To achieve the similar results as the old function call,
#'\preformatted{
#'argosTrack <- function(lon,lat,dates,locationclass,
#'                       include = rep(TRUE,length(dates)),
#'                       equalbetas = TRUE,
#'                       timevarybeta = 1,
#'                       fixgammas = TRUE,
#'                       fixcorrection = FALSE,
#'                       dfVals = NULL,
#'                       dfMap = NULL,
#'                       minDf = 3.0,
#'                       errordistribution = "t",
#'                       movementmodel = "ctcrw",
#'                       verbose = TRUE,
#'                       timeunit = "mins",
#'                       nlminb.control = list(eval.max=2000,
#'                            iter.max=1500,
#'                             rel.tol=1e-3,
#'                             x.tol=1.5e-2))
#'}
#' use:
#' \preformatted{
#'     obs <- Observation(lat = lat,
#'                        lon = lon,
#'                        dates = as.POSIXct(dates),
#'                        locationclass = locationclass,
#'                        include = include)
#'     mov <- CTCRW(dates = unique(as.POSIXct(dates)),
#'                  timeunit = timeunit)
#'     meas <- Measurement(model = model,minDf = minDf)
#'     anim <- Animal(obs,mov,meas)
#'     fitTrack(anim,
#'              silent = !verbose,
#'              fixcorrection = fixcorrection,
#'              nlminb.control = nlminb.control
#'              equaldecay = equalbetas,
#'              fixdrift = fixgammas)
#' }
#' where the input of the functions corresponds to the argument names of the \code{argosTrack} function.


##' @export
argosTrack <- function(...){
    .Defunct(c("CTCRW","Animal","fitTrack"), package = "argosTrack")
}
