#### Example: Date-Time Data, Recoding, & Joins w/ the hotel bookings data ###
# Larri Miller
# DACSS 601
# July 17, 2024

library(tidyverse)

hotel <- read_csv("data/hotel_bookings.csv") # reading in the file
# this data can be found at the following link: https://www.kaggle.com/datasets/jessemostipak/hotel-booking-demand

View(hotel) # to see the whole dataset
head(hotel) # to see just a snippet of the dataset

### Date Time Data -------------------------------------------------------------
# let's merge the separate arrival columns into one date column
hotel_date <- hotel |>
  mutate(date_arrival = str_c(arrival_date_day_of_month,
                              arrival_date_month,
                              arrival_date_year, sep = "/"),
  date_arrival = dmy(date_arrival)) |>
  select(!starts_with("arrival")) |> # removing the three columns we've combined
  relocate(date_arrival)

hotel_date # now we have one date_arrival column at the beginning 

## Visualizing Date Time Data
# We will cover visualization in a few weeks. In the meantime, here's a sneak peek
# Let's visualize the variation in number of bookings across time, split by hotel type

?floor_date() # check out this function

hotel_date_month <- hotel_date |>
  mutate(month=floor_date(date_arrival,unit="month")) |> #rounding to months
  group_by(month, hotel) |> 
  summarize(n=n()) |> # summarizing counts
  ungroup()
hotel_date_month

hotel_date_month |>
  ggplot(aes(month,n,col=hotel)) + # plotting month, count, and hotel type
  geom_line() + # using a line graph
  scale_x_date(NULL, date_labels = "%b %y",breaks="2 months") + # specifying date breaks
  scale_y_continuous(limits=c(0,5000)) + # adjusting y axis
  labs(title = "Hotel Bookings Over Time", # labels
       x="date",
       y="number of bookings") + 
  theme(axis.text.x=element_text(angle=90)) # angling labels

### Recoding -------------------------------------------------------------------
# There are a few columns I see that I think can be recoded to make more sense: 
# Meal types & Country
# Meal types: BB = Bed and Breakfast, FB = Full Board, HB = Half Board, SC = Undefined

hotel_date_meal <- hotel_date |>
  mutate(month=floor_date(date_arrival,unit="month"), # creating a rounded month column
         meal=recode(meal, # recoding
                     BB="Bed and Breakfast",
                     FB="Full board",
                     HB="Half board",
                     SC="Undefined"),
         across(c(hotel, meal),as.factor)) |> # making these columns factors
  group_by(month,hotel,meal) |> # grouping across the three variables
  summarise(n=n()) |> # counts
  ungroup() 
hotel_date_meal

## Visualizing the breakfasts
ggplot(hotel_date_meal,aes(month, n, col=meal))+ #specifying data and columns to be plotted
  geom_path()+ # connects observations in order
  facet_wrap(vars(hotel))+ # splits graphs into different hotel types
  scale_x_date()+ # x axis
  theme(axis.text.x=element_text(angle=90)) # angles label text

### Joins ----------------------------------------------------------------------
# Country categories are in the ISO 3155-3:2013 format, which isn't immediately helpful to readers
# Let's merge a dataframe that lists these country names out
# I found this one on github: https://gist.github.com/tadast/8827699#file-countries_codes_and_coordinates-csv
# The csv is called countries_codes_and_coordinates.csv

country_codes <- read_csv("data/countries_codes_and_coordinates.csv")

# I want to make a column in my primary data (hotel) that references the Alpha-3 code of countries

# first I am making country_codes smaller, because I only need two columns - the code and full name
country_codes_reduced <- select(country_codes, Country, `Alpha-3 code`) |>
# I put the second column name in `` because it contains a space and a number
rename(country = `Alpha-3 code`) |> # I renamed the country to match the column in hotels 
rename(country_full = Country) 

hotel_merged <- hotel_date |>
  left_join(country_codes_reduced, by = "country") |> # joining by the shared column
  relocate(country, country_full) # moving these columns to the front so they're easy to see

hotel_country_n <- hotel_merged |>
  group_by(hotel, country_full) |> # grouping across the variables
  summarise(n=n()) |> # counts 
  ungroup() |> # ungrouping so I can arrange
  arrange(desc(n))



