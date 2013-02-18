module RakeHelper
  def build_dir(effective_platform_name)
    File.join(BUILD_DIR, CONFIGURATION + effective_platform_name)
  end

  def system_or_exit(cmd, stdout = nil)
    puts "Executing #{cmd}"
    cmd += " > #{stdout}" if stdout
    system(cmd) or raise "******** Build failed ********"
  end

  def output_file(target)
    output_dir = if ENV['IS_CI_BOX']
                   ENV['CC_BUILD_ARTIFACTS']
                 else
                   Dir.mkdir(BUILD_DIR) unless File.exists?(BUILD_DIR)
                   BUILD_DIR
                 end

    output_file = File.join(output_dir, "#{target}.output")
    puts "Output: #{output_file}"
    output_file
  end
end