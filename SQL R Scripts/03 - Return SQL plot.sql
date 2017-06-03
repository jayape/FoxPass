USE DemoDB;
GO

DECLARE @ServerName VARCHAR(100) = 'DCICHISQL1\MISDB'

DECLARE @RScript NVARCHAR(MAX) = N'
	library(dplyr)
	library(tidyr)
	library(ggplot2)
	library(reshape2)

	image_file <- tempfile()
	jpeg(filename = image_file, width = 1000, height = 1000)

	drive1$DriveUsedSpace <- drive1$DriveTotalSpaceMB - drive1$DriveFreeSpaceMB
	
    drive_melted <- melt(drive1[,c(1,3,4)])
	drive_melted$value <- drive_melted$value / 1024

	names(drive_melted) <- c("Drive", "Variable", "SizeInGB")

	#dm <- ddply(drive_melted, .(Drive), transform, pos = cumsum(SizeInGB))
	
	ds_plot <- ggplot(data = drive_melted, aes(x = Drive, y = SizeInGB, fill = Variable)) +
					geom_bar(stat = ''identity'') +
					geom_text(aes(label = format(round(SizeInGB, 2), nsmall = 2)), color=''black'', size = 5)

	print(ds_plot)
	dev.off()

	drive_plot <-as.data.frame(readBin(file(image_file, "rb"), what=raw(), n=1e6))	
'
DECLARE @SQLScript NVARCHAR(MAX) = N'
	SELECT Drive, DriveTotalSpaceMB, DriveFreeSpaceMB
    FROM DSInfo
	WHERE ServerName = ''' + @ServerName + ''' AND PollDate = (SELECT MAX(PollDate) FROM DSInfo)
'

EXECUTE sp_execute_external_script
	@language=N'R',
	@script = @RScript,
	@input_data_1 = @SQLScript,
	@input_data_1_name = N'drive1',
	@output_data_1_name = N'drive_plot'
WITH RESULT SETS ((Plot VARBINARY(MAX)));




