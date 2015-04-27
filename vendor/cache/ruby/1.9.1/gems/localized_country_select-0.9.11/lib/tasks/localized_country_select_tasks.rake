require 'rubygems'
require 'open-uri'
require 'active_support/inflector'
require 'csv'

# Rake task for importing country names from Unicode.org's CLDR repository
# (http://www.unicode.org/cldr/data/charts/summary/root.html).
#
# It parses a HTML file from Unicode.org for given locale and saves the
# Rails' I18n hash in the plugin +locale+ directory
#
# Don't forget to restart the application when you add new locale to load it into Rails!
#
# == Parameters
#   LOCALE (required): Sets the locale to use. Output file name will include this.
#   FORMAT (optional): Output format, either 'rb' or 'yml'. Defaults to 'rb' if not specified.
#   WEB_LOCALE (optional): Forces a locale code to use when querying the Unicode.org CLDR archive.
#   PARSER (optional): Forces parser to use. Available are nokogiri, hpricot and libxml.
#
# == Examples
#   rake import:country_select LOCALE=de
#   rake import:country_select LOCALE=pt-BR WEB_LOCALE=pt FORMAT=yml
#
# The code is deliberately procedural and simple, so it's easily
# understandable by beginners as an introduction to Rake tasks power.
# See https://github.com/svenfuchs/ruby-cldr for much more robust solution

namespace :import do

  desc "Import country codes and names for various languages from the Unicode.org CLDR archive."
  task :country_select do
    # TODO : Implement locale import chooser from CLDR root via Highline

    # Setup variables
    locale = ENV['LOCALE']
    unless locale
      puts "\n[!] Usage: rake import:country_select LOCALE=de\n\n"
      exit 0
    end

    # convert locale code to Unicode.org CLDR acceptable code
    web_locale = if ENV['WEB_LOCALE'] then ENV['WEB_LOCALE']
                 elsif %w(zht zhtw).include?(locale.downcase.gsub(/[-_]/,'')) then 'zh_Hant'
                 elsif %w(zhs zhcn).include?(locale.downcase.gsub(/[-_]/,'')) then 'zh_Hans'
                 else locale.underscore.split('_')[0] end

    # ----- Get the CLDR HTML     --------------------------------------------------
    begin
      puts "... getting the HTML file for locale '#{web_locale}'"
      url = "http://www.unicode.org/cldr/data/charts/summary/#{web_locale}.html"
      html = open(url).read
    rescue => e
      puts "[!] Invalid locale name '#{web_locale}'! Not found in CLDR (#{e})"
      exit 0
    end


    set_parser(ENV['PARSER']) if ENV['PARSER']
    puts "... parsing the HTML file using #{parser.name.split("::").last}"
    countries = parser.parse(html).inject([]) { |arr, (_code, attrs)| arr << attrs }
    countries.sort_by! { |c| c[:code] }
    puts '... fetching correct list of country codes and filtering translations'
    correct_list = CSV.parse(open('https://raw.githubusercontent.com/datasets/un-locode/master/data/country-codes.csv').string)
    country_codes = correct_list.map { |c| c[0] }
    countries.delete_if { |c| !country_codes.member?(c[:code].to_s) }
    puts "\n\n... imported #{countries.count} countries:"

    puts countries.map { |c| "#{c[:code]}: #{c[:name]}" }.join(", ")


    # ----- Prepare the output format     ------------------------------------------

    format = if ENV['FORMAT'].nil?||%(rb ruby).include?(ENV['FORMAT'].downcase) then :rb
             elsif %(yml yaml).include?(ENV['FORMAT'].downcase) then :yml end

    unless format
      puts "\n[!] FORMAT must be either 'rb' or 'yml'\n\n"
      exit 0
    end

    if format==:yml
      output =<<HEAD
#{locale}:
  countries:
HEAD
      countries.each do |country|
        output << "    \"#{country[:code]}\": \"#{country[:name]}\"\n"
      end

    else # rb format
    output = "#encoding: UTF-8\n"
    output <<<<HEAD
{ :#{locale} => {

    :countries => {
HEAD
    countries.each do |country|
      output << "\t\t\t:#{country[:code]} => \"#{country[:name]}\",\n"
    end
    output <<<<TAIL
    }

  }
}
TAIL
    end

    # ----- Write the parsed values into file      ---------------------------------
    puts "\n... writing the output"
    filename = Rails.root.join('config', 'locales', "countries.#{locale}.#{format}")
    if filename.exist?
      filename = Pathname.new("#{filename.to_s}.NEW")
    end
    File.open(filename, 'w+') { |f| f << output }
    puts "\n---\nWritten values for the '#{locale}' into file: #{filename}\n"
    # ------------------------------------------------------------------------------
  end

  module LocalizedCountrySelectTasks
    class Parser
      attr_reader :html

      def initialize(html)
        @html = html
      end

      def self.parse(html)
        self.new(html).parse
      end

      def parse
        raise NotImplementedError, "#parse method need to be implemented in child class!"
      end
    end

    class NokogiriParser < Parser
      def document
        @document ||= Nokogiri::HTML(html)
      end

      def parse
        document.search("//tr").inject({}) do |hash, row|
          n = row.search("td[@class='n']")
          g = row.search("td")
          if n.inner_html =~ /Locale Display Names/ && g.count >= 6 && g[4].inner_html =~ /^[A-Z]{2}$/
            code = g[4].inner_text
            code = code[-code.size, 2].to_sym
            name = row.search("td[@class='v']:not([@title])").inner_text

            hash[code] = {:code => code, :name => name.to_s}
          end
          hash
        end
      end
    end

    class HpricotParser < NokogiriParser
      def document
        @document ||= Hpricot(html)
      end
    end

    class LibXMLParser < Parser
      def document
        @document ||= LibXML::XML::HTMLParser.string(html, options: LibXML::XML::HTMLParser::Options::RECOVER).parse
      end

      def parse
        document.find("//tr").inject({}) do |hash, row|
          n = row.find("td[@class='n']")
          g = row.find("td")
          if n.map(&:content).join =~ /Locale Display Names/ && g.count >= 6 && g[4].inner_xml =~ /^[A-Z]{2}/
            code = g[4].content
            code = code[-code.size, 2].to_sym
            name = row.find("td[@class='v' and not(@title)]").map(&:content).join

            hash[code] ||= {:code => code, :name => name.to_s}
          end
          hash
        end
      end
    end

    REQUIREMENTS_MAP = [
        ['nokogiri', :Nokogiri],
        ['hpricot', :Hpricot],
        ['libxml', :LibXML]
    ]

    def self.detect_parser
      REQUIREMENTS_MAP.each do |library, klass|
        return const_get(:"#{klass}Parser") if const_defined?(klass)
      end

      REQUIREMENTS_MAP.each do |library, klass|
        begin
          require library
          return const_get(:"#{klass}Parser")
        rescue LoadError
        end
      end

      raise StandardError, "One of nokogiri, hpricot or libxml-ruby gem is required! Add \"gem 'nokogiri'\" to your Gemfile to resolve this issue."
    end
  end

  def parser
    @parser ||= LocalizedCountrySelectTasks.detect_parser
  end

  def set_parser(arg)
    @parser = begin
      parser = nil
      requirements = LocalizedCountrySelectTasks::REQUIREMENTS_MAP
      found = requirements.detect { |library, _| library == arg }
      raise ArgumentError, "Can't find parser for #{arg}! Supported parsers are: #{requirements.map(&:first).join(", ")}." unless found
      library, klass = found
      begin
        require library
        parser = LocalizedCountrySelectTasks.const_get(:"#{klass}Parser")
      rescue LoadError
        gem_name = library == 'libxml' ? 'libxml-ruby' : library
        raise ArgumentError, "Can't find #{library} library! Add \"gem '#{gem_name}'\" to Gemfile."
      end
      parser
    end
  end
end
