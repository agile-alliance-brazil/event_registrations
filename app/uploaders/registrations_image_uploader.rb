# frozen_string_literal: true

class RegistrationsImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{model.id}"
  end

  version :thumb do
    process resize_to_fit: [50, 50]
  end

  version :resized do
    # returns an image with a maximum width of 100px
    # while maintaining the aspect ratio
    # 10000 is used to tell CW that the height is free
    # and so that it will hit the 100 px width first
    process resize_to_fit: [600, -1]
  end

  def extension_whitelist
    %w[jpg jpeg gif png]
  end
end
