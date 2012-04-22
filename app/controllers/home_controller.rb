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
    bw_image = image.
      charcoal.
      despeckle.
      quantize(8, Magick::GRAYColorspace)
    @images = []
    @colors = []
    num_tiles.times.each do |col|
      top = offset_top + col * screen_width / num_tiles + tile_offset_y
      cols = []
      @images << num_tiles.times.map do |row|
        left = row * screen_width / num_tiles + tile_offset_left
        img = image.crop(left.to_i, top.to_i, tile_width, tile_height).quantize(2, Magick::HSLColorspace)
        bw_img = bw_image.crop(left.to_i, top.to_i, tile_width, tile_height)
        if bw_img.color_histogram.reject { |key, val| val < 100 }.length < 2
          cols << nil
        else
          if img.color_histogram.select { |key, val| key.red > 40000 && key.blue < 40000 && key.green < 40000 }.length > 0
            cols << 'red'
          elsif img.color_histogram.select { |key, val| key.red < 40000 && key.blue > 40000 && key.green < 40000 }.length > 0
            cols << 'blue'
          elsif img.color_histogram.select { |key, val| key.red < 40000 && key.blue < 40000 && key.green > 40000 }.length > 0
            cols << 'green'
          else
            diff = img.difference(tw_tile)
            if diff[0] < 10000 && diff[1] < 0.05
              cols << 'tw'
            else
              cols << img.color_histogram.reject { |key, val| val < 100 }
            end
          end
        end
        Base64.encode64(img.to_blob)
      end
      @colors << cols
    end
  end
end
