globalVariables(c("BS_AUC", "FPR", "LowerTPR", "Signatures",
                  "TBsignatures", "TPR", "UpperTPR", "sigAnnotData"))

#' Plot a heatmap of signature scores.
#'
#' This function takes a dataset of scored gene expression data as an input
#' and returns a \code{ComplexHeatmap} plot for for visual comparison of
#' signature performance. The function takes arguments listed here as well
#' as any others to be passed on to \code{ComplexHeatmap::Heatmap()}.
#'
#' If both \code{annotationData = NULL} and \code{annotationColNames = NULL},
#' no annotation bar will be drawn on the heatmap.
#'
#' @param inputData an input data object. It should either be of the class
#' \code{SummarizedExperiment} and contain the profiled signature data and
#' annotation data as columns in the colData, or alternatively be of the classes
#' \code{data.frame} or \code{matrix} and contain only the gene expression data.
#' Required.
#' @param annotationData a \code{data.frame} or \code{matrix} of annotation
#' data, with one column. Only required if \code{inputData} is a
#' \code{data.frame} or \code{matrix} of signature data.
#' The row names must equal those of the \code{inputData} column names.
#' Default is \code{NULL}.
#' @param name a character string with the plot title of the heatmap. The
#' default is \code{"Signatures"}.
#' @param signatureColNames a vector of the column names in \code{colData} that
#' contain the signature data. Only required if \code{inputData} is a
#' SummarizedExperiment object.
#' @param annotationColNames a vector of the column names in \code{colData} that
#' contain the annotation data. Only required if \code{inputData} is a
#' \code{SummarizedExperiment}. Default is \code{NULL}.
#' @param colList a named \code{list} of named vectors specifying custom color
#' information to
#' pass to \code{ComplexHeatmap::Heatmap()}. The list should have as many
#' elements as there are annotation columns, and each element name should
#' correspond exactly with the name of each annotation column.
#' The colors in the vector elements should be named according to the
#' levels of the factor in that column's annotation data if the annotation
#' is discrete, or it should be produced with \code{circlize::colorRamp2}
#' if the annotation is continuous.
#' By default, \code{ColorBrewer} color sets will be used.
#' See the the parameter \code{colorSets} for additional details.
#' @param scale logical. Setting \code{scale = TRUE} scales the signature data.
#' The default is \code{FALSE}.
#' @param showColumnNames logical. Setting \code{showColumnNames = TRUE} will
#' show the column names (i.e. sample names) on the heatmap. The default is
#' \code{TRUE}.
#' @param showRowNames logical. Setting \code{showColumnNames = TRUE} will
#' show the row names (i.e. signature names) on the heatmap. The default is
#' \code{TRUE}.
#' @param colorSets a vector of names listing the color sets in the order
#' that they should be used in creating the heatmap. By default, this function
#' will use the color sets in the order listed in \code{Usage} for annotation
#' information. You may replace the default with the same collection of sets
#' in order that you want to use them, or provide custom color sets with the
#' \code{colList} parameter.
#' @param choose_color a vector of color names to be interpolated for the
#' heatmap gradient, or a \code{colorRamp} function produced by
#' \code{circlize::colorRamp2}. The default is \code{c("blue", "gray95", "red")}.
#' @param split_heatmap a character string either giving the column title of
#' \code{annotationSignature} containing annotation data for which to split
#' the heatmap rows (i.e., signatures), or \code{"none"} if no split is desired.
#' To split based on the type of signature, set \code{split_heatmap = "disease"}.
#' The default is \code{"none"}.
#' @param annotationSignature a \code{data.frame} or \code{matrix} with information
#' to be used
#' in splitting the heatmap. The first column should signature names. The
#' column of annotation information should be specified in \code{split_heatmap.}
#' Other columns will be ignored. The default is \code{sigAnnotData}.
#' @param column_order a vector of character strings indicating the order in
#' which to manually arrange the heatmap columns. Default is \code{NULL},
#' such that column order is automatically determined via clustering.
#' @param ... Additional arguments to be passed to
#' \code{ComplexHeatmap::Heatmap()}.
#'
#' @return A ComplexHeatmap plot.
#'
#' @export
#'
#' @examples
#' library(SummarizedExperiment)
#' # Generate some artificial data that shows a difference in Zak_RISK_16
#' mat_testdata <- rbind(matrix(c(rnorm(80), rnorm(80) + 5), 16, 10,
#'                              dimnames = list(TBsignatures$Zak_RISK_16,
#'                                              paste0("sample", seq_len(10)))),
#'                       matrix(rnorm(1000), 100, 10,
#'                              dimnames = list(paste0("gene", seq_len(100)),
#'                                              paste0("sample", seq_len(10)))))
#' # Create a SummarizedExperiment object that contains the data
#' testdataSE <- SummarizedExperiment(assays = SimpleList(data = mat_testdata),
#'                                      colData = DataFrame(sample =
#'                                                            c(rep("down", 5),
#'                                                                 rep("up", 5))))
#' res <- runTBsigProfiler(testdataSE, useAssay = "data",
#'                         signatures = TBsignatures["Zak_RISK_16"],
#'                         algorithm = c("GSVA", "ssGSEA"), parallel.sz = 1,
#'                         combineSigAndAlgorithm = TRUE)
#' signatureHeatmap(res, signatureColNames = c("GSVA_Zak_RISK_16",
#'                                             "ssGSEA_Zak_RISK_16"),
#'                  annotationColNames = "sample", scale = TRUE,
#'                  showColumnNames = FALSE, split_heatmap = "none")
#'
#' # Example using custom colors for the annotation information
#' color2 <- stats::setNames(c("purple", "black"), c("down", "up"))
#' color.list <- list("sample" = color2)
#'
#' signatureHeatmap(res, signatureColNames = c("GSVA_Zak_RISK_16",
#'                                             "ssGSEA_Zak_RISK_16"),
#'                  annotationColNames = "sample", scale = TRUE,
#'                  showColumnNames = FALSE,
#'                  colList = color.list, split_heatmap = "none")
#'
signatureHeatmap <- function(inputData, annotationData = NULL, name = "Signatures",
                             signatureColNames,
                             annotationColNames = NULL,
                             colList = list(), scale = FALSE,
                             showColumnNames = TRUE,
                             showRowNames = TRUE, colorSets = c("Set1", "Set2",
                                                                "Set3", "Pastel1", "Pastel2", "Accent", "Dark2",
                                                                "Paired"),
                             choose_color = c("blue", "gray95", "red"),
                             split_heatmap = "none",
                             annotationSignature = sigAnnotData,
                             column_order = NULL,
                             ...) {
  if (methods::is(inputData, "SummarizedExperiment")) {
    if (any(duplicated(signatureColNames))) {
      stop("Duplicate signature column name is not supported.")
    }
    if (!all(signatureColNames %in% colnames(SummarizedExperiment::colData(inputData)))) {
      stop("Signature column name not found in inputData.")
    }
    if (!is.null(annotationColNames)) {
      if (!all(annotationColNames %in% colnames(SummarizedExperiment::colData(inputData)))) {
        stop("Annotation column name not found in inputData.")
      }
      annotationData <- SummarizedExperiment::colData(inputData)[, annotationColNames, drop = FALSE]
      inputData <- SummarizedExperiment::colData(inputData)[, signatureColNames, drop = FALSE]
    }
  } else {
    if (is.null(annotationData)) {
      stop("annotationData must be provided for a data.frame input object.")
    } else if (!is.null(annotationData)) {
      annotationColNames <- colnames(annotationData)
    }
  }
  if (!is.null(annotationData)) {
    if (nrow(annotationData) == nrow(inputData)) {
      if (!all(rownames(annotationData) == rownames(inputData))) {
        stop("Annotation data and signature data does not match.")
      }
    } else if (nrow(annotationData) == ncol(inputData)) {
      if (!all(rownames(annotationData) == colnames(inputData))) {
        stop("Annotation data and signature data does not match.")
      }
      inputData <- t(inputData)
    } else {
      stop("Annotation data and signature data does not match.")
    }
  }
  sigresults <- t(as.matrix(inputData))
  keyname <- "Score"
  if (scale) {
    sigresults <- t(scale(t(sigresults)))
    keyname <- "Scaled Score"
  }
  # To split heatmap by signatures
  if (split_heatmap != "none") {
    if (!(split_heatmap %in% colnames(annotationSignature))) {
      stop("The column specified in 'split_heatmap' must be in the matrix or data.frame
           provided by 'annotationSignature'")
    }
  }
  ann_data <- annotationSignature[annotationSignature[, 1] %in%
                                    signatureColNames, ]
  if (split_heatmap == "none") {
    row_split_pass <- c()
  } else {
    row_split_pass <- ann_data[, split_heatmap]
  }
  if (!is.null(annotationData)) {
    if (length(colList) == 0) {
      colorSetNum <- 1
      for (annot in annotationColNames) {
        if (is.numeric(annotationData[, annot])) {
          t1min <- min(annotationData[, annot], na.rm = TRUE)
          t1max <- max(annotationData[, annot], na.rm = TRUE)
          colList[[annot]] <- circlize::colorRamp2(c(t1min, t1max),
                                                   c("white", "blue"))
        } else {
          if (is.factor(annotationData[, annot][!is.na(annotationData[, annot])])) {
            condLevels <- levels(annotationData[, annot][!is.na(annotationData[, annot])])
          } else {
            condLevels <- unique(annotationData[, annot][!is.na(annotationData[, annot])])
          }
          if (length(condLevels) > 8) {
            colors <- distinctColors(length(condLevels))
          } else {
            colors <- RColorBrewer::brewer.pal(8, colorSets[colorSetNum])
            colorSetNum <- colorSetNum + 1
          }
          colList[[annot]] <- stats::setNames(colors[seq_along(condLevels)],
                                              condLevels)
        }
      }
    }
    topha2 <- ComplexHeatmap::HeatmapAnnotation(
      df = data.frame(annotationData),
      col = colList, height = grid::unit(0.4 * length(annotationColNames), "cm"),
      show_legend = TRUE, show_annotation_name = TRUE)
    return(ComplexHeatmap::draw(
      ComplexHeatmap::Heatmap(sigresults, column_title = name,
                              show_column_names = showColumnNames,
                              col = choose_color,
                              show_row_names = showRowNames,
                              top_annotation = topha2, name = keyname,
                              row_split = row_split_pass,
                              column_order = column_order,
                              cluster_columns = TRUE,
                              ...),
      annotation_legend_side = "bottom"))
  }
}

#' Plot a boxplot of signature genes.
#'
#' @param inputData an input data object. It should either be of the class
#' \code{SummarizedExperiment} and contain the profiled signature data and
#' annotation data as columns in the \code{colData}, or alternatively be of the
#' classes \code{data.frame} or \code{matrix} and contain only the gene
#' expression data. Required.
#' @param annotationData a \code{data.frame} or \code{matrix} of annotation data,
#' with one column. Only required if \code{inputData} is a \code{data.frame} or
#' \code{matrix} of signature data.
#' @param signatureColNames a \code{vector} of the column names in \code{colData}
#' that contain the signature data. Only required if \code{inputData} is a
#' \code{SummarizedExperiment} object.
#' @param annotationColName a character string naming the column name in the
#' \code{colData} that contains the annotation data to be used in making the
#' boxplot. Only required if inputData is a \code{SummarizedExperiment} object.
#' @param name a character string giving the title of the boxplot. The default
#' is \code{"Signatures"}.
#' @param scale logical. Setting \code{scale = TRUE} scales the signature data.
#' The default is \code{FALSE}.
#' @param violinPlot logical. Setting \code{violinPlot = TRUE} creates violin
#' plots in place of boxplots. The default is \code{FALSE}.
#' @param includePoints logical. If \code{TRUE}, points will be included over
#' the boxplots. The default is \code{TRUE}.
#' @param notch logical. Notches are used to compare groups; if the notches of
#' two boxes do not overlap, this suggests that the medians are significantly
#' different. If \code{TRUE}, the boxplot will be notched. The default is
#' \code{FALSE}.
#' @param rotateLabels logical. If \code{TRUE}, the x-axis labels will be
#' rotated. The default is \code{FALSE}.
#' @param nrow integer giving the number of rows in the resulting array.
#' @param ncol integer giving the number of columns in the resulting array.
#' @param fill_colors a vector of color names to be used as the fill colors for
#' the boxplot. If \code{NULL}, colors will be supplied via RColorBrewer.
#' The default is \code{fill_colors = NULL}.
#'
#' @return A \code{ggplot2} boxplot of the signature data using the provided
#' annotation information.
#'
#' @export
#'
#' @examples
#' library(SummarizedExperiment)
#'
#' # Generate some artificial data that shows a difference in Zak_RISK_16
#' mat_testdata <- rbind(matrix(c(rnorm(80), rnorm(80) + 5), 16, 10,
#'                              dimnames = list(TBsignatures$Zak_RISK_16,
#'                                              paste0("sample", seq_len(10)))),
#'                       matrix(rnorm(1000), 100, 10,
#'                              dimnames = list(paste0("gene", seq_len(100)),
#'                                              paste0("sample", seq_len(10)))))
#'
#' # Create a SummarizedExperiment object that contains the data
#' testdataSE <- SummarizedExperiment(assays = SimpleList(data = mat_testdata),
#'                                    colData = DataFrame(sample =
#'                                                          c(rep("down", 5),
#'                                                            rep("up", 5))))
#'
#' # Run profiler using GSVA and ssGSEA on Zak_RISK_16 signature
#' res <- runTBsigProfiler(testdataSE, useAssay = "data",
#'                         signatures = TBsignatures["Zak_RISK_16"],
#'                         algorithm = c("GSVA", "ssGSEA"), parallel.sz = 1,
#'                         combineSigAndAlgorithm = TRUE)
#' signatureBoxplot(res, signatureColNames = c("GSVA_Zak_RISK_16",
#'                                             "ssGSEA_Zak_RISK_16"),
#'                  annotationColName = "sample", name = "Zak_RISK_16 Signature")
#'
signatureBoxplot <- function(inputData, annotationData, signatureColNames, annotationColName, 
                             name = "Signatures", scale = FALSE, violinPlot = FALSE, 
                             includePoints = TRUE, notch = FALSE, rotateLabels = FALSE, 
                             nrow = NULL, ncol = NULL, fill_colors = NULL) {
  if (methods::is(inputData, "SummarizedExperiment")) {
    if (any(duplicated(signatureColNames))) {
      stop("Duplicate signature column name is not supported.")
    }
    if (!all(signatureColNames %in% colnames(SummarizedExperiment::colData(inputData)))) {
      stop("Signature column name not found in inputData.")
    }
    if (!all(annotationColName %in% colnames(SummarizedExperiment::colData(inputData)))) {
      stop("Annotation column name not found in inputData.")
    }
    annotationData <- data.frame(SummarizedExperiment::colData(inputData)[, 
                                                                          annotationColName, drop = FALSE])
    inputData <- data.frame(SummarizedExperiment::colData(inputData)[, 
                                                                     signatureColNames, drop = FALSE])
  }
  else {
    if (ncol(annotationData) != 1) {
      stop("annotationData must have only one column.")
    }
    annotationColName <- colnames(annotationData)
  }
  if (length(annotationColName) != 1) {
    stop("You must specify a single annotation column name to color boxplots by.")
  }
  if (!is.factor(annotationData[, 1])) {
    annotationData[, 1] <- as.factor(annotationData[, 1])
  }
  n <- length(levels(annotationData[, 1]))
  if (n > 9) {
    stop("Too many levels in the annotation data. The boxplot can contain a maximum of 9 levels")
  }
  if (nrow(annotationData) == nrow(inputData)) {
    if (!all(rownames(annotationData) == rownames(inputData))) {
      stop("Annotation data and signature data does not match.")
    }
  }
  else if (nrow(annotationData) == ncol(inputData)) {
    if (!all(rownames(annotationData) == colnames(inputData))) {
      stop("Annotation data and signature data does not match.")
    }
    inputData <- t(inputData)
  }
  else {
    stop("Annotation data and signature data does not match.")
  }
  pathwaydata <- t(inputData)
  if (scale) {
    pathwaydata <- t(scale(t(pathwaydata)))
  }
  boxplotdf <- data.frame(t(pathwaydata), Group = annotationData[, 
                                                                 1])
  boxplotdfm <- reshape2::melt(boxplotdf, value.name = "Score", 
                               variable.name = "Signature", id.vars = "Group")
  theplot <- ggplot2::ggplot(boxplotdfm,
                             ggplot2::aes(boxplotdfm$Group, boxplotdfm$Score)) +
    ggplot2::facet_wrap(~Signature, scales = "free", nrow = nrow, ncol = ncol)
  if (violinPlot) {
    theplot <- theplot + ggplot2::geom_violin(ggplot2::aes(fill = boxplotdfm$Group)) + 
      ggplot2::theme_classic()
  }
  else {
    theplot <- theplot + ggplot2::geom_boxplot(outlier.shape = NA, 
                                               ggplot2::aes(fill = boxplotdfm$Group), notch = notch) + 
      ggplot2::theme_classic()
  }
  if (includePoints) {
    theplot <- theplot + ggplot2::geom_point(position = ggplot2::position_jitter(width = 0.1))
  }
  if (rotateLabels) {
    theplot <- theplot + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, 
                                                                            hjust = 1))
  }
  if (is.null(fill_colors)) {
    if (n < 3) 
      n <- 3
    fill_colors <- RColorBrewer::brewer.pal(n, "Set1")
  }
  return(theplot + ggplot2::scale_fill_manual(values = fill_colors) + 
           ggplot2::ggtitle(name))
}

#' Plot a heatmap of a single signature score with individual gene expression levels.
#'
#' This function takes the profiled gene expression data for a single signature
#' and creates a heatmap based on the expression scores.
#'
#' @inheritParams signatureHeatmap
#' @param inputData a \code{SummarizedExperiment} object containing the profiled
#' signature data and annotation data as columns in the \code{colData}.
#' Required.
#' @param useAssay a character string specifying the assay to use for the gene
#' expression data. Required.
#' @param sigGenes a vector identifying the genes in the signature to use in
#' the heatmap. For inbuilt signatures, you can use \code{TBsignatures}
#' (e.g., \code{TBsignatures[["ACS_COR"]]}). Required.
#' @param name a character string with the plot title of the heatmap. The
#' default is \code{"Signatures"}.
#' @param signatureColNames a vector of the column names in the \code{colData}
#' that contain the signature data. Required.
#' @param annotationColNames a vector of the column names in the \code{colData}
#' that contain the annotation data. If \code{NULL}, no annotation bar besides
#' those of the scoring algorithms will be drawn on the heatmap. The default
#' is \code{NULL}.
#' @param scale logical. Setting \code{scale = TRUE} scales the signature data.
#' The default is \code{TRUE}.
#' @param showColumnNames logical. Setting \code{showColumnNames = TRUE} will
#' show the column names (i.e. sample names) on the heatmap. The default is
#' \code{TRUE}.
#' @param showRowNames logical. Setting \code{showColumnNames = TRUE} will
#' show the row names (i.e. signature names) on the heatmap. The default is
#' \code{TRUE}.
#' @param colList a named \code{list} of named vectors specifying custom color
#' information to pass to \code{ComplexHeatmap::Heatmap()}.
#' The list should have as many elements as there are annotation columns
#' and gene signatures (i.e. \code{sigGenes}), and each element name should
#' correspond exactly with the name of each annotation column/signature.
#' The colors in the vector elements should be named according to the
#' levels of the factor in that column's annotation data if the annotation
#' is discrete, or it should be produced with \code{circlize::colorRamp2}
#' if the annotation/gene is continuous.
#' By default, \code{ColorBrewer} color sets will be used.
#' See the the parameter \code{colorSets} for additional details.
#'
#' @return  A \code{ComplexHeatmap} plot.
#'
#' @export
#'
#' @examples
#' library(SummarizedExperiment)
#' # Generate some artificial data that shows a difference in Zak_RISK_16
#' mat_testdata <- rbind(matrix(c(rnorm(80), rnorm(80) + 5), 16, 10,
#'                              dimnames = list(TBsignatures$Zak_RISK_16,
#'                                              paste0("sample", seq_len(10)))),
#'                       matrix(rnorm(1000), 100, 10,
#'                              dimnames = list(paste0("gene", seq_len(100)),
#'                                              paste0("sample", seq_len(10)))))
#'
#' # Create a SummarizedExperiment object that contains the data
#' testdataSE <- SummarizedExperiment(assays = SimpleList(data = mat_testdata),
#'                                    colData = DataFrame(sample =
#'                                                        c(rep("down", 5),
#'                                                          rep("up", 5))))
#' # Run profiler using GSVA and ssGSEA on Zak_RISK_16
#' res <- runTBsigProfiler(testdataSE, useAssay = "data",
#'                         signatures = TBsignatures["Zak_RISK_16"],
#'                         algorithm = c("GSVA", "ssGSEA"), parallel.sz = 1,
#'                         combineSigAndAlgorithm = TRUE)
#'
#' # Plot a heatmap of signature genes and pathway predictions
#' signatureGeneHeatmap(res, useAssay = "data",
#'                      sigGenes = TBsignatures[["Zak_RISK_16"]],
#'                      signatureColNames = c("GSVA_Zak_RISK_16",
#'                                            "ssGSEA_Zak_RISK_16"),
#'                      annotationColNames = c("sample"), showColumnNames = FALSE,
#'                      name = "Zak_RISK_16")
signatureGeneHeatmap <- function(inputData, useAssay, sigGenes,
                                 name = "Signature", signatureColNames = NULL,
                                 annotationColNames = NULL, scale = TRUE,
                                 showColumnNames = TRUE, showRowNames = TRUE,
                                 colList = list(), colorSets = c("Set1", "Set2",
                                 "Set3", "Pastel1", "Pastel2", "Accent",
                                 "Dark2", "Paired"),
                                 choose_color = c("blue", "gray95", "red"),
                                 column_order = NULL,
                                 ...) {
  if (!is.null(signatureColNames)) {
    pathwaycols <- list()
    pathwaydata <- data.frame(SummarizedExperiment::
                                colData(inputData)[, signatureColNames,
                                                   drop = FALSE])
    for (i in colnames(pathwaydata)) {
      t1min <- min(pathwaydata[, i], na.rm = TRUE)
      t1max <- max(pathwaydata[, i], na.rm = TRUE)
      pathwaycols[[i]] <- circlize::colorRamp2(c(t1min,
                                                 mean(c(t1min, t1max)),
                                                 t1max),
                                               c("darkgreen",
                                                 "white",
                                                 "darkorange"))
    }
  } else {
    pathwaycols <- NULL
    pathwaydata <- NULL
  }
  heatdata <- SummarizedExperiment::assay(
    inputData, useAssay)[sigGenes[sigGenes %in% rownames(inputData)], ]
  heatname <- useAssay
  if (scale) {
    heatdata <- heatdata[base::rowSums(heatdata, na.rm = TRUE) != 0, ]
    heatdata <- t(scale(t(heatdata)))
    heatname <- paste("Scaled", heatname, sep = "\n")
  }

  if (!is.null(annotationColNames)) {
    annotationData <- data.frame(SummarizedExperiment::
                                   colData(inputData)[, annotationColNames,
                                                      drop = FALSE])
    if (length(colList) == 0) {
      colorSetNum <- 1
      for (annot in annotationColNames) {
        if (is.numeric(annotationData[, annot])) {
          t1min <- min(annotationData[, annot], na.rm = TRUE)
          t1max <- max(annotationData[, annot], na.rm = TRUE)
          colList[[annot]] <- circlize::colorRamp2(c(t1min, t1max),
                                                   c("white", "blue"))
        } else {
          if (is.factor(annotationData[, annot][!is.na(annotationData[, annot])])) {
            condLevels <- levels(
              annotationData[, annot][!is.na(annotationData[, annot])])
          } else {
            condLevels <- unique(
              annotationData[, annot][!is.na(annotationData[, annot])])
          }
          if (length(condLevels) > 8) {
            colors <- distinctColors(length(condLevels))
          } else {
            colors <- RColorBrewer::brewer.pal(8, colorSets[colorSetNum])
            colorSetNum <- colorSetNum + 1
          }
          colList[[annot]] <- stats::setNames(colors[seq_along(condLevels)],
                                              condLevels)
        }
      }
    } else {
      if (any(annotationColNames != names(colList))) {
        stop("The colList is out of sync with the annotation columns")
      }
    }
    colList <- c(colList, pathwaycols)
  } else {
    colList <- pathwaycols
  }

  if (!is.null(pathwaydata) | !is.null(annotationColNames)) {
    if (!is.null(annotationColNames) && !is.null(pathwaydata)) {
      annotDF <- cbind(data.frame(
        SummarizedExperiment::colData(inputData)[, annotationColNames,
                                                 drop = FALSE]),
                       pathwaydata)
    } else if (!is.null(annotationColNames)) {
      annotDF <- cbind(data.frame(SummarizedExperiment::
                                    colData(inputData)[, annotationColNames,
                                                       drop = FALSE]))
    } else {
      annotDF <- pathwaydata
    }
    topha <- ComplexHeatmap::HeatmapAnnotation(
      df = annotDF,
      col = colList,
      height = grid::unit(0.4 * length(c(annotationColNames,
                                         signatureColNames)), "cm"),
      show_legend = TRUE,
      show_annotation_name = TRUE)
  } else {
    topha <- NULL
  }
  return(ComplexHeatmap::draw(
    ComplexHeatmap::Heatmap(
      heatdata, show_column_names = showColumnNames,
      col = choose_color,
      show_row_names = showRowNames, top_annotation = topha,
      name = heatname, column_title = name,
      cluster_columns = TRUE,
      column_order = column_order, ...),
    annotation_legend_side = "bottom")
  )
}

#' Generate a distinct palette for coloring different clusters.
#'
#' Create a distinct palette for coloring different heatmap clusters. The
#' function returns colors for input into \code{ComplexHeatmap:Heatmap()},
#' \code{signatureGeneHeatmap()} and \code{signatureHeatmap()}.
#'
#' @param n an integer describing the number of colors to generate. Required.
#' @param hues a vector of character strings indicating the R colors available
#' from the \code{colors()} function. These will be used as the base colors for
#' the clustering scheme. Different saturations and values (i.e. darkness)
#' will be generated for each hue. Default is \code{c("red", "cyan", "orange",
#' "blue", "yellow", "purple", "green", "magenta")}
#' @param saturation.range a numeric vector of length 2 with values between 0
#' and 1 giving the range of saturation. The default is \code{c(0.25, 1)}.
#' @param value.range a numeric vector of length 2 with values between 0 and 1
#' giving the range of values. The default is \code{c(0.5, 1)}.
#'
#' @return A vector of distinct colors that have been converted to HEX from
#' HSV.
#'
#' @export
#'
#' @examples
#'
#' distinctColors(10)
#'
distinctColors <- function(n, hues = c("red", "cyan", "orange", "blue",
                                       "yellow", "purple", "green", "magenta"),
                           saturation.range = c(0.7, 1),
                           value.range = c(0.7, 1)) {

  if (!(all(hues %in% grDevices::colors()))) {
    stop("Only color names listed in the 'color'",
         " function can be used in 'hues'")
  }

  ## Convert R colors to RGB and then to HSV color format
  hues.hsv <- grDevices::rgb2hsv(grDevices::col2rgb(hues))

  ## Calculate all combination of saturation/value pairs.
  ## Note that low saturation with low value (i.e. high darkness) is too dark
  ## for all hues. Likewise, high saturation with high value (i.e. low darkness)
  ## is hard to distinguish. Therefore, saturation and value are set to be
  ## anticorrelated.
  num.vs <- ceiling(n / length(hues))
  s <- seq(from = saturation.range[1], to = saturation.range[2],
           length = num.vs)
  v <- seq(from = value.range[2], to = value.range[1], length = num.vs)

  ## Create all combinations of hues with saturation/value pairs
  new.hsv <- c()
  for (i in seq_len(num.vs)) {
    temp <- rbind(hues.hsv[1, ], s[i], v[i])
    new.hsv <- cbind(new.hsv, temp)
  }

  ## Convert to HEX
  col <- grDevices::hsv(new.hsv[1, ], new.hsv[2, ], new.hsv[3, ])

  return(col[seq_len(n)])
}
