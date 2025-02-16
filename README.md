# Amazon Product Crawler

This is a simple web scraper for extracting product information from Amazon using Ruby and the Nokogiri library.  

## Features  
- Extracts basic product data (title, price) from a specific Amazon category.  
- Can be extended to scrape product details from individual product pages.  
- Stores product links for further processing.  
- Data can be saved to a database (e.g., SQLite via Sequel).  

## Requirements  
- Ruby  
- Nokogiri  
- HTTParty (or another HTTP client)  
- Sequel (if storing data in a database)  

## Usage  
Run the script to scrape product data from the specified Amazon category. Modify the code to extend functionality, such as keyword-based search or additional product details extraction.  
