module Led
  struct Color
    getter red, green, blue, alpha

    def self.black(alpha : Float64 = 1.0)
      self.new(0, 0, 0, alpha)
    end

    def self.white(alpha : Float64 = 1.0)
      self.new(1, 1, 1, alpha)
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
      Color.new(
        other.alpha * other.red + alpha_inverted * red,
        other.alpha * other.green + alpha_inverted * green,
        other.alpha * other.blue + alpha_inverted * blue
      )
    end
  end
end
