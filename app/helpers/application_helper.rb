# encoding: utf-8

module ApplicationHelper
  def self.check_int_param int_param
    return nil if ((!int_param.is_a?(Integer) && !int_param.is_a?(String)) || 
      (int_param.is_a?(String) && int_param.empty?))
    
    max_abs_fixnum = 2147483648 # not true, minimal Fixnum -1073741824 
    return nil if (int_param.is_a?(String) && ! (int_param =~ /\A[+-]?\d{1,10}\z/m))

    int_representation = int_param.to_i

    if int_representation.abs > max_abs_fixnum
      return nil
    end

    return int_representation
  end

  def self.validate_user_name name
    buf = name.to_s

    buf = buf[0..MEGABALL_CONFIG['name_max_length']]

    buf.gsub! /[^a-zA-Z10-9а-яА-ЯёЁ.,!?_\-\ ]*/u, ''

    return buf
  end

  def self.validate_club_name name
    buf = name.to_s

    buf = buf[0..MEGABALL_CONFIG['club_defaults']['name_max_length']]

    buf.gsub! /[^a-zA-Z10-9а-яА-ЯёЁ_\-\ ]*/u, ''

    return buf
  end

  def self.validate_club_short_name name
    buf = name.to_s

    buf = buf[0..MEGABALL_CONFIG['club_defaults']['short_name_max_length']]

    buf.gsub! /[^a-zA-Z10-9а-яА-ЯёЁ]*/u, ''

    return buf
  end

  def self.validate_level_range from, to
		from = from.to_i
		to = to.to_i
		bound = MEGABALL_CONFIG['levels'].count 
  	from > 0 and to > 0 and from <= bound and to <= bound
  end

  def self.check_object_id_param object_id
    object_id.to_s[1..24].gsub /[^0-9a-e]/, ''
  end

  def image_url(file)
    request.protocol + request.host_with_port + ActionController::Base.helpers.asset_path(file)
  end
end
