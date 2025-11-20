import pandas as pd
from sklearn.datasets import load_iris
import requests

iris = load_iris()
df = pd.DataFrame(iris.data, columns=iris.feature_names)
df["target"] = iris.target
df = df.drop("target", axis=1)

df = df.rename(
    columns = {
        'sepal length (cm)':'sepal_length',
        'sepal width (cm)':'sepal_width',
        'petal length (cm)':'petal_length',
        'petal width (cm)' :'petal_width'
    }
)

df_sample = df.sample(n=5)
df_request = df_sample.to_dict('records')

try:
    for i in range(len(df_sample)):
        response = requests.post(
            "http://20.252.101.232:8000/iris/predict",
            json = df_request[i]
        )
        result = response.json()
        print(df_request[i], "--> ", result)
        print("-" * 120)
        
except Exception as ex:
    print(f"Request: The following error occurred: {ex}")