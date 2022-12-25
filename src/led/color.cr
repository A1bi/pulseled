module Led
  struct Color
    getter red, green, blue

    def self.black
      self.new(0, 0, 0)
    end

    def self.white
      self.new(0xff, 0xff, 0xff)
    end

    def initialize(@red : UInt8, @green : UInt8, @blue : UInt8)
    end

    def *(factor : Float64) : Color
      Color.new(
        (@red * factor).to_u8,
        (@green * factor).to_u8,
        (@blue * factor).to_u8
      )
    end
  end
end
