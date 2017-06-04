USE DemoDB;
GO

CREATE PROCEDURE dbo.GetDBSpaceByServer_Plot (@ServerName VARCHAR(100)) AS

DECLARE @FileName1	VARCHAR(100)

SET @FileName1 = REPLACE(@ServerName, '\', '-') + '-' + CONVERT(CHAR(10), GETDATE(), 110) + '.jpeg'

SELECT name, file_stream
FROM dbo.Documents
WHERE name = @FileName1
				   
GO


