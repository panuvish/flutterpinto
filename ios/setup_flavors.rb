#!/usr/bin/env ruby

require 'xcodeproj'

# Change to the ios directory
Dir.chdir(File.dirname(__FILE__))

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the Runner target
runner_target = project.targets.find { |target| target.name == 'Runner' }

# Define flavors and their bundle identifiers
flavors = {
  'local' => 'com.fldp.mobileApp.local',
  'dev' => 'com.fldp.mobileApp.dev',
  'prod' => 'com.fldp.mobileApp'
}

# Define app display names
display_names = {
  'local' => 'mobile_app_standard Local',
  'dev' => 'mobile_app_standard Dev',
  'prod' => 'mobile_app_standard'
}

# Get existing Debug and Release configurations
debug_config = project.build_configurations.find { |config| config.name == 'Debug' }
release_config = project.build_configurations.find { |config| config.name == 'Release' }
profile_config = project.build_configurations.find { |config| config.name == 'Profile' }

# Create build configurations for each flavor
flavors.each do |flavor_name, bundle_id|
  # Create Debug configuration for this flavor
  debug_flavor_config = project.add_build_configuration("#{flavor_name}-Debug", :debug)
  debug_flavor_config.build_settings.merge!(debug_config.build_settings) if debug_config

  # Create Release configuration for this flavor
  release_flavor_config = project.add_build_configuration("#{flavor_name}-Release", :release)
  release_flavor_config.build_settings.merge!(release_config.build_settings) if release_config

  # Create Profile configuration for this flavor (Flutter uses this)
  profile_flavor_config = project.add_build_configuration("#{flavor_name}-Profile", :release)
  profile_flavor_config.build_settings.merge!(profile_config.build_settings) if profile_config

  # Set bundle identifier for each configuration in the Runner target
  runner_target.build_configurations.each do |config|
    if config.name.include?("#{flavor_name}-")
      config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = bundle_id
      config.build_settings['DISPLAY_NAME'] = display_names[flavor_name]
      config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
    end
  end
end

# Save the project
project.save

puts "✅ Flavor configurations created successfully!"
puts "Created configurations for: #{flavors.keys.join(', ')}"
