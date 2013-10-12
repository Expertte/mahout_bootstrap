# Mahout Bootstrap

If you don't have jruby install it first:

``` rvm install jruby-1.7.4
```

If you like create a gemset and yout .rvmrc file

rvm use jruby-1.7.4@mahout_bootstrap --create

# Data File

Your data file has the following itens `user_id`, `item_id`,`interest_score`

# Run the recommender

In your command line run:

``` 
jruby kolplex_recommender.rb [user_id] [num_of_recommendations]

jruby kolplex_recommender.rb 2 2

# Get 2 recommendations for the user_id 2

```
