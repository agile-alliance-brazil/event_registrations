# encoding: utf-8

module Unparser
  # Class to colorize strings
  class Color
    include Adamantium::Flat, Concord.new(:code)

    # Format text with color
    #
    # @param [String] text
    #
    # @return [String]
    #
    # @api private
    #
    def format(text)
      "\e[#{@code}m#{text}\e[0m"
    end

    NONE = Class.new(self) do

      # Format null color
      #
      # @param [String] text
      #
      # @return [String]
      #   the argument string
      #
      # @api private
      #
      def format(text)
        text
      end

    private

      # Initialize null color
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize
      end

    end.new

    RED   = Color.new(31)
    GREEN = Color.new(32)
    BLUE  = Color.new(34)

  end # Color
end # Unparser
