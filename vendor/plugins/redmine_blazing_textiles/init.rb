require 'redmine'

Redmine::Plugin.register :redmine_blazing_textiles do
	name 'Redmine Blazing Textiles plugin'
	author 'J.W.Marsden'
	description 'This plugin is an extender for the the standard textile functionality in Redmine.'
	version '0.0.2'
	url 'http://github.com/openecho/redmine_blazing_textiles'
	author_url 'http://jwm.slavitica.net'
	# Register Blazing Textiles Formatter
	wiki_format_provider 'blazing textiles', BlazingTextiles::WikiFormatter, BlazingTextiles::Helper
end
