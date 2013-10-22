# Demo for ELO7
$root = File.dirname(__FILE__)

module Kolplex

  require 'java'

  # Mahout External Dependencies
  $CLASSPATH << "#{$root}/lib/java/slf4j-api-1.7.5"
  $CLASSPATH << "#{$root}/lib/java/slf4j-simple-1.7.5"
  $CLASSPATH << "#{$root}/lib/java/guava-15.0"
  $CLASSPATH << "#{$root}/lib/java/math3"

  # Mahout
  $CLASSPATH << "#{$root}/lib/java/mahout-math"
  $CLASSPATH << "#{$root}/lib/java/mahout-core"


  module DataModel
    java_import "org.apache.mahout.cf.taste.impl.model.file.FileDataModel"
    java_import "org.apache.mahout.cf.taste.impl.model.GenericDataModel"
    java_import "org.apache.mahout.cf.taste.impl.model.GenericUserPreferenceArray"
    java_import "org.apache.mahout.cf.taste.impl.common.FastByIDMap"
  end

  module Neighborhood

    java_import "org.apache.mahout.cf.taste.neighborhood.UserNeighborhood"
    java_import "org.apache.mahout.cf.taste.impl.neighborhood.NearestNUserNeighborhood"
    autoload :NearestNUserNeighborhood, 'neighborhood/nearestn_user_neighborhood'

  end

  module Recommender

    java_import "org.apache.mahout.cf.taste.recommender.Recommender"
    java_import "org.apache.mahout.cf.taste.recommender.UserBasedRecommender"
    java_import "org.apache.mahout.cf.taste.impl.recommender.GenericUserBasedRecommender"
    java_import "org.apache.mahout.cf.taste.impl.recommender.CachingRecommender"

    autoload :GenericUserBasedRecommender, 'recommender/generic_user_based_recommender'
    autoload :CachingRecommender, 'recommender/caching_recommender'

  end

  module Similarity

    java_import "org.apache.mahout.cf.taste.impl.similarity.AveragingPreferenceInferrer"
    java_import "org.apache.mahout.cf.taste.similarity.UserSimilarity"
    java_import "org.apache.mahout.cf.taste.impl.similarity.PearsonCorrelationSimilarity"

    autoload :PearsonCorrelationSimilarity, 'similarity/pearson_correlation_similarity.rb'

  end

  autoload :InterestScoreBuilder, 'interest_score_builder.rb'

  def self.items_hash_from_file(file = 'data.csv')
    File.readlines('data.csv').each_with_object(Hash.new {|h,k| h[k] = [] }) do |item, result|
      user_item_score = item.chomp.split(',').map(&:to_i)
      result[user_item_score.first] << user_item_score.values_at(1..-1)
    end
  end

  def self.build_generic_data_model(data)
    users_preferences = data.each_with_object([]) do |(user_id, item_preferences), result|
      user_preference = DataModel::GenericUserPreferenceArray.new(item_preferences.size)
      item_preferences.each_with_index do |item_preference, index|
        user_preference.setUserID(index, user_id)
        user_preference.setItemID(index, item_preference.first)
        user_preference.setValue(index, item_preference.last)
      end
      result << user_preference
    end

    preferences_id_map = DataModel::FastByIDMap.new
    users_preferences.each_with_index { |item, index| preferences_id_map.put(index, item) }
    DataModel::GenericDataModel.new(preferences_id_map)
  end

  def self.recommend(user_id, num_of_recommendations, tracker_data)
    # model = DataModel::FileDataModel.new(java.io.File.new("data.csv"))
    builder = InterestScoreBuilder.new(tracker_data)


    model = build_generic_data_model(builder.data_model)
    pearson_similarity = Similarity::PearsonCorrelationSimilarity.new(model)
    pearson_similarity.setPreferenceInferrer(Similarity::AveragingPreferenceInferrer.new(model))
    neighborhood = Neighborhood::NearestNUserNeighborhood.new(3, pearson_similarity, model)
    recommender = Recommender::GenericUserBasedRecommender.new(model, neighborhood, pearson_similarity)
    caching_recommender = Recommender::CachingRecommender.new(recommender)

    mapped_user_id = builder.get_user_mapped_id(user_id)

    recommended_items = caching_recommender.recommend(mapped_user_id, num_of_recommendations.to_i)
    items = recommended_items.map do |item|
      [ builder.get_item_real_id(item.getItemID), item.getValue ]
    end
    items
  end

end

#puts Kolplex.recommend(ARGV[0], ARGV[1])
