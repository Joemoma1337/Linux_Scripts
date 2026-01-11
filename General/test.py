import pandas as pd
import os

# --- CONFIGURATION ---
input_files = ['Checking.csv', 'CreditCard.csv']
output_file = 'Financial_Analysis_Results.csv'

category_map = {
    "CHICK-FIL-A": ("Fast Food", "Variable"),
    "MCDONALDS": ("Fast Food", "Variable"),
    "SHELL": ("Gas", "Variable"),
    # Add your others here...
    # Fast Food & Coffee
    "MCDONALDS": ("Fast Food", "Variable"),
    "STARBUCKS": ("Coffee", "Variable"),
    "DUNKIN": ("Coffee", "Variable"),
    "CHICK-FIL-A": ("Fast Food", "Variable"),
    
    # Delivery (High Priority to track)
    "DOORDASH": ("Delivery", "Variable"),
    "UBER* EATS": ("Delivery", "Variable"),
    
    # General Dining
    "RESTAURANT": ("Dining", "Variable"),
    "STEAKHOUSE": ("Dining", "Variable"),
    "GRILL": ("Dining", "Variable"),
    "KITCHEN": ("Dining", "Variable"),
}

def categorize_vendor(vendor):
    v_clean = str(vendor).upper().strip()
    for keyword, (cat, exp_type) in category_map.items():
        if keyword in v_clean:
            return cat, exp_type
    return "Other", "Variable"

def run_analysis():
    all_data = []

    for f in input_files:
        if not os.path.exists(f):
            print(f"!!! File not found: {f}")
            continue
        
        print(f"--- Processing {f} ---")
        # We load the CSV without names first to see what the columns look like
        try:
            # Change header=0 if your file has a header row
            temp_df = pd.read_csv(f, header=None)
            
            # DEBUG: Print the first row so you can see if Vendor is actually where you think
            print(f"First row of {f} looks like this:")
            print(temp_df.iloc[0].tolist())
            
            # Map your columns here based on the printout above
            # If Vendor is the 5th column, it is index 4
            df_mapped = pd.DataFrame()
            df_mapped['Date'] = pd.to_datetime(temp_df[0], errors='coerce')
            df_mapped['Amount'] = pd.to_numeric(temp_df[1], errors='coerce').fillna(0)
            df_mapped['Vendor'] = temp_df[4] # Ensure this matches your file!
            
            all_data.append(df_mapped)
        except Exception as e:
            print(f"Error reading {f}: {e}")

    if not all_data:
        print("!!! No data was loaded. Check your file paths and names.")
        return

    df = pd.concat(all_data, ignore_index=True)
    
    # Apply categorization
    res = df['Vendor'].apply(lambda x: pd.Series(categorize_vendor(x)))
    df['Category'] = res[0]
    df['Type'] = res[1]

    # Save and Confirm
    df.to_csv(output_file, index=False)
    print(f"\nSUCCESS! Created {output_file} with {len(df)} rows.")

if __name__ == "__main__":
    run_analysis()
