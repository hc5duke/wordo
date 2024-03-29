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

    image = Magick::Image.from_blob(params[:picture].read).first.resize(screen_width, screen_height)#.charcoal
    @images = []
    num_tiles.times.each do |row|
      top = offset_top + row * screen_width / num_tiles + tile_offset_top
      @images << num_tiles.times.map do |col|
        left = col * screen_width / num_tiles + tile_offset_left
        img = image.crop(left.to_i, top.to_i, tile_width, tile_height)
        Base64.encode64(img.to_blob)
      end
    end
  end
end
