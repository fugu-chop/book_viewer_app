# Book Viewer App
A repo to test out using some of the Sinatra functionality. 

### Basic Overview
This app allows users to view different parts of the Sherlock Holmes literature, with the ability to search for particular strings, and navigate directly to those paragraphs.

### How to Run
The application has been deployed to Heroku and can be found here: https://book-viewer-dw.herokuapp.com/

The application can be run in development, if you like:
1. Clone the repo locally
2. Make sure you have the `bundle` gem installed.
3. Run `bundle install` in your CLI
4. Run `bundle exec rackup -s webrick` in your CLI
5. Visit `http://localhost:9292` in your web browser

### Challenges
Deployment wasn't too bad - Heroku is pretty easy to deploy to, and none of the configuration on my machine seemed to create any issues.

I had to lean heavily on some provided HTML and CSS, having no real background on this. Otherwise, writing the logic wasn't too bad. 

However, not really understanding jumplinks made it very difficult to think of a way to structure the data to provide useful navigation points - I ended up with a hash of ids (used for paragraphs), the chapter name, and the paragraph itself. Working around this was pretty challenging. It's ugly, and probably not best practice, since the method itself does a lot of things (e.g. filtering and storing things to a hash, then appending to an array).
```ruby
def each_chapter
    @contents.each_with_index do |name, index|
      number = index + 1
      contents = File.read("data/chp#{number}.txt")
      yield(number, name, contents)
    end
  end

  def chapters_matching(query)  
    results = []
    return results if !query || query.empty?

    each_chapter do |number, name, contents|
      matches = {}
      contents.split("\n\n").each_with_index do |paragraph, index|
        matches[index] = paragraph if paragraph.include?(query)
      end
      results << { number: number, name: name, paragraphs: matches } if matches.any?
    end

    results
  end
```
