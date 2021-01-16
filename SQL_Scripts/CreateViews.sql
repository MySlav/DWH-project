USE [US_Crossings_DWH]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


  CREATE VIEW [dbo].[vw_d_Location] AS 

SELECT   [LocationID]
      ,[BorderName]
      ,[StateName]
      ,[PortCode]
      ,[PortName]
  FROM [US_Crossings_DWH].[dbo].[d_Location]
GO

CREATE VIEW [dbo].[vw_d_Date] AS 

SELECT  [DateID]
      ,[Date]
      ,[Year]
      ,[Quarter]
      ,[Month]
      ,[halfyear]
      ,[quarterdesc_hr]
      ,[quarterdesc_en]
      ,[monthdesc_hr]
      ,[monthdesc_en]
  FROM [US_Crossings_DWH].[dbo].[d_Date]
GO

CREATE VIEW [dbo].[vw_d_ModeOfTransport] AS 

SELECT [MoTID]
      ,[MoTName]
  FROM [US_Crossings_DWH].[dbo].[d_ModeOfTransport]
GO

CREATE VIEW [dbo].[vw_f_Crossings] AS 

SELECT [CrossingsID]
      ,[LocationID]
      ,[MoTID]
      ,[DateID]
      ,[Value]
  FROM [US_Crossings_DWH].[dbo].[f_Crossings]