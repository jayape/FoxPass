# Basic math
1 + 3
4 / 2


# Assignment operators. = can be used but <- is preferred
a <- 3
a

b = 4
b

# You can also use print
print(a)


# View and remove objects in your environment
objects()

rm(a)
objects()

rm(list = objects())
objects()

# concatenation
a <- c(1,3,5,7,9)
a

a[2]

# sequence
b <- c(1:50)
b
b [35]

# class
class(b)

a <- c(1, 1.0001)
a
class(a)

a <- c(1, "1", 1.0)
a
class(a)

# single or double quotes allowed, but be consistent
a <- c(1, '1', 1.0)
a
class(a)

# Looping and comparisons
if (1 == 1) {
  print("1 = 1")
}

if (1 == 2) {
  print("1 = 2")
} else {
  print ("1 != 2")
}

if (1 == 2) {
  print("1 = 2")
} else if (1 != 1){
  print ("1 != 1")
} else {
  print ("1 must = 1")
}
  

c <- 1
while (c <= 10) {
  print(c)
  c <- c + 1
}

for (i in 1:10) {
  print(i)
}

for (i in 1:10) {
  print(i)
  if (i == 5){
    break
  }
}

# Create other object types
l <- list(title="My List", MyCols = a, b)
l
class(l)
l <- list(MyCols = b, a)
l

m <- matrix(1:10, nrow=2)
m
class(m)
m <- matrix(1:10, ncol=2)
m
m <- matrix(1:10, ncol=2, byrow=TRUE)
m

df <- data.frame(1:10, 1:5)
df
class(df)
head(df,8)
tail(df)

names(df)
names(df) <- c("Col1", "Col2")
df
df$Col1
df[,1]
df[,-1]
df[1,]
df[-5,]
df[c(-2,-4),]
attach(df)
Col1

df$Col3 <- c(11:20)
df
Col4 <- c(30:21)

df <- cbind(df,Col4)
df <- rbind(df, c(11,21,31, 41))
df

# NA and NULL values
c <- c(1,2,NA, 4,5,NA)
c
is.na(c)
mean(c)
mean(c, na.rm = TRUE)

d <- c(1, 2, NULL, 4, 5, NULL)
d
is.null(d)
e <- NULL
is.null(e)
mean(d)

# Packages
search()
View(installed.packages())
View(available.packages())
install.packages("abc")
library(abc)
help (package= "abc")
help(getmode)
remove.packages("abc")

# Working directory
getwd()
setwd("C:/R Sessions")
setwd("C:/Users/John/Documents/GitHub/FoxPass")

# Functions
celcius <- function(f) {
  c <- (f - 32) * 5/9
  
}

howhot <- celcius(75)
howhot

rm(celcius)
source("./MyFunctions.r")

howhot <- celcius(75)
howhot
howhot <- fahrenheit(28)
howhot

