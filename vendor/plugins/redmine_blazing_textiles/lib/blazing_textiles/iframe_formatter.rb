require 'digest/sha2'

module BlazingTextiles
	class IframeFormatter
		include ActionView::Helpers::TagHelper
		
		def initialize(src)
			@src = src
		end	
		def helpers
		  ActionController::Base.helpers
		end
			
		def to_html(options = {})
			height = 600
			width = "100%"
			out = content_tag(:iframe, 
				"<p>Your browser does not support iframes.</p>", 
				:src => @src.gsub!("&amp;","&"), 
				:class => "iframe", 
				:width => width, 
				:height => height, 
				:style => "border-width:0", 
				:frameborder => 0, 
				:scrolling => "no"
				)
		end	
		
	end
end
