module BlazingTextiles
	class WikiFormatter
		def initialize(text)
			@text = text
		end	
		def to_html(&block)
			RAILS_DEFAULT_LOGGER.info 'RedmineBlazingTextilesFormatter.to_html'
			@macros_runner = block
			# Wiki Format The Text
			parsedText = Redmine::WikiFormatting::Textile::Formatter.new(@text).to_html
			# Format Any Latex in the Text
			parsedText = parseBlazingInserts(parsedText)
			
		rescue => e
			return(
				"<pre>problem parsing wiki text: #{e.message}\n" +
				"original text: \n" + @text+ "</pre>"
			)
		end
		
		# Regular Expression for Matching (ZA̡͊͠͝LGΌ ISͮ̂҉̯͈͕̹̘̱ TO͇̹̺ͅƝ̴ȳ̳ TH̘Ë͖́̉ ͠P̯͍̭O̚​N̐Y̡ H̸̡̪̯ͨ͊̽̅̾̎Ȩ̬̩̾͛ͪ̈́̀́͘ ̶̧̨̱̹̭̯ͧ̾ͬC̷̙̲̝͖ͭ̏ͥͮ͟Oͮ͏̮̪̝͍M̲̖͊̒ͪͩͬ̚̚͜Ȇ̴̟̟͙̞ͩ͌͝S̨̥̫͎̭ͯ̿̔̀ͅ!)
		BLAZING_REGEX = /<pre[\s]*class="(-?[_a-zA-Z]+[_a-zA-Z0-9-]*)">(.*?)<\/pre>/mi
                  
		def parseBlazingInserts(text)
			text.gsub!(BLAZING_REGEX) { |input|
				out = ""
				if $1 == "latex"
					out << BlazingTextiles::LatexFormatter.new($2).to_html	
				elsif $1 == "iframe"
					out << BlazingTextiles::IframeFormatter.new($2).to_html
				else
					# Found a match but no handler.
					out << input
				end
			}
			text
		end
	end
end
