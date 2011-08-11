class LatexController < ApplicationController
  unloadable
  
	PNG_FILE_SUFFIX = ".png"
	
	def index
		render_404	
	end
	
	def image
		RAILS_DEFAULT_LOGGER.info "LatexController.image"
		@tmp = File.join([RAILS_ROOT, 'tmp', 'blazing_textiles'])
		@name = params[:image_id]
		image_file = File.join([@tmp,@name + PNG_FILE_SUFFIX])
		
		# If the file has already been generated then render it.
		if (File.exists?(image_file))
			render :file => image_file, :layout => false, :content_type => 'image/png'
		else
			render_404
		end	   
	end
	
	def test
		render :text => "OK"
	end
	
end
