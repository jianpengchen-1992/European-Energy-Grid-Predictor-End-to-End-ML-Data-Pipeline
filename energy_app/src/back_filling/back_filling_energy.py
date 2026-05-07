from datetime import datetime
import time

# Assuming your pipeline function is in a file called `pipeline.py` inside src/pipeline
# Adjust the import path if your file is named differently
from src.pipeline.energy.pipeline import pipeline 

def run_backfill():
    # 1. Define your overall start and end dates
    start_date_str = "2019-01-01"
    end_date_str = "2026-04-19"

    # Convert strings to datetime objects for math
    overall_start = datetime.strptime(start_date_str, "%Y-%m-%d")
    overall_end = datetime.strptime(end_date_str, "%Y-%m-%d")

    # 2. Define your target categories
    categories = [
        {"main_cat": "Stromerzeugung", "sub_cat": "Realisierte Erzeugung"},
        {"main_cat": "Stromverbrauch", "sub_cat": "Realisierter Stromverbrauch"},
        {"main_cat": "Markt", "sub_cat": "Großhandelspreise"},
        {"main_cat": "Stromerzeugung", "sub_cat": "Prognostizierte Erzeugung Day-Ahead"}
    ]

    current_start = overall_start

    # 3. The Calendar Year Chunking Loop
    while current_start <= overall_end:
        current_year = current_start.year
        
        # Define the end of the current year
        end_of_year = datetime(current_year, 12, 31)

        # The magic trick: The chunk ends either on Dec 31st, or the overall_end date
        current_end = min(end_of_year, overall_end)

        # Convert back to strings for your pipeline
        start_str = current_start.strftime("%Y-%m-%d")
        end_str = current_end.strftime("%Y-%m-%d")

        print(f"\n--- Processing Date Range: {start_str} to {end_str} ---")

        # 4. Loop through the categories for this specific date chunk
        for cat in categories:
            main_cat = cat["main_cat"]
            sub_cat = cat["sub_cat"]
            
            print(f"Ingesting: {main_cat} -> {sub_cat}...")
            
            try:
                # Call your existing pipeline function
                pipeline(start_str, end_str, main_cat, sub_cat)
                
                # Pause for 2 seconds to be polite to the API
                time.sleep(2) 
                
            except Exception as e:
                print(f"Error on {main_cat}/{sub_cat} for {start_str} to {end_str}: {e}")
                # You can choose to break or continue here if an error occurs

        # 5. Move the start date to January 1st of the next year
        current_start = datetime(current_year + 1, 1, 1)

    print("\n✅ Historical backfill complete!")

if __name__ == "__main__":
    run_backfill()