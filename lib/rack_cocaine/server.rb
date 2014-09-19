require 'optparse'
require 'rack'
require_relative './handler'

module RackCocaine

  class Server < Rack::Server

    class Options
      def parse!(args)
        options = {}
        opt_parser = OptionParser.new("", 24, '  ') do |opts|
          opts.banner = "Usage: cocaine-rackup [ruby options] [rack options] [rackup config]"

          opts.separator ""
          opts.separator "Ruby options:"

          lineno = 1
          opts.on("-e", "--eval LINE", "evaluate a LINE of code") { |line|
            eval line, TOPLEVEL_BINDING, "-e", lineno
            lineno += 1
          }

          opts.on("-b", "--builder BUILDER_LINE", "evaluate a BUILDER_LINE of code as a builder script") { |line|
            options[:builder] = line
          }

          opts.on("-d", "--debug", "set debugging flags (set $DEBUG to true)") {
            options[:debug] = true
          }
          opts.on("-w", "--warn", "turn warnings on for your script") {
            options[:warn] = true
          }
          opts.on("-q", "--quiet", "turn off logging") {
            options[:quiet] = true
          }

          opts.on("-I", "--include PATH",
                  "specify $LOAD_PATH (may be used more than once)") { |path|
            (options[:include] ||= []).concat(path.split(":"))
          }

          opts.on("-r", "--require LIBRARY",
                  "require the library, before executing your script") { |library|
            options[:require] = library
          }

          opts.separator ""
          opts.separator "Rack options:"
          options[:server] = 'cocaine'

          opts.on('--app NAME', 'Worker name') { |a| options[:app] = a }
          opts.on('--locator ADDRESS', 'Locator address') { |a| options[:locator] = a }
          opts.on('--uuid UUID', 'Worker uuid') { |a| options[:uuid] = a }
          opts.on('--endpoint ENDPOINT', 'Worker endpoint') { |a| options[:endpoint] = a }


          opts.on("-O", "--option NAME[=VALUE]", "pass VALUE to the server as option NAME. If no VALUE, sets it to true. Run '#{$0} -s SERVER -h' to get a list of options for SERVER") { |name|
            name, value = name.split('=', 2)
            value = true if value.nil?
            options[name.to_sym] = value
          }

          opts.on("-E", "--env ENVIRONMENT", "use ENVIRONMENT for defaults (default: development)") { |e|
            options[:environment] = e
          }

          options[:daemonize] = false
          options[:pid] = false


          opts.separator ""
          opts.separator "Common options:"

          opts.on_tail("-h", "-?", "--help", "Show this message") do
            puts opts
            exit
          end

          opts.on_tail("--version", "Show version") do
            puts "Rack #{Rack.version} (Release: #{Rack.release})"
            exit
          end
        end

        begin
          opt_parser.parse! args
        rescue OptionParser::InvalidOption => e
          warn e.message
          abort opt_parser.to_s
        end

        options[:config] = args.last if args.last
        options
      end
    end

    def self.start(options = nil, &block)
      new(options).start(&block)
    end

    def opt_parser
      RackCocaine::Server::Options.new
    end

  end
end
