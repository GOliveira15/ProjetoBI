SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dw].[SALES_UPSERT_FACT_Orders] AS

BEGIN

	DECLARE @Procedure VARCHAR(255) = '[dw].[SALES_UPSERT_FACT_Orders]'
	DECLARE @Object VARCHAR(255) = '[dw].[Sales_FACT_Orders]'
	DECLARE @Description VARCHAR(255) = 'Procedure que insere os pedidos.'
	DECLARE @Quantity VARCHAR(255)
	DECLARE @Type VARCHAR(10)
	DECLARE @ExecTime VARCHAR(240)
	DECLARE @Startime DATETIME = DATEADD(HOUR,-3,GETDATE()) 
	DECLARE @Endtime DATETIME 
	DECLARE @Error VARCHAR(510)
	
	BEGIN TRY

		--> Atualiza quando o pedido é alterado
		UPDATE K
		SET 
            K.SKCustomer = B.SKCustomer,
            K.OrderStatus = A.order_status,
            K.OrderDate = A.order_date,
            K.RequiredDate = A.required_date,
            K.ShippedDate =  A.shipped_date,
            K.SKStore = C.SKStore,
            K.SKStaff = D.SKStaff
		FROM
			[stg].[Sales_Orders] A

			LEFT JOIN [dw].[Sales_DIM_Customers] B ON
				A.customer_id = B.NKCustomer

			LEFT JOIN [dw].[Sales_DIM_Stores] C
				ON A.store_id = C.NKStore

			LEFT JOIN [dw].[Sales_DIM_Staffs] D
				ON A.staff_id = D.NKStaff

			LEFT JOIN [dw].[Sales_FACT_Orders] K ON
				A.order_id = K.NKOrder

		WHERE A.order_id IN (SELECT L.NKOrder FROM [dw].[Sales_FACT_Orders] L)
			AND K.IsActive = 1
			OR (ISNULL(B.SKCustomer, -1)				<> K.SKCustomer
			OR A.order_status						    <> K.OrderStatus
			OR A.order_date 							<> K.OrderDate
			OR A.required_date							<> K.RequiredDate
			OR A.shipped_date						    <> K.ShippedDate
            OR ISNULL(C.SKStore, -1)				    <> K.SKStore
			OR ISNULL(D.SKStaff, -1)					<> K.SKStaff)

		--> Insere um novo pedido
		INSERT INTO [dw].[Sales_FACT_Orders]
		SELECT
			A.order_id								AS NKOrder,
            ISNULL(B.SKCustomer, -1)                AS SKCustomer,
            A.order_status                          AS OrderStatus,
            A.order_date                            AS OrderDate,
            A.required_date                         AS RequiredDate,
            A.shipped_date                          AS ShippedDate,
            ISNULL(C.SKStore, -1)                   AS SKStore,
            ISNULL(D.SKStaff, -1)                   AS SKStaff,
			DATEADD(HOUR,-3,GETDATE())				AS InsertDate,
			NULL 									AS UpdatedDate,
			1										AS IsActive

		FROM
			[stg].[Sales_orders] A

			LEFT JOIN [dw].[Sales_DIM_Customers] B ON
				A.customer_id = B.NKCustomer

			LEFT JOIN [dw].[Sales_DIM_Stores] C
				ON A.store_id = C.NKStore

			LEFT JOIN [dw].[Sales_DIM_Staffs] D
				ON A.staff_id = D.NKStaff

		WHERE A.order_id NOT IN (SELECT K.NKOrder FROM [dw].[Sales_FACT_Orders] K)

		--> Insere o Log de Execução
		SET @Endtime = DATEADD(HOUR,-3,GETDATE()) 
		SET @ExecTime = DATEDIFF(ss, @Startime,@Endtime)

		SET @Quantity  = (SELECT COUNT(*) FROM  [dw].[Sales_FACT_Orders] WHERE CAST(UpdatedDate AS DATE) = CAST(DATEADD(HOUR,-3,GETDATE()) AS DATE) OR CAST(InsertDate AS DATE) = CAST(DATEADD(HOUR,-3,GETDATE()) AS DATE) AND IsActive = 1)
		IF @Quantity <> 0
			EXECUTE [dw].[BIKE_InsertLogExec] 'I', @Procedure, @Object,@Description,@Quantity,@ExecTime,@Startime,@Endtime

		SET @Quantity  = (SELECT COUNT(*) FROM  [dw].[Sales_FACT_Orders] WHERE CAST(UpdatedDate AS DATE) = CAST(DATEADD(HOUR,-3,GETDATE()) AS DATE) AND IsActive = 0)
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