require 'haml'
require 'aws'
require 'mime/types'

task :start do
  exec 'ruby app.rb'
end

desc 'Render all haml files and copy public files to output'
task :render => :clean do
  haml_options = {:format => :html5, :escape_html => true}
  haml_layout = File.read('views/layout.haml')
  layout = Haml::Engine.new(haml_layout, haml_options)
  Dir['views/*.haml'].each do |f|
    name = File.basename(f, '.haml')
    next if name == 'layout'

    haml_view = File.read(f)
    view = Haml::Engine.new(haml_view, haml_options)
    html = layout.to_html(Object.new, {:name=>name}) do
      view.to_html
    end
    File.open("output/#{name}.html", 'w+') {|o| o.write html}
  end

  FileUtils.cp_r 'public/.', 'output'
end

desc 'Recreate the output folder'
task :clean do
  FileUtils.rm_rf 'output'
  FileUtils.mkdir_p 'output'
end

desc 'Sync output with s3 bucket www.mon7.se'
task :upload => :render do
  s3 = AWS::S3.new(YAML.load(File.read('aws.yml')))
  objects = s3.buckets['www.mon7.se'].objects
  files = Dir['output/**/*'].select{ |f| File.file? f }

  objects.each do |obj|
    if f = files.find {|f| f == "output/#{obj.key}" }
      md5 = Digest::MD5.file(f).to_s
      if not obj.etag[1..-2] == md5
        ct = MIME::Types.of(f).first
        puts "Updating: #{f} Content-type: #{ct}"
        objects[f.sub(/output\//,'')].write(:file => f, :content_type => ct)
      else
        puts "Not changed: #{f}"
      end
      files.delete f
    else
      obj.delete
      puts "deleted: #{obj.key}"
    end
  end

  files.each do |f|
    ct = MIME::Types.of(f).first
    puts "Uploading: #{f} Content-type: #{ct}"
    objects[f.sub(/output\//,'')].write(:file => f, :content_type => ct)
  end
end
