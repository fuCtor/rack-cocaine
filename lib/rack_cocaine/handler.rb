require 'cocaine'
require "rack/handler"
require 'uri'

module RackCocaine
  module Handler
    class Wrapper
      attr_reader :app
      def initialize(app)
        @app = app
      end

      def stringio_encode(content)
        io = StringIO.new(content)
        io.binmode
        io.set_encoding "ASCII-8BIT" if io.respond_to? :set_encoding
        io
      end

      def execute(request, response)
        df = request.read
        df.callback do |msg|
          method, url, version, headers, body = MessagePack::unpack msg

          # should take a look to RACK SPEC.
          env = Hash[*headers.flatten]
          parsed_url = URI.parse("http://#{env['Host']}#{url}")
          default_hostname = ENV['HOSTNAME'] || parsed_url.hostname  || 'localhost'
          default_port = ENV['PORT'] || parsed_url.port || '80'
          env.update({
              "GATEWAY_INTERFACE" => "Cocaine/#{Cocaine::VERSION}",
              "PATH_INFO" => parsed_url.path || '',
              "QUERY_STRING" => parsed_url.query || '',
              "REMOTE_ADDR" => "::1",
              "REMOTE_HOST" => "localhost",
              "REQUEST_METHOD" => method,
              "REQUEST_URI" => url,
              "SCRIPT_NAME" => "",
              "SERVER_NAME" => default_hostname,
              "SERVER_PROTOCOL" => "HTTP/#{version}",
              "SERVER_PORT" => default_port.to_s,
              "rack.version" => Rack::VERSION,
              "rack.input" => stringio_encode(body),
              "rack.errors" => $stderr,
              "rack.multithread" => false,
              "rack.multiprocess" => false,
              "rack.run_once" => false,
              "rack.url_scheme" => "http",
              "HTTP_VERSION" => "HTTP/#{version}",
              "REQUEST_PATH" => parsed_url.path
          })

          code, headers, body = app.call(env)
          response.write([code, headers.to_a])
          body.each {|item| response.write(item) }
          response.close
        end
      end
    end

    def self.run(app, options=nil)

      params = {}
      params[:app] = options[:app]
      params[:locator] = options[:locator]
      params[:uuid] = options[:uuid]
      params[:endpoint] = options[:endpoint]

      worker = ::Cocaine::Worker.new params

      yield worker, app if block_given?

      wrapped_app = Wrapper.new(app)

      worker.on 'rack', wrapped_app
      worker.run
    end

    def self.valid_options
      {
          "app=NAME" => "Worker name",
          "locator=ADDRESS" => "Locator address",
          "uuid=UUID" => "Worker uuid",
          "endpoint=ENDPOINT" => "Worker endpoint"
      }
    end
  end
end

Rack::Handler.register 'cocaine', 'RackCocaine::Handler'

