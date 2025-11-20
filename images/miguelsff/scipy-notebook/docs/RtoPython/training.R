# Funcion en R
library(mlflow)
Sys.setenv(MLFLOW_BIN=system("which mlflow", intern=TRUE))
Sys.setenv(MLFLOW_PYTHON_BIN=system("which python", intern=TRUE))

get_model <- function(name) {
    model <- mlflow_load_model(model_uri=name)
    return(model)
}