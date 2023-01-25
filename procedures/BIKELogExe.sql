SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dw].[BIKE_InsertLogExec] @ParamType [VARCHAR](1),@ParamProcedure [VARCHAR](255), @ParamObject [VARCHAR](255),@ParamDescription [VARCHAR](255),@ParamQuantity [int],@ParamExecTime [VARCHAR](40),@Inicio [DATETIME],@Final [DATETIME] AS

BEGIN

     INSERT INTO dw.BIKE_LogExec
		(
			[Type],
			[Procedure],
			[Object], 
			[Description], 
			[Quantity], 
			[ExecTime], 
			[Startime], 
			[Endtime]
		) 

	 VALUES
		(
			@ParamType, 
			@ParamProcedure,
			@ParamObject, 
			@ParamDescription, 
			@ParamQuantity, 
			@ParamExecTime, 
			@Inicio,
			@Final
		)

END

GO