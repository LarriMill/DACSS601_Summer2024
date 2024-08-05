#### Function & Iteration + Exploratory Data Analysis used in Lecture 4 Slides ###
# Larri Miller
# DACSS 601
# July 24, 2024

### Packages needed for this script --------------------------------------------
# install.packages("tidyverse") # install tidyverse if you have not done so already
library(tidyverse)
# by loading tidyverse, you get access to dplyr, tidyr, readr, etc.

# install.packages("nycflights13") #uncomment this line to install the package
library(nycflights13)

#install.packages("Lahman")
library(Lahman)

# install.packages("haven")
library(haven)

library(readxl)

### Functions ------------------------------------------------------------------

## Vector Functions
# problem 1 from textbook - turn the following into functions
mean(is.na(x))
mean(is.na(y))
mean(is.na(z))

# we repeat mean(is.na()) multiple times, so let's make a function
mean_na <- function(x){ # descriptive name, argument x
  mean(is.na(x)) # body
}

x / sum(x, na.rm = TRUE)
y / sum(y, na.rm = TRUE)
z / sum(z, na.rm = TRUE)

# let's make a function
divide_sum <- function(x){ # descriptive name, argument x
  x/sum(x, na.rm = TRUE) # body
}

# let's make a function that creates summary stats for a given vector (which can be a column within a df)
# this is essentially another version of summarize()
sum_stat <- function(x){       # x is a vector
  stat <- tibble(              # stat holds the values
    mean=mean(x,na.rm=TRUE),      # calculate mean
    median=median(x,na.rm=TRUE),  # calculate median
    sd=sd(x,na.rm=TRUE)           # calculate standard deviation
  )
  return(stat)                 # return the stat data
}

data(flights) # using the flights data
sum_stat(flights$arr_delay) # pulling in one column using $
sum_stat(flights$distance) # trying a different column


## Data frame functions
# problem 2 from textbook - count the number of cancelled flights & number of flights delayed > 1 hr
summarize_severe <- function(df, group_var, cancelled_var, delayed_var) { # specifying the values I will need
  df |> # opening the df
    group_by({{ group_var }}) |> # grouping
    summarize(
      num_cancelled = sum(is.na({{ cancelled_var }}), na.rm = TRUE), #summarizing # cancelled & # delayed > 1 hr
      num_delayed_over_hr = sum({{ delayed_var }} > 60, na.rm = TRUE)
    ) |>
 arrange(desc(num_cancelled)) # arranging in order of # cancelled
}

summarize_severe(flights, dest, arr_time, arr_delay) # calling the function 

## Plot functions
# just like DF functions, the variable to be plotted needs to be put in {{ }}
histogram <- function(df, var, binwidth = NULL) { # function name + arguments
  df |>                                           # open the df
    ggplot(aes(x = {{ var }})) +                  # call the plot w/ the desired variables
    geom_histogram(binwidth = binwidth)           # specify plot type
}

?diamonds # check out the diamond dataset, part of ggplot, which is loaded already with tidyverse

diamonds |> # open up the diamonds df
  histogram(x, 0.1) + # call the function with x (length) & 0.1 as arguments
  labs(x = "Length in mm", y = "Number of diamonds") # add axis labels

### Iteration ------------------------------------------------------------------

## across() 
?across()

# from challenge 2 - using across()
railroad <- read_excel("data/railroads.xlsx", # filepath
                       sheet = 1, # sheet
                       skip = 4, # skipping blank rows + column name row
                       col_names = c("state", "delete", "county", "delete", "employees")) |> # new col names
  select(!contains("delete")) |> # selecting all but the columns named delete
  filter(!str_detect(state, "Total|CANADA")) # selecting all rows but those with Total or CANADA

railroad <- railroad[-c(2931:2932),] # removing the last two rows with notes

railroad |> # number of distinct states and counties
  summarize(across(c(state, county), n_distinct)) # across(columns, function on columns)

### Conditions & Loops ---------------------------------------------------------
## if
age <- 19 # assigning a single element vector
if(age >= 18){ # if ( var - logical operator - value)
  print("the person is an adult") # do this
} 

age <- 5 # trying where age is outside the if() range
if(age >= 18){
  print("the person is an adult")
} 
# This gives us no output

## if else
if(age >= 18){ # if (var - logical operator - value)
  print ("the person is an adult") # do this
} else { # if variable value is NOT within above if() range
  print ("the person is an adolescent") # do this instead
}

#if() cannot use for more than one condition; 
age <- c(19, 8)

if(age >= 18){
  print ("the person is an adult")
} else{
  print ("the person is an adolescent")
}
# We got an error message here

#ifelse() can have multiple input conditions
?ifelse()
age = c(19, 8, 20, 4)

ifelse(age >= 18, print("the person is an adult"), print("the person is an adolescent"))

## Potential Problem using ifelse()
country <- c("US", "Mexico", "Canada", 
             "India", "China", "Japan", "Korea", 
             "Germany", "France", "Britain",
             "Ethiopia", "Egypt", "Nigeria",
             "Australia", "New Zealand", "Thailand") # creating a vector of country names

get_continent <- function(country_name) { # creating a function
  ifelse(country_name %in% c("US", "Mexico", "Canada"), "North America",
         ifelse(country_name %in% c("India", "China", "Japan", "Korea"), "Asia",
                ifelse(country_name %in% c("Germany", "France", "Britain"), "Europe",
                       ifelse(country_name %in% c("Ethiopia", "Egypt", "Nigeria"), "Africa",
                              ifelse(country_name %in% c("Australia", "New Zealand"), "Australia/Oceania",
                                     "Unknown"))))) # look at how many () we need to keep track of!
} 

get_continent(country)

# Use case_when() instead
get_continent <- function(country_name) {
  case_when(
    country_name %in% c("US", "Mexico", "Canada") ~ "North America", # this is much easier to read and follow
    country_name %in% c("India", "China", "Japan", "Korea") ~ "Asia",
    country_name %in% c("Germany", "France", "Britain") ~ "Europe",
    country_name %in% c("Ethiopia", "Egypt", "Nigeria") ~ "Africa",
    country_name %in% c("Australia", "New Zealand") ~ "Australia/Oceania",
    TRUE ~ "Unknown" # anything that does not fall into the above categories
  )
}

get_continent(country) # same result as the first version, but this function is much easier to understand

## for() and while() loops

#Basic example
volumns <- c(1.6, 3, 5.7, 9) # vector to read in

result <- vector()                   # 1. Output
for (i in 1:length(volumns)){        # 2. Sequence
  result[i] <- 2.5*volumns[i]        # 3. Body
}
print(result)

#Revisit Age and ifelse example
age <- c(5, 12, 15, 48, 2, 48)

for (i in age){ # this will run for every index in age, starting at 1
  if(i >= 18){ # first statement 
    print ("the person is an adult")
  } else if(i >=10 & i < 18){ # middle statements
    print ("the person is an adolescent")
  }
  else{ # last statement
    print ("the person is a child")
  }
}

# If I want to put results in a vector
result <- vector()                       # 1. Output
for (i in 1:length(age)){                # 2. Sequence
  result[i] <- if(age[i] >= 18){         # 3. Body
    "the person is an adult"
  } else if(age[i] >=10 & age[i] < 18){
    "the person is an adolescent"
  }
  else{
    "the person is a child"
  }
}
result


## while loops:
# variable to store the initiate number
number <- 1
# variable to store the initiate sum
sum <- 0

# while loop to calculate sum
while(number <= 10) {
  sum = sum + number   # calculate sum
  number = number + 1  # increment number by 1
}

print(sum)
print(number)

### purrr and map() ------------------------------------------------------------
?map # check out the map() function

#example of using a for loop
library(Lahman)
data(Teams) 
##the MLB data with 30 teams of all the games played for the over 100 years.

View(Teams)
head(Teams)
## column 15-40 contains numerical data about how each team performed in that season


##writing a for loop to compute the average of the player columns, 15 - 40
averages <- NULL    # create an output to be stored
for (i in 15:40) {  # loop that iterates through a sequence of integers from 15 to 40. 
  averages[i - 14] <- mean(Teams[, i], na.rm = TRUE) 
  #[i-14]: give the new index to the new average vecotr; 
  # calculates the mean for the i-th column in the Teams data frame.
}
names(averages) <- names(Teams)[15:40]
# this line assigns column names to the averages vector. 
#It uses the names() function to retrieve the column names from the Teams data frame for columns 15 to 40, 
#and assigns them to the averages vector. 

averages #show the results


##using map() - much easier!
Teams |> 
  select(15:40) |>
  map_dbl(mean, na.rm = TRUE)

### Exploratory Data Analysis (EDA) --------------------------------------------
gss <- read_dta("data/GSS2022.dta") # read in data
head(gss) # sanity check
dim(gss) # dimensions

# unit of observation: the individual respondent who took the General Social Survey in 2022

# variables of interest: degree & polviews
# also keeping id

# RQ: How do political views correlate to one's level of degree?

gss_degree_polviews <- gss |> # creating a df with just the columns I want
  select("id", "degree", "polviews")

# recoding the values so they make sense
gss_degree_polviews <- gss_degree_polviews |>
  mutate(degree_name = case_when(
    degree == 0 ~ "Less than High School",
    degree == 1 ~ "High School",
    degree == 2 ~ "Associate/Junior College",
    degree == 3 ~ "Bachelors",
    degree == 4 ~ "Graduate"
  )) |>
  mutate(polviews_name = case_when(
    polviews == 1 ~ "Extremely Liberal",
    polviews == 2 ~ "Liberal",
    polviews == 3 ~ "Slightly Liberal",
    polviews == 4 ~ "Moderate",
    polviews == 5 ~ "Slightly Conservative",
    polviews == 6 ~ "Conservative",
    polviews == 7 ~ "Extremely Conservative"
  )) 

head(gss_degree_polviews)

# let's convert our new variables to factors, too, for later visualization
degree_levels <- c("Less than High School", "High School", "Associate/Junior College", "Bachelors", "Graduate")
pol_levels <- c("Extremely Liberal", "Liberal", "Slightly Liberal", "Moderate", "Slightly Conservative", "Conservative", "Extremely Conservative")

gss_degree_polviews$degree_name <- factor(gss_degree_polviews$degree_name, level = degree_levels)
gss_degree_polviews$polviews_name <- factor(gss_degree_polviews$polviews_name, level = pol_levels)

head(gss_degree_polviews)

# checking summary statistics using the original numerical columns
gss_degree_polviews_stats <- gss_degree_polviews |>
  summarize(range_degree = range(degree, na.rm = TRUE),
            range_pol = range(polviews, na.rm = TRUE),
            mean_degree = mean(degree, na.rm = TRUE),
            mean_pol = mean(polviews, na.rm = TRUE),
            sd_degree = sd(degree, na.rm = TRUE),
            sd_pol = sd(polviews, na.rm = TRUE),
            na_degree = sum(is.na(degree)),
            na_pol = sum(is.na(polviews)))

gss_degree_polviews_stats

# We could use the sum_stat function we wrote above instead

sum_stat(gss_degree_polviews$degree)
sum_stat(gss_degree_polviews$polviews)

# I do not expect you to accomplish the next steps for challenge 4! This is just to help you think through visualizing next week

# these are two categorical variables so we can do a stacked bar plot

gss_degree_polviews |>
  subset(!is.na(polviews_name)) |> # remove NAs from polviews
  ggplot(aes(x = degree_name, fill = polviews_name)) + # variables to be plotted
  geom_bar(position = "stack") +  # plot type
  labs(title = "Distribution of Political Views and Education Levels", x = "Education Level") + # labels
  theme(axis.text.x = element_text(angle = 70, hjust = 1)) + # avoid overlapping text in the x axis
  guides(fill = guide_legend(title = "Political Views")) # relabel the legend

# let's try a geom_tile() like the book
gss_degree_polviews |>
  subset(!is.na(polviews_name)) |> # remove NAs from polviews
  count(degree_name, polviews_name) |> # count occurrences within each variable
  ggplot(aes(x = degree_name, y = polviews_name)) + # designate the plot + variables
  geom_tile(aes(fill = n)) + # filling with count
  labs(title = "Distribution of Political Views and Education Levels", x = "Education Level") + # labels
  theme(axis.text.x = element_text(angle = 70, hjust = 1))  # avoid overlapping text in the x axis
