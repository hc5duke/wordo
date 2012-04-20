class HomeController < ApplicationController
  def index
  end

  def analyze
    params[:picture]
    image = Magick::Image.from_blob(params[:picture].read).first
    image = image.quantize(16, Magick::GRAYColorspace)
    @images = []
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
    num_tiles.times.each do |col|
      top = offset_top + col * screen_width / num_tiles
      arr = num_tiles.times.map do |row|
        left = row * screen_width / num_tiles
        img = image.resize(screen_width, screen_height).
          crop(left.to_i + tile_offset_left, top.to_i + tile_offset_y, tile_width, tile_height)
        Base64.encode64(img.to_blob)
      end
      @images << arr
    end
  end
end
