
# Data sets
library(help = datasets)
mydata <- iris
head(mydata)

# Read data
myCSV <- read.csv("./Data/CHI2017.csv", header = TRUE)

myCSV

# Read data from a web page
library(XML)

url <- "http://www.hockey-reference.com/leagues/NHL_2017_standings.html"

tables <- readHTMLTable(url, stringsAsFactors = FALSE)
standings <- tables$standings
View(standings)
mystandings1 <- standings[1:5]
View(mystandings1)

write.csv(mystandings1, "./Data/NHL2017.csv", row.names = FALSE)

# Connect to a SQL database
library(RODBC)
library(ggmap)

myConn <- odbcDriverConnect("driver={SQL Server};
                            server=PERTELL03;
                            database=DemoDB;
                            uid=Demoman;
                            pwd=12345678")


userData <- sqlFetch(myConn, "Locations")
close(myConn)

map <- get_map("United State", scale = 2, zoom = 4)

ggmap(map) +
  geom_point(aes(x = lon, y = lat), data = userData, alpha = .5)
