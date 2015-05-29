#!/usr/bin/ruby

class Debride
  module Curly
  end

  ##
  # Process curly and parse the result. Returns the sexp of the parsed
  # ruby.
  def process_curly(path)
    text = File.read(path)

    # A dirty cheat that may break down. Converting the Curly structure
    # to the "vanilla" rails ERB template in which we aren't calling helper
    # methods but instead levaring a receiver.
    text.gsub!(/\{\{[\/\#\^\*\@]? */, '<% dummy.' )
    text.gsub!(/\}\}/, ' %>')

    as_ruby = Erubis.new(text).src

    begin
      RubyParser.for_current_ruby.process(as_ruby, path)
    rescue Racc::ParseError => e
      warn "Parse Error parsing #{path}. Skipping."
      warn "  #{e.message}"
    rescue Timeout::Error
      warn "TIMEOUT parsing #{path}. Skipping."
    end
  end
end