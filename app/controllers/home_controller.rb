class HomeController < ApplicationController
  def index
  end

  def analyze
    params[:picture]
    image = Magick::Image.from_blob(params[:picture].read).first
    image = image.quantize(16, Magick::GRAYColorspace)
    @images = []
    15.times.each do |col|
      top = 65 + (col * 320 / 15).to_i
      height = (320 / 15).to_i
      img = image.crop(0, top, 320, height)
      @images << ActiveSupport::Base64.encode64(img.to_blob)
    end
  end
end
