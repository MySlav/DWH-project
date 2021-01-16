USE [master]
GO


CREATE DATABASE [US_Crossings_DWH]
 CONTAINMENT = NONE
GO
ALTER DATABASE [US_Crossings_DWH] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [US_Crossings_DWH].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [US_Crossings_DWH] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [US_Crossings_DWH] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [US_Crossings_DWH] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [US_Crossings_DWH] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [US_Crossings_DWH] SET ARITHABORT OFF 
GO
ALTER DATABASE [US_Crossings_DWH] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [US_Crossings_DWH] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [US_Crossings_DWH] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [US_Crossings_DWH] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [US_Crossings_DWH] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [US_Crossings_DWH] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [US_Crossings_DWH] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [US_Crossings_DWH] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [US_Crossings_DWH] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [US_Crossings_DWH] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [US_Crossings_DWH] SET  DISABLE_BROKER 
GO
ALTER DATABASE [US_Crossings_DWH] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [US_Crossings_DWH] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [US_Crossings_DWH] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [US_Crossings_DWH] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [US_Crossings_DWH] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [US_Crossings_DWH] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [US_Crossings_DWH] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [US_Crossings_DWH] SET RECOVERY FULL 
GO
ALTER DATABASE [US_Crossings_DWH] SET  MULTI_USER 
GO
ALTER DATABASE [US_Crossings_DWH] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [US_Crossings_DWH] SET DB_CHAINING OFF 
GO
ALTER DATABASE [US_Crossings_DWH] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [US_Crossings_DWH] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'US_Crossings_DWH', N'ON'
GO
USE [US_Crossings_DWH]
GO
/******StoredProcedure [dbo].[sp_fill_d_Date]******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[sp_fill_d_Date]
	@myYear as int
,	@dwh_db_name as nvarchar(100)
as

declare @myDateLoop as datetime
declare @myLoopTo as datetime
declare @sql nvarchar(max), @param_def nvarchar(500)

set @myDateLoop = cast( '01/01/' + cast(@myYear as char(4)) as datetime)
set @myLoopTo = dateAdd(yy, 1, @myDateLoop)
set @param_def = N'@myDate datetime'

SET DATEFIRST 1

-- ako ne postoji unknown date dodaj i njega
set @sql = 
N'if not exists (select DateID from ' + @dwh_db_name + N'.dbo.d_Date where DateID = -99)
begin
	insert into ' + @dwh_db_name + N'.dbo.d_Date
	([DateID], [Date]
       ,[Year],[Quarter],[Month],[halfyear]
       ,[quarterdesc_hr],[quarterdesc_en],[monthdesc_hr],[monthdesc_en])
	values (-99, ''19000101'', 0, 0, 0, 0,''NA'',''NA'',''NA'',''NA'')
end'

exec sp_executesql @sql

while @myDateLoop < @myLoopTo
begin
	set @sql = 
	N'insert into ' + @dwh_db_name + N'.dbo.d_Date
		([DateID], [Date]
       ,[Year],[Quarter],[Month],[halfyear]
       ,[quarterdesc_hr],[quarterdesc_en],[monthdesc_hr],[monthdesc_en])
	select year(@myDate) * 10000 + month(@mydate) * 100 + day(@mydate), @myDate
			, year (@myDate) -- year
			, datepart(qq, @myDate) -- quarter
			, month(@myDate)
			, case when month(@myDate) < 7 then 1 else 2 end
			, ''Kvartal '' + cast(datepart(qq, @myDate) as nvarchar(1))
			, ''Quarter '' + cast(datepart(qq, @myDate) as nvarchar(1))
			, case month(@myDate)   --monthdesc_hr
				when 1 then ''Siječanj''
				when 2 then ''Veljača''
				when 3 then ''Ožujak''
				when 4 then ''Travanj''
				when 5 then ''Svibanj''
				when 6 then ''Lipanj''
				when 7 then ''Srpanj''
				when 8 then ''Kolovoz''
				when 9 then ''Rujan''
				when 10 then ''Listopad''
				when 11 then ''Studeni''
				when 12 then ''Prosinac''
			end
			, case month(@myDate)  --month_desc_en
				when 1 then ''January''
				when 2 then ''February''
				when 3 then ''March''
				when 4 then ''April''
				when 5 then ''May''
				when 6 then ''June''
				when 7 then ''July''
				when 8 then ''August''
				when 9 then ''September''
				when 10 then ''October''
				when 11 then ''November''
				when 12 then ''December''
			end'

	exec sp_executesql @sql, @param_def, @myDate = @myDateLoop

	SET @myDateLoop = dateAdd(dd, 1, @myDateLoop)

end



GO
/****** Object:  StoredProcedure [dbo].[sp_insert_unknown_member]******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_insert_unknown_member]
as
-- DESCRIPTION:
-- skripta dodaje unknown membere u sve tablice koje poèinje s 'd_%' prema tipu podatke kolone. Skripta ignorira vremensku dimenziju
-- defaulti za tipove su:
--		datetime:		'19000101'
--		int:			-99
--		bit:			0
--		decimal:		0
--		numeric:		0
--		varchar(1):		''
--		varchar(<=20):	'NA'
--		varchar(>20):	'Nepoznato'

-- TODO:
-- ignoriraj tablice koje veæ imaju nepoznatog membera
-- napraviti skriptu u više prolaza
-- 1. tablice koje nisu referencirane od niti jedne druge d_tablice
-- 2. tablice koje su referencirane od neke druge d_tablice i veæ su ažurirane
-- 3. ponavljaj 2 sve dok broj updejtanih tablica nije jednak broj d_tablica


declare @dim_prefix varchar(10), @unknown_id int
set @dim_prefix = 'd_'
set @unknown_id = -99

declare @tc varchar(100), @ts varchar(100), @tn varchar(100)
declare @cn varchar(100), @dt varchar(100), @cml varchar(100)
declare @sql_ins nvarchar(4000), @values nvarchar(4000)

declare cTables cursor
for
select table_catalog, table_schema, table_name
from INFORMATION_SCHEMA.TABLES
where table_type = 'BASE TABLE'
-- and table_name like 'd_product' --@dim_prefix + '%'
and table_schema = 'dbo'
and table_name != 'd_Date' -- ne radi ništa s datumima jer je to specifièno!
and table_name like 'd\_%' escape '\'
and table_name in ('d_Location', 'd_ModeOfTransport')

open ctables

fetch next from ctables into @tc, @ts, @tn

while @@fetch_status = 0 
begin
	set @sql_ins = 'set identity_insert ' + @tc + '.' + @ts + '.' + @tn + ' on ' + char(10) + char(13)
	set @sql_ins = @sql_ins + 'insert into ' + @tc + '.' + @ts + '.' + @tn + '('
	
	set @values = char(10) + 'values ('
	
	declare cColumns cursor
	for
	select column_name, data_type, character_maximum_length from INFORMATION_SCHEMA.COLUMNS
	where table_name = @tn
	order by ordinal_position
	
	open cColumns
	fetch next from ccolumns into @cn, @dt, @cml
	
	while @@fetch_status = 0
	begin
		
		set @sql_ins = @sql_ins + '[' + @cn + '], '
		
		set @values = @values + case when @dt = 'int' then '-99'
			when @dt = 'datetime' then '''19000101'''
			when @dt like '%varchar' and cast(@cml as int) = 1 then ''''''
			when @dt like '%varchar' and cast(@cml as int) <= 20 then '''NA'''
			when @dt like '%varchar' and cast(@cml as int) > 20 then '''Nepoznato'''
			when @dt like 'bit' then '0'
			when @dt like 'decimal' or @dt like 'numeric' then '0'
			else 'BUG'
			end 
		set @values = @values + ', '
		
		fetch next from ccolumns into @cn, @dt, @cml
	end
	close ccolumns
	deallocate ccolumns
	
	
	-- makni zadnji zarez
	set @sql_ins = left(@sql_ins, len(@sql_ins) - 1) + ')'
	set @values = left(@values, len(@values) - 1) + ')'
	
	set @sql_ins = @sql_ins + @values + char(10) + char(13) + 'set identity_insert ' + @tc + '.' + @ts + '.' + @tn + ' off ' + char(10) + char(13)
	
	print @sql_ins
	
	--begin try
		exec sp_executesql @sql_ins
	--end try
	--begin catch
	--	print @@error
	--	print 'Fali: ' + @tn
	--end catch
	
	fetch next from ctables into @tc, @ts, @tn

end

close ctables
deallocate ctables


GO
/****** Object:  Table [dbo].[d_Location]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[d_Location](
	[LocationID] [int] IDENTITY(1,1) NOT NULL,
	[BorderName] [nvarchar](50) NULL,
	[StateName] [nvarchar](50) NULL,
	[PortCode] [int] NOT NULL,
	[PortName] [nvarchar](50) NULL,
 CONSTRAINT [PK_d_Location] PRIMARY KEY CLUSTERED 
(
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[d_Date]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[d_Date](
	[DateID] [int] NOT NULL,
	[Date] [datetime] NOT NULL,
	[Year] [int] NOT NULL,
	[Quarter] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[halfyear] [int] NOT NULL,
	[quarterdesc_hr] [nvarchar](50),
	[quarterdesc_en] [nvarchar](50),
	[monthdesc_hr] [nvarchar](50),
	[monthdesc_en] [nvarchar](50)
 CONSTRAINT [PK_d_Date] PRIMARY KEY CLUSTERED 
(
	[DateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[d_ModeOfTransport]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[d_ModeOfTransport](
	[MoTID] [int] IDENTITY(1,1) NOT NULL,
	[MoTName] [nvarchar](50) NULL,
 CONSTRAINT [PK_d_ModeOfTransport] PRIMARY KEY CLUSTERED 
(
	[MoTID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[f_Crossings]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[f_Crossings](
	[CrossingsID] [int] NOT NULL,
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
ALTER TABLE [dbo].[f_Crossings]  WITH CHECK ADD  CONSTRAINT [FK_f_Crossings_d_Date] FOREIGN KEY([DateID])
REFERENCES [dbo].[d_Date] ([DateID])
GO
ALTER TABLE [dbo].[f_Crossings] CHECK CONSTRAINT [FK_f_Crossings_d_Date]
GO
ALTER TABLE [dbo].[f_Crossings]  WITH CHECK ADD  CONSTRAINT [FK_f_Crossings_d_ModeOfTransport] FOREIGN KEY([MoTID])
REFERENCES [dbo].[d_ModeOfTransport] ([MoTID])
GO
ALTER TABLE [dbo].[f_Crossings] CHECK CONSTRAINT [FK_f_Crossings_d_ModeOfTransport]
GO
USE [master]
GO
ALTER DATABASE [US_Crossings_DWH] SET  READ_WRITE 
GO
