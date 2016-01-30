module CollectionHelper
  include PriseHelper

  def unprocessed_items
    unprocessed = current_user.user_collection.reject(&:processed?)
    
    Collection.where(:_id.in => unprocessed.map(&:collection_id).uniq)
              .entries
              .map do |coll|
                json = coll.as_json except: [:collection_item]
                json['collection_item'] = coll.collection_item.reject do |item| 
                  unprocessed.index do |user_item|
                    user_item.collection_id == coll.id && \
                      user_item.item_id == item.id
                  end.nil?
                end.as_json
                json
              end
  end

  def check_collections!
    items = current_user.user_collection.reject(&:processed?)

    colls_to_check = Set.new(items.map do |item|
      item.processed = true
      item.collection_id
    end)

    finished = Collection.where(:_id.in => colls_to_check.to_a).entries
                         .reject { |c| not c.completed_by?(current_user) }

    finished.inject(prise_for(current_user)) { |p, c| p.with(c, 'collection') }
            .give!

    current_user.save

    finished
  end

end
