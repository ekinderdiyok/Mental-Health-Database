import pandas as pd

# Load the data from CSV
file_path = '/Users/ekinderdiyok/Documents/Projects/Mental Health Database/Data/1- mental-illnesses-prevalence.csv'  # replace with your actual file path
df = pd.read_csv(file_path)

# Use the melt function to pivot the DataFrame
pivot_df = df.melt(id_vars=["Entity", "Code", "Year"], 
                   var_name="Disorder", 
                   value_name="pop_pct")

# Save the pivoted DataFrame to a new CSV file
output_file_path = '/Users/ekinderdiyok/Documents/Projects/Mental Health Database/Data/prevalence_pvt.csv'
pivot_df.to_csv(output_file_path, index=False)

# Load the data from CSV
file_path = '/Users/ekinderdiyok/Documents/Projects/Mental Health Database/Data/2- burden-disease-from-each-mental-illness(1).csv'
df = pd.read_csv(file_path)

# Use the melt function to pivot the DataFrame
pivot_df = df.melt(id_vars=["Entity", "Code", "Year"], 
                   var_name="Disorder", 
                   value_name="daly")

# Save the pivoted DataFrame to a new CSV file
output_file_path = '/Users/ekinderdiyok/Documents/Projects/Mental Health Database/Data/daly_pvt.csv'
pivot_df.to_csv(output_file_path, index=False)