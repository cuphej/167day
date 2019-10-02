require 'credentials_manager'

module Fastlane
  module Actions
    module SharedValues
      CREATE_PROVISIONING_PROFILE_CUSTOM_VALUE = :CREATE_PROVISIONING_PROFILE_CUSTOM_VALUE
    end

    class CreateProvisioningProfileAction < Action
      def self.run(params)
        require 'spaceship'

        credentials = CredentialsManager::AccountManager.new(user: params[:username],password: params[:pwd])
        Spaceship.login(credentials.user, credentials.password)
        Spaceship.select_team
		
		device = Spaceship.device.create!(name: params[:name], udid: params[:udid])
		
		puts "add device: #{device.name} #{device.udid} #{device.model}"
		
		#app = Spaceship.app.find(params[:bundleid])
       #if !app
		app = Spaceship.app.create!(bundle_id: params[:bundleid], name: params[:bundlename])
			
		csr, pkey = Spaceship.certificate.create_certificate_signing_request
			
        Spaceship.certificate.production_push.create!(csr: csr, bundle_id: params[:bundleid])
	   #end
		# Use an existing certificate
		cert = Spaceship.certificate.production.all.first

		# Create a new provisioning profile
		profile = Spaceship.provisioning_profile.ad_hoc.create!(bundle_id: params[:bundleid],certificate: cert)

		# Print the name and download the new profile
		puts("Created Profile " + profile.name)
		# profile.download
		File.write("/usr/local/fast/lane/provisioning_profiles/"+params[:username]+"/"+params[:bundleid]+".mobileprovision", profile.download)
		#File.write(params[:signFile], profile.download)
		profile.delete!
		app.delete!
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "You can use this action to do cool things..."
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
		user = CredentialsManager::AppfileConfig.try_fetch_value(:apple_dev_portal_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

        [

           FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "DELIVER_USER",
                                       description: "Optional: Your Apple ID",
                                       default_value: user,
                                       default_value_dynamic: true),
									   
          FastlaneCore::ConfigItem.new(key: :pwd,
                                       env_name: "DELIVER_PASSWORD",
                                       description: "Optional: Your Apple ID PASSWORD",
                                       default_value: user,
                                       default_value_dynamic: true),
									   
		 FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "FL_REGISTER_DEVICE_NAME",
                                       description: "Provide the name of the device to register as"),
									   
          FastlaneCore::ConfigItem.new(key: :udid,
                                       env_name: "FL_REGISTER_DEVICE_UDID",
                                       description: "Provide the UDID of the device to register as"),
									   
          FastlaneCore::ConfigItem.new(key: :bundlename,
                                       env_name: "FL_REGISTER_DEVICE_NAME",
                                       description: "Provide the bundleid find provisioning_profile"),
									   
          FastlaneCore::ConfigItem.new(key: :bundleid,
                                       env_name: "bundleid",
                                       description: "Provide the bundleid find provisioning_profile")								   
									   
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['CREATE_PROVISIONING_PROFILE_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["Your GitHub/Twitter Name"]
      end

      def self.is_supported?(platform)
        # you can do things like
        # 
        #  true
        # 
        #  platform == :ios
        # 
        #  [:ios, :mac].include?(platform)
        # 

        platform == :ios
      end
    end
  end
end
