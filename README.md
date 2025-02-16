# Amazon Book Crawler  

A Ruby script that scrapes book data from Amazon Poland and saves it to an SQLite database.  

## Features  
- Extracts book details (title, price, rating, release date).  
- Supports keyword-based search or default category scraping.  
- Scrapes additional details from product pages (publisher, ISBN-13, etc.).  
- Stores data in `books.db` using Sequel.  

## Requirements  
Install dependencies with:  
gem install nokogiri open-uri sequel sqlite3 securerandom

## Usage
1. Run the script:
ruby amazon_crawler.rb
2. Enter a search keyword or press Enter for the default category.
3. Specify the number of pages to scrape (default: 3).
