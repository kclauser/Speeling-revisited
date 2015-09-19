require 'webrick'
require 'yaml'
require 'erb'

class CurrentWords < WEBrick::HTTPServlet::AbstractServlet

TEMPLATE = %{
  <html>
  <body>
  <form method="POST" action="/search"
  <ul>
  <li><input name="searchword"/><li>
  </ul>
  <button type="submit">Search!</button>
  </form>
  <a href="/add">"Add word"</a>
  <ul>

  <% words.each do |hash| %>
    <li>
    <%= hash[:word] %>
    <%= hash[:definition] %>

    </li>
  <% end %>
  </ul>
  </body>
  </html>
}

  def do_GET(request, response)

    if File.exist?("words.yml")
      words = YAML::load(File.read("words.yml"))
    else
      words = []
    end

    # The following is jsut for use in the template above
    # words.each { |hash| puts "word: #{hash[:word]} definition: #{hash[:definition]}" }
    # this isnt needed at all ever with erb
    # html = words.map { |hash| "#{hash[:word]} -> #{hash[:definition]}" }.join("<br/>")

    response.status = 200
    response.body = ERB.new(TEMPLATE).result(binding)
  end
end

class AddWord < WEBrick::HTTPServlet::AbstractServlet

TEMPLATE = %{
  <html>
  <body>

  <form method="POST" action="/save">
  <ul>
  <li><input name="word"/></li><- word
  <li><input name="definition"/></li><- definition
  </ul>
  <button type="submit">Submit!</button>
  </form>
  </body>
  </html>
}

  def do_GET(request, response)

    response.status = 200
    response.body = ERB.new(TEMPLATE).result(binding)

  end
end

class SaveWord < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    if File.exist?("words.yml")
      dictionary = YAML::load(File.read("words.yml"))
    else
      dictionary = []
    end

      word = request.query["word"].to_s
      definition = request.query["definition"].to_s
      new_entry = { word: word, definition: definition }
      dictionary << new_entry
      File.write("words.yml", dictionary.to_yaml)


    response.status = 302
    response.header["Location"] = "/"
    response.body = "Word added!"
  end
end

class SearchWord < WEBrick::HTTPServlet::AbstractServlet
  TEMPLATE = %{
    <html>
    <body>
    <ul>
    <% search_result.each do |hash| %>
      <li>
      <%= hash[:word] %>
      <%= hash[:definition] %>
      </li>
    <% end %>
    </ul>
    </body>
    </html>

  }

  def do_POST(request, response)
    if File.exist?("words.yml")
      dictionary = YAML::load(File.read("words.yml"))
    else
      dictionary = []
    end


search_result = dictionary.select { |hash| hash[:word] == request.query["searchword"] }

    # html = "<ul>" + (search_result.map { |hash| "<li>word: #{hash[:word]} definition: #{hash[:definition]}</li>"}).join + "</ul>"

    response.status = 200
    response.body = ERB.new(TEMPLATE).result(binding)
  end
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount "/", CurrentWords
server.mount "/add", AddWord
server.mount "/save", SaveWord
server.mount "/search", SearchWord

trap("INT") { server.shutdown }

server.start
