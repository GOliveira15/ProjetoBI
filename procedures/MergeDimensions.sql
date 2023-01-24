SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dw].[BIKE_MERGE_DIMENSIONS] AS

BEGIN
    --> Parâmetros para inserir na tabela dw.BIKE_LogExecucao
    DECLARE @SummaryOfChanges TABLE(Change VARCHAR(20));
    DECLARE @Procedure VARCHAR(255) = '[dw].[BIKE_MERGE_DIMENSIONS]'
    DECLARE @Object VARCHAR(255)
    DECLARE @Description VARCHAR(255)
    DECLARE @Quantity VARCHAR(255)
    DECLARE @Type VARCHAR(10)
    DECLARE @ExecTime VARCHAR(240)
    DECLARE @Startime DATETIME
    DECLARE @Endtime DATETIME
    DECLARE @Error VARCHAR(510)

    --> Sales <--

    --> Customers
    BEGIN TRY

        SET @Object = 'Customers'
        SET @Description = 'Customers dimension merge'
        SET @Startime = DATEADD(HOUR,-3,GETDATE())
            
        MERGE
            [dw].[Sales_DIM_Customers] AS Destino
        USING 
            [stg].[Sales_Customers] AS Origem
        ON 
            Destino.NKCustomer = Origem.customer_id

        WHEN MATCHED THEN 
            UPDATE SET
                Destino.FirstName			        = Origem.FirstName,
                Destino.LastName			        = Origem.LastName,
                Destino.Phone			            = Origem.Phone,
                Destino.Email   			        = Origem.Email,
                Destino.Street   			        = Origem.Street,
                Destino.City   			            = Origem.City,
                Destino.State   			        = Origem.State,
                Destino.ZipCode   			        = Origem.ZipCode,
                Destino.InsertDate		            = CAST(DATEADD(HOUR,-3,GETDATE()) AS datetime)
    
        WHEN NOT MATCHED BY SOURCE AND Destino.NKCustomer <> -1 THEN
            UPDATE SET
                Destino.isActive = 0,
                Destino.UpdatedDate	= CAST(DATEADD(HOUR,-3,GETDATE()) AS datetime)		  

        WHEN NOT MATCHED THEN
                    INSERT
                    (
                        NKCustomer,
                        FirstName,
                        LastName,
                        Phone,
                        Email,
                        Street,
                        City,
                        State,
                        ZipCode,
                        InsertDate,
                        UpdatedDate,
                        isActive
                    )
                    VALUES
                    (
                        Origem.customer_id,
                        Origem.first_name,
                        Origem.last_name,
                        Origem.phone,
                        Origem.email,
                        Origem.street,
                        Origem.city,
                        Origem.state,
                        Origem.zip_code,
                        CAST(DATEADD(HOUR,-3,GETDATE()) AS datetime),
                        NULL,
                        1
                    )
        OUTPUT $action INTO @SummaryOfChanges;

        --> Insere o Log de Execução
        SET @Endtime = DATEADD(HOUR,-3,GETDATE()) 
        SET @ExecTime = DATEDIFF(ss, @Startime,@Endtime)

        SET @Quantity  = (SELECT COUNT(*) FROM  @SummaryOfChanges WHERE Change = 'INSERT')
        IF @Quantity <> 0
            EXECUTE [dw].[TS_InsertLogExec] 'I', @Procedure, @Object,@Description,@Quantity,@ExecTime,@Startime,@Endtime

        SET @Quantity  = (SELECT COUNT(*) FROM  @SummaryOfChanges WHERE Change = 'UPDATE')
        IF @Quantity <> 0
            EXECUTE [dw].[TS_InsertLogExec] 'U', @Procedure, @Object,@Description,@Quantity,@ExecTime,@Startime,@Endtime

    END TRY

    BEGIN CATCH  

        --> Se der erro, insere o log de erro
        SET @Error = ERROR_MESSAGE();			
        SET @Endtime = DATEADD(HOUR,-3,GETDATE()) 
        EXECUTE [dw].[TS_InsertLogExec] 'E', @Procedure, @Object,@Error,NULL,@ExecTime,@Startime,@Endtime

    END CATCH

    --> Stores
    BEGIN TRY

        SET @Object = 'Stores'
        SET @Description = 'Stores dimension merge'
        SET @Startime = DATEADD(HOUR,-3,GETDATE())
            
        MERGE
            [dw].[Sales_DIM_Stores] AS Destino
        USING 
            [stg].[Sales_Stores] AS Origem
        ON 
            Destino.NKStore = Origem.store_id

        WHEN MATCHED THEN 
            UPDATE SET
                Destino.StoreName			        = Origem.StoreName,
                Destino.Phone			            = Origem.Phone,
                Destino.Email   			        = Origem.Email,
                Destino.Street   			        = Origem.Street,
                Destino.City   			            = Origem.City,
                Destino.State   			        = Origem.State,
                Destino.ZipCode   			        = Origem.ZipCode,
                Destino.InsertDate		            = CAST(DATEADD(HOUR,-3,GETDATE()) AS datetime)
    
        WHEN NOT MATCHED BY SOURCE AND Destino.NKStore <> -1 THEN
            UPDATE SET
                Destino.isActive = 0,
                Destino.UpdatedDate	= CAST(DATEADD(HOUR,-3,GETDATE()) AS datetime)		  

        WHEN NOT MATCHED THEN
                    INSERT
                    (
                        NKStore,
                        StoreName,
                        Phone,
                        Email,
                        Street,
                        City,
                        State,
                        ZipCode,
                        InsertDate,
                        UpdatedDate,
                        isActive
                    )
                    VALUES
                    (
                        Origem.store_id,
                        Origem.store_name,
                        Origem.phone,
                        Origem.email,
                        Origem.street,
                        Origem.city,
                        Origem.state,
                        Origem.zip_code,
                        CAST(DATEADD(HOUR,-3,GETDATE()) AS datetime),
                        NULL,
                        1
                    )
        OUTPUT $action INTO @SummaryOfChanges;

        --> Insere o Log de Execução
        SET @Endtime = DATEADD(HOUR,-3,GETDATE()) 
        SET @ExecTime = DATEDIFF(ss, @Startime,@Endtime)

        SET @Quantity  = (SELECT COUNT(*) FROM  @SummaryOfChanges WHERE Change = 'INSERT')
        IF @Quantity <> 0
            EXECUTE [dw].[TS_InsertLogExec] 'I', @Procedure, @Object,@Description,@Quantity,@ExecTime,@Startime,@Endtime

        SET @Quantity  = (SELECT COUNT(*) FROM  @SummaryOfChanges WHERE Change = 'UPDATE')
        IF @Quantity <> 0
            EXECUTE [dw].[TS_InsertLogExec] 'U', @Procedure, @Object,@Description,@Quantity,@ExecTime,@Startime,@Endtime

    END TRY

    BEGIN CATCH  

        --> Se der erro, insere o log de erro
        SET @Error = ERROR_MESSAGE();			
        SET @Endtime = DATEADD(HOUR,-3,GETDATE()) 
        EXECUTE [dw].[TS_InsertLogExec] 'E', @Procedure, @Object,@Error,NULL,@ExecTime,@Startime,@Endtime

    END CATCH

    --> Staffs
    BEGIN TRY

        DELETE FROM @SummaryOfChanges
        SET @Object = 'Staffs'
        SET @Description = 'Staffs dimension merge'
        SET @Startime = DATEADD(HOUR,-3,GETDATE())

        IF OBJECT_ID('stg.Sales_StaffsAUX') IS NOT NULL BEGIN DROP TABLE stg.Sales_StaffsAUX END;
            SELECT
                A.staff_id                    		AS NKStaff,
                A.first_name			            AS FirstName,
                A.last_name			                AS LastName,
                A.email			                    AS Email,
                A.phone		                        AS Phone,
                A.active    		                AS Active,
                ISNULL(B.SKStore, -1)			    AS SKStore,
                ISNULL(A.manager_id, -1)			AS SKManager
            INTO [stg].[Sales_StaffsAUX]
            FROM
                [stg].[Sales_Staffs] A
            LEFT JOIN [dw].[Sales_DIM_Stores] B
                ON A.store_id = B.NKStore

            MERGE
                [dw].[Sales_DIM_Staffs AS Destino
            USING
                [stg].[Sales_StaffsAUX] AS Origem
            ON
                Destino.NKStaff = Origem.NKStaff

            WHEN MATCHED THEN
                UPDATE SET
                    Destino.FirstName				= Origem.FirstName,
                    Destino.LastName			    = Origem.LastName,
                    Destino.Email   			    = Origem.Email,
                    Destino.Phone			        = Origem.Phone,
                    Destino.Active  			    = Origem.Active,
                    Destino.SKStore 			    = Origem.SKStore,
                    Destino.SKManager			    = Origem.SKManager

            WHEN NOT MATCHED BY SOURCE AND Destino.NKStaff <> -1 THEN
                UPDATE SET
                    Destino.isActive = 0,
                    Destino.UpdatedDate = CAST(DATEADD(HOUR,-3,GETDATE()) AS datetime)

            WHEN NOT MATCHED THEN
                        INSERT
                        (
                            NKStaff,
                            FirstName,
                            LastName,
                            Email,
                            Phone,
                            Active,
                            SKStore,
                            SKManager,
                            InsertDate,
                            UpdatedDate,
                            isActive
                        )
                        VALUES
                        (
                            Origem.NKStaff,
                            Origem.FirstName,
                            Origem.LastName,
                            Origem.Email,
                            Origem.Phone,
                            Origem.Active,
                            Origem.SKStore,
                            Origem.SKManager,
                            CAST(DATEADD(HOUR,-3,GETDATE()) AS datetime),
                            NULL,
                            1
                        )
            OUTPUT $action INTO @SummaryOfChanges;

            IF OBJECT_ID('stg.Sales_StaffsAUX') IS NOT NULL BEGIN DROP TABLE stg.Sales_StaffsAUX END;

            --> Insere o Log de Execução
            SET @Endtime = DATEADD(HOUR,-3,GETDATE())
            SET @ExecTime = DATEDIFF(ss, @Startime,@Endtime)

            SET @Quantity  = (SELECT COUNT(*) FROM  @SummaryOfChanges WHERE Change = 'INSERT')
            IF @Quantity <> 0
                EXECUTE [dw].[BIKE_InsertLogExec] 'I', @Procedure, @Object,@Description,@Quantity,@ExecTime,@Startime,@Endtime

            SET @Quantity  = (SELECT COUNT(*) FROM  @SummaryOfChanges WHERE Change = 'UPDATE')
            IF @Quantity <> 0
                EXECUTE [dw].[BIKE_InsertLogExec] 'U', @Procedure, @Object,@Description,@Quantity,@ExecTime,@Startime,@Endtime

    END TRY

    BEGIN CATCH

        --> Se der erro, insere o log de erro
        SET @Error = ERROR_MESSAGE();
        SET @Endtime = DATEADD(HOUR,-3,GETDATE())
        EXECUTE [dw].[BIKE_InsertLogExec] 'E', @Procedure, @Object,@Error,NULL,@ExecTime,@Startime,@Endtime

    END CATCH

    --> Prod <--

    --> Brands
    BEGIN TRY

        SET @Object = 'Brands'
        SET @Description = 'Brands dimension merge'
        SET @Startime = DATEADD(HOUR,-3,GETDATE())
            
        MERGE
            [dw].[Prod_DIM_Brands] AS Destino
        USING 
            [stg].[Prod_Brands] AS Origem
        ON 
            Destino.NKBrand = Origem.brand_id

        WHEN MATCHED THEN 
            UPDATE SET
                Destino.BrandName			        = Origem.BrandName,
                Destino.InsertDate		            = CAST(DATEADD(HOUR,-3,GETDATE()) AS datetime)
    
        WHEN NOT MATCHED BY SOURCE AND Destino.NKBrand <> -1 THEN
            UPDATE SET
                Destino.isActive = 0,
                Destino.UpdatedDate	= CAST(DATEADD(HOUR,-3,GETDATE()) AS datetime)		  

        WHEN NOT MATCHED THEN
                    INSERT
                    (
                        NKBrand,
                        BrandName,
                        InsertDate,
                        UpdatedDate,
                        isActive
                    )
                    VALUES
                    (
                        Origem.brand_id,
                        Origem.brand_name,
                        CAST(DATEADD(HOUR,-3,GETDATE()) AS datetime),
                        NULL,
                        1
                    )
        OUTPUT $action INTO @SummaryOfChanges;

        --> Insere o Log de Execução
        SET @Endtime = DATEADD(HOUR,-3,GETDATE()) 
        SET @ExecTime = DATEDIFF(ss, @Startime,@Endtime)

        SET @Quantity  = (SELECT COUNT(*) FROM  @SummaryOfChanges WHERE Change = 'INSERT')
        IF @Quantity <> 0
            EXECUTE [dw].[TS_InsertLogExec] 'I', @Procedure, @Object,@Description,@Quantity,@ExecTime,@Startime,@Endtime

        SET @Quantity  = (SELECT COUNT(*) FROM  @SummaryOfChanges WHERE Change = 'UPDATE')
        IF @Quantity <> 0
            EXECUTE [dw].[TS_InsertLogExec] 'U', @Procedure, @Object,@Description,@Quantity,@ExecTime,@Startime,@Endtime

    END TRY

    BEGIN CATCH  

        --> Se der erro, insere o log de erro
        SET @Error = ERROR_MESSAGE();			
        SET @Endtime = DATEADD(HOUR,-3,GETDATE()) 
        EXECUTE [dw].[TS_InsertLogExec] 'E', @Procedure, @Object,@Error,NULL,@ExecTime,@Startime,@Endtime

    END CATCH

    --> Categories
    BEGIN TRY

        SET @Object = 'Categories'
        SET @Description = 'Categories dimension merge'
        SET @Startime = DATEADD(HOUR,-3,GETDATE())
            
        MERGE
            [dw].[Prod_DIM_Categories] AS Destino
        USING 
            [stg].[Prod_Categories] AS Origem
        ON 
            Destino.NKCategory = Origem.category_id

        WHEN MATCHED THEN 
            UPDATE SET
                Destino.CategoryName			        = Origem.CategoryName,
                Destino.InsertDate		            = CAST(DATEADD(HOUR,-3,GETDATE()) AS datetime)
    
        WHEN NOT MATCHED BY SOURCE AND Destino.NKCategory <> -1 THEN
            UPDATE SET
                Destino.isActive = 0,
                Destino.UpdatedDate	= CAST(DATEADD(HOUR,-3,GETDATE()) AS datetime)		  

        WHEN NOT MATCHED THEN
                    INSERT
                    (
                        NKCategory,
                        CategoryName,
                        InsertDate,
                        UpdatedDate,
                        isActive
                    )
                    VALUES
                    (
                        Origem.category_id,
                        Origem.category_name,
                        CAST(DATEADD(HOUR,-3,GETDATE()) AS datetime),
                        NULL,
                        1
                    )
        OUTPUT $action INTO @SummaryOfChanges;

        --> Insere o Log de Execução
        SET @Endtime = DATEADD(HOUR,-3,GETDATE()) 
        SET @ExecTime = DATEDIFF(ss, @Startime,@Endtime)

        SET @Quantity  = (SELECT COUNT(*) FROM  @SummaryOfChanges WHERE Change = 'INSERT')
        IF @Quantity <> 0
            EXECUTE [dw].[TS_InsertLogExec] 'I', @Procedure, @Object,@Description,@Quantity,@ExecTime,@Startime,@Endtime

        SET @Quantity  = (SELECT COUNT(*) FROM  @SummaryOfChanges WHERE Change = 'UPDATE')
        IF @Quantity <> 0
            EXECUTE [dw].[TS_InsertLogExec] 'U', @Procedure, @Object,@Description,@Quantity,@ExecTime,@Startime,@Endtime

    END TRY

    BEGIN CATCH  

        --> Se der erro, insere o log de erro
        SET @Error = ERROR_MESSAGE();			
        SET @Endtime = DATEADD(HOUR,-3,GETDATE()) 
        EXECUTE [dw].[TS_InsertLogExec] 'E', @Procedure, @Object,@Error,NULL,@ExecTime,@Startime,@Endtime

    END CATCH

    --> Products
    BEGIN TRY

        DELETE FROM @SummaryOfChanges
        SET @Object = 'Products'
        SET @Description = 'Products dimension merge'
        SET @Startime = DATEADD(HOUR,-3,GETDATE())

        IF OBJECT_ID('stg.Prod_ProductsAUX') IS NOT NULL BEGIN DROP TABLE stg.Prod_ProductsAUX END;
            SELECT
                A.product_id                    	AS NKProduct,
                A.product_name			            AS ProductName,
                ISNULL(B.SKBrand, -1)	            AS SKBrand,
                ISNULL(C.SKCategory, -1)	        AS SKCategory,
                A.model_year	                    AS ModelYear,
                A.list_price  		                AS ListPrice
            INTO [stg].[Sales_StaffsAUX]
            FROM
                [stg].[Prod_Products] A
            LEFT JOIN [dw].[Prod_DIM_Brands] B
                ON A.brand_id = B.NKBrand
            LEFT JOIN [dw].[Prod_DIM_Categories] C
                ON A.category_id = C.NKCategory

            MERGE
                [dw].[Prod_DIM_Products AS Destino
            USING
                [stg].[Prod_ProductsAUX] AS Origem
            ON
                Destino.NKProduct = Origem.NKProduct

            WHEN MATCHED THEN
                UPDATE SET
                    Destino.ProductName				= Origem.ProductName,
                    Destino.SKBrand				    = Origem.SKBrand,
                    Destino.SKCategory				= Origem.SKCategory,
                    Destino.ModelYear				= Origem.ModelYear,
                    Destino.ListPrice				= Origem.ListPrice,

            WHEN NOT MATCHED BY SOURCE AND Destino.NKProduct <> -1 THEN
                UPDATE SET
                    Destino.isActive = 0,
                    Destino.UpdatedDate = CAST(DATEADD(HOUR,-3,GETDATE()) AS datetime)

            WHEN NOT MATCHED THEN
                        INSERT
                        (
                            NKStaff,
                            ProductName,
                            SKBrand,
                            SKCategory,
                            ModelYear,
                            ListPrice,
                            InsertDate,
                            UpdatedDate,
                            isActive
                        )
                        VALUES
                        (
                            Origem.NKProduct,
                            Origem.ProductName,
                            Origem.SKBrand,
                            Origem.SKCategory,
                            Origem.ModelYear,
                            Origem.ListPrice,
                            CAST(DATEADD(HOUR,-3,GETDATE()) AS datetime),
                            NULL,
                            1
                        )
            OUTPUT $action INTO @SummaryOfChanges;

            IF OBJECT_ID('stg.Prod_ProductsAUX') IS NOT NULL BEGIN DROP TABLE stg.Prod_ProductsAUX END;

            --> Insere o Log de Execução
            SET @Endtime = DATEADD(HOUR,-3,GETDATE())
            SET @ExecTime = DATEDIFF(ss, @Startime,@Endtime)

            SET @Quantity  = (SELECT COUNT(*) FROM  @SummaryOfChanges WHERE Change = 'INSERT')
            IF @Quantity <> 0
                EXECUTE [dw].[BIKE_InsertLogExec] 'I', @Procedure, @Object,@Description,@Quantity,@ExecTime,@Startime,@Endtime

            SET @Quantity  = (SELECT COUNT(*) FROM  @SummaryOfChanges WHERE Change = 'UPDATE')
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