target :Objektiv do
platform :osx, '12.0'
pod 'MASShortcut',       '~> 2.0'
pod 'CDEvents',          '~> 1.2.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |t|
    t.build_configurations.each { |c| c.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '12.0' }
  end
end
