class HomeController < ApplicationController
  def index
  end

  def analyze
    screen_width = 640
    screen_height = 960
    offset_top = 130
    num_tiles = 15
    tile_offset_left = 6
    tile_offset_right = 12
    tile_offset_top = 9
    tile_offset_bottom = 9
    tile_size = (screen_width / num_tiles).to_i
    tile_width = tile_size - tile_offset_left - tile_offset_right
    tile_height = tile_size - tile_offset_top - tile_offset_bottom
    colorspace = 3

    image = Magick::Image.from_blob(params[:picture].read).first.
      resize(screen_width, screen_height)
    @images = []
    @colors = []
    num_tiles.times.each do |col|
      top = offset_top + col * screen_width / num_tiles + tile_offset_top
      cols = []
      @images << num_tiles.times.map do |row|
        left = row * screen_width / num_tiles + tile_offset_left
        tile = image.crop(left.to_i, top.to_i, tile_width, tile_height)
        img = tile.quantize(2, Magick::HSLColorspace)
        color_histogram = img.color_histogram
        palette = color_histogram.reject { |key, val| val < 100 }
        if palette.length == 1
          cols << 'empty'
        else
          cols << palette
          img = img.negate if color_histogram.select { |key, val| key.red > 50000 && key.blue > 50000 && key.green > 50000 }.length > 0
          Base64.encode64(img.charcoal.quantize(2, Magick::GRAYColorspace).to_blob)
        end
      end
      @colors << cols
    end
  end
end
