class Collaborator < ApplicationRecord
  belongs_to :enterprise
  has_many :interactions, dependent: :destroy
  has_many :requests, dependent: :nullify

  STATUS = {inactive: 0, active: 1}

  def friendly_phone
    return nil if self.phone_area.nil? or self.phone.nil?
    "(#{self.phone_area}) #{self.phone}"
  end

  def get_initials
    splited_name = self.name.split(' ')
    return splited_name.reduce { |arr, str| arr.first.upcase + str.first.upcase } if splited_name.size > 1
    return splited_name[0][0] + splited_name[0][1]
  end

  def get_status_name
  	return "Ativo" if self.status == Collaborator::STATUS[:active]
  	return "Inativo" if self.status == Collaborator::STATUS[:inactive]
    return ""
  end

  def hsl_user_color hex
    r = ((hex[1] + hex[2]).to_i(16))/255.0
    g = ((hex[3] + hex[4]).to_i(16))/255.0
    b = ((hex[5] + hex[6]).to_i(16))/255.0
    rgb = [r, g, b]

    min = rgb.min
    max = rgb.max
    delta = max - min

    if delta == 0
      h = 0
    elsif max == r
      h = ((g - b) / delta) % 6
    elsif max == g
      h = (b - r) / delta + 2
    else
      h = (r - g) / delta + 4
    end

    h = (h*60).round
    h += 360 if h < 0

    l = (max + min) / 2;
    s = (delta == 0) ? 0 : delta / (1 - (2 * l - 1).abs)
    s = +(s * 100).round

    "hsl(#{h}, #{s}%, 43%)"
  end

  def get_color
    hex_color = '#' + Digest::MD5.hexdigest(self.email)[0..5]
    return hsl_user_color hex_color
  end
end
