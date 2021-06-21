########
# SOM #
#######
# Limpiamos el entorno
rm(list=ls())
set.seed(42)

# Establecemos el directorio de trabajo donde estan los datos
setwd(".")
df <- read.csv('selected_trips.csv')
colnames(df)

# Nuevo data frame (df.clean) donde limpiar los datos (conservamos el original df)
df.clean <- df#[sample(nrow(df), 100000), ]

################################################
# Normalize columnwise
################################################
df.clean[,1:7] <- apply(df.clean[, 1:7], 2, function(x) (x - min(x))/(max(x)-min(x)))


################################################
# Correlations
################################################
cor(df.clean)

########################################################
# SOM (lo probamos con libreria som y libreria kohonen)
########################################################
# In this example SOM does not provide dimensionality reduction
library(som)
# Dimension del mapa
dimX <- 3
dimY <- 3
data_train_matrix <- as.matrix(scale(df.clean))
som.out <- som(data_train_matrix,xdim=dimX,ydim=dimY,alphaType="inverse",neig="gaussian",topol="hexa",
               init="sample",radius=c(3,1),rlen=c(100,1000))
plot(som.out)
# Vectores de codigo xdim*ydim por filas rownumber=x+y*xdim
print(som.out$code)

detach("package:som", unload=TRUE)

######################################################################################
# Ojo, si cargo la libreria kohonen (distinta a la libreria som), se da una nueva 
#funcionalidad a som y no funciona el comando som asociado a la anterior libreria som 
library(kohonen)
som_grid <- somgrid(xdim = 3, ydim=3, topo="hexagonal")
som_model <- som(data_train_matrix, 
                 grid=som_grid, 
                 rlen=500, 
                 alpha=c(0.05,0.01), 
                 keep.data = TRUE )
# Plot vector of mean average deviations from code vectors
#plot(som_model, type="changes", main="Mean average deviations from code vectors")
# Plot the number of objects mapped to the individual units
plot(som_model, type="count", main="Node Counts", shape = "straight")
# Plot sum of the distances to all immediate neighbors
plot(som_model, type="dist.neighbours",
     main = "SpacOM neighbor distances", shape = "straight")
# Plot code vectors
plot(som_model, type="codes", main="Code vectors",
     shape = "straight",
     codeRendering = "segments")
plot(som_model, type="codes", main="Code vectors",
     shape = "straight",
     codeRendering = "lines")
plot(som_model, type="codes", main="Code vectors",
     shape = "straight",
     codeRendering = "stars")

plot(som_model, type="changes")
#plot(som_model, type="mapping")

plot(som_model, type="quality", shape = "straight")

# Create a palette
coolBlueHotRed <- function(n, alpha = 1) {
  rainbow(n, end=4/6, alpha=alpha)[n:1]
}
# Property indicates the values to use with the "property" plotting type
plot(som_model, type = "property", property = getCodes(som_model)[,4], main=colnames(getCodes(som_model))[4], palette.name=coolBlueHotRed)

detach("package:kohonen", unload=TRUE)
