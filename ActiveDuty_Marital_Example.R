#### Example: Data Import + Data Transformation + Data Tidying w/ the Active Duty Marital Excel Data ###
# Larri Miller
# DACSS 601
# July 11, 2024

library(tidyverse)

### Step by Step ---------------------------------------------------------------

# For this example I run through everything step by step with intermediate dfs, and then have a condensed version at the end

# reading in the data with no prep
dod_mess <- read_excel("data/ActiveDuty_MaritalStatus.xls")

# first let's create our own column names, using "delete" for those we want to remove
dod_cols <- c("delete", "payGrade_payLevel", "single_nokids_male", "single_nokids_female", "delete", "single_kids_male", "single_kids_female",
              "delete", "married_military_male", "married_military_female", "delete", "married_civilian_male", "married_civilian_female", "delete",
              rep("delete", 3))

# we do not want any "total" column
marital_dod <- read_excel("data/ActiveDuty_MaritalStatus.xls", # file name
                          sheet = "TotalDoD", # specifying which sheet
                          skip = 9, # how many rows to skip
                          col_names = dod_cols) # assigning our own column names

# removing blank columns
dod_select <- marital_dod |>
  select(!contains("delete")) # this selects anything that does NOT contain "delete"

# removing rows with "TOTAL"
dod_filter <- dod_select |>
  filter(!str_detect(payGrade_payLevel, "TOTAL")) # this is a stringr function that detects if a string is present

# pivoting longer so that we can separate out the columns that represent marital status + kids/spouse + gender
dod_longer <- dod_filter |>
  pivot_longer(cols = !payGrade_payLevel, # all columns EXCEPT payGrade_payLevel
               names_to = c("marital", "other", "gender"), 
               names_sep = "_",
               values_to = "count")

# splitting pay grade and pay level
dod_split <- dod_longer |>
  separate_wider_delim(cols = payGrade_payLevel,
                       delim = "-",
                       names = c("pay_grade", "pay_level"))

# using case_when to change the values of pay_grade so they make sense
dod_mutate <- dod_split |>
  mutate(pay_grade = case_when(
    pay_grade == "E" ~ "Enlisted",
    pay_grade == "O" ~ "Officer",
    pay_grade == "W" ~ "Warrant Officer"
  ))

### Condensed ------------------------------------------------------------------

dod_cols <- c("delete", "payGrade_payLevel", "single_nokids_male", "single_nokids_female", "delete", "single_kids_male", "single_kids_female",
              "delete", "married_military_male", "married_military_female", "delete", "married_civilian_male", "married_civilian_female", "delete",
              rep("delete", 3))

dod <- read_excel("data/ActiveDuty_MaritalStatus.xls", 
                          sheet = "TotalDoD",
                          skip = 9, 
                          col_names = dod_cols) |>
  select(!contains("delete")) |>
  filter(!str_detect(payGrade_payLevel, "TOTAL")) |>
  pivot_longer(cols = !payGrade_payLevel,
               names_to = c("marital", "other", "gender"),
               names_sep = "_",
               values_to = "count") |>
  separate_wider_delim(cols = payGrade_payLevel,
                       delim = "-",
                       names = c("pay_grade", "pay_level")) |>
  mutate(pay_grade = case_when(
    pay_grade == "E" ~ "Enlisted",
    pay_grade == "O" ~ "Officer",
    pay_grade == "W" ~ "Warrant Officer"
  ))


  
