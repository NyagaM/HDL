if(!require("doSNOW",character.only = TRUE)){
  cat("Pacakge doSNOW has not been installed. Start installing... \n")
  try_error <- try(install.packages("doSNOW",dependencies=TRUE, lib = Sys.getenv("R_LIBS_USER")), silent = TRUE)
  if(!is.null(try_error)){
    try_error <- try(install.packages("doSNOW", 
                                      dependencies=TRUE), silent = TRUE)
  }
}

args <- commandArgs(trailingOnly = TRUE)
args.print <- paste("Function arguments:", paste(args, collapse = "\n"), sep = "\n")
cat("\n")
cat(args.print, "\n\n")
if(length(args) == 0){
  library(HDL)
  q()
}
gwas1.df.path <- gsub(x = args[grep(x = args, pattern = "gwas1.df=")], pattern = "gwas1.df=", replacement = "")
gwas2.df.path <- gsub(x = args[grep(x = args, pattern = "gwas2.df=")], pattern = "gwas2.df=", replacement = "")
LD.path <- gsub(x = args[grep(x = args, pattern = "LD.path=")], pattern = "LD.path=", replacement = "")
Nref <- gsub(x = args[grep(x = args, pattern = "Nref=")], pattern = "Nref=", replacement = "")
N0 <- gsub(x = args[grep(x = args, pattern = "N0=")], pattern = "N0=", replacement = "")
output.file <- gsub(x = args[grep(x = args, pattern = "output.file=")], pattern = "output.file=", replacement = "")
numCores <- gsub(x = args[grep(x = args, pattern = "numCores=")], pattern = "numCores=", replacement = "")

if(length(output.file) == 0){
  length(output.file) <- ""
}

if(output.file != ""){
  if(file.exists(output.file) == T){
    system(paste0("rm ",output.file))
  }
}

smart.reader <- function(path){
  path.split <- unlist(strsplit(path, split = "\\."))
  file.type <- path.split[length(path.split)]
  if(file.type == "rds"){
    return(readRDS(path))
  } else if(file.type == "txt"){
    return(read.table(file = path, header = T))
  } else if(file.type == "sumstats"){
    return(read.table(file = path, header = T))
  } else{
    error.message <- "The extension of input file has to be .rds or .txt!"
    if(output.file != ""){
      cat(error.message, file = output.file, append = T)
    }
    stop(error.message)
  }
}
message <- "Loading GWAS1 ... \n"
if(output.file != ""){
  cat(message, file = output.file, append = T)
}
cat(message)
gwas1.df <- smart.reader(gwas1.df.path)

message <- "Loading GWAS2 ... \n"
if(output.file != ""){
  cat(message, file = output.file, append = T)
}
cat(message)
gwas2.df <- smart.reader(gwas2.df.path)

if(length(Nref)==0)
  Nref <- 336000
if(length(N0) == 0)
  N0 <- min(gwas1.df$N, gwas2.df$N)


##### Run HDL #####

library(HDL)
res.HDL <- HDL.rg.parallel(gwas1.df, gwas2.df, LD.path, Nref = Nref, N0 = N0, output.file = output.file, numCores = numCores)

if(output.file != ""){
  fConn <- file(output.file)
  Lines <- readLines(fConn)
  writeLines(c(args.print,Lines), con = fConn)
  close(fConn)
}