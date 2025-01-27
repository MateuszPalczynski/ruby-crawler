require 'nokogiri'
require 'open-uri'
require 'sequel'
require 'sqlite3'

# Połączenie z bazą SQLite
DB = Sequel.sqlite('books.db')

# Tworzenie tabeli, jeśli nie istnieje
DB.create_table? :books do
  primary_key :id
  String :name
  String :link
  String :release_date
  String :price
  String :rating
  String :asin
  String :publisher
  String :language
  String :soft_cover
  String :isbn_13
  String :dimensions
end

# Model Sequel dla książek
class Book < Sequel::Model(:books)
end

# Pobranie słowa od użytkownika
puts "Wprowadź słowo do wyszukania (lub naciśnij Enter, aby użyć domyślnego linku):"
user_input = gets.chomp.strip

# URL główny
main_url = 'https://www.amazon.pl/s?i=stripbooks&rh=n%3A20657313031&s=popularity-rank&fs=true&page=1&qid=1737983292&xpid=S8T52ZYA_T-Zx&ref=sr_pg_4'

# Jeśli użytkownik poda słowo, budujemy link, jeśli nie, używamy domyślnego
base_url = user_input.empty? ? main_url : "https://www.amazon.pl/s?k=#{user_input}&i=stripbooks&ref=nb_sb_noss"

# Pobranie liczby stron do pobrania
puts "Wprowadź liczbę stron do pobrania (lub naciśnij Enter, aby pobrać 10 stron):"
pages_input = gets.chomp.strip

# Jeśli użytkownik nie poda liczby, ustawiamy domyślną wartość na 10
n = pages_input.empty? ? 10 : pages_input.to_i

# Ustawienie nagłówków dla requestów
headers = {
  "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
  "Accept-Language" => "en-US,en;q=0.9"
}

# Pobieranie i zapisywanie danych z kolejnych stron
(1..n).each do |page|
  url = "#{base_url}&page=#{page}"
  
  begin
    html = URI.open(url, headers)
    doc = Nokogiri::HTML(html)

    book_sections = doc.css('.a-section.a-spacing-small.a-spacing-top-small')

    book_sections.each do |section|
      book = {}

      # Tytuł
      title_tag = section.at_css('h2.a-size-medium')
      book['name'] = title_tag ? title_tag.text.strip : ""

      # Link
      link_tag = section.at_css('a.a-link-normal')
      book['link'] = link_tag ? "https://www.amazon.pl#{link_tag['href']}" : ""

      # Data wydania
      release_date_tag = section.at_css('span.a-size-base.a-color-secondary.a-text-normal')
      book['release_date'] = release_date_tag ? release_date_tag.text.strip : ""

      # Cena
      price_tag = section.at_css('span.a-price-whole')
      book['price'] = price_tag ? "#{price_tag.text.strip} zł" : ""

      # Oceny
      rating_tag = section.at_css('i.a-icon-star-small')
      book['rating'] = rating_tag ? rating_tag.text.strip : ""

      # Jeśli nie ma tytułu, pomijamy książkę
      next if book['name'].empty?

      # Pobieranie szczegółowych informacji z podstrony książki
      if book['link'] != ""
        begin
          book_html = URI.open(book['link'], headers)
          book_doc = Nokogiri::HTML(book_html)

          book_doc.css('ul.a-unordered-list.a-nostyle.a-vertical.a-spacing-none.detail-bullet-list li').each do |item|
            text = item.text.strip
            if text.include?('Wydawca')
              book['publisher'] = text.split(':').last.strip
            elsif text.include?('Język')
              book['language'] = text.split(':').last.strip
            elsif text.include?('Miękka oprawa')
              book['soft_cover'] = text.split(':').last.strip
            elsif text.include?('ISBN-13')
              book['isbn_13'] = text.split(':').last.strip
            elsif text.include?('Wymiary')
              book['dimensions'] = text.split(':').last.strip
            end
          end

          # ASIN (identyfikator Amazon)
          asin_tag = book_doc.at_css('meta[name="ASIN"]')
          book['asin'] = asin_tag ? asin_tag['content'] : ""

        rescue => e
          puts "Błąd podczas pobierania szczegółów dla '#{book['name']}': #{e.message}"
        end
      end

      # Zapis do bazy danych
      Book.create(
        name: book['name'],
        link: book['link'],
        release_date: book['release_date'],
        price: book['price'],
        rating: book['rating'],
        asin: book['asin'],
        publisher: book['publisher'],
        language: book['language'],
        soft_cover: book['soft_cover'],
        isbn_13: book['isbn_13'],
        dimensions: book['dimensions']
      )

      puts "Dodano do bazy: #{book['name']}"
    end

  rescue OpenURI::HTTPError => e
    puts "Błąd HTTP na stronie #{page}: #{e.message}"
  rescue => e
    puts "Inny błąd na stronie #{page}: #{e.message}"
  end
end

puts "Dane książek zostały zapisane do bazy 'books.db'."
