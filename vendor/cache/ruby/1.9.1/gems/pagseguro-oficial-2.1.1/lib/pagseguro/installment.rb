module PagSeguro
  class Installment
    include Extensions::MassAssignment

    # Set the credit card brand.
    attr_accessor :card_brand

    # Set the installments quantity.
    attr_accessor :quantity

    # Set the amount.
    # Must fit the patern: \\d+.\\d{2} (e.g. "12.00")
    attr_accessor :amount

    # Set total amount.
    attr_accessor :total_amount

    # Set interest free.
    attr_accessor :interest_free

    # Find installment options by a given amount
    # Optional. Credit card brand
    # Return an Array of PagSeguro::Installment instances
    def self.find(amount, card_brand = nil)
      string = "installments?amount=#{amount}"
      string += "&cardBrand=#{card_brand}" if card_brand
      load_from_response Request.get(string, 'v2')
    end

    # Serialize the HTTP response into data.
    def self.load_from_response(response) # :nodoc:
      if response.success? and response.xml?
        Nokogiri::XML(response.body).css("installments > installment").map do |node|
          load_from_xml(node)
        end
      else
        Response.new Errors.new(response)
      end
    end

    # Serialize the XML object.
    def self.load_from_xml(xml) # :nodoc:
      new Serializer.new(xml).serialize
    end
  end
end
