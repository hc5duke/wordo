class HomeController < ApplicationController
  def index
  end

  def analyze
    tw_tile = Magick::Image::read('./data/tw.gif').first
    screen_width = 640
    screen_height = 960
    offset_top = 130
    num_tiles = 15
    tile_offset_left = 4
    tile_offset_right = 8
    tile_offset_y = 8
    tile_size = (screen_width / num_tiles).to_i
    tile_width = tile_size - tile_offset_left - tile_offset_right
    tile_height = tile_size - 2 * tile_offset_y
    colorspace = 3

    image = Magick::Image.from_blob(params[:picture].read).first.
      resize(screen_width, screen_height)
    @images = []
    @colors = []
    num_tiles.times.each do |col|
      top = offset_top + col * screen_width / num_tiles + tile_offset_y
      cols = []
      @images << num_tiles.times.map do |row|
        left = row * screen_width / num_tiles + tile_offset_left
        img = image.crop(left.to_i, top.to_i, tile_width, tile_height).quantize(2, Magick::HSLColorspace)
        color_histogram = img.color_histogram
        palette = color_histogram.reject { |key, val| val < 100 }
        if palette.length == 1
          cols << 'empty'
        elsif color_histogram.select { |key, val| key.red > 40000 && key.blue < 40000 && key.green < 40000 }.length > 0
          cols << 'dw'
        elsif color_histogram.select { |key, val| key.red < 40000 && key.blue > 40000 && key.green < 40000 }.length > 0
          cols << 'dl'
        elsif color_histogram.select { |key, val| key.red < 40000 && key.blue < 40000 && key.green > 40000 }.length > 0
          cols << 'tl'
        else
          diff = img.difference(tw_tile)
          if diff[0] < 4000 && diff[1] < 0.04
            cols << 'tw'
          else
            cols << palette
          end
        end
        if color_histogram.select { |key, val| key.red > 50000 && key.blue > 50000 && key.green > 50000 }.length > 0
          Base64.encode64(img.negate.charcoal.to_blob)
        else
          Base64.encode64(img.charcoal.to_blob)
        end
      end
      @colors << cols
    end
  end
end
