class NewsController < ApplicationController
  
  before_filter :authenticate_user!

  def index
    user = current_user

    last_news = News.where(show: true)
                    .order_by([:_id, :desc])
                    .first

    no_news = last_news.nil?
    need_to_show = !no_news && user.last_shown_news < last_news.id

    user.last_shown_news = last_news.id if !last_news.nil?
    user.save

    result = {
      no_news: no_news,
      need_to_show: need_to_show
    }

    result = result.merge! last_news.as_json unless last_news.nil?

    render json: result
  end
end
