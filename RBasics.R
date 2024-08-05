#### R Basics Script Examples used in Lecture 1 Slides ###
# Larri Miller
# DACSS 601
# July 7, 2024

### Installing & calling packages ----------------------------------------------
install.packages(tidyverse) # you can run this line in the console instead of in the script
library(tidyverse) # you should always have the libraries you are using at the very top of the code

### Commenting code ------------------------------------------------------------
# When you comment, be descriptive. Anything behind the hashtag is not read as code

x <- "Hello World" # assigning a string value

empty_list <- list() # creating an empty list

# creating a function called add_1 that takes an input of x and returns x + 1
add_1 <- function(x) {
  y <- x + 1
  print(y)
}

add_1(1) # running add_1 with an x value of 1

### Code Style -----------------------------------------------------------------
# Naming nomenclature is really important!

Pet Names <- # this name is improper because it has a space and capital letters in it
blah <- # this name is improper because it is not descriptive
pet_names <- # this name is descriptive, uses a _ between words, and is in lowercase
  
### Data Types and Data Structures ---------------------------------------------

logical_var <- TRUE # assinging a logical variable
class(logical_var) # checking the class

numerical_var <- 718 # assinging a numerical variable
class(numerical_var) # checking the class

numerical_to_string <- as.character(numerical_var) #changing a numerical value to a string one
class(numerical_to_string) # checking the class

string_var <- "718" # assigning a string variable
class(string_var) # checking the class

## Vectors 
larri_pet_names <- c("George", "Brian", "Button", "Dave", "Egg") # creating a vector of names
larri_pet_names # viewing the vector
class(larri_pet_names) # checking the data type of the vector

ages <- c(25, 31, 39) # creating a vector of ages
ages # viewing the vector
class(ages) # checking the data type of the vector

vector_coercion_example <- c("hello", 18, TRUE) # this vector has string, numerical, and logical data 
class(vector_coercion_example) # but R forced all of the data to be character

## Factors
animal_type <- c("Rabbit", "Fish", "Snail", "Snail", "GuineaPig") # here I am referencing the type of animal in larri_pet_names
animal_type # printing the values

# However, my house has one more animal type: shrimp! So if you looked at the animal_type vector, you wouldn't realize that
# there are more options for the animals in my home!

animal_type_factor <- factor(animal_type, levels = c("Rabbit", "GuineaPig", "Fish", "Snail", "Shrimp")) # I use the factor() function
# to convert animal_type to factor and make the possible levels explicit

animal_type_factor # now when I view animal_type it tells me what levels I have

## Data Frames
larri_pets <- data.frame(Name = larri_pet_names, Type = animal_type_factor) # Here I give my dataframe a descriptive name, use the data.framne() function
# and specify what I want the columns to be. Now the pet name is matched up to the pet type.
larri_pets # this allows me to view the dataframe
  
## Lists
example_list <- list("this", FALSE, "contains", 3, "different", TRUE, 9.7, "elements") # using the list() function
example_list

## Missing Data
na_example <- c(1, 2, NA, 4, 5) # this is a vector because I use "c" to create it
na_example

is.na(na_example) # using the is.na() function, which returns logical values

mean(na_example) # if there is an NA, the calculation comes back as NA
mean(na_example, na.rm = TRUE) # using na.rm = TRUE allows the computation to run

### Accessing Specific Elements of a Data Structure ----------------------------
# Vector Example
animal_type[1] # use the [ ] to indicate what element you want

# Data frame example
larri_pets[1,1] # I just want the "George" cell

larri_pets[,1] # all rows of only the first column
larri_pets[1,] # only the first row of all of the columns

# Accessing a specific column
larri_pets$Name

# Subsetting with logical vectors
# for this example I am expanding the larri_pets data frame to include a numerical column
pet_age <- c(2.5, 1, 1, 1, 5) # this is the pet's ages in years
larri_pets_age <- data.frame(Name = larri_pet_names, Type = animal_type_factor, Age = pet_age) # creating a new df with a descriptive name
larri_pets_age

larri_pets_aquatic <- subset(larri_pets_age, Type == "Fish" | Type == "Snail") #using multiple |
larri_pets_aquatic

larri_pets_aquatic2 <- subset(larri_pets_age, Type %in% c("Fish", "Snail")) # using %in%
larri_pets_aquatic2

