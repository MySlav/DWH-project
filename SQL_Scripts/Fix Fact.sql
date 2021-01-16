USE US_Crossings_DWH
GO

DROP TABLE [dbo].[f_Crossings]

CREATE TABLE [dbo].[f_Crossings](
	[CrossingsID] [int] IDENTITY (1,1) NOT NULL,
	[LocationID] [int] NOT NULL,
	[MoTID] [int] NOT NULL,
	[DateID] [int] NOT NULL,
	[Value] [bigint] NULL,
 CONSTRAINT [PK_f_Crossings] PRIMARY KEY CLUSTERED 
(
	[CrossingsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


ALTER TABLE [dbo].[f_Crossings]  WITH CHECK ADD  CONSTRAINT [FK_f_Crossings_d_Location] FOREIGN KEY([LocationID])
REFERENCES [dbo].[d_Location] ([LocationID])
GO
ALTER TABLE [dbo].[f_Crossings] CHECK CONSTRAINT [FK_f_Crossings_d_Location]
GO
ALTER TABLE [dbo].[f_Crossings]  WITH CHECK ADD  CONSTRAINT [FK_f_Crossings_d_ModeOfTransport] FOREIGN KEY([MoTID])
REFERENCES [dbo].[d_ModeOfTransport] ([MoTID])
GO
ALTER TABLE [dbo].[f_Crossings] CHECK CONSTRAINT [FK_f_Crossings_d_ModeOfTransport]
GO
ALTER TABLE [dbo].[f_Crossings]  WITH CHECK ADD  CONSTRAINT [FK_f_Crossings_d_Date] FOREIGN KEY([DateID])
REFERENCES [dbo].[d_Date] ([DateID])
GO
ALTER TABLE [dbo].[f_Crossings] CHECK CONSTRAINT [FK_f_Crossings_d_Date]
