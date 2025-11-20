import pandas as pd
import re
import numpy as np
import mlflow.pyfunc


class CustomModel:
    def remove_accents(self, col_name):
        accent_mapping = {
            r"Á": "A", r"É": "E", r"Í": "I", r"Ó": "O", r"Ú": "U",
            r"Â": "A", r"Ê": "E", r"Î": "I", r"Ô": "O", r"Û": "U",
            r"Ä": "A", r"Ë": "E", r"Ï": "I", r"Ö": "O", r"Ü": "U",
            r"À": "A", r"È": "E", r"Ì": "I", r"Ò": "O", r"Ù": "U",
            r"Ñ": "N", r"Ý": "Y", r"Ç": "C", r"Ã": "A", r"Õ": "O"
            # ,".":""             # Added period replacement with nothing
            }
        for character, replacement in accent_mapping.items():
            col_name = re.sub(character, replacement, col_name)
        return col_name

    def remove_special_chars(self, col_name):
        return re.sub(r'[^a-zA-Z0-9\s]', '', col_name)

    def remove_spaces(self, col_name):
        return re.sub(r' ', '', col_name)

    def preprocess_transactions(self, transactions):
        try:
            transactions['description'] = transactions['description'].str.upper()
            transactions['description'] = transactions['description'].apply(self.remove_accents)
            transactions['description'] = transactions['description'].apply(self.remove_special_chars)
            transactions['description'] = transactions['description'].apply(self.remove_spaces)
            transactions = transactions.drop_duplicates()
        except Exception as e:
            raise e
        return transactions

    def predict(self, transactions, percentiles):
        try:
            transactions = self.preprocess_transactions(transactions)
            merged = pd.merge(transactions, percentiles, on=["description"], how="left")
            merged["flag_p25"] = (merged["price"] < merged["p25"]).astype(int)
            merged = merged.reset_index(drop=True)
            merged['amount_difference'] = merged['p25'] - merged['price']
            merged['differential_tax'] = merged['amount_difference'] * merged['quantity'] * 0.18
            merged = merged.reset_index(drop=True)
            merged['ratio'] = merged['differential_tax'] / 700
            merged['ratio'] = merged['ratio'].mask(merged['ratio'] > 1, 1)
        except Exception as e:
            raise e
        return np.array(merged[['ratio']])


class CustomModelWrapper(mlflow.pyfunc.PythonModel):
    def __init__(self, model):
        self.model = model

    def load_context(self, context):
        # Load percentiles CSV from artifacts
        self.percentiles_df = pd.read_csv(context.artifacts["percentiles"])

    def predict(self, context, transactions):
        return self.model.predict(transactions, self.percentiles_df)