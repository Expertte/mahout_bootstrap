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

  def user_ids_map
    @user_ids_map ||= map_to_hash_id(:user_id)
  end

  def item_ids_map
    @item_ids_map ||= map_to_hash_id(:item_id)
  end

  # Build a hash where the key is the user_id (String) and the values are [item_ids, score] pairs
  def data_model
    @user_data_model = items.each_with_object(Hash.new {|h,k| h[k] = [] }) do |item, result|
      result[item.user_id] << [item.item_id, item.interest_score]
    end
  end

  # Same data hash as data_model, but user_ids and item_ids are maped as integers
  def integer_data_model
    data_model.inject({}) do |result, (user_id, item)|
      result[user_ids_map[key]] = item_ids_map[item.first], item.last
      result
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
