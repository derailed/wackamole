require 'json'
require 'will_paginate/view_helpers/base'
require 'will_paginate/view_helpers/link_renderer'

# BOZO !! Refact helpers...
module WillPaginate::ViewHelpers
  class LinkRenderer
    def url( page )
      "#{@options[:params][:url]}/#{page}"
    end
  end
end
   
module MainHelper  
 helpers do   
    include WillPaginate::ViewHelpers::Base   
    
    def pluralize( count, name )
      count.to_s + " " + name + (count.to_i > 1 ? "s" : "")
    end
        
    def javascript_tag( code )
      content_tag( :script, code )
    end
    
    def remote_function(options)
      jq_options = {}
      jq_options[:beforeSend] = options[:before] if options.has_key?( :before )
      jq_options[:complete]   = options[:complete] if options.has_key?( :complete )
      jq_options[:success]    = options[:success] if options.has_key?( :success )
      jq_options[:error]      = options[:error] if options.has_key?( :error )      
      jq_options[:url]        = options[:url]  if options.has_key?( :url )
      jq_options[:data]       = options[:data] if options.has_key?( :data )      
      jq_options[:dataType]   = options[:data_type] || 'script'
      jq_options[:type]       = options[:type] || "GET"
            
      buff = []
      jq_options.each_pair { |k,v| buff << "#{k}:'#{v}'" }
      
      "$.ajax({#{buff.join( "," )}})"
    end    
    
    def periodically_call_remote(options = {})
      frequency = options[:frequency] || 10 # every ten seconds by default
      code = "setInterval(function() {#{remote_function(options)}}, #{frequency} * 1000)"
      javascript_tag(code)
    end
    
    def content_tag( tag, content, opts={} )
      "<#{tag} #{html_options( opts )}>#{content}</#{tag}>"
    end
    
    def options_for_select( list, selection )
      buff = []
      list.each do |option|
        opts = {}
        if option.is_a? Array
          opts[:value]    = option.last
          content         = option.first
          opts[:selected] = "selected" if option.last == selection
        else
          content         = option
          opts[:value]    = option
          opts[:selected] = "selected" if option == selection          
        end
        buff << content_tag( :option, content, opts )
      end
      buff.join( "\n" )
    end
    
    def image_tag( name, opts={} )
      "<img src=\"/images/#{name}\" #{html_options( opts )}/>"
    end
    
    def link_to_remote( name, url, opts={} )
      "<a href=\"#\" onclick=\"#{remote_function({:url=>url})};return false;\" #{html_options(opts)}>#{name}</a>"
    end
    
    # def form_remote_tag( name, opts={}, html_opts={} )
    #   "<form onsubmit=\"#{remote_function(opts)};return false;\" #{html_options(html_opts)}></form>"
    # end
    
    def link_to( name, url, opts={} )
      "<a href=\"#{url}\" #{html_options(opts)}>#{name}</a>"
    end
      
    def html_options( opts )
      html = []
      html << "id=\"#{opts[:id]}\""         if opts.has_key?( :id )
      html << "border=\"#{opts[:border]}\"" if opts.has_key?( :border )
      html << "class=\"#{opts[:class]}\""   if opts.has_key?( :class )
      if opts.has_key?( :size )
        size = opts[:size]
        width, height = size.split( 'x' )
        style = "width:#{width}px;height:#{height}px;"
        if opts[:style]
          opts[:style] += ";#{style}"
        else
          opts[:style] = style
        end
      end      
      html << "style=\"#{opts[:style]}\""   if opts.has_key?( :style )
      html << "selected=\"selected\""       if opts.has_key?( :selected )
      html << "value=\"#{opts[:value]}\""   if opts.has_key?( :value )
      html.empty? ? "" : html.join( " " )
    end
    
    def stylesheets( styles )
      buff = []
      styles.each do |style|
        buff << "<link rel=\"stylesheet\" href=\"#{v_styles( style )}\" type=\"text/css\" media=\"screen\" />"
      end
      buff.join( "\n" )
    end
    
    def javascripts( scripts )
      buff = []
      scripts.each do |script|
        buff << "<script src=\"#{v_js( script )}\" type=\"text/javascript\"></script>"
      end
      buff.join( "\n" )      
    end
          
    def v_styles(stylesheet)
      "/stylesheets/#{stylesheet}.css?" + File.mtime(File.join(Sinatra::Application.public, "stylesheets", "#{stylesheet}.css")).to_i.to_s
    end
    
    def v_js(js)
      "/javascripts/#{js}.js?" + File.mtime(File.join(Sinatra::Application.public, "javascripts", "#{js}.js")).to_i.to_s
    end
      
    # truncate a string - won't work for multibyte      
    def truncate(text, length = 30, truncate_string = "...")
      return "" if text.nil?
      l = length - truncate_string.size
      text.size > length ? (text[0...l] + truncate_string).to_s : text
    end
      
    def align_for( value )
      return "right" if value.is_a?(Fixnum)
      "left"
    end
    
    # Add thousand markers
    def format_number( value )
      return value.to_s.gsub(/(\d)(?=\d{3}+(\.\d*)?$)/, '\1,') if value.instance_of?(Fixnum)
      value
    end
               
    def partial( page, options={} )
      if object = options.delete(:object)        
        template = page.to_s.split("/").last
        options.merge!( :locals => { template.to_sym => object } )
      end
      
      if page.to_s.index( /\// )
        page = page.to_s.gsub( /\//, '/_' ) 
      else 
        page = "_" + page.to_s
      end
      erb page.to_sym, options.merge!( :layout => false )
    end
   
    JS_ESCAPE_MAP = 
    {
      '\\'    => '\\\\',
      '</'    => '<\/',
      "\r\n"  => '\n',
      "\n"    => '\n',
      "\r"    => '\n',
      '"'     => '\\"',
      "'"     => "\\'" 
    }   
    def escape_javascript(javascript)
      if javascript
         javascript.gsub(/(\\|<\/|\r\n|[\n\r"'])/) { JS_ESCAPE_MAP[$1] }
      else
         ''
      end
    end    
  end  
end