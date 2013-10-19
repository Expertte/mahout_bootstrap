require 'user_item_score_data'

class InterestScoreBuilder
  attr_reader :tracker_data

  def self.data_model
    # connect to somewhere to get the data
    tracker_data = [
      {
       "guid"=>"235g14l4o-b72a0", "uuid"=>"kplx-demo-0001",
       "page_uid"=>"235r9a7i9-a2bjb","page_uri"=>"http://www.elo7.com.br/jack-daniels-suporte-botao-55-x-25-cm/dp/33A599",
       "page_type"=>"show_prod", "page_id"=>"33A599", "client_id"=>"1", "exit"=>false,
      "resources"=>[
      {"id"=>"33A599", "type"=>"social", "arg"=>"", "events"=>{"intoviewport"=>[4, 0, 4], "outofviewport"=>[4, 0, 4], "click"=>[3, 0, 3]}},
      {"id"=>"33A599", "type"=>"buy_button", "arg"=>"", "events"=>{"intoviewport"=>[13, 0, 13], "outofviewport"=>[13, 0, 13]}},
      {"id"=>"33A599", "type"=>"contact_seller", "arg"=>"", "events"=>{"intoviewport"=>[2, 1, 1], "outofviewport"=>[2, 0, 2], "click"=>[1, 0, 1]}},
      {"id"=>"window", "type"=>"window", "arg"=>nil,"events"=>{"time_on_page"=>[30015, 2, 30013], "max_y"=>[2140, 647, 1493], "active_time_on_page"=>[8552, 0, 8552]}}]
      }
    ]

    builder = self.new(tracker_data)
    builder.user_int_data_model
  end

  def initialize(tracker_data)
    @tracker_data = tracker_data || []
    @items = []
  end

  def items
    @tracker_data.map do |item|
      UserItemScoreData.new(item)
    end
  end

  # Build a hash where the key is the user_id (String) and the values are item_ids, score_pairs
  def user_data_model
    @user_data_model = items.each_with_object(Hash.new {|h,k| h[k] = [] }) do |item, result|
      result[item.user_id] << [item.item_id, item.interest_score]
    end
  end

  # Same data hash as user_data_model but user_ids and item_ids are converted to Integers
  def integer_data_model
    hash = {}
    user_data_model.values.each_with_index do |item, index|
      hash[index] = item
    end
    hash
  end

end
