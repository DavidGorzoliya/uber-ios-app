# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
end

target 'Uber-clone' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Uber-clone
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
  pod 'Firebase/Storage'
  pod 'GeoFire', '>= 1.1'
  
end
