#This script will take an export of a date range and categorize to a monthly files
import csv
import os
from collections import defaultdict
from datetime import datetime

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

# Get month name from the date in the format MM.MonthName.YYYY
def get_month_filename(date_str):
    try:
        date_obj = datetime.strptime(date_str, "%m/%d/%Y")
        return f"{date_obj.strftime('%Y.%m.%b')}.csv"
    except ValueError:
        return None  # If the date is not in the expected format

# Process input files and separate transactions into month-specific CSV files with summary totals
def process_files(input_files):
    monthly_files = defaultdict(list)  # Dictionary to store rows by month
    category_totals_per_month = defaultdict(lambda: defaultdict(float))  # Track category totals for each month

    for input_file in input_files:
        with open(input_file, mode='r') as csvfile:
            reader = csv.reader(csvfile, delimiter=',')  # Adjust for comma delimiter
            for row in reader:
                # Skip blank lines and ensure there are at least 5 columns
                if len(row) < 5 or not row[0].strip():
                    continue

                date = row[0]
                amount = float(row[1])  # Convert amount to float for summing
                vendor = row[4]  # Vendor is in column 5
                category = categorize_vendor(vendor)

                # Get the filename for the corresponding month
                month_file = get_month_filename(date)
                if month_file:
                    # Append the row with the categorized transaction to the monthly list
                    monthly_files[month_file].append([date, amount, vendor, category])
                    # Add the amount to the corresponding category total for that month
                    category_totals_per_month[month_file][category] += amount

    # Write to each month's CSV file
    for month_file, transactions in monthly_files.items():
        with open(month_file, mode='w', newline='') as output_csv:
            writer = csv.writer(output_csv)
            writer.writerow(["Date", "Amount", "Vendor", "Category"])  # Write header
            writer.writerows(transactions)  # Write all transactions for that month

            # Append summary totals at the end of the CSV
            writer.writerow([])  # Blank row before summary
            writer.writerow(["Category", "Total Amount"])  # Summary header
            for category, total in category_totals_per_month[month_file].items():
                writer.writerow([category, f"{total:.2f}"])  # Write category totals
            print(f"Written {len(transactions)} transactions and summary totals to {month_file}")

# Input files
input_files = ['export1.csv']

# Process files and split transactions by month, including summary totals
process_files(input_files)

print("Monthly categorized transactions with summary totals written to corresponding files.")
