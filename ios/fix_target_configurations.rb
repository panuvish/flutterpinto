#!/usr/bin/env ruby

require 'xcodeproj'

# Change to the ios directory
Dir.chdir(File.dirname(__FILE__))

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the Runner target
runner_target = project.targets.find { |target| target.name == 'Runner' }

# Define flavors
flavors = ['local', 'dev', 'prod']
base_configs = ['Debug', 'Release', 'Profile']

# Get existing configurations
existing_config_names = runner_target.build_configurations.map(&:name)

puts "Existing Runner target configurations: #{existing_config_names.join(', ')}"

# Add flavor configurations to Runner target if they don't exist
flavors.each do |flavor|
  base_configs.each do |base_config|
    config_name = "#{flavor}-#{base_config}"

    unless existing_config_names.include?(config_name)
      # Find the project-level configuration
      project_config = project.build_configurations.find { |c| c.name == config_name }

      if project_config
        # Add configuration to Runner target by duplicating the base configuration
        base_target_config = runner_target.build_configurations.find { |c| c.name == base_config }

        if base_target_config
          new_config = runner_target.add_build_configuration(config_name, project_config.type)

          # Copy settings from base configuration
          new_config.build_settings = base_target_config.build_settings.dup

          # Set flavor-specific bundle identifier and display name
          bundle_ids = {
            'local' => 'com.fldp.mobileApp.local',
            'dev' => 'com.fldp.mobileApp.dev',
            'prod' => 'com.fldp.mobileApp'
          }

          display_names = {
            'local' => 'mobile_app_standard Local',
            'dev' => 'mobile_app_standard Dev',
            'prod' => 'mobile_app_standard'
          }

          new_config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = bundle_ids[flavor]
          new_config.build_settings['DISPLAY_NAME'] = display_names[flavor]

          puts "Added #{config_name} to Runner target"
        end
      end
    end
  end
end

# Save the project
project.save

puts "\n✅ Runner target configurations updated successfully!"
puts "Runner target now has: #{runner_target.build_configurations.map(&:name).join(', ')}"
