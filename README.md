# Idealista scrapping
Scrapping and modeling some Idealista data from Barcelona

## Problems I faced
+ Captchas
+ Not that much info available
+ Only 60 pages available (normally)
+ 0 tunning
+ I didn't lie about the results

## Shitty results here (for the training data):
    SVM
        .metric .estimator  mean     n std_err
        <chr>   <chr>      <dbl> <int>   <dbl>
      1 rmse    standard   0.543    25  0.0326
      2 rsq     standard   0.754    25  0.0523
      
     bag_tree:
        .metric .estimator  mean     n std_err
        <chr>   <chr>      <dbl> <int>   <dbl>
      1 rmse    standard   0.536    25  0.0451
      2 rsq     standard   0.751    25  0.0498
      
