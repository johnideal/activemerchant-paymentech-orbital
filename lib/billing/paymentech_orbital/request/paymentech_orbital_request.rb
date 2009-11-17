class PaymentechOrbitalRequest
  attr_reader :gateway, :options

  def initialize(options={})
    @options = options
  end

  def to_xml
    @_xml ||= build_request(options)
  end

  def headers
    @_headers ||= options[:headers] || {}
  end

  private
  # Delegate these to options hash.
  [:login, :password, :merchant_id, 
   :bin, :terminal_id, :currency_code, 
   :currency_exponent, :customer_ref_num, 
   :order_id].each do |attr|
    define_method(:"#{attr}") do
      options[:"#{attr}"]
    end
  end

  def address
    @_address ||= options[:billing_address] || options[:address] || {}
  end

  def full_street_address
    "#{address[:address1]} #{address[:address2]}".strip
  end

  # Implement me. I should be the parent tag for the request.
  def request_type; "RequestType"; end

  def build_request(options={})
    xml = Builder::XmlMarkup.new(:indent => 2)

    xml.instruct!(:xml, :version => '1.0', :encoding => 'UTF-8')
    xml.tag! "Request" do
      xml.tag! request_type do
        add_authentication(xml)

        request_body(xml)
      end
    end

    xml.target!
  end

  # Implement me. I should take the provided
  # xml builder and add tags to the request.
  def request_body(xml); xml; end

  def add_authentication(xml)
    xml.tag! "OrbitalConnectionUsername", login
    xml.tag! "OrbitalConnectionPassword", password
  end
end