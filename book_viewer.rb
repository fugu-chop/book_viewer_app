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
    text.split("\n\n").each_with_index.map do |line, index|
      # Use jumplinks to focus on paragraph
      "<p id=paragraph#{index}>#{line}</p>"
    end.join
  end

  def each_chapter
    # Iterate through each chapter, yielding it
    @contents.each_with_index do |name, index|
      number = index + 1
      contents = File.read("data/chp#{number}.txt")
      yield(number, name, contents)
    end
  end

  def chapters_matching(query)  
    results = []
    return results if !query || query.empty?

    # each_chapter iterates through each chapter, yielding it to the block
    each_chapter do |number, name, contents|
      matches = {}
      # The contents variable here is a chapter - we're splitting it up into paragraphs
      contents.split("\n\n").each_with_index do |paragraph, index|
        # Filtering occurs within the block
        matches[index] = paragraph if paragraph.include?(query)
      end
      # The .any? call is equivalent to !matches.empty? 
      # It's necessary to filter out empty hashes, since the each_with_index will iterate through each chapter
      # When nothing matches in the chapter, the matches hash is empty and would otherwise make the results array
      results << { number: number, name: name, paragraphs: matches } if matches.any?
    end

    results
  end

  # We can use this directly in our search.erb file
  def highlight(text, term)
    text.gsub(term, %(<strong>#{term}</strong>))
  end
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb(:home)
end

get "/chapters/:number" do
  # Note this returns a string
  number = params[:number].to_i

  # Return true if number is between beginning and end of range
  redirect "/" unless (1..@contents.size).cover?(number)

  @title = "Chapter #{number}: #{@contents[number - 1]}"
  @chapter = File.read("data/chp#{number}.txt")

  erb(:chapter)
end

# We're using GET as the method because performing a search doesn't modify any data.
# If our form submission was modifying data, we would use POST as the form's method.
get "/search" do
  @results = chapters_matching(params[:query])
  erb(:search)
end

not_found do
  redirect "/"
end
