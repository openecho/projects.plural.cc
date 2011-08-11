require 'digest/sha2'

module BlazingTextiles
	class LatexFormatter
		include ActionView::Helpers::TagHelper
		
		LATEX_FILE_SUFFIX = ".tex"
		DVI_FILE_SUFFIX = ".dvi"
		PNG_FILE_SUFFIX = ".png"
		LOG_FILE_SUFFIX = ".log"
		
		def initialize(source)
			fixed_source = source;
			# Replace &
			fixed_source = fixed_source.sub('&#38;','&');
			# Replace >
			fixed_source = fixed_source.sub('&gt;','>');
			# Replace <
			fixed_source = fixed_source.sub('&lt;','<');
			
			@source = fixed_source;
			@tmp = File.join([RAILS_ROOT, 'tmp', 'blazing_textiles'])
			@name = Digest::SHA256.hexdigest(source)
		end	
		
#		def helpers
#			BlazingTextiles::Helper.instance.params = self.params
#			BlazingTextiles::Helper.instance
#		end
		def helpers
		  ActionController::Base.helpers
		end
			
		def to_html(options = {})
			# Create base asset directory if it does not exist
			if !File::directory?(@tmp)
				begin
					Dir.mkdir(@tmp)
				rescue
				end
			end
		
			# Check if latex image file exists
			image_file = File.join([@tmp,@name + PNG_FILE_SUFFIX])
			
			out = ""
			if File.file?(image_file)
				# If File Exists, Serve Image File
				out << tag(:img, :src => "http://#{Setting.host_name}/latex/image?image_id=#{@name}", :class => "latex")
			else
				# If No File, Create One
				latex_file = File.join([@tmp,@name + LATEX_FILE_SUFFIX])
				dvi_file = File.join([@tmp,@name + DVI_FILE_SUFFIX])
				log_file = File.join([@tmp,@name + LOG_FILE_SUFFIX])
				image_file = File.join([@tmp,@name + PNG_FILE_SUFFIX])
				create_latex_file(latex_file)
				compile_latex_file(latex_file,dvi_file,log_file)
				if File.file?(dvi_file)
					convert_dvi_to_png(dvi_file,image_file,log_file)
					if File.file?(image_file)
						# Serve Image
						out << tag(:img, :src => "http://#{Setting.host_name}/latex/image?image_id=#{@name}", :class => "latex")
					else
						# Image Create Fail, Serve Log
					end
				else	
					# DVI Create Fail, Serve Log	
				end
			end
			out
		end
		
		private
		def create_latex_file(latex_file)
			latex_file_handle = File.open(latex_file,'w')
			# TODO: Make this a configuration
			latex_file_handle.puts('\documentclass[10pt]{article}')
			latex_file_handle.puts('\usepackage[margin=0px,noheadfoot]{geometry}')
			latex_file_handle.puts('\pagestyle{empty}')
	
			# TODO: Make this a configuration
			latex_file_handle.puts('\usepackage{algorithmic}')
			latex_file_handle.puts('\usepackage{amsmath}')
			latex_file_handle.puts('\usepackage{amsfonts}')
			latex_file_handle.puts('\usepackage{amssymb}')
			latex_file_handle.puts('\usepackage{color}')
			
			# Write the latex contents
			latex_file_handle.puts('\begin{document}')
			
			latex_file_handle.puts '% Start User Latex'
			latex_file_handle.puts ''
			
			latex_file_handle.puts @source
			
			latex_file_handle.puts ''
			latex_file_handle.puts '% End User Latex'
			latex_file_handle.puts '\end{document}'
			
			# Close the file
			latex_file_handle.flush
			latex_file_handle.close
		end
		
		def compile_latex_file(latex_file,dvi_file,log_file)
			latex_command = "/usr/bin/latex --interaction=nonstopmode -output-directory=" + @tmp + " " + latex_file
			RAILS_DEFAULT_LOGGER.info "Latex Compile: '" + latex_command + "'"
			fork_exec(latex_command + " > " + log_file)	
		end
		
		def convert_dvi_to_png(dvi_file,image_file,log_file)
			dvipng_command = "/usr/bin/dvipng -v " + dvi_file + " -o " + image_file
			RAILS_DEFAULT_LOGGER.info "Dvipng Command: '" + dvipng_command + "'"
			fork_exec(dvipng_command + " >> " + log_file)	
		end
		
		def fork_exec(cmd)
			pid = fork {
				exec(cmd)
				exit! ec
			}
			ec = nil
			begin
				Process.waitpid pid
				ec = $?.exitstatus
			rescue
			end
		end
		

	end	
	

 
    	
end
