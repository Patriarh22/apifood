 module Models 
 	extend ActiveSupport::Concern
    cattr_accessor :url

	included do
      validates_uniqueness_of :tele_chat_id
  
    end
    
    module Events
     APPLICATION_NAME = 'Apifood'	
      
      def get_events
       client = Google::APIClient.new
       client.authorization.access_token = self.oauth_token
       service = client.discovered_api('calendar', 'v3')
       result = client.execute(
        :api_method => service.events.list,
        :parameters => {
            :calendarId => 'primary',
            :maxResults => 10,
            :singleEvents => true,
            :orderBy => 'startTime',
            :timeMin => Time.now.iso8601 })

        result.data['items']
        end
    
    end



    cattr_accessor :url
  	@@next_update_id = 0

    def self.configure_home_url(url)
      @@home_url = url
    end

    def self.configure_dev_url(url)
      @@dev_url = url
    end

    def self.active_url
      if Rails.env.production?
        @@home_url
      else
        @@dev_url
      end
    end

    def self.configure_token(token)
      if token =~ /^[0-9]+:[\w-]+$/ #hacker proof
        @@token = token
        self.url ||= "https://api.telegram.org/bot" + token + "/"
        @@callback_url = active_url + "/" + @@token
        RestClient.post(self.url + "setWebhook", { url: @@callback_url })
      else
        raise "Invalid token!"
      end
    end

    def self.send_message_to_all(text)
      success = true
       User.all.each do |user|
        success = false if !user.send_message(text)
      end
      success
    end

    def send_message(text)
      response = JSON.parse(RestClient.post(self.url + "sendMessage", chat_id: self.tele_chat_id, text: text), { symbolize_names: true })
      response[:ok]
    end


end


