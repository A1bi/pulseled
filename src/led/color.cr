module Led
  struct Color
    getter red, green, blue, alpha

    def self.black(alpha : Float64 = 1.0)
      self.new(0, 0, 0, alpha)
    end

    def self.white(alpha : Float64 = 1.0)
      self.new(1, 1, 1, alpha)
    end

    def self.red(alpha : Float64 = 1.0)
      self.new(1, 0, 0, alpha)
    end

    def self.green(alpha : Float64 = 1.0)
      self.new(0, 1, 0, alpha)
    end

    def self.blue(alpha : Float64 = 1.0)
      self.new(0, 0, 1, alpha)
    end

    def self.clear
      black(0)
    end

    def initialize(@red : Float64, @green : Float64, @blue : Float64, @alpha : Float = 1.0)
    end

    def *(alpha : Float) : Color
      Color.new(red, green, blue, alpha)
    end

    def +(other : Color) : Color
      alpha_inverted = 1 - other.alpha
      new_color(add_channels)
    end

    def brighten_by_alpha(other : Color) : Color
      new_color(brighten_channel_by_alpha, alpha)
    end

    def to_bridge_bytes : Bytes
      Bytes[bridge_byte(red), bridge_byte(green), bridge_byte(blue)]
    end

    macro new_color(method, alpha = nil)
      Color.new({{method}}(red), {{method}}(green), {{method}}(blue){% if alpha %}, {{ alpha }}{% end %})
    end

    macro add_channels(channel)
      other.alpha * other.{{channel}} + alpha_inverted * {{channel}}
    end

    macro brighten_channel_by_alpha(channel)
      [1.0, {{channel}} * (other.alpha + 1)].min
    end

    macro bridge_byte(channel)
      (UInt8::MAX * {{channel}}).to_u8
    end
  end
end
