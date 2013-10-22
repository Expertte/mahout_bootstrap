require 'user_item_score_data'

class InterestScoreBuilder
  attr_reader :tracker_data

  def initialize(tracker_data)
    @tracker_data = tracker_data || []
  end

  def items
    @items ||= @tracker_data.map do |item|
      UserItemScoreData.new(item)
    end
  end

  def get_user_real_id(user_mapped_id)
    user_ids_map[user_mapped_id]
  end

  def get_item_real_id(item_mapped_id)
    item_ids_map[item_mapped_id]
  end

  def get_user_mapped_id(user_id)
    user_ids_map.key(user_id)
  end

  def get_item_mapped_id(item_id)
    item_ids_map.key(item_id)
  end

  def user_ids_map
    @user_ids_map ||= map_to_hash_id(:user_id)
  end

  def item_ids_map
    @item_ids_map ||= map_to_hash_id(:item_id)
  end

  # Build a hash where the key is the user_id (Integer) and the values are [item_ids (Integer), score (Integer)] pairs
  # user_ids and item_ids are mapped to integers.
  # This hash is the base to build the recommender data model
  def data_model
    @data_model ||= items.each_with_object(Hash.new {|h,k| h[k] = [] }) do |item, result|
      result[get_user_mapped_id(item.user_id)] << [get_item_mapped_id(item.item_id), item.interest_score]
    end
  end

  private

  def map_to_hash_id(field)
    items.map { |item| item.send(field) }.uniq.each_with_index.inject({}) do |result, (item, index)|
      result[index] = item
      result
    end
  end

end
