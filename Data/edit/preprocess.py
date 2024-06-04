import pandas as pd
import numpy as np

# Load the data from CSV
file_path_1 = '/Users/ekinderdiyok/Documents/Projects/Mental Health Database/Data/raw/1- mental-illnesses-prevalence.csv'  # replace with your actual file path
df1 = pd.read_csv(file_path_1)

# Use the melt function to pivot the DataFrame
pivot_df1 = df1.melt(id_vars=["Entity", "Code", "Year"], 
                     var_name="Disorder", 
                     value_name="pop_pct")

# Recode entries in the Disorder variable
conditions = [
    pivot_df1['Disorder'].str.contains('eating', case=False, na=False),
    pivot_df1['Disorder'].str.contains('bipolar', case=False, na=False),
    pivot_df1['Disorder'].str.contains('schizophrenia', case=False, na=False),
    pivot_df1['Disorder'].str.contains('anxiety', case=False, na=False),
    pivot_df1['Disorder'].str.contains('depressive', case=False, na=False)
]
choices = ['eating', 'bipolar', 'schizophrenia', 'anxiety', 'depressive']
pivot_df1['Disorder'] = np.select(conditions, choices, default=pivot_df1['Disorder'])

# Save the pivoted DataFrame to a new CSV file
output_file_path_1 = '/Users/ekinderdiyok/Documents/Projects/Mental Health Database/Data/prevalence_pvt.csv'
pivot_df1.to_csv(output_file_path_1, index=False)

# Load the second data from CSV
file_path_2 = '/Users/ekinderdiyok/Documents/Projects/Mental Health Database/Data/raw   /2- burden-disease-from-each-mental-illness(1).csv'
df2 = pd.read_csv(file_path_2)

# Use the melt function to pivot the DataFrame
pivot_df2 = df2.melt(id_vars=["Entity", "Code", "Year"], 
                     var_name="Disorder", 
                     value_name="daly")

# Recode entries in the Disorder variable
conditions = [
    pivot_df2['Disorder'].str.contains('eating', case=False, na=False),
    pivot_df2['Disorder'].str.contains('bipolar', case=False, na=False),
    pivot_df2['Disorder'].str.contains('schizophrenia', case=False, na=False),
    pivot_df2['Disorder'].str.contains('anxiety', case=False, na=False),
    pivot_df2['Disorder'].str.contains('depressive', case=False, na=False)
]
choices = ['eating', 'bipolar', 'schizophrenia', 'anxiety', 'depressive']
pivot_df2['Disorder'] = np.select(conditions, choices, default=pivot_df2['Disorder'])

# Save the pivoted and recoded DataFrame to a new CSV file
output_file_path_2 = '/Users/ekinderdiyok/Documents/Projects/Mental Health Database/Data/burden_pvt.csv'
pivot_df2.to_csv(output_file_path_2, index=False)
