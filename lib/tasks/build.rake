namespace :buildit do
  desc "Build project"
  task :install => :clean do
    puts "xcodebuild -project #{PROJECT_NAME}.xcodeproj -configuration #{CONFIGURATION}  install"
    system_or_exit "xcodebuild -project #{PROJECT_NAME}.xcodeproj -configuration #{CONFIGURATION}  install", output_file("install")
  end

  desc "Clean project"
  task :clean do
    puts "rm -rf #{BUILD_DIR}/*"
    system_or_exit "rm -rf #{BUILD_DIR}/*", output_file("clean")
  end
end