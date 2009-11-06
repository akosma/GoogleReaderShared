#!/usr/bin/env ruby

require 'xml'
require 'time'
$KCODE = 'u'

class Post
  attr_accessor :article_url
  attr_accessor :article_title
  attr_accessor :source_url
  attr_accessor :source_title
  attr_accessor :published_date
  attr_accessor :content_text
  
  def to_s
    # We could output the whole article contents 
    # stored in the "content_text" attribute!
    date = published_date.strftime("%A %d %B %Y, %H:%M")
    "<li><a href=\"#{article_url}\">#{article_title}</a> (<a href=\"#{source_url}\">#{source_title}</a>, #{date})</li>"
  end
end

reader = XML::Reader.file(ARGV[0])

# Flags used for processing the XML
in_entry = false
in_title = false
in_published = false
in_content = false
in_source = false

post = nil
posts = []

while reader.read

  # Opening tags
  if reader.node_type == XML::Reader::TYPE_ELEMENT
    if reader.name == "entry"
      in_entry = true
      post = Post.new
    end

    if in_entry
      in_content = true if reader.name == "content"
      in_title = true if reader.name == "title"
      in_source = true if reader.name == "source"
      in_published = true if reader.name == "published"

      if reader.name == "link"
        reader.move_to_attribute "href"
        post.source_url = reader.value if in_source
        post.article_url = reader.value if !in_source
      end
    end
  end

  # Processing tag contents
  if in_entry && reader.node_type == XML::Reader::TYPE_TEXT
    post.article_title = reader.value if in_title && !in_source
    post.source_title = reader.value if in_title && in_source
    post.published_date = Time.parse(reader.value) if in_published
    post.content_text = reader.value if in_content
  end

  # Closing tags
  if in_entry && reader.node_type == XML::Reader::TYPE_END_ELEMENT 
    in_published = false if in_published && reader.name == "published"
    in_title = false if in_title && reader.name == "title"
    in_source = false if in_source && reader.name == "source"
    in_content = false if in_content && reader.name == "content"

    if reader.name == "entry"
      in_entry = false
      posts << post
    end
  end

end

# Sort the posts in place by ascending published date
posts.sort! {|x, y| x.published_date <=> y.published_date }

# Create the HTML output
puts "<html><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" /><body>"
if ARGV.count > 1
  posts = posts.select { |post| post.published_date.year == ARGV[1].to_i }
end
puts "<h1>#{posts.length} shared items</h1>"
puts "<ul>"
posts.each { |post| puts post }
puts "</ul></body></html>"
