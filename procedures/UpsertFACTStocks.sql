SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dw].[PROD_UPSERT_FACT_Stocks] AS

BEGIN

	DECLARE @Procedure VARCHAR(255) = '[dw].[PROD_UPSERT_FACT_Stocks]'
	DECLARE @Object VARCHAR(255) = '[dw].[Prod_FACT_Stocks]'
	DECLARE @Description VARCHAR(255) = 'Procedure que insere o estoque.'
	DECLARE @Quantity VARCHAR(255)
	DECLARE @Type VARCHAR(10)
	DECLARE @ExecTime VARCHAR(240)
	DECLARE @Startime DATETIME = DATEADD(HOUR,-3,GETDATE()) 
	DECLARE @Endtime DATETIME 
	DECLARE @Error VARCHAR(510)
	
	BEGIN TRY

		--> Atualiza quando o estoque é alterado
		UPDATE K
		SET 
            K.SKStore = ISNULL(B.SKStore, -1),
            K.SKProduct = ISNULL(C.SKProduct, -1),
            K.Quantity = A.quantity
		FROM
			[stg].[Prod_stocks] A

			LEFT JOIN [dw].[Sales_DIM_Stores] B ON
				A.store_id = B.NKStore

			LEFT JOIN [dw].[Prod_DIM_Products] C
				ON A.product_id = C.NKProduct

			LEFT JOIN [dw].[Prod_FACT_Stocks] K ON
				A.product_id = K.SKProduct

		WHERE A.product_id IN (SELECT L.SKProduct FROM [dw].[Prod_FACT_Stocks] L)
			AND K.isActive = 1
			OR (ISNULL(B.SKStore, -1)					<> K.SKStore
			OR ISNULL(C.SKProduct, -1)					<> K.SKProduct
			OR A.quantity								<> K.Quantity)

		--> Insere um novo estoque
		INSERT INTO [dw].[Prod_FACT_Stocks]
		SELECT
			ISNULL(B.SKStore, -1)					AS SKStore,
			ISNULL(C.SKProduct, -1)					AS SKProduct,
			A.quantity								AS Quantity,
			DATEADD(HOUR,-3,GETDATE())				AS InsertDate,
			NULL 									AS UpdatedDate,
			1										AS IsActive

		FROM
			[stg].[Prod_stocks] A

			LEFT JOIN [dw].[Sales_DIM_Stores] B ON
				A.store_id = B.NKStore

			LEFT JOIN [dw].[Prod_DIM_Products] C
				ON A.product_id = C.NKProduct

		WHERE A.product_id NOT IN (SELECT K.SKProduct FROM [dw].[Prod_FACT_Stocks] K)

		--> Insere o Log de Execução
		SET @Endtime = DATEADD(HOUR,-3,GETDATE()) 
		SET @ExecTime = DATEDIFF(ss, @Startime,@Endtime)

		SET @Quantity  = (SELECT COUNT(*) FROM  [dw].[Prod_FACT_Stocks] WHERE CAST(UpdatedDate AS DATE) = CAST(DATEADD(HOUR,-3,GETDATE()) AS DATE) OR CAST(InsertDate AS DATE) = CAST(DATEADD(HOUR,-3,GETDATE()) AS DATE) AND IsActive = 1)
		IF @Quantity <> 0
			EXECUTE [dw].[BIKE_InsertLogExec] 'I', @Procedure, @Object,@Description,@Quantity,@ExecTime,@Startime,@Endtime

		SET @Quantity  = (SELECT COUNT(*) FROM  [dw].[Prod_FACT_Stocks] WHERE CAST(UpdatedDate AS DATE) = CAST(DATEADD(HOUR,-3,GETDATE()) AS DATE) AND IsActive = 0)
		IF @Quantity <> 0
			EXECUTE [dw].[BIKE_InsertLogExec] 'U', @Procedure, @Object,@Description,@Quantity,@ExecTime,@Startime,@Endtime
	END TRY

	BEGIN CATCH  
		--> Se der erro, insere o log de erro
		SET @Error = ERROR_MESSAGE();			
		SET @Endtime = DATEADD(HOUR,-3,GETDATE()) 
		EXECUTE [dw].[BIKE_InsertLogExec] 'E', @Procedure, @Object,@Error,NULL,@ExecTime,@Startime,@Endtime
	END CATCH
END
GO