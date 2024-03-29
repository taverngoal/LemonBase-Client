class Spa
  def initialize
    @filenames = ['', '.html', 'index.html', '/index.html']
    @rack_static = ::Rack::Static.new(
        lambda { [404, {}, []] },
        root: File.expand_path('../../public', __FILE__),
        urls: ['/']
    )
  end

  def self.included(app)
    db_config = YAML.load(ERB.new(File.read("config/database.yml")).result)[(ENV['RACK_ENV'] || :development).to_s]
    ActiveRecord::Base.default_timezone = :utc
    ActiveRecord::Base.establish_connection(db_config)

    # re-connect if database connection dropped
    app.before { ActiveRecord::Base.verify_active_connections! if ActiveRecord::Base.respond_to?(:verify_active_connections!) }
    app.after  { ActiveRecord::Base.clear_active_connections! }
  end

  def self.instance
    @instance ||= Rack::Builder.new do
      use Rack::Cors do
        allow do
          origins '*'
          resource '*', headers: :any, methods: :get
        end
      end

      run Spa.new
    end.to_app
  end

  def call(env)
    # api
    response = Spa::API.call(env)

    # Check if the App wants us to pass the response along to others
    if response[1]['X-Cascade'] == 'pass'
      # static files
      request_path = env['PATH_INFO']
      @filenames.each do |path|
        response = @rack_static.call(env.merge('PATH_INFO' => request_path + path))
        return response if response[0] != 404
      end
    end

    # Serve error pages or respond with API response
    case response[0]
      when 404, 500
        content = @rack_static.call(env.merge('PATH_INFO' => "/errors/#{response[0]}.html"))
        [response[0], content[1], content[2]]
      else
        response
    end
  end
end