USE DemoDB;
GO
 
DECLARE @ServerName VARCHAR(100) = 'DCICHISQL1\MISDB'

DECLARE @RScript NVARCHAR(MAX) = N'
	library(dplyr)
	library(tidyr)

	db_filtered$DBUsedSpaceGB <- (db_filtered$DBUsedSpaceMB / 1024)

	db_sizes <- db_filtered %>%
		group_by(DBLogicalFileName) %>%
		arrange(PollDate) %>%
		filter(row_number()==1 | row_number()==n()) %>% 
		select(PollDate, DBLogicalFileName, DBUsedSpaceGB) %>%
		spread(DBLogicalFileName, DBUsedSpaceGB)
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
	@output_data_1_name = N'db_sizes'
WITH RESULT SETS ((PollDate DATETIME, darwin_db NUMERIC(5, 2), darwin_db_log NUMERIC(5, 2), 
				   dialysis_db_data NUMERIC(5, 2), dialysis_db_indexes NUMERIC(5, 2),
				   dialysis_db_log NUMERIC(5, 2), indexfile NUMERIC(5, 2), 
				   misdb_data NUMERIC(5, 2), misdb_log NUMERIC(5, 2)));