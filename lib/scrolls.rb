module Scrolls
  module Log
    def log(action, attrs = {})
      unless block_given?
        str = "#{action} #{unparse(attrs)}"
        mtx.synchronize { $stdout.puts str }
      else
        start = Time.now
        log(action, attrs.merge(at: :start))
        res = yield
        log(action, attrs.merge(at: :finish,
          elapsed: "#{((Time.now - start) * 1000).to_i}ms"))
        res
      end
    end

    private

    def mtx
      @mtx ||= Mutex.new
    end

    def unparse(attrs)
      attrs.map { |k, v| unparse_pair(k, v) }.join(" ")
    end

    def unparse_pair(k, v)
      v = v.call if v.is_a?(Proc)
      # only quote strings if they include whitespace
      if v.is_a?(String) && v =~ /\s/
        %{#{k}="#{v}"}
      else
        "#{k}=#{v}"
      end
    end
  end

  extend Log
end
