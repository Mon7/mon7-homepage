require 'haml'
require 'aws'

desc 'Render all haml files and copy public files to output'
task :render => :clean do
  haml_options = {:format => :html5, :escape_html => true}
  haml_layout = File.read('views/layout.haml')
  layout = Haml::Engine.new(haml_layout, haml_options)
  FileUtils.mkdir_p 'output'
  Dir['views/*.haml'].each do |f|
    name = File.basename(f, '.haml')
    next if name == 'layout'

    haml_view = File.read(f)
    view = Haml::Engine.new(haml_view, haml_options)
    html = layout.to_html do
      view.to_html
    end
    File.open("output/#{name}.html", 'w+') {|o| o.write html}
  end

  FileUtils.cp_r 'public/.', 'output'
end

desc 'Remove output folder'
task :clean do
  FileUtils.rm_rf 'output/*'
end

desc 'Sync output with s3 bucket www.mon7.se'
task :upload => :render do
  s3 = AWS::S3.new(YAML.load(File.read('aws.yml')))
  objects = s3.buckets['www.mon7.se'].objects
  Dir['output/**/*'].each do |f|
    next if File.directory? f
    objects[f.sub(/output\//,'')].write(File.read f)
  end
  objects.each do |obj|
    unless File.exists? "output/#{obj.key}"
      obj.delete
    end
  end
end
