module ActionJackson
  module DSL
    def action(opts, &block)
      @@deps ||= {}
      case opts
      when String
        return super(opts)
      when Symbol
        name = opts
      when Hash
        name = opts.keys.first
        @@deps[name] =  opts[name]
      end
      define_method(name, block)
    end

    # How else can we hook into closing the class?
    def register_filters
      @@deps.each do |dependent, dependencies|
        case dependencies
        when Symbol
          register_filter(dependent, dependencies)
        when Array
          dependencies.each do |dependency|
            register_filter(dependent, dependency)
          end
        end
      end
    end

    def register_filter(dependent, dependency)
      case @@deps[dependency].class
      when String
        register_filter(dependency, @@deps[dependency])
      when Array
        @@deps[dependency].each do |dependencydependency|
          register_filter(dependency, dependencydependency)
        end
      end
      send(:before_filter, dependency, :only => dependent)
    end

    alias :filter :action
  end
end
