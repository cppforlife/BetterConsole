PROJECT_NAME = "BetterConsole"
CONFIGURATION = "Release"
SDK_VERSION = "6.0"

def build_dir
  File.join(File.dirname(__FILE__), "build").tap do |path|
    Dir.mkdir(path) unless File.exists?(path)
  end
end

def output_file(target)
  File.join(build_dir, "#{target}.output")
end

def system_or_exit(cmd, stdout = nil)
  cmd.gsub!("\n", "")
  cmd += " > #{stdout}" if stdout
  puts "Executing #{cmd}"
  system(cmd) or raise "******** Build failed ********"
end

desc "Build & install"
task :install => :clean do
  system_or_exit <<-BASH, output_file("install")
    xcodebuild
      -project #{PROJECT_NAME}.xcodeproj
      -configuration #{CONFIGURATION}
      install
  BASH
end

desc "Uninstall"
task :uninstall do
  plugins_dir = "~/Library/Application\\ Support/Developer/Shared/Xcode/Plug-ins"
  system_or_exit "rm -rf #{plugins_dir}/#{PROJECT_NAME}.xcplugin"
end

desc "Clean"
task :clean do
  system_or_exit "rm -rf #{build_dir}/*", output_file("clean")
end
