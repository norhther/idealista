library(tidyverse)
library(viridis)
library(RColorBrewer)
library(parsnip)
library(baguette)

df <- readr::read_csv('C:\\Users\\omarl\\OneDrive\\Escritorio\\idealistaBCN.csv')

df <- df %>%
  select(-X1) %>%
  filter(habs <= 10) %>%
  filter(floor < 20)

df$floor[is.na(df$floor)] <- "None"

df %>%
  group_by(type) %>%
  summarize(n = n(), m = mean(price/m2)) %>%
  mutate(type = fct_reorder(type, m)) %>%
  ggplot(aes(x = type, y = m, fill = type)) + 
  geom_col() + labs(x = "", y = "Price/m2 in euros") + theme(legend.position = "none") + 
  scale_fill_brewer(palette = "Purples")

df %>%
  ggplot(aes(x = habs, fill = type)) + geom_histogram(binwidth = 1) +
  scale_fill_brewer(palette = "Blues") + theme_gray()

df %>%
  group_by(neigh) %>%
  summarize(price_per_m2 = mean(price/m2)) %>%
  arrange(price_per_m2) %>%
  top_n(5) %>%
  mutate(neigh = fct_reorder(neigh, price_per_m2)) %>%
  ggplot(aes(x = neigh, y = price_per_m2, fill = neigh)) + geom_col() + coord_flip() + 
  
  theme(legend.position = "None") + scale_fill_brewer(palette = "Blues")



#MODELING


df <- df %>% 
  mutate_if(is.character, factor) %>%
  mutate(elevator = as_factor(elevator)) %>%
  mutate(exterior = as_factor(exterior)) %>%
  select(-info)


library(tidymodels)

set.seed(42)
df_split <- initial_split(df)

pisos_train <- training(df_split)
pisos_test <- testing(df_split)

pisos_rec <- recipe(price ~ ., data = pisos_train) %>% 
  step_downsample(type) %>%
  step_dummy(elevator, exterior, neigh, type) %>%
  step_zv(all_numeric()) %>%
  step_normalize(all_numeric()) %>%
  prep()


test_proc <- bake(pisos_rec, new_data = pisos_test)

bag_model <- bag_tree(tree_depth = 10) %>%
  set_mode("regression") %>%
  set_engine("rpart", times = 3)

svm_model <- svm_rbf() %>% 
  set_engine("kernlab") %>% 
  set_mode("regression") %>% 
  translate()

bag_fit <- bag_model %>%
  fit(price ~ ., data = juice(pisos_rec))

svm_fit <- svm_model %>%
  fit(price ~ ., data = juice(pisos_rec))


#EVALUATION

valid_splits <- mc_cv(juice(pisos_rec), prop = 0.9)

svm_results <- fit_resamples(
  price ~ .,
  svm_model,
  valid_splits, 
  control = control_resamples(save_pred = TRUE)
)

svm_results %>%
  collect_metrics()

bag_results <- fit_resamples(
  price ~ .,
  bag_model,
  valid_splits, 
  control = control_resamples(save_pred = TRUE)
)

bag_results %>%
  collect_metrics()
