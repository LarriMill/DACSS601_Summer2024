#### Visualization used in Lecture 5 Slides ###
# Larri Miller
# DACSS 601
# August 4, 2024

### packages needed for this script --------------------------------------------
# install.packages("tidyverse") # install tidyverse if you have not done so already
library(tidyverse)
# by loading tidyverse, you get access to ggplot2

# install.packages("ggthemes") # install ggthemes
library(ggthemes)
# check out https://github.com/jrnold/ggthemes for different ggtheme options

# install.packages("palmerpenguins") # install palmerpenguins if you have not already
library(palmerpenguins)

# install.packages("scales") # install scales if you have not already
library(scales)

# install.packages("ggrepel") # install ggrepel if you have not already
library(ggrepel)

# install.packages("patchwork") # install patchwork if you have not already
library(patchwork)

### ggplot2 building blocks ----------------------------------------------------

# step 1 - call ggplot()
ggplot() # this should pop up a blank "plots" window in your bottom right quadrant 

# step 2 - define the data you are using
ggplot(data = penguins) # you don't have to explicitly type "data", ggplot know the 
# first argument is the data

# step 3 - map your aesthetics (variables)
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)) # now you have defined axes

# step 4 - define plot type
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point() # specify that you want a scatterplot

# step 5 - add more aesthetics and layers

# add in color
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)) + # color is an arg within aes()
  geom_point()

# add in a smooth curve to show the relationship
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)) +
  geom_point() +
  geom_smooth(method = "lm") # this adds in a line of best fit based on a linear model
# this graph produces 3 separate lines of best fit based on the species

# instead let's only break up the species when regarding color
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(mapping = aes(color = species)) + # now the line of best fit will just be 1 rather than 3
  geom_smooth(method = "lm")

# adjust shape based on species
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(mapping = aes(color = species, shape = species)) + # we do this just at the level of the scatterplot
  geom_smooth(method = "lm")

# add labels
ggplot(                                                                    # call ggplot()
  data = penguins,                                                         # specify data
  mapping = aes(x = flipper_length_mm, y = body_mass_g)) +                 # specify x and y mapping
  geom_point(aes(color = species, shape = species)) +                      # scatterplot + species broken down by color & shape
  geom_smooth(method = "lm") +                                             # line of best fit
  labs(                                                                    # labels
    title = "Body mass and flipper length",
    subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo Penguins",
    x = "Flipper length (mm)", y = "Body mass (g)",                        # axes
    color = "Species", shape = "Species") +                                # legend labels                                
  scale_color_colorblind()                                                 # colorblind friendly pallette from ggthemes
  

# 1.2.5 exercise # 8 from R4DS - replicate the example
penguins |> # can open up df and then pipe
  ggplot(
  aes(flipper_length_mm, body_mass_g)) +
  geom_point(aes(color = bill_depth_mm)) +
  geom_smooth() + # by not specifying method =, smoothing is based on the largest group
  labs( # I chose to add in labels
    title = "Body mass and flipper length",
    subtitle = "Flipper length and body mass show a positive correlation inverse to bill depth", # descriptive subtitle
    x = "Flipper Length (mm)", y = "Body mass (g)",
    color = "Bill depth (mm)"
  )

### plotting distributions -----------------------------------------------------
# also known as Univariate Analysis

# histogram binwidth example

ggplot(penguins, aes(x = body_mass_g)) + # specify data, x variable
  geom_histogram(binwidth = 20) + # specify plot type, set bin width
  labs(title = "Binwidth = 20", # add labels
       subtitle = "This binwidth is too small")

ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 2000) +
  labs(title = "Binwidth = 2000",
       subtitle = "This binwidth is too large")

ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 200) +
  labs(title = "Binwidth = 200",
       subtitle = "This binwidth is just right #Goldilocks")

# 1.4.3. Exercise 4 - make a histogram of the carat variable of the diamonds data
?diamonds
# I see that the carat variable ranges from 0.2 - 5.01

diamonds |>
  ggplot(aes(x = carat)) +
  geom_histogram(binwidth = 0.01) # this looks too small

diamonds |>
  ggplot(aes(x = carat)) +
  geom_histogram(binwidth = 1) # this looks too big

diamonds |>
  ggplot(aes(x = carat)) +
  geom_histogram(binwidth = 0.1) # this is the binwidth used in ch. 25 from last week

### Visualizing relationships between variables --------------------------------
# also known as Multivariate Analysis

## Numerical and Categorical Variable

# side-by-side box plot
ggplot(penguins, aes(x = species, y = body_mass_g)) +
  geom_boxplot()
# this shows us that gentoo are by far the largest, adelie & chinstrap are closer but chinstrap is more
# densely packed around the middle with a few outliers

# density plot
ggplot(penguins, aes(x = body_mass_g, color = species)) +
  geom_density(linewidth = 0.75) # play with the line thickness

ggplot(penguins, aes(x = body_mass_g, color = species)) +
  geom_density(linewidth = 0.5) # thinner line

ggplot(penguins, aes(x = body_mass_g, color = species)) +
  geom_density(linewidth = 1) # thicker line

# fill in the area under the curves
ggplot(penguins, aes(x = body_mass_g, color = species, fill = species)) +
  geom_density(alpha = 0.5) # play with the transparency from 0 to 1

ggplot(penguins, aes(x = body_mass_g, color = species, fill = species)) +
  geom_density(alpha = 0.25) # less opaque

ggplot(penguins, aes(x = body_mass_g, color = species, fill = species)) +
  geom_density(alpha = 0.75) # more opaque

# adjust line width and under curve transparency
ggplot(penguins, aes(x = body_mass_g, color = species, fill = species)) +
  geom_density(alpha = 0.5, linewidth = 0.75) +
  scale_color_colorblind() # adjusted for colorblind friendliness

## Two Categorical Variables

# stacked bar chart
ggplot(penguins, aes(x = island, fill = species)) +
  geom_bar() # heights different

ggplot(penguins, aes(x = island, fill = species)) +
  geom_bar(position = "fill") # heights all the same

## Two Numerical Variables
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point() +
  geom_smooth() # I added this in addition to the R4DS ch. 1 code

## Three or More Variables

ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species, shape = island)) # adding in the 3rd variable as color & 4th as shape

# facets
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species, shape = species)) + # color and shape both indicate species
  facet_wrap(~island) # now individual facets represent islands

# R4DS 1.5.5 Exercise 2 - hwy vs. display w/ 3rd numerical var
?mpg
mpg |>
  ggplot(aes(displ, hwy)) +
  geom_point(aes(color = class, shape = class)) + # geom_point because these are 2 numerical vars
  # I am plotting class, a categorical var of car type, using color + shape
  geom_smooth() + # I always add in line of best fit to better interpret the graph +
  labs(title = "Miles per Gallon vs. Engine Displacement by Class",
       x = "Engine displacement (Litres)",
       y = "Highway miles per gallon (mpg)")

# SUV isn't plotted in this graph, because there are only 6 shapes available

mpg |>
  ggplot(aes(displ, hwy)) +
  geom_point(aes(color = class)) + # geom_point because these are 2 numerical vars
  # I am plotting class, a categorical var of car type, using color + shape
  geom_smooth() + # I always add in line of best fit to better interpret the graph 
  labs(title = "Miles per Gallon vs. Engine Displacement by Class",
       x = "Engine displacement (Litres)",
       y = "Highway miles per gallon (mpg)")
# just using color is more appropriate

# version with colorblindness palette
mpg |>
  ggplot(aes(displ, hwy)) +
  geom_point(aes(color = class)) + # geom_point because these are 2 numerical vars
  # I am plotting class, a categorical var of car type, using color + shape
  geom_smooth() + # I always add in line of best fit to better interpret the graph 
  labs(title = "Miles per Gallon vs. Engine Displacement by Class",
       x = "Engine displacement (Litres)",
       y = "Highway miles per gallon (mpg)") +
  scale_color_colorblind()

### Layers ---------------------------------------------------------------------

# R4DS 9.2.1 Exercise 1 - scatterplot w/ points that are pink filled in triangles
mpg |>
  ggplot(aes(displ, hwy)) +
  geom_point(shape = 24, color = "hotpink", fill = "pink") # used shape, color, fill
# I like to make the outline a bit darker than the fill

# adjusting line type
ggplot(mpg, aes(x = displ, y = hwy, color = drv)) + # specify drv as a global var
  geom_point() +
  geom_smooth(aes(linetype = drv)) # adjusting line type based on drv

# display different aesthetics in different layers
ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point() + # plot global x and y
  geom_point(
    data = mpg |> filter(class == "2seater"), # add in a second layer of data
    color = "red"
  ) +
  geom_point(
    data = mpg |> filter(class == "2seater"), # circle that second layer
    shape = "circle open", size = 3, color = "red"
  )

## position adjustments - bar chart

# note that in the following 2 examples x = the same var used for color & fill
ggplot(mpg, aes(x = drv, color = drv)) + # color = adjusts the outline
  geom_bar()

ggplot(mpg, aes(x = drv, fill = drv)) + # fill = adjusts bar color
  geom_bar() 

# now filling aes() with a variable other than what was used for x

# stacked
ggplot(mpg, aes(x = drv, fill = class)) + 
  geom_bar()

# bars the same height w/ position = fill
ggplot(mpg, aes(x = drv, fill = class)) + 
  geom_bar(position = "fill") # position arg only goes in the geom_bar() call

# bars positioned next to each other w/ position = dodge
ggplot(mpg, aes(x = drv, fill = class)) + 
  geom_bar(position = "dodge")

## position adjustments - scatter plot
ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point() # regular scatter plot

ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_jitter() # adding in some randomness.

### Communication --------------------------------------------------------------

## labels
ggplot(mpg, aes(x = displ, y = hwy)) + # x and y variables
  geom_point(aes(color = class)) + # graph type, 3rd categorical var shown with color
  geom_smooth(se = FALSE) + # se is confidence interval
  labs(
    x = "Engine displacement (L)", # units!
    y = "Highway fuel economy (mpg)",
    color = "Car type", # legend description
    title = "Fuel efficiency generally decreases with engine size", # summarize main finding
    subtitle = "Two seaters (sports cars) are an exception because of their light weight", # points out exception
    caption = "Data from fueleconomy.gov" # tells where data is from
  )

## annotation
# mutate a new column that describes drive type beyond a single letter
mpg <- mpg |>
  mutate(drive_type = case_when( # new descriptive column
      drv == "f" ~ "front-wheel drive",
      drv == "r" ~ "rear-wheel drive",
      drv == "4" ~ "4-wheel drive")) |>
    relocate(drive_type) # moving to front to see easily w/ head()

head(mpg) # it worked!

ggplot(mpg, aes(x = displ, y = hwy, color = drv)) + # 3 chosen variables
  geom_point(alpha = 0.3) + # transparency of point
  geom_smooth(se = FALSE) + # line of best fit with no confidence interval
  geom_label_repel( # adjust labels so they don't overlap
    aes(x = displ, y = hwy, label = drive_type),
    fontface = "bold", size = 5, nudge_y = 2 # font parameters
  ) +
  theme(legend.position = "none") # no legend because the graph itself is labeled

# Multiple points of the same category are labelled, which is not what we want. Instead:

# create a df just with label info
label_info <- mpg |>
  group_by(drv) |>
  arrange(desc(displ)) |>
  slice_head(n = 1) |>
  mutate(
    drive_type = case_when(
      drv == "f" ~ "front-wheel drive",
      drv == "r" ~ "rear-wheel drive",
      drv == "4" ~ "4-wheel drive"
    )
  ) |>
  select(displ, hwy, drv, drive_type)
head(label_info)

ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point(alpha = 0.3) +
  geom_smooth(se = FALSE) +
  geom_label_repel(
    data = label_info, 
    aes(x = displ, y = hwy, label = drive_type),
    fontface = "bold", size = 5, nudge_y = 2
  ) +
  theme(legend.position = "none")
# now we only have one label for each position!

# adjusting label to be %
ggplot(diamonds, aes(x = cut, fill = clarity)) +
  geom_bar(position = "fill") +
  scale_y_continuous(name = "Percentage", labels = label_percent())
# for a complete version of this graph, the legend labels should be recoded & a title should be added

# change location of legend
ggplot(mpg, aes(x = displ, y = hwy)) + # variables
  geom_point(aes(color = class)) + # scatterplot, categorical var as color
  geom_smooth(se = FALSE) + # line of best fit
  theme(legend.position = "bottom") + # adjust legend position
  guides(color = guide_legend(nrow = 2, override.aes = list(size = 4))) + 
# the above line makes the legend have 2 rows of 4 columns
  labs(
    x = "Engine displacement (L)", # units!
    y = "Highway fuel economy (mpg)",
    color = "Car type", # legend description
    title = "Fuel efficiency generally decreases with engine size", # summarize main finding
    subtitle = "Two seaters (sports cars) are an exception because of their light weight", # points out exception
    caption = "Data from fueleconomy.gov" # tells where data is from
  )

# manually adjust color scale
presidential |> # dataset in ggplot
  mutate(id = 33 + row_number()) |> # adding in var that tells us what # pres was (starts @ Eisenhower, # 34)
  ggplot(aes(x = start, y = id, color = party)) + # start date, pres #, party
  geom_point() +
  geom_segment(aes(xend = end, yend = id)) + # line from end date to next pres start date
  scale_color_manual(values = c(Republican = "#E81B23", Democratic = "#00AEF3"))  + # manually create color w/ hex code 
  labs(x = "Start Date",
       y = "President Number",
       title = "Term lengths for Presidents from 1960 to 2020")

# adjust theme
?theme

# R4DS 11.5.1 Exercise 1 - pick a theme and apply to last plot
presidential |> # dataset in ggplot
  mutate(id = 33 + row_number()) |> # adding in var that tells us what # pres was (starts @ Eisenhower, # 34)
  ggplot(aes(x = start, y = id, color = party)) + # start date, pres #, party
  geom_point() +
  geom_segment(aes(xend = end, yend = id)) + # line from end date to next pres start date
  scale_color_manual(values = c(Republican = "#E81B23", Democratic = "#00AEF3"))  + # manually create color w/ hex code 
  labs(x = "Start Date",
       y = "President Number",
       title = "Term lengths for Presidents from 1960 to 2020") +
  theme_economist() # picked out the economist theme

# Exercise 2 - make axis blue and bolded
presidential |> # dataset in ggplot
  mutate(id = 33 + row_number()) |> # adding in var that tells us what # pres was (starts @ Eisenhower, # 34)
  ggplot(aes(x = start, y = id, color = party)) + # start date, pres #, party
  geom_point() +
  geom_segment(aes(xend = end, yend = id)) + # line from end date to next pres start date
  scale_color_manual(values = c(Republican = "#E81B23", Democratic = "#00AEF3"))  + # manually create color w/ hex code 
  labs(x = "Start Date",
       y = "President Number",
       title = "Term lengths for Presidents from 1960 to 2020") +
  theme( # I made everything different shades of blue because I feel chaotic
    axis.title.x = element_text(color = "deepskyblue3", face = "bold.italic", family = "arial"),
    axis.title.y = element_text(color = "cyan3", face = "bold"),
    title = element_text(color = "darkblue", family = "serif")
    ) 
# In a real graph you don't want to choose this many colors/fonts. I am just showing you the versatility of theme.
# find color options here: https://r-graph-gallery.com/ggplot2-color.html

# put plots next to each other with patchwork
p1 <- ggplot(mpg, aes(x = displ, y = hwy)) + # save plots as objects
  geom_point() + 
  labs(title = "Plot 1")
p2 <- ggplot(mpg, aes(x = drv, y = hwy)) + 
  geom_boxplot() + 
  labs(title = "Plot 2")
p3 <- ggplot(mpg, aes(x = cty, y = hwy)) + 
  geom_point() + 
  labs(title = "Plot 3")

(p1 | p3) / p2 # put plot 1 and 3 next to each other, 3 below

### Factors --------------------------------------------------------------------
?fct
?gss_cat

# R4DS 16.3.1 Exercise 2 - most common relig and partyid in survey
head(gss_cat) # both vars are factors

gss_cat |>
  count(relig) |>
  arrange(desc(n)) # 15 different religious categories, with Protestant having the most by far

gss_cat |>
  count(partyid) |>
  arrange(desc(n)) # 10 different partyid categories, with Independent having the most

# R4DS 16.3.1 Exercise 3 - Which relig does denom apply to, find out with visual
gss_cat |>
  ggplot(aes(x = denom, color = relig, fill = relig)) + 
  geom_bar(position = "fill") +
  theme(axis.text.x = element_text(angle = 90)) + # adjust angle of x axis labels
  scale_color_colorblind()

# find out with table
gss_cat |>
  count(denom, relig) |>
  arrange(desc(n))

# both show that denom is overwhelmingly protestant
# we need to lump some of these categories together

gss_cat |>
  mutate(relig = fct_lump_n(relig, n = 10)) |> # specify # of levels
  count(relig, sort = TRUE)

gss_cat |>
  mutate(denom = fct_lump_lowfreq(denom)) |> # don't specify # of levels
  count(denom, sort = TRUE)
# 29 categories seems excessive

gss_cat |>
  mutate(denom = fct_lump_n(denom, n = 10)) |> # specify number of levels
  count(denom, sort = TRUE)

## modify factor order
relig_summary <- gss_cat |> # creating new df
  group_by(relig) |> 
  summarize(
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n() # count
  )

ggplot(relig_summary, aes(x = tvhours, y = relig)) + # plotting
  geom_point() # can't see a particular trend

average_num_hrs <- mean(gss_cat$tvhours, na.rm = TRUE) # to add average line
above_average <- relig_summary |>
  filter(tvhours > average_num_hrs)

ggplot(relig_summary, aes(x = tvhours, y = fct_reorder(relig, tvhours), size = n)) + # reorder the factor
  geom_point() + # now it's easy to see most vs. least TV hours
  geom_vline(xintercept = average_num_hrs, color = "red", linetype = "dashed") + # add line at mean
  labs(x = "Hours per day watching TV",
       y = "Religious affilitation",
       caption = "Data from gss.dataexplorer.norc.org",
       title = "Religious Affiliation and Hours Spent Watching TV",
       subtitle = "Those who 'Don't Know', Native Americans, & Protestants watch above average",
       size = "Number of participants") +
  annotate(geom = "label",
           x = 3.75, # play around with x and y position
           y = 2,
           label = "Average: 2.98 hours",
           size = 3) + # can adjust text size 
  geom_point(data = above_average,
             color = "red", 
             shape = "circle open",
             show.legend = FALSE) # don't want the legend to have red outline
