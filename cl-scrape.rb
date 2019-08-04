require 'mechanize'
require 'pry-byebug'
require 'csv'

scraper = Mechanize.new
scraper.history_added = Proc.new { sleep 0.5 }
BASE_URL = 'http://sandiego.craigslist.org'
ADDRESS = 'http://sandiego.craigslist.org/d/bicycles/search/bia'
results = []

scraper.get(ADDRESS) do |search_page|
  # everything else will go here
  search_form = search_page.form_with(:id => 'searchform') do |search|
    search['query'] = 'Specialized'
    search['min_price'] = 250
    search['max_price'] = 2500
  end

  result_page = search_form.submit
  #puts result_page.search('p.result-info')

  ## Stop here
  #binding.pry

  # Parse results
  raw_results = result_page.search('p.result-info')
  raw_results.each do |result|
    link = result.search('a')[0]
    name = link.text.strip 
    url = result.search('a')[0].attributes["href"].value
    datetime = result.search('time')[0].attributes["datetime"].value
    #puts datetime 
    price = result.search('span.result-price').children[0]
    #puts price
    #location = result.search('span.pnr').text[3..-13]
    location = result.search('span.result-hood').children[0]
    unless location.to_s.strip.empty?
      loc = location.text.strip.tr('()', '')
    else
      loc = "N/A"
    end
    #binding.pry
    #puts loc
    puts "name:", name, "datetime:", datetime, "url:", url, "loc:", loc

    results << [name, url, price, loc, datetime]
  end

  ## Stop here
  #binding.pry

end

CSV.open("cl_results.csv", "w+") do |csv_file|
  results.each do |row|
    csv_file << row
  end
end


