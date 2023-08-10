class ForwardedMailSanitizer

  def call(html:)
    case html
    when /\<br class="Apple-interchange-newline"\>/
      remove_apple_header(html)
    when /\<div class=3D"gmail_quote"\>/
      remove_gmail_header(html)
    else
      html
    end
  end

  def self.call(html:)
    new.call(html: html)
  end

  private 

  def remove_apple_header(html)
    html_doc = Nokogiri::HTML(html)
    # pp html_doc.css('blockquote[type="cite"] > :nth-child(-n+6)')
    html_doc.css('blockquote[type="cite"] > :nth-child(-n+6)').each do |element|
      element.remove
    end
    # puts "-----"
    html_doc.to_html
  end

  def remove_gmail_header(html)
    raise 'TODO'
  end
end