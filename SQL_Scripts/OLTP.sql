/****** #State******/



CREATE TABLE [dbo].[State] (
    [ID][int] NOT NULL IDENTITY(1,1),
    [StateName][nvarchar](50),
    PRIMARY KEY (ID)
)

INSERT INTO dbo.State (StateName) SELECT DISTINCT State FROM US_Crossings_CSV.dbo.Crossings

/****** #Border******/


CREATE TABLE [dbo].[Border] (
    [ID][int] NOT NULL IDENTITY(1,1),
    [BorderName][nvarchar](50),
    PRIMARY KEY (ID)
)


INSERT INTO dbo.Border (BorderName) SELECT DISTINCT Border FROM US_Crossings_CSV.dbo.Crossings

/****** #Port******/


 CREATE TABLE [dbo].[Port] (
    [ID][int] NOT NULL IDENTITY(1,1),
    [StateID] [int] NOT NULL,
    [BorderID] [int] NOT NULL,
    [PortCode] [int],
    [PortName] [nvarchar](50),
    PRIMARY KEY (ID),
    FOREIGN KEY (StateID) REFERENCES [dbo].[State](ID),
    FOREIGN KEY (BorderID) REFERENCES [dbo].[Border](ID)
)


INSERT INTO  dbo.Port (StateID,BorderID,PortCode,PortName)
SELECT DISTINCT s.ID, b.ID, x.Port_Code, x.Port_Name
FROM US_Crossings_CSV.dbo.Crossings x
INNER JOIN dbo.Border b ON b.BorderName=x.Border
INNER JOIN dbo.State s ON s.StateName=x.State 


/****** #ModeOfTransport******/

CREATE TABLE [dbo].[ModeOfTransport] (
    [ID][int] NOT NULL IDENTITY(1,1),
    [MoTName][nvarchar](50),
    PRIMARY KEY (ID)
)

INSERT INTO dbo.ModeOfTransport (MoTName) SELECT DISTINCT Measure FROM US_Crossings_CSV.dbo.Crossings


/****** #Crossings******/

 CREATE TABLE [dbo].[Crossings] (
    [ID][int] NOT NULL IDENTITY(1,1),
    [PortID] [int] NOT NULL,
    [MoTID] [int] NOT NULL,
    [Date] [datetime],
    [Value] [bigint],
    PRIMARY KEY (ID),
    FOREIGN KEY (PortID) REFERENCES [dbo].[Port](ID),
    FOREIGN KEY (MoTID) REFERENCES [dbo].[ModeOfTransport](ID)
)

INSERT INTO  dbo.Crossings (PortID,MoTID,Date,Value)
SELECT  p.ID, m.ID, x.Date, x.Value
FROM US_Crossings_CSV.dbo.Crossings x
INNER JOIN dbo.Port p ON p.PortCode=x.Port_Code
INNER JOIN dbo.ModeOfTransport m ON m.MoTName=x.Measure
