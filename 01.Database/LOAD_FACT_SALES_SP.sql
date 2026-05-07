CREATE OR ALTER PROCEDURE Load_FACT_SALES
AS
BEGIN
    SET NOCOUNT ON;

    /*========================================
    1. Validation Log Table
    ========================================*/
    IF OBJECT_ID('tempdb..#Validation_Log') IS NOT NULL
        DROP TABLE #Validation_Log;

    CREATE TABLE #Validation_Log
    (
        Dim_Name VARCHAR(100),
        Fact_Name VARCHAR(100),
        Missing_ID VARCHAR(100),
        Fact_ID VARCHAR(100)
    );

    /*========================================
    2. Source Data
    ========================================*/
    IF OBJECT_ID('tempdb..#src') IS NOT NULL
        DROP TABLE #src;

    SELECT *
    INTO #src
    FROM GAMING_STG.dbo.STG_SALES
    WHERE row_state IN (1,2,3);

    /*========================================
    3. FACT SALES MERGE
    ========================================*/
    MERGE FACT_SALES AS T
    USING (
        SELECT 
            s.order_id,

            ISNULL(u.USER_SK, -1) AS user_sk,
            ISNULL(gm.game_sk, -1) AS game_sk,
            ISNULL(p.Pay_SK, -1) AS pay_sk,
            ISNULL(d.date_key, -1) AS date_key,

            s.price,
            s.quantity,
            s.discount_amount,
            s.tax_amount,
            s.total_amount,
            s.is_refunded,
            s.refund_date,

            s.user_id,
            s.game_id,
            s.payment_method,
            s.row_state
        FROM #src s

        LEFT JOIN DIM_User_Info u
            ON s.user_id = u.user_id
            AND u.End_Date = '9999-12-31'

        LEFT JOIN DIM_GAME_INFO gm
            ON s.game_id = gm.game_id

        LEFT JOIN DIM_Payment_Method p
            ON s.payment_method = p.payment_method

        LEFT JOIN Dim_Date d
            ON s.order_date = d.full_date
    ) AS S
    ON T.order_id = S.order_id
       AND T.End_Date = '9999-12-31'

    /*========================================
    UPDATE
    ========================================*/
     WHEN MATCHED 
     THEN UPDATE SET
     
         T.user_sk = CASE 
                         WHEN S.row_state = 2 THEN S.user_sk 
                         ELSE T.user_sk 
                     END,
     
         T.game_sk = CASE 
                         WHEN S.row_state = 2 THEN S.game_sk 
                         ELSE T.game_sk 
                     END,
     
         T.pay_sk = CASE 
                         WHEN S.row_state = 2 THEN S.pay_sk 
                         ELSE T.pay_sk 
                     END,
     
         T.date_key = CASE 
                         WHEN S.row_state = 2 THEN S.date_key 
                         ELSE T.date_key 
                     END,
     
         T.price = CASE 
                     WHEN S.row_state = 2 THEN S.price 
                     ELSE T.price 
                   END,
     
         T.quantity = CASE 
                         WHEN S.row_state = 2 THEN S.quantity 
                         ELSE T.quantity 
                     END,
     
         T.discount_amount = CASE 
                                 WHEN S.row_state = 2 THEN S.discount_amount 
                                 ELSE T.discount_amount 
                             END,
     
         T.tax_amount = CASE 
                             WHEN S.row_state = 2 THEN S.tax_amount 
                             ELSE T.tax_amount 
                        END,
     
         T.total_amount = CASE 
                             WHEN S.row_state = 2 THEN S.total_amount 
                             ELSE T.total_amount 
                          END,
     
         T.is_refunded = CASE 
                             WHEN S.row_state = 2 THEN S.is_refunded 
                             ELSE T.is_refunded 
                         END,
     
         T.refund_date = CASE 
                             WHEN S.row_state = 2 THEN S.refund_date 
                             ELSE T.refund_date 
                         END,

    -- Soft Delete
    T.End_Date = CASE 
                    WHEN S.row_state = 3 THEN GETDATE()
                    ELSE T.End_Date
                 END
    /*========================================
    INSERT
    ========================================*/
    WHEN NOT MATCHED THEN
        INSERT (
            order_id,
            user_sk,
            game_sk,
            pay_sk,
            date_key,
            price,
            quantity,
            discount_amount,
            tax_amount,
            total_amount,
            is_refunded,
            refund_date,
            Start_Date,
            End_Date
        )
        VALUES (
            S.order_id,
            S.user_sk,
            S.game_sk,
            S.pay_sk,
            S.date_key,
            S.price,
            S.quantity,
            S.discount_amount,
            S.tax_amount,
            S.total_amount,
            S.is_refunded,
            S.refund_date,
            GETDATE(),
            '9999-12-31'
        );

    /*========================================
    4. LOG - USER
    ========================================*/
    INSERT INTO #Validation_Log
    SELECT DISTINCT
        'DIM_User_Info',
        'FACT_SALES',
        CAST(s.user_id AS VARCHAR),
        CAST(s.order_id AS VARCHAR)
    FROM #src s
    LEFT JOIN DIM_User_Info u
        ON s.user_id = u.user_id
    WHERE u.USER_SK IS NULL;

    /*========================================
    5. LOG - GAME
    ========================================*/
    INSERT INTO #Validation_Log
    SELECT DISTINCT
        'DIM_Game',
        'FACT_SALES',
        CAST(s.game_id AS VARCHAR),
        CAST(s.order_id AS VARCHAR)
    FROM #src s
    LEFT JOIN DIM_GAME_INFO gm
        ON s.game_id = gm.game_id
    LEFT JOIN DIM_GAME_INFO g
        ON gm.game_sk = g.game_sk
    WHERE g.Game_SK IS NULL;

    /*========================================
    6. LOG - PAYMENT
    ========================================*/
    INSERT INTO #Validation_Log
    SELECT DISTINCT
        'DIM_Payment_Method',
        'FACT_SALES',
        s.payment_method,
        CAST(s.order_id AS VARCHAR)
    FROM #src s
    LEFT JOIN DIM_Payment_Method p
        ON s.payment_method = p.payment_method
    WHERE p.Pay_SK IS NULL;

    /*========================================
    7. PUSH LOGS
    ========================================*/
    INSERT INTO Dim_Validation_Log
    (
        Dim_Name,
        Fact_Name,
        Missing_ID,
        Fact_ID,
        Log_Date
    )
    SELECT 
        Dim_Name,
        Fact_Name,
        Missing_ID,
        Fact_ID,
        GETDATE()
    FROM #Validation_Log;

END;

exec Load_FACT_SALES
select * from Dim_Validation_Log
