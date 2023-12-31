% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bootstrap.R
\name{bootstrapAUC}
\alias{bootstrapAUC}
\title{Bootstrap the AUC and conduct T-Tests for a collection of signatures.}
\usage{
bootstrapAUC(
  SE_scored,
  annotationColName,
  signatureColNames,
  num.boot = 100,
  pb.show = TRUE
)
}
\arguments{
\item{SE_scored}{a \code{SummarizedExperiment} object with genes as the
row features and signature scores in the \code{colData}. There should also
be a column of annotation data. Required.}

\item{annotationColName}{a character string giving the column name in
\code{colData} that contains the annotation data. Required.}

\item{signatureColNames}{a vector of column names in the
\code{colData} that contain the signature score data. Required.}

\item{num.boot}{integer. The number of times to bootstrap the data. The
default is \code{100}.}

\item{pb.show}{logical for whether to show a progress bar while running code.
The default is \code{TRUE}.}
}
\value{
A list of length 5 returning a vector of p-values for a 2-sample
t-test, bootstrapped AUC values, an AUC value for using all scored values
for all signatures specified in \code{signatureColNames},
and values for the lower and upper bounds of a bootstrapped AUC confidence
interval using \code{pROC::roc()}.
}
\description{
Run bootstrapping of the AUC and derive the p-value for a 2-sample t-test
for all signatures tested on a given dataset.
}
\examples{
 # Run signature profiling
 choose_sigs <- list("madeupsig" = c("FCRL3", "OAS2", "IFITM3"))
 prof_indian <- runTBsigProfiler(TB_indian, useAssay = "logcounts",
                                 algorithm = "ssGSEA",
                                 combineSigAndAlgorithm = TRUE,
                                 signatures = choose_sigs,
                                 parallel.sz = 1)
 # Bootstrapping
 booted <- bootstrapAUC(SE_scored = prof_indian, annotationColName = "label",
                        signatureColNames = names(choose_sigs), num.boot = 2)
 booted

}
