module ApplicationHelper

  # ---------------------------------------------------------------------------  
  # Display flash if any?
  def flash_messages
    messages = flash.keys.select{ |k| [:error, :info, :warning].include?(k) }
puts "MESSAGES !!!"    
puts messages.inspect    
    return messages if messages.empty?
    formatted_messages = messages.map do |type|
      content_tag :div, :class => type.to_s do
        flash[type]
      end
    end
    formatted_messages.join
  end
end
