# # frozen_string_literal: true

# # TODO: DEPRECATED

# class ForwardedMailSanitizer
#   def call(html:)
#     case html
#     when /<br class="Apple-interchange-newline">/
#       remove_apple_header(html)
#     when /<div class="gmail_quote">/
#       remove_gmail_header(html)
#     else
#       html
#     end
#   end

#   def self.call(html:)
#     new.call(html: html)
#   end

#   private

#   def remove_apple_header(html)
#     transform_html(html) do |html_doc|
#       html_doc.css('blockquote[type="cite"] > :nth-child(-n+6)').each(&:remove)
#     end
#   end

#   def remove_gmail_header(html)
#     transform_html(html) do |html_doc|
#       html_doc.css('div.gmail_attr').each(&:remove)
#     end
#   end

#   def transform_html(html)
#     html_doc = Nokogiri::HTML(html)
#     yield html_doc
#     html_doc.to_html
#   end
# end
