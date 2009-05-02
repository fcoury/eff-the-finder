F::Finder.define :google do
  description 'Google search'
  base_uri 'http://www.google.com/'
  find { |http, o| http.get '/search', :q => o[:terms], :hl => 'en' }

  parse do |page, result|
    result.header = 'Google Search' + page.css('#ssb p').text
    result.previous_url = page.css('#nav td.b:first a')
    result.next_url = page.css('#nav td.b:last a')
    result.items = page.css('h3.r a.l')
  end

end
