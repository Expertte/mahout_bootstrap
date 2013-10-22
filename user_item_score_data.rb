class UserItemScoreData
  attr_reader :data, :feature_weights

  # Data hash example:
  # {
  #  "guid"=>"235g14l4o-b72a0", "uuid"=>"kplx-demo-0001",
  #  "page_uid"=>"235r9a7i9-a2bjb","page_uri"=>"http://www.elo7.com.br/jack-daniels-suporte-botao-55-x-25-cm/dp/33A599",
  #  "page_type"=>"show_prod", "page_id"=>"33A599", "client_id"=>"1", "exit"=>false,
  # "resources"=>[
  # {"id"=>"33A599", "type"=>"social", "arg"=>"", "events"=>{"intoviewport"=>[4, 0, 4], "outofviewport"=>[4, 0, 4], "click"=>[3, 0, 3]}},
  # {"id"=>"33A599", "type"=>"buy_button", "arg"=>"", "events"=>{"intoviewport"=>[13, 0, 13], "outofviewport"=>[13, 0, 13]}},
  # {"id"=>"33A599", "type"=>"contact_seller", "arg"=>"", "events"=>{"intoviewport"=>[2, 1, 1], "outofviewport"=>[2, 0, 2], "click"=>[1, 0, 1]}},
  # {"id"=>"window", "type"=>"window", "arg"=>nil,"events"=>{"time_on_page"=>[30015, 2, 30013], "max_y"=>[2140, 647, 1493], "active_time_on_page"=>[8552, 0, 8552]}}]
  # }

  def initialize(data, feature_weights = {'buy_button' => 4, 'social' => 3, 'contact_seller' => 2, 'window' => 1})
    @data = data
    @feature_weights = feature_weights
  end

  def user_id
    data["guid"]
  end

  def item_id
    data["page_id"]
  end

  def resources
    data["resources"]
  end

  # Returns a hash with the features based on the resources events
  # all values take a binary value multiplied by the given weight
  # For now only click events and the active time on page are being considered
  # E.g.: { 'social' => 2, 'buy_buttom' => 1, 'contact_seller' => 3 }

  def features
    @features ||= resources.inject({}) do |result, resource|
      events = resource["events"]
      type   = resource["type"]

      if events.include?("click")
        result[type] = (events["click"].last >= 1 ? feature_weights.fetch(type, 0) : 0)
      elsif events.include?("active_time_on_page")
        # TO DO: Experiment with a sigmoid function here
        result[type] = (events["active_time_on_page"].last >= 5000 ? feature_weights.fetch(type, 0) : 0)
      end

      result
    end
  end

  def interest_score
    features.values.inject(&:+).to_i
  end

  private

  # def sigmoid(val)
  #     return 1.0/(1.0 + Math.exp(-val))
  # end

end