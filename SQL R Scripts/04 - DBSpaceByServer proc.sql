USE DemoDB;
GO
 
CREATE PROCEDURE dbo.DBSpaceByServer (@ServerName VARCHAR(100)) AS
DECLARE @Plot VARBINARY(MAX)
DECLARE @FileName1	VARCHAR(100), @FileName2 VARCHAR(250)

SET @FileName1 = REPLACE(@ServerName, '\', '-') + '-' + CONVERT(CHAR(10), GETDATE(), 110) + '.jpeg'
SET @FileName2 = 'C:/SQL2016/Plots/' + @FileName1

DECLARE @RScript NVARCHAR(MAX) = N'
	library(dplyr)
	library(tidyr)
	library(ggplot2)
	library(gridExtra)
			
	db_filtered$DBUsedSpaceGB <- (db_filtered$DBUsedSpaceMB / 1024)

	db_plot1 <- db_filtered %>%
		group_by(DBLogicalFileName) %>%
		arrange(PollDate) %>%
		filter(row_number()==1 | row_number()==n()) %>% 
		select(PollDate, DBLogicalFileName, DBUsedSpaceGB) %>%
		spread(DBLogicalFileName, DBUsedSpaceGB)

    db_plot2 <- db_filtered %>% group_by(DBName) 
    
	image_file <- file
	jpeg(filename = image_file, width = 1000, height = 1000)
	
	plot1 <- ggplot(data = db_plot2 %>% filter(DBName == "mis_db"), aes(x = PollDate, y = DBUsedSpaceGB, group = DBLogicalFileName )) + 
				geom_line(aes(color = DBLogicalFileName)) +
				ggtitle("Space Used mis_db")
	plot2 <- ggplot(data = db_plot2 %>% filter(DBName == "dialysis_db"), aes(x = PollDate, y = DBUsedSpaceGB, group = DBLogicalFileName )) + 
				geom_line(aes(color = DBLogicalFileName)) +
				ggtitle("Space Used dialysis_db") 
	plot3 <- ggplot(data = db_plot2 %>% filter(DBName == "darwin_db"), aes(x = PollDate, y = DBUsedSpaceGB, group = DBLogicalFileName )) + 
				geom_line(aes(color = DBLogicalFileName)) +
				ggtitle("Space Used darwin_db") 

	plotList <- list(plot1, plot2, plot3)
	do.call(grid.arrange, plotList)

	dev.off()

	plotbin <- readBin(file(image_file, "rb"), what=raw(), n=1e6)
	db_sizes <- db_plot1	
'

DECLARE @SQLScript NVARCHAR(MAX) = N'
	SELECT RTRIM(ServerName) AS ServerName, PollDate, DBName, DBLogicalFileName, DBFileSizeMB, 
           DBFileSizeMB - DBFreeSpaceMB AS DBUsedSpaceMB, DBFreeSpaceMB
    FROM DBInfo
    WHERE Servername = ''' + @ServerName + '''
    AND DBName IN (''mis_db'', ''darwin_db'', ''dialysis_db'')
    AND PollDate >= DATEADD(year, -1, GETDATE())'

EXEC sp_execute_external_script
	@language = N'R',
	@script = @RScript,
  	@input_data_1 = @SQLScript,
	@input_data_1_name = N'db_filtered',
	@output_data_1_name = N'db_sizes',
	@params = N'@file varchar(250), @plotbin varbinary(max) OUTPUT',
	@file = @FileName2, @plotbin = @plot OUTPUT
WITH RESULT SETS ((PollDate DATETIME, darwin_db NUMERIC(5, 2), darwin_db_log NUMERIC(5, 2), dialysis_db_data NUMERIC(5, 2), dialysis_db_indexes NUMERIC(5, 2),
				   dialysis_db_log NUMERIC(5, 2), indexfile NUMERIC(5, 2), misdb_data NUMERIC(5, 2), misdb_log NUMERIC(5, 2)))


				  
IF EXISTS(SELECT * FROM dbo.Documents WHERE name = @FileName1)
	DELETE dbo.Documents WHERE name = @FileName1
					   
INSERT INTO dbo.documents(name, file_stream)
SELECT @FileName1, @plot;
				   
GO


