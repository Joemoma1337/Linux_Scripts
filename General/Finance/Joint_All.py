#This script will take an export of a date range and categorize to a single file
import csv
from collections import defaultdict

# Define categories for vendors
categories = {
    "Car Expense": ["car1", "car2"],
    "CreditCard": ["Credit Card AUTO PAY", "AUTOMATIC PAYMENT"],
    "Dining": ["dining1", "dining2"],
    "Education": ["education1", "education2"],
    "Electric": ["electric_co1"],
    "Entertainment": ["entertainment1"],
    "Extra Income": ["ext_income1"],
    "Extra": ["extra1"],
    "Gas": ["SHELL", "EXXON"],
    "Groceries": ["grocery1", "grocery2"],
    "Health": ["health1"],
    "Home Expense": ["LOWES", "HOME DEPOT"],
    "Income - 1": ["income 1"],
    "Income - 2": ["income2"],
    "Insurance": ["insurance1", "insurance2"],
    "Internet-Phone": ["ISP1"],
    "Investment": ["investment1"],
    "Medical": ["medical1"],
    "Mortgage": ["mortgage1"],
    "Pets": ["pet1"],
    "Shopping": ["shopping1"],
    "Taxes": ["taxes1"],
    "Travel": ["UBER"]
}

# Function to categorize transactions
def categorize_vendor(vendor):
    for category, keywords in categories.items():
        if any(keyword.upper() in vendor.upper() for keyword in keywords):  # Case-insensitive match
            return category
    return "Other"

# Read input files and process data
def process_files(input_files, output_file):
    category_totals = defaultdict(float)  # To store category totals

    with open(output_file, mode='w', newline='') as output_csv:
        writer = csv.writer(output_csv)
        writer.writerow(["Date", "Amount", "Vendor", "Category"])  # Write header

        for input_file in input_files:
            with open(input_file, mode='r') as csvfile:
                reader = csv.reader(csvfile, delimiter=',')  # Assuming comma delimiter
                for row in reader:
                    # Skip blank lines and ensure there are at least 5 columns
                    if len(row) < 5 or not row[0].strip():
                        continue

                    date = row[0]
                    amount = float(row[1])  # Convert amount to float for summing
                    vendor = row[4]  # Vendor is in column 5
                    category = categorize_vendor(vendor)
                    writer.writerow([date, amount, vendor, category])

                    # Add amount to the corresponding category total
                    category_totals[category] += amount

        # Write summary at the end of the CSV
        writer.writerow([])  # Blank row before summary
        writer.writerow(["Category", "Total Amount"])  # Summary header
        for category, total in category_totals.items():
            writer.writerow([category, f"{total:.2f}"])  # Write category total

# Input and output file paths
input_files = ['export1.csv']
output_file = 'Joint_output.csv'

# Process files
process_files(input_files, output_file)

print(f"Categorized transactions and summary totals written to {output_file}")
