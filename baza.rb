require 'sqlite3'

db = SQLite3::Database.new 'books.db'  # Połączenie z bazą

db.execute('SELECT * FROM books') do |row|
  puts row.inspect
end
