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

  java_import "org.apache.mahout.cf.taste.impl.model.file.FileDataModel"

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
  
  autoload :InterestScore, 'interest_score.rb'
  
  def self.recommend(user_id, num_of_recommendations)
    model = FileDataModel.new(java.io.File.new("data.csv"))
    pearson_similarity = Similarity::PearsonCorrelationSimilarity.new(model)
    pearson_similarity.setPreferenceInferrer(Similarity::AveragingPreferenceInferrer.new(model))
    neighborhood = Neighborhood::NearestNUserNeighborhood.new(3, pearson_similarity, model)
    recommender = Recommender::GenericUserBasedRecommender.new(model, neighborhood, pearson_similarity)
    caching_recommender = Recommender::CachingRecommender.new(recommender)
    caching_recommender.recommend(user_id.to_i, num_of_recommendations.to_i)
  end

end

puts Kolplex.recommend(ARGV[0], ARGV[1])
