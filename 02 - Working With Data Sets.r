
# Data sets
library(help = datasets)
mydata <- iris
head(mydata)

# Read data from file
myCSV <- read.csv("./Data/Chicago2016.csv", header = TRUE)
head(myCSV)

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
library(ggplot2)
library(ggmap)

myConn <- odbcDriverConnect("driver={SQL Server};
                            server=(local);
                            database=DemoDB;
                            Trusted_Connection=yes")


userData <- sqlFetch(myConn, "Locations")
close(myConn)

map <- get_map("United State", scale = 2, zoom = 4)

ggmap(map) +
  geom_point(aes(x = lon, y = lat), data = userData, alpha = .5)


url <- "http://www.hockey-reference.com/teams/CHI/2017_games.html"

tables <- readHTMLTable(url, stringsAsFactors = FALSE)
temp <- tables$games
names(temp) <- c("GP", "Date", "Time", "Loc", "Opponent", "GF", "GA", "Result", "OT", "W", "L", "OL", "Streak", "Blank1", 
                 "tS", "tPIM", "tPPG", "tPPO", "tSHG", "Blank2", "oS","oPIM", "oPPG", "oPPO", "oSHG", "Att", "LOG", "Notes")
temp <- subset(temp, temp$GP  != "GP" & temp$Date != "Cumulative" & temp$Date != "Team" & temp$Result != "")
temp <- temp[, c(1, 2, 4:9, 15:19, 21:27)]

temp$GP <- as.integer(temp$GP)
temp$Date <- as.Date(temp$Date)
temp$Loc <- as.character(temp$Loc)
temp$Loc[temp$Loc == "@"] <- "A"
temp$Loc[temp$Loc == ""] <- "H"
temp$Loc <- as.factor(temp$Loc)
temp$GF <- as.integer(temp$GF)
temp$GA <- as.integer(temp$GA)
temp$Result <- as.factor(temp$Result)
temp$OT[temp$OT == ""] <- "REG"
temp$OT <- as.factor(temp$OT)
temp$tS <- as.integer(temp$tS)
temp$tPIM <- as.integer(temp$tPIM)
temp$tPPG <- as.integer(temp$tPPG)
temp$tPPO <- as.integer(temp$tPPO)
temp$tSHG <- as.integer(temp$tSHG)
temp$oS <- as.integer(temp$oS)
temp$oPIM <- as.integer(temp$oPIM)
temp$oPPG <- as.integer(temp$oPPG)
temp$oPPO <- as.integer(temp$oPPO)
temp$oSHG <- as.integer(temp$oSHG)
temp$Att <- gsub("[[:punct:]]","", temp[, 19])
temp$Att <- as.integer(temp$Att)
temp$diff <- temp$GF - temp$GA

chi2017 <- temp
head(chi2017)

mean(chi2017$GF)
min(chi2017$GF)
max(chi2017$GF)
median(chi2017$GF)
summary(chi2017$GF)
summary(chi2017)
table(chi2017$GF)
aggregate(GF ~ Result, chi2017, mean)
aggregate(cbind(GF, GA, tS, oS, tPIM, oPIM, tPPG, oPPG) ~ Result + Loc, chi2017, mean)
aggregate(cbind(GF, GA, tS, oS, tPIM, oPIM, tPPG, oPPG) ~ Opponent, chi2017, mean)
var(chi2017$GF)
sd(chi2017$GF)
cor(chi2017$tS, chi2017$GF)
lm(tS ~ GF, chi2017)

ggplot(chi2017, aes(x = tS, y = GF)) +
  geom_point() +
  geom_smooth(method = "lm") + labs(x = "Shots Taken", y = "Goals For")

par(mfrow=c(2,2))
hist(chi2017$GF[chi2017$Loc == "H"], freq=F, col = "lightblue", main = "Home Goals Scored", xlab = "Number of Goals")
curve(dnorm(x, mean(chi2017$GF[chi2017$Loc == "H"]), sd(chi2017$GF[chi2017$Loc == "H"])), add=T)
hist(chi2017$GA[chi2017$Loc == "H"], freq=F, col = "orangered", main = "Home Goals Allowed", xlab = "Number of Goals")
curve(dnorm(x, mean(chi2017$GA[chi2017$Loc == "H"]), sd(chi2017$GA[chi2017$Loc == "H"])), add=T)
hist(chi2017$GF[chi2017$Loc == "A"], freq=F, col = "lightblue", main = "Away Goals Scored", xlab = "Number of Goals")
curve(dnorm(x, mean(chi2017$GF[chi2017$Loc == "A"]), sd(chi2017$GF[chi2017$Loc == "A"])), add=T)
hist(chi2017$GA[chi2017$Loc == "A"], freq=F, col = "orangered", main = "Away Goals Allowed", xlab = "Number of Goals")
curve(dnorm(x, mean(chi2017$GA[chi2017$Loc == "A"]), sd(chi2017$GA[chi2017$Loc == "A"])), add=T)

myConn <- odbcDriverConnect("driver={SQL Server};
                            server=(local);
                            database=DemoDB;
                            Trusted_Connection=yes")

sqlSave(myConn, dat = chi2017, tablename = 'Chicago_2017', safer = FALSE, rownames = FALSE, verbose = TRUE)
close(myConn)
