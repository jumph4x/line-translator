require 'open-uri'
require 'nokogiri'
require "i18n"

I18n.available_locales = [:en]

EN = 'EN_PIDS.txt'
RU = 'RU_PIDS.txt'
INPUT = 'PIDS.txt'
URL = 'https://translate.google.com/?gbv=1&q=:query:&um=1&ie=UTF-8&sl=de&tl=:lang:&sa=X'

def translate input, lang
  text = I18n.transliterate input
  addr = URL.sub(":query:",text.gsub(" ","+")).sub(":lang:",lang)
  doc = Nokogiri::HTML(open(addr))
  doc.css("#result_box").inner_text
end

def format_line text, offset
  "--- --- #{text}#{offset}"
end

File.open(RU, 'w') do |ru_out|
File.open(EN, 'w') do |en_out|
  File.open(INPUT).each do |line|
    match = line.match(/ \- (.+)\, offset/)
    # There is a translation to be performed
    if match
      text = I18n.transliterate match[1]
      offset = line.match(/, (.+)/)

      en_out.puts format_line(translate(text, "en"), offset)
      ru_out.puts format_line(translate(text, "ru"), offset)
    # We simply copy the group name
    else
      existing = line.match(/\] (.+)/)
      next unless existing
      
      en_out.puts existing[1]
      ru_out.puts existing[1]
    end

  end
end
end
