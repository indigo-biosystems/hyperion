class Hyperion
  class ServerPool
    def initialize
      @free = []
      @in_use = []
    end

    def check_out
      s = @free.pop || FakeServer.new(next_port)
      @in_use.push(s)
      s
    end

    def check_in(s)
      @in_use.delete(s)
      @free.push(s)
    end

    def clear
      all = @free + @in_use
      all.each(&:teardown)
      @free = []
      @in_use = []
    end

    private

    def next_port
      @last_port ||= 9000
      @last_port += 1
    end
  end
end
