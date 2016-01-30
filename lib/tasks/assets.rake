require 'sprite_factory'

namespace :assets do
  desc 'recreate sprite images and css'
  task :resprite => :environment do 
    SpriteFactory.cssurl = "image-url('$IMAGE')"    # use a sass-rails helper method to be evaluated by the rails asset pipeline
    SpriteFactory.run!('app/assets/images/signin', :style => 'sass' ,:output_style => 'app/assets/stylesheets/signin_dir.css.sass', :selector => '.', layout: 'packed')
    SpriteFactory.run!('app/assets/images/layouts', :style => 'sass' ,:output_style => 'app/assets/stylesheets/layouts_dir.css.sass', :selector => '.', layout: 'packed')
    SpriteFactory.run!('app/assets/images/label', :style => 'sass' ,:output_style => 'app/assets/stylesheets/label_dir.css.sass', :selector => '.', :padding => 2 , layout: 'packed')
    #SpriteFactory.run!('app/assets/images/buttons', :style => 'sass' ,:output_style => 'app/assets/stylesheets/buttons_dir.css.sass', :selector => '.', :padding => 2 , layout: 'packed')
    SpriteFactory.run!('app/assets/images/buttons', :output_style => 'app/assets/stylesheets/buttons_dir.css.scss', :selector => '.', :padding => 2 , layout: 'packed') do |images|
      images
        .keys
        .map do |i| 
          selector = i.to_s
          extra = ""
          extra = ':before' if selector.include? ' before'
          extra = ':after' if selector.include? ' after'
          [i, selector.gsub(/\safter/, '').gsub(/\sbefore/, ''), extra]
        end
        .map do |x|
          i = x[1]
          extra = x[2]
          style = images[x[0]][:style]
          selector = if i.include? ':active' 
                       type = 2
                       ".#{i}#{extra}, .#{i.gsub(/\:active/, '')}.inactive#{extra}, #{i.gsub(/(.*)\:(.*)$/, ".button:\\2 .\\1#{extra}, .button.inactive .\\1#{extra}")} {\n #{style} }"
                     elsif i.include? ':hover'
                       type = 1
                       ".#{i}#{extra}, #{i.gsub(/(.*)\:(.*)$/, ".button:\\2 .\\1#{extra}")} {\n #{style} }"
                     elsif i.include? '.inactive'
                       type = 3
                       ".#{i}#{extra}, #{i.gsub(/(.*)\.inactive/, ".button.inactive .\\1#{extra}")} {\n #{style} !important }"
                     else
                       type = 0
                       ".#{i}#{extra} {\n #{style} }"
                     end 
          [type, selector]
        end
        .sort { |x, y| x[0] <=> y[0] }
        .map { |i| i[1] }
        .join "\n"
    end
    #SpriteFactory.run!('app/assets/images/ach', :style => 'sass' ,:output_style => 'app/assets/stylesheets/ach_dir.css.sass', :selector => '.ach.', layout: 'packed')    
    SpriteFactory.run!('app/assets/images/backgrounds', :style => 'sass' ,:output_style => 'app/assets/stylesheets/backgrounds_dir.css.sass', :selector => '.', :padding => 2, layout: 'packed')
    SpriteFactory.run!('app/assets/images/icons', :style => 'sass',  :output_style => 'app/assets/stylesheets/icons_dir.css.sass', layout: 'packed', :selector => '.')
    # ... etc ...
  end
end
