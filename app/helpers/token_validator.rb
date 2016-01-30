class TokenValidator
  def self.create(user)
    if user == nil
      return [ "User doesn't exists", :unprocessable_entity ]
    else
      token   = Zlib.crc32(SecureRandom.hex(16))

      if token >  2 ** 31
        token = token - (2 ** 32)
      end

      user.token = token
      user.exp_date = Time.now.to_i + 60 * 60          # 60 minute
    end

    if user.save
      return [ user.token, :ok ]
    else
      return [ 'Some error occurred', :unprocessable_entity ]
    end

  end
end