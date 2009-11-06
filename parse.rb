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
    date = published_date.strftime("%A %d %B %Y, %H:%M")
    "<li><a href=\"#{article_url}\">#{article_title}</a> (<a href=\"#{source_url}\">#{source_title}</a>, #{date})</li>"
  end
end

reader = XML::Reader.file(ARGV[0])
in_entry = false
in_title = false
in_published = false
in_content = false
in_source = false

post = nil
posts = []

while reader.read

  # ==============================
  # Opening tags
  # ==============================
  if reader.node_type == XML::Reader::TYPE_ELEMENT && reader.name == "entry"
    in_entry = true
    post = Post.new
  end

  if in_entry && reader.node_type == XML::Reader::TYPE_ELEMENT && reader.name == "content"
    in_content = true
  end

  if in_entry && reader.node_type == XML::Reader::TYPE_ELEMENT && reader.name == "title"
    in_title = true
  end

  if in_entry && reader.node_type == XML::Reader::TYPE_ELEMENT && reader.name == "link"
    reader.move_to_attribute "href"
    if in_source
      post.source_url = reader.value
    else
      post.article_url = reader.value
    end
  end

  if in_entry && reader.node_type == XML::Reader::TYPE_ELEMENT && reader.name == "source"
    in_source = true
  end
  
  if in_entry && reader.node_type == XML::Reader::TYPE_ELEMENT && reader.name == "published"
    in_published = true
  end
  
  # ==============================
  # Tag contents
  # ==============================
  if in_entry && in_title && !in_source && reader.node_type == XML::Reader::TYPE_TEXT
    post.article_title = reader.value
  end

  if in_entry && in_title && in_source && reader.node_type == XML::Reader::TYPE_TEXT
    post.source_title = reader.value
  end

  if in_entry && in_published && reader.node_type == XML::Reader::TYPE_TEXT
    post.published_date = Time.parse(reader.value)
  end
  
  if in_entry && in_content && reader.node_type == XML::Reader::TYPE_TEXT
    post.content_text = reader.value
  end

  # ==============================
  # Closing tags
  # ==============================
  if in_entry && in_published && reader.node_type == XML::Reader::TYPE_END_ELEMENT && reader.name == "published"
    in_published = false
  end

  if in_entry && in_title && reader.node_type == XML::Reader::TYPE_END_ELEMENT && reader.name == "title"
    in_title = false
  end

  if in_entry && in_source && reader.node_type == XML::Reader::TYPE_END_ELEMENT && reader.name == "source"
    in_source = false
  end

  if in_entry && in_content && reader.node_type == XML::Reader::TYPE_END_ELEMENT && reader.name == "content"
    in_content = false
  end

  if in_entry && reader.node_type == XML::Reader::TYPE_END_ELEMENT && reader.name == "entry"
    in_entry = false
    posts << post
  end
end

posts.sort! {|x, y| x.published_date <=> y.published_date }

# Output all the articles of the year passed as parameter, or just all of them
puts "<html><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" /><body><ul>"
if ARGV.count == 1
  posts.each { |post| puts post }
else
  posts.select { |post| post.published_date.year == ARGV[1].to_i }.each { |post| puts post }
end
puts "</ul></body></html>"
