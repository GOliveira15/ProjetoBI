SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dw].[SALES_UPSERT_FACT_OrderItems] AS

BEGIN

	DECLARE @Procedure VARCHAR(255) = '[dw].[SALES_UPSERT_FACT_OrderItems]'
	DECLARE @Object VARCHAR(255) = '[dw].[Sales_FACT_OrderItems]'
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
            K.SKOrder = ISNULL(B.SKOrder, -1),
            K.SKProduct = ISNULL(C.SKProduct, -1),
            K.Quantity = A.quantity,
            K.ListPrice = A.list_price,
            K.Discount = A.discount
		FROM
			[stg].[Sales_order_items] A

			LEFT JOIN [dw].[Sales_FACT_Orders] B ON
				A.order_id = B.SKOrder

			LEFT JOIN [dw].[Prod_DIM_Products] C
				ON A.product_id = C.NKProduct

			LEFT JOIN [dw].[Sales_FACT_OrderItems] K ON
				A.order_id = K.SKOrder

		WHERE A.order_id IN (SELECT L.SKOrder FROM [dw].[Sales_FACT_OrderItems] L)
			AND K.isActive = 1
			OR (ISNULL(B.SKOrder, -1)					<> K.SKOrder
			OR ISNULL(C.SKProduct, -1)					<> K.SKProduct
			OR A.quantity								<> K.Quantity
            OR A.list_price								<> K.ListPrice
            OR A.discount							    <> K.Discount)

		--> Insere novos itens de pedido
		INSERT INTO [dw].[Sales_FACT_OrderItems]
		SELECT
			ISNULL(B.SKOrder, -1)					AS SKOrder,
			ISNULL(C.SKProduct, -1)					AS SKProduct,
			A.quantity								AS Quantity,
            A.list_price							AS ListPrice,
            A.discount							    AS Discount,
			DATEADD(HOUR,-3,GETDATE())				AS InsertDate,
			NULL 									AS UpdatedDate,
			1										AS IsActive

		FROM
			[stg].[Sales_order_items] A

			LEFT JOIN [dw].[Sales_FACT_Orders] B ON
				A.order_id = B.SKOrder

			LEFT JOIN [dw].[Prod_DIM_Products] C
				ON A.product_id = C.NKProduct

		WHERE A.order_id NOT IN (SELECT K.SKOrder FROM [dw].[Sales_FACT_OrderItems] K)

		--> Insere o Log de Execução
		SET @Endtime = DATEADD(HOUR,-3,GETDATE()) 
		SET @ExecTime = DATEDIFF(ss, @Startime,@Endtime)

		SET @Quantity  = (SELECT COUNT(*) FROM  [dw].[Sales_FACT_OrderItems] WHERE CAST(UpdatedDate AS DATE) = CAST(DATEADD(HOUR,-3,GETDATE()) AS DATE) OR CAST(InsertDate AS DATE) = CAST(DATEADD(HOUR,-3,GETDATE()) AS DATE) AND IsActive = 1)
		IF @Quantity <> 0
			EXECUTE [dw].[BIKE_InsertLogExec] 'I', @Procedure, @Object,@Description,@Quantity,@ExecTime,@Startime,@Endtime

		SET @Quantity  = (SELECT COUNT(*) FROM  [dw].[Sales_FACT_OrderItems] WHERE CAST(UpdatedDate AS DATE) = CAST(DATEADD(HOUR,-3,GETDATE()) AS DATE) AND IsActive = 0)
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