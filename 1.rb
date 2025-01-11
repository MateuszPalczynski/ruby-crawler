require 'selenium-webdriver'
require 'nokogiri'

# Konfiguracja Selenium dla Edge
options = Selenium::WebDriver::Edge::Options.new
options.add_argument('--disable-gpu')
options.add_argument('--no-sandbox')
# Usuń --headless, jeśli chcesz widzieć działanie przeglądarki
options.add_argument('--headless') 

# Uruchomienie przeglądarki Edge
driver = Selenium::WebDriver.for(:edge, options: options)

begin
  # Nawigacja do strony Allegro
  url = 'https://allegro.pl/kategoria/silownia-i-fitness-19626'
  driver.navigate.to(url)

  # Czekanie na załadowanie treści (np. głównego kontenera z produktami)
  wait = Selenium::WebDriver::Wait.new(timeout: 15) # Zwiększ czas oczekiwania
  wait.until { driver.find_element(css: 'div[data-box-name="items-v3"]') }

  # Pobranie źródła strony
  html = driver.page_source

  # Wyświetlenie pełnego HTML w konsoli
  puts "Pobrany HTML:"
  puts html

  # Zapisanie HTML do pliku (opcjonalnie)
  File.open('allegro.html', 'w') do |file|
    file.write(html)
  end
  puts "\nHTML został zapisany do pliku 'allegro.html'"

  # Parsowanie HTML za pomocą Nokogiri (dla dalszej obróbki)
  doc = Nokogiri::HTML(html)
  puts "\nTytuł strony: #{doc.title}"

ensure
  # Zamknięcie przeglądarki
  driver.quit
end
