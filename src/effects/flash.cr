require "./flash_segments"

module Effects
  class Flash < FlashSegments
    private def segment_range(strip)
      0..strip.size
    end
  end
end
