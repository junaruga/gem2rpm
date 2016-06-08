module Gem2Rpm
  class App

    def self.start
      begin
        app = Gem2Rpm::App.new
        app.run(Gem2Rpm::Configuration.instance.options)
        true
      rescue Exception => e
        Gem2Rpm.show_message(e.message)
        false
      end
    end

    def run(options = {})
      if options[:templates]
        Gem2Rpm.show_templates
        return true
      end
      if options[:version]
        Gem2Rpm.show_version
        return true
      end

      rest = options[:args]

      template =
        Gem2Rpm::Template.find options[:template_file], :gem_file => rest[0]

      if options[:print_template_file]
        puts template.read
        return
      end

      if rest.size != 1
        raise 'Missing GEMFILE'
      end
      gemfile = rest[0]
      out_dir = options[:directory]
      unless File.directory?(out_dir)
        raise "No such directory #{out_dir}"
      end

      if options[:fetch]
        gem_uri = ''
        open("https://rubygems.org/api/v1/gems/#{gemfile}.json") do |f|
          gem_uri = f.read.match(/"gem_uri":\s*"(.*?)",/m)[1]
          gemfile = URI.parse(gem_uri).path.split('/').last
          gemfile = File.join(out_dir, gemfile)
          open(gemfile, 'w') do |gf|
            gf.write(open(gem_uri).read)
          end
        end
      end

      unless File.exist?(gemfile)
        raise "Invalid GEMFILE #{gemfile}"
      end
      srpmdir = nil
      specfile = nil
      if options[:srpm]
        gemname = Gem2Rpm::Package.new(gemfile).spec.name
        srpmdir = `/bin/mktemp -t -d gem2rpm-#{gemname}.XXXXXX`.chomp
        specfile = File.join(srpmdir, "rubygem-#{gemname}.spec")
        options[:output_file] ||= specfile
      end

      # Produce a specfile
      if options[:output_file].nil?
        Gem2Rpm.convert(gemfile, template, $stdout, options[:nongem], options[:local], options[:doc_subpackage]) unless options[:deps]
      else
        begin
          out = open(options[:output_file], "w")
          Gem2Rpm.convert(gemfile, template, out, options[:nongem], options[:local], options[:doc_subpackage])
        ensure
          out.close
        end
      end

      # Create a  source RPM
      if options[:srpm]
        FileUtils.copy(options[:output_file], specfile) unless File.exist?(specfile)
        FileUtils.copy(gemfile, srpmdir)

        build_rpm(srpmdir, out_dir, specfile)
      end

      Gem2Rpm.print_dependencies(gemfile) if options[:deps]
    end

    def get_options
      Gem2Rpm::Configuration.instance.options
    end

    def build_rpm(srpmdir, out_dir, specfile)
      command = "rpmbuild -bs --nodeps --define '_sourcedir #{srpmdir}' " +
        "--define '_srcrpmdir #{out_dir}' #{specfile}"
      unless system(command)
         raise "Command failed: #{command}"
      end
    end
  end
end
