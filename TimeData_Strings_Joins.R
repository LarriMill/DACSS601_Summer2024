#### Time Data, Strings, Joins used in Lecture 3 Slides ###
# Larri Miller
# DACSS 601
# July 12, 2024

### Packages needed for this script --------------------------------------------
library(tidyverse)
library(nycflights13)

### Time data ------------------------------------------------------------------
# this section uses functions from lubridate

# current date/time
today() # pops up in console
now() # has more detail than today()

## reading from a file

# creating a mock csv file with only one entry
csv <- "
  date
  07/11/24
"
csv_mdy <- read_csv(csv, col_types = cols(date = col_date("%m/%d/%y")))
csv_mdy # produces 2024-07-11
csv_dmy <- read_csv(csv, col_types = cols(date = col_date("%d/%m/%y")))
csv_dmy # produces 2024-11-07
csv_ymd <- read_csv(csv, col_types = cols(date = col_date("%y/%m/%d")))
csv_ymd # produces 2007-11-24

## from strings
ymd("2002-05-23") # we use the right function based on the order of the string
mdy("October 25, 2008") # these functions can take various date formats
dmy("05/12/1994") 

mdy("07/08/2024", tz = "UTC") # you can use the tz argument to set a timezone
mdy_hms("07/08/2024 12:00:00", tz = "UTC") # you can expand the function to include time

## from individual components
fed_funds_rate <- read_csv("data/FedFundsRate.csv") # reading in dataset that has date/time columns
# this is data that you will use for challenge 3, so download it from that assignment on classroom
head(fed_funds_rate) # we see year, month, and day

fed_funds_rate_time <- fed_funds_rate |>
  mutate(date = make_date(Year, Month, Day)) |> # combining into one column
  relocate(date) # moving this new column to the front

head(fed_funds_rate_time) # now the date column is of data type <date>

## pulling out individual date/time components
# let's pretend that we don't have the original month/day/year columns in the fed data

fed_funds_rate_time |>
  mutate(month1 = month(date, label = TRUE)) |> # using month() with abbreviations
  ggplot(aes(x = month1)) + # don't worry, we will learn visualization in a few weeks!
  geom_bar()

## you can calculate age using today() - a date column
# how old is Larri?
larri_age <- today() - ymd("1998-07-18")
larri_age # 9,491 days (when I first ran this command) is pretty meaningless to me

as.duration(larri_age) # the duration makes more sense - at the time of writing, I am nearly 26 yrs old

## we can group data by decade
# let's say I'm interested in the inflation rate of the fed funds data

# using %/% - modular arithmetic
# first breaking down %/%
fed_funds_rate_modular <- fed_funds_rate |>
  mutate(decade1 = (Year %/% 10))
head(fed_funds_rate_modular$decade1) # now our decades are only 195 instead of 1950
fed_funds_rate_modular <- fed_funds_rate_modular |>
  mutate(decade2 = (Year %/% 10)*10)


fed_funds_rate |>
  mutate(decade_mod = (Year %/% 10)*10) |> # using modular arithmetic
  group_by(decade_mod) |>
  summarize(avg_inflation = mean(`Inflation Rate`, na.rm = TRUE)) |>
  arrange(desc(avg_inflation))

# using cut()
fed_funds_rate |>
  mutate(decade_cut = cut(Year, # identifying column
                      breaks = seq(1949, 2020, by = 10), # how you want the data broken
                      labels = format(seq(1950, 2010, by = 10), # needs one less than breaks
                                      right = TRUE, # intervals should be right closed
                                      include.lowest = TRUE, # lowest value included in first interval
                                      format = "%Y"))) |>
  group_by(decade_cut) |>
  summarize(avg_inflation = mean(`Inflation Rate`, na.rm = TRUE)) |>
  arrange(desc(avg_inflation))

### Strings --------------------------------------------------------------------
# this section uses functions from stringr

## str_c()
str_c("this", "is", "a", "character", "vector") # str_c() combines different strings
# notice how the above smashes everything together
# look up str_c to see if there are any arguments we can use
?str_c

str_c("this", "is", "a", "character", "vector", sep = " ") # using the sep arg
# this looks much better with spaces between the words!

df <- tibble(name = c("George", "Egg", "Brian", "Dave", NA, "Shrimp")) # creating a tibble of names
df_goodboy <- df |>
  mutate(good_boy = str_c(name, " is a very good boy!")) #adding in a column

## str_glue()
# anything in { } is treated as not part of the string

df_goodboy <- df_goodboy |>
  mutate(best_boy = str_glue("{name} is the best boy :)")) # using { }
# notice that str_glue() treats NA as a value, whereas str_c() ignores it

## str_flatten()
string_df <- tibble(name = c("Kuan Jung", "Ana Julia", "Sean", "Josh"),
                    discipline = c("Linguistics", "Performance Studies", "Psychology", "Acoustics"))

string_df |>
  summarize(disciplines = str_flatten(discipline, ", ", last = ", and "))

## extract data from strings
# separate_longer_delim()

string_separate <- tibble(pet_names = c("George, Cleo, Pippin", "Brian, Lemon", "Cenza")) 
# in this tibble the individual elements are of different lengths, but they are all separated by ,

string_separate |> 
  separate_longer_delim(pet_names, delim = ",") # now they are a single column

## Letters & Subsetting

# let's say I want to know how many names in the babynames data are between 15 and 20 letters
babynames <- read_csv("data/babynames.csv") # you should recognize this from challenge 2

babynames |>
  filter(str_length(Name) >= 15 & str_length(Name) <= 20) # there are 138 names 15 - 20 letters long

# now I want to know just the first letter of every name, and which first letter is the most common
first_letter <- babynames |>
  mutate(first = str_sub(Name, 1, 1)) |> # creating a column that subsets the first letter
  group_by(first) |> # grouping by that column, which is the letter
  count() |>
  arrange(desc(n))

first_letter # a has the most with 210,042, and X has the least with 3,521

### Joins ----------------------------------------------------------------------
# in this section we will use the airlines data from the chapter
data(airlines) # records carrier code and full name of every airline. carrier is the primary key
data(airports) # records data about each airport. faa is the primary key
data(planes) # records data about each plane. tailnum is the primary key
data(weather) # records data about the weather at origin airports. origin and time_hour is the compound primary key
data(flights) # records data about flights leaving NYC. time_hour, flight, carrier is the compound primary

## double checking if the keys are good
?count()
airlines |>
  count(carrier) |> 
  filter(n > 1)
# good, each value in carrier is unique - we know this because there are 0 rows in the output

?is.na()
airlines |>
  filter(is.na(carrier))
# good, there are no NA values - we know this because there are 0 rows in the output

## Practice Inner Joins
# Let's say we want to see which airlines are faster than others on average
# We can start with a representative flight (JFK -> LAX) and compute mean air time for each

jfk_lax_flights <- flights |>
  filter(str_detect(origin, "JFK") & str_detect(dest, "LAX")) # using str_detect() to isolate our carriers
jfk_lax_flights

flight_summary <- jfk_lax_flights |>
  group_by(carrier) |>
  summarise(mean_air = mean(air_time, na.rm = TRUE)) |>
  ungroup() |>
  arrange(mean_air)
flight_summary

# AA, UA, B6, DL, and VX mean nothing to me. We need to pull in the airline name into our summary
# we will use left join to match the carrier column in "airlines" to the rows of "flight_summary"
flight_summary_left_join <- left_join(flight_summary, airlines, by = "carrier") #specifying by = is good practice
flight_summary_left_join

# now we know what each airline name is!

# right_join() works the same as left_join(), but it keeps every row in the second data rather than the first
flight_summary_right_join <- right_join(airlines, flight_summary, by = "carrier")
flight_summary_right_join

# let's expand our analysis to include LGA -> ATL flights
flight_summary_2 <- flights |>
  filter((str_detect(origin,"JFK") & str_detect(dest,"LAX")) | 
          (str_detect(origin,"LGA") & str_detect(dest,"ATL"))) |>
  mutate(trip = str_c(origin, dest, sep = "-")) |> # using str_c to combine into one column
  group_by(trip, carrier) |>
  summarize(mean_air = mean(air_time, na.rm = TRUE)) |>
  ungroup()
flight_summary_2

flight_summary_2_left_join <- left_join(flight_summary_2, airlines)
flight_summary_2_left_join

# we can also use inner_join(), which only keeps matching observations in x and y
flight_summary_2_inner_join <- inner_join(flight_summary_2, airlines)
flight_summary_2_inner_join

# full_join() is NOT appropriate because it keeps all observations of x and y 
# not all carriers are in our flight_summary data, so this does not make sense

flight_summary_2_full_join <- full_join(flight_summary_2, airlines)
flight_summary_2_full_join # lots of NA values

# let's say I don't know what LAX is and want full airline names, which is in the airports data
# this will combine pivoting and joining
# step 1. join summary with airlines
# step 2. separate trip into origin and dest
# step 3. use pivot_longer() to spread these values across rows. Put these into a column called faa,
# which matches the column in airports that we are referencing
# step 4. use left_join() to match airports to our df
# step 5. select() the columns we need
# step 6. pivot_wider() again


flight_summary_2_final <- flight_summary_2 |>
  left_join(airlines, by = "carrier") |>
  rename(airline = name) |>
  separate(trip, into = c("origin", "dest"), sep = "-") |>
  pivot_longer(c(origin, dest), names_to = "tmp", values_to = "faa") |>
  left_join(airports, by = "faa") |>
  select(airline, mean_air, tmp, name) |>
  pivot_wider(names_from = tmp, values_from = name) |>
  arrange(origin, mean_air)

View(flight_summary_2_final)

## Practice Filtering Joins

# semi_join() is essentially an alternative to filter()
# let's say we want to analyze in more detail the flights that make up flight_summary2_final -
# we want to return to the original flights data and do analysis there

flight_summary_3 <- flight_summary_2 |>
  separate(trip, into = c("origin", "dest")) # separate trip

# we could use filter()
flights |>
  filter(origin %in% flight_summary_3$origin & dest %in% flight_summary_3$dest)

# but semi_join() is a bit easier
flights_semi_join <- flights |>
  semi_join(flight_summary_3)
flights_semi_join

# double checking that this worked
distinct(flights_semi_join, origin, dest) # great!

# we could also filter out flights to include everything BUT the LGA -> ATL and JFK -> LAX flights
flights_anti_join <- flights |>
  anti_join(flight_summary_3, by = c("origin", "dest"))
flights_anti_join
