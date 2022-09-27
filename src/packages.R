############################
# Wrapper functions ########
############################
silent.require <- function(x) suppressMessages(require(package=x, character.only=TRUE, quietly=TRUE))
github.wrapper <- function(package, user){
  if(!silent.require(package)){
    install_github(paste(package,user,sep="/"), upgrade=FALSE)
    if(!silent.require(package))
      stop("Cannot install ", package)
  }
}
manage.packages <- function(packages){
  ready <- sapply(packages, silent.require)
  for(i in seq_along(packages))
    if(!ready[i])
      install.packages(ready[i], quietly=TRUE, dependencies=TRUE)
  ready <- sapply(packages, silent.require)
  if(any(!ready))
    stop("Cannot install packages", ready[!ready])
}

############################
# Package dependencies #####
############################
# Set number of cores
manage.packages(c("parallel","yaml"))
if(file.exists("config.yml")){
    config <- read_yaml("config.yml")
    if("r" %in% names(config)){
        r.config <- config$r
        if("mc.cores" %in% names(r.config))
            options(mc.cores=r.config$mc.cores)
    }
}
