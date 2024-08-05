#### Example: Joins, Functions, EDA, and Strings with the SNL data ###
# Larri Miller
# DACSS 601
# July 27, 2024


library(tidyverse)

## in this challenge we will use the following files: snl_casts, snl_actors, and snl_seasons

casts <- read_csv("data/snl_casts.csv")
actors <- read_csv("data/snl_actors.csv")
seasons <- read_csv("data/snl_seasons.csv")

### Joins & Functions ----------------------------------------------------------
## checking the primary key for each

# in casts I think the compound primary key is aid (actor id) + sid (season id)
casts |>
  count(aid, sid) |>
  filter(n > 1) # none!
casts |>
  filter(across(c(aid, sid), is.na)) # none! Good to go with using these as keys

# in actors I think the primary key is aid (actor id). Check if there are duplicates or na values
actors |>
  count(aid) |>
  filter(n > 1) # none!
actors |>
  filter(is.na(aid)) # none!

# in seasons I think the primary key is sid (season id)
seasons |>
  count(sid) |>
  filter(n > 1) # none!
seasons |> 
  filter(is.na(sid)) # none!

# I just copied and pasted code, so I can write a function instead

check_key <- function(df, key_var) { # this function will only work on single primary keys
df |>
    count({{key_var}}, name = "n") |>
    filter(n > 1 | is.na({{key_var}}))
}

check_key(actors, aid) # no rows in this df
check_key(seasons, sid) # no rows in this df

# challenge if you are bored - can you write a function that checks compound primary keys?

 ## Join the datasets ----------------------------------------------------------

# I want to see how actors have changed over time on SNL
# seasons has sid and year
# casts has aid and sid
# actors has aid and other information about the actors - I am using this as my primary data

actors_cast <- actors |>
  left_join(casts, join_by(aid))  # merging actors and casts by the aid column
head(actors_cast)

actors_cast_season <- actors_cast |> # merging my actors + casts df with season by the sid column
  left_join(seasons, join_by(sid))
head(actors_cast_season)

# now I subset to just the columns I care about
snl <- actors_cast_season |>
  select(aid, type, gender, sid, year)

head(snl) # sanity check

## EDA -------------------------------------------------------------------------

# How does the sex composition of cast members shift over time?
# variables: year, gender 

# let's change date to be of date type
snl$year <- make_date(snl$year)
class(snl$year) # it worked!

snl |>
  group_by(gender) |>
  summarize(unique_gender = n_distinct(gender),
            unique_year = n_distinct(year))

# we have 5 weird entries: andy and unknown. Let's filter these out.

snl_gender <- snl |>
  filter(!str_detect(gender, "andy|unknown"))

# did it work?
snl_gender |>
  group_by(gender) |>
  summarize(unique_gender = n_distinct(gender),
            unique_year = n_distinct(year))

# yes! Now we have 47 years that represent two different sexes: Male and Female

# now we need to create a count variable

snl_gender_count <- snl_gender |>
  group_by(gender, year) |> # grouping by gender and year
  summarise(n=n()) |> # counts
  ungroup() 
snl_gender_count

# let's plot
snl_gender_count |>
  subset(!is.na(n)) |>
  ggplot(aes(year, n, col = gender)) + #specifying data and columns to be plotted
  geom_path() + # connects observations in order
  scale_x_date() + # x axis
  ylim(0, 15) + # scale y axis 
  labs(title = "Saturday Night Live Gender Makeup Over Time",
       x = "Year", y = "Count") # labels


# Who has appeared on snl the most?
snl_mvp <- snl |>
  group_by(aid) |>
  summarise(n = n()) |>
  ungroup() |>
  arrange(desc(n))
snl_mvp # Kenan Thompson at 18 appearances

### Strings --------------------------------------------------------------------

# Let's say I want to create a column called "snl" in case I were to combine this dataset with data from other shows

snl <- snl |>
  mutate(show = "snl") |>
  relocate(show)
head(snl)


# What SNL cast member has the longest name?

snl |>
  filter(str_detect(type, "cast")) |> # filtering to only include cast
  mutate(name_no_spaces = str_remove_all(aid, " "), # removing spaces
         name_length = str_length(name_no_spaces)) |> # getting length
  arrange(desc(name_length))

# Julia Louis-Dreyfus has the longest name

# What is the string length distribution?
snl_name_length <- snl |>
  count(length = str_length(aid)) 
# we have a range of different name lengths, from 2 with length 2 to 1 with length 42 (Julia)

# I am curious about the 460 names with 12 characters
snl |>
  filter(str_length(aid) == 12) |>
  count(aid, sort = TRUE)
# Fred Armisen is in our data 11 times, Kevin Nealon 9, etc.


# One of my favorite SNL skits is Pete Davidson's "I'm Just Pete." Is Pete in this dataset?
sum(str_detect(snl$aid, "^Pete Davidson$")) # I use regex to specify that I specifically want only this phrase
# Pete is in here 7 times! 

# What about Zendaya?
sum(str_detect(snl$aid, "^Zendaya$")) # She is not!

# I copied and pasted code, so let's write a function instead:

names <- c("^Pete Davidson$", "^Zendaya$")
name_counts <- NULL

for (i in names){
  name_counts <- sum(str_detect(snl$aid, i))
  if (name_counts > 0) {
    print("This name is in the data.")
  } else {
    print("This name is not in the data.")
  }
}


??pivot_wider()
         