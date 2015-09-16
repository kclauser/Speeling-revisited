require 'webrick'

class CurrentWords < WEBrick::HTTPServlet::AbstractServlet

  def do_GET(request, response)

    if File.exist?("words.txt")
      words = File.readlines("words.txt")
    else
      words = []
    end

    response.status = 200
    response.body = %{
      <html>
        <body>
        <form method="POST" action="/search"
        <ul>
          <li><input name="searchword"/><li>
        </ul>
        <button type="submit">Search!</button>
        </form>
        <a href="/add">"Add word"</a>
        <p>#{words.join("<br/>")}</p>
        </body>
      </html>
    }
  end
end

class AddWord < WEBrick::HTTPServlet::AbstractServlet

def do_GET(request, response)

  if File.exist?("words.txt")
    words = File.readlines("words.txt")
  else
    words = []
  end

  response.status = 200
  response.body = %{
    <html>
      <body>

    <!--#{words.join("<br/")}-->
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

end
end

class SaveWord < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    File.open("words.txt", "a+") do |file|
      file.puts "Word: #{request.query["word"]} Definition: #{request.query["definition"]}"
    end

    response.status = 302
    response.header["Location"] = "/"
    response.body = "Word added!"
  end
end

class SearchWord < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    lines = File.readlines("words.txt")
    matching_lines = lines.select { |line| line.include?(request.query["searchword"])}
    html = "<ul>" + (matching_lines.map { |line| "<li>#{line}</li>"}).join + "</ul>"

response.status = 200
response.body = %{
<html>
<body>
#{html}
</body>
</html>

}
end
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount "/", CurrentWords
server.mount "/add", AddWord
server.mount "/save", SaveWord
server.mount "/search", SearchWord

trap("INT") { server.shutdown }

server.start
