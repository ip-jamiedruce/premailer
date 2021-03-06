require 'optparse'
require 'premailer'

# defaults
options = {
  :base_url => nil,
  :link_query_string => nil,
  :remove_classes => false,
  :verbose => false,
  :line_length => 65,
  :css_to_attributes => false,
  #:remove_ids => false,
  #:remove_comments => false,
  #:reset_contenteditable => true,
  #:css_to_attributes => true,
  #:css_string => nil,
  #:preserve_styles => false,
  #:preserve_reset => true,
  #:debug => false,
  #:include_link_tags => true,
  #:include_style_tags => true,
  #:input_encoding => 'ASCII-8BIT',
  #:replace_html_entities => false,
  #:escape_url_attributes => true,
  #:unescaped_ampersand => false,
  #:create_shorthands => true
}

mode = :html

opts = OptionParser.new do |opts|
  opts.banner = "Improve the rendering of HTML emails by making CSS inline among other things. Takes a path to a local file, a URL or a pipe as input.\n\n"
  opts.define_head "Usage: premailer <optional uri|optional path> [options]"
  opts.separator ""
  opts.separator "Examples:"
  opts.separator "  premailer http://example.com/ > out.html"
  opts.separator "  premailer http://example.com/ --mode txt > out.txt"
  opts.separator "  cat input.html | premailer -q src=email > out.html"
  opts.separator "  premailer ./public/index.html"
  opts.separator ""
  opts.separator "Options:"

  opts.on("--mode MODE", [:html, :txt], "Output: html or txt") do |v|
    mode = v
  end

  opts.on("-b", "--base-url STRING", String, "Base URL, useful for local files") do |v|
    options[:base_url] = v
  end

  opts.on("-q", "--query-string STRING", String, "Query string to append to links") do |v|
    options[:link_query_string] = v
  end

  opts.on("--css FILE,FILE", Array, "Additional CSS stylesheets") do |v|
    options[:css] = v
  end

  opts.on("--cssattr", "Copy related CSS attributes into HTML attribute") do |v|
    options[:css_to_attributes] = v
  end

  opts.on("-r", "--remove-classes", "Remove HTML classes") do |v|
    options[:remove_classes] = v
  end

  opts.on("-j", "--remove-scripts", "Remove <script> elements") do |v|
    options[:remove_scripts] = v
  end

  opts.on("-l", "--line-length N", Integer, "Line length for plaintext (default: #{options[:line_length].to_s})") do |v|
    options[:line_length] = v
  end

  opts.on("-e", "--entities", "Output HTML entities instead of UTF-8 when using Nokogiri") do |v|
    options[:output_encoding] = "US-ASCII"
  end

  opts.on("-d", "--io-exceptions", "Abort on I/O errors") do |v|
    options[:io_exceptions] = v
  end

  opts.on("-v", "--verbose", "Print additional information at runtime") do |v|
    options[:verbose] = v
  end

  opts.on_tail("-?", "--help", "Show this message") do
    puts opts
    exit
  end

  opts.on_tail("-V", "--version", "Show version") do
    puts "Premailer #{Premailer::VERSION} (c) 2008-2010 Alex Dunae, Jamie Druce"
    exit
  end
end
opts.parse!

$stderr.puts "Processing in #{mode} mode with options #{options.inspect}" if options[:verbose]

premailer = nil
input = nil

if ARGV.size > 0
  # Executed via command line or shell script
  input = ARGV.shift
else
  # Called in piped command
  input = $stdin.read
  options[:with_html_string] = true
end

if input
  premailer = Premailer.new(input, options)
else
  puts opts
  exit 1
end

if mode == :txt
  print premailer.to_plain_text
else
  print premailer.to_inline_css
end

exit
