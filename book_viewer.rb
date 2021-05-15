require "sinatra"
require "sinatra/reloader"
# Tilt is an adapter between web applications and different Ruby templating languages.
# It's like a USB plug: devices can communicate without having to know about each other when they are built.
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  # Necessary because whitespace is ignored in HTML (i.e. paragraph breaks)
  def in_paragraphs(text)
    text.split("\n\n").map do |paragraph|
      "<p>#{paragraph}</p>"
    end.join
  end
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb(:home)
end

get "/chapters/:number" do
  # Note this returns a string
  number = params[:number].to_i
  @title = "Chapter #{number}: #{@contents[number - 1]}"
  @chapter = File.read("data/chp#{number}.txt")

  erb(:chapter)
end
