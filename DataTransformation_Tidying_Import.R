#### Data Transformation, Tidying & Import used in Lecture 2 Slides ###
# Larri Miller
# DACSS 601
# July 11, 2024

### Packages needed for this script --------------------------------------------
# install.packages("tidyverse") # install tidyverse if you have not done so already
library(tidyverse)
# by loading tidyverse, you get access to dplyr, tidyr, readr, etc.

#install.packages("nycflights13") #uncomment this line to install the package
library(nycflights13)

# install.packages("readxl") # uncomment this line to install the package
library(readxl)

### Data Transformation --------------------------------------------------------
# this section uses functionality from dplyr
# we are using the flights dataset referenced in Ch. 3. This dataset is part of nycflights13

?flights # this pulls up information about the data in our help panel
data(flights) #this pulls flights into my environment
View(flights) # this opens flights in a new tab of the source window

## transformation based on rows ##
## Filter()
# flights delayed more than one hour
flights |> # using the pipe
  filter(dep_delay > 60) # specifying the column and the condition > 60

# flights that departed on July 18 (my birthday!)
flights |> 
  filter(month == 7 & day == 18)

# let's say I want to save just the 7/18 flights in a separate data frame:
flights_larri_bday <- flights |> # flights_larri_bday is the new name
  filter(month == 7 & day == 18)

# Maybe I only want the flights from summer months:
flights_summer <- flights |>
  filter(month %in% c(7, 8, 9))

## arrange()
# I can arrange the data in ascending or descending order
flights_larri_bday |>
  arrange(desc(dep_delay))
# The longest flight delay time on my birthday in 2013 was 396 minutes - over 6 hours!

## distinct()
# I want to know how many different carriers there are in the data
n_distinct(flights$carrier) # here I can just use $ to isolate a single column

# I could also use summarize(), which generates a new dataframe:
flights |>
  summarize(unique_carriers = n_distinct(carrier))
  # in summarize() I declare the column name to be unique_carriers
  # and the value of that column is n_distinct(carrier)

## transformation based on columns ##
## mutate()

# When I checked how many hours 396 minutes is for the above example, I pulled out
# my calculator. But r is a calculator, and I can use mutate() to create an hours column:

flights_dep_delay_hr <- flights |>
  mutate(dep_delay_hr = dep_delay/60, # new column = existing column / 60
         .after = dep_delay) # moving new column to be beside column it references

# now I can arrange with the hour variable:
flights_dep_delay_hr |> 
  arrange(desc(dep_delay_hr))
# wow, the longest delay in 2013 was 21 hours!

## select()
# I can easily select only the columns that I want

flights |>
  select(year, month, day)

# if I want to save this subset, I need to adjust the first line:
flights_date <- flights |>
  select(year, month, day)

# let's say I want all columns BUT those with date info:
flights_no_date <- flights |>
  select(!year:day)

# or I don't want the columns that have the word "dep"
flights_no_dep <- flights |>
  select(!contains("dep"))

## rename() renames a column
# this is particularly useful when the names don't make inherent sense or are
# associated with an experiment/survey

flights_rename <- flights |>
  rename(distance_in_miles = distance) # here I remind myself of the unit
# when renaming, the format is: rename(new_name = old_name)

## relocate() allows you to move variables around
flights_rename_relocate <- flights_rename |>
  relocate(distance_in_miles) # now distance_in_miles is up front

## Grouping - group_by() and summarize()
flights_dep_delay_hr |> # using the df where we created the hour delay column
  group_by(origin) |> # grouping by origin airport
  summarize(avg_hr_delay = mean(dep_delay_hr, na.rm = TRUE), 
            n = n()) # naming two columns: one that calculates mean, one that counts

# grouping by multiple columns
flights |>
  group_by(origin, dest) 

# practice: what origin - dest combo has the highest hr delay average?
flights_dep_delay_hr |>
  group_by(origin, dest) |>
  summarise(mean_delay = mean(dep_delay_hr, na.rm = TRUE)) |>
  arrange(desc(mean_delay))

## slice() - allow you to extract specific rows from each group
flights_dep_delay_hr |>
  group_by(origin) |> 
  slice_max(dep_delay_hr, n = 1) |> 
  relocate(origin)

# The longest departure delay from EWR is 18.8 hrs, from JFK is 21.7 hrs, and 
# from LGA is 15.2 hrs.

### Data Tidying ---------------------------------------------------------------
# this section uses functionality from tidyr

# let's work with the table examples from the textbook. I recreate them below
table2 <- data.frame(country = c("Afghanistan", "Afghanistan", "Afghanistan", "Afghanistan", "Brazil", "Brazil"),
                     year = c(1999, 1999, 2000, 2000, 1999, 1999),
                     type = c("cases", "population", "cases", "population", "cases", "population"),
                     count = c(745, 19987071, 2666, 20595360, 37737, 172006362))

table3 <- data.frame(country = c("Afghanistan", "Afghanistan", "Brazil", "Brazil", "China", "China"),
                     year = c(1999, 2000, 1999, 2000, 1999, 2000),
                     rate = c("745/19987071", "2666/20595360", "37737/172006362", "80488/174504898", "212258/1272915272", "213766/1280438583"))

## fixing table2
# table2 has two different variables under the type column, so it needs to be pivoted wider

table2_wide <- table2 |> # naming a new data frame
  pivot_wider(
    names_from = type,
    values_from = count
  )

table2_wide # inspecting my new dataframe - now cases and population each have their own columns

## fixing table3
# table3 has two values in rate, separated by /
table3_wide <- table3 |>
  separate_wider_delim(cols = rate, delim = "/", names = c("cases", "population")) 
# separate_wider_delim() is from tidyr. It separates a column based on a specific delimiter, in this case /
# you have to tell it what the new column names should be via names =
?separate_wider_delim # delete the first hashtag and run this line to learn more

table3_wide # inspecting my new dataframe - now cases and population each have their own columns

# this example references the FAOSTAT_livestock.csv dataset. You can download this data
# from classroom under week 2
livestock <- read_csv("data/FAOSTAT_livestock.csv")

View(livestock) # checking out the data

# let's remove the code columns as well as flag, as these don't give us any new information
livestock_reduced <- livestock |>
  select(!contains("code")) |>
  select(!contains("flag"))

# domain, element, and unit look to just be the same thing repeated over and over. 
# We can check this with n_distinct() or unique()

n_distinct(livestock_reduced$Domain) # gives ouput "1"
unique(livestock_reduced$Domain) # output is "Live Animals"

# I can use summarize here to calculate all at once
livestock_reduced |> summarize(
  n_domain = n_distinct(Domain),
  n_element = n_distinct(Element),
  n_unit = n_distinct(Unit)
) # each of these only have one value, so let's remove them!

livestock_reduced <- livestock_reduced |>
  select(!c(Domain, Element, Unit))

head(livestock_reduced)

# Let's arrange by year
livestock_reduced |>
  arrange(Year)

# We notice that there are Items spread across multiple rows
# The animal type seems like an important variable, so we can pivot_wider()
# so that each type (Asses, Camels, Cattle, etc.) has it's own column

livestock_wide <- livestock_reduced |>
  pivot_wider(names_from = Item,
              values_from = Value)

head(livestock_wide)
dim(livestock_wide) # our data went from 4 x 82,116 to 11 x 13,347

# pivot_longer example from book
data(billboard)
?billboard

View(billboard)

# Here we can pivot_longer so that week is not spread across so many columns
# this will be helpful for visualization across time if all weeks are in a single column

billboard_long <- billboard |>
  pivot_longer(
    cols = starts_with("wk"), # that way you don't have to type wk1, wk2, all the way to wk 76
    names_to = "week",
    values_to = "rank"
  )

head(billboard_long) # double check

# Now we can group by week, sort by ascending value, and slice to show the top artist from each week

billboard_rank <- billboard_long |>
  group_by(week) |>
  slice_max(rank, n = 1) |>
  relocate(artist, track)

billboard_rank

### Data Import ----------------------------------------------------------------
# this section uses functionality from readr, readxl, and haven
?read_excel # check out the function via the help panel


# the wild bird data is in excel format
# excel formats are tricky because people often use these as publication format, with lots of white space, notes, etc

# let's try just reading in the data

birds <- read_excel("data/wild_bird_data.xlsx")
birds #the titles aren't right, we have extra info in the first view rows, & the columns are classed as char

# we need to use the skip argument
birds_skipped <- read_excel("data/wild_bird_data.xlsx", skip = 1)
birds_skipped # columns are now the right type

# let's skip the title columns and assign our own
birds_updated_cols <- read_excel("data/wild_bird_data.xlsx", skip = 2, col_names = c("weight", "pop_size"))
glimpse(birds_updated_cols) # this looks much better!





