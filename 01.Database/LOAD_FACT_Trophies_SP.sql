CREATE OR ALTER PROCEDURE Load_FACT_TROPHIES
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
    2. Source
    ========================================*/
    IF OBJECT_ID('tempdb..#src') IS NOT NULL
        DROP TABLE #src;

    SELECT *
    INTO #src
    FROM GAMING_STG.dbo.STG_Trophies
    WHERE row_state IN (1,3);

    /*========================================
    3. Build Final Dataset
    ========================================*/
    IF OBJECT_ID('tempdb..#final') IS NOT NULL
        DROP TABLE #final;

    SELECT 
        S.user_id,
        S.game_id,
        S.trophy_name,
        S.trophy_type,
        CAST(S.earned_date AS DATE) AS earned_date,

        ISNULL(U.user_sk, -1) AS user_sk,
        ISNULL(G.game_sk, -1) AS game_sk,
        ISNULL(T.D_Trophy_SK, -1) AS trophy_sk,
        ISNULL(D.date_key, -1) AS date_key,

        S.row_state
    INTO #final
    FROM #src S

    LEFT JOIN DIM_User_Info U
        ON S.user_id = U.user_id
        AND U.End_Date = '9999-12-31'

    LEFT JOIN DIM_GAME_INFO G
        ON S.game_id = G.game_id

    LEFT JOIN DIM_TROPHY_INFO T
        ON S.trophy_name = T.trophy_name
       AND S.trophy_type = T.trophy_type

    LEFT JOIN Dim_Date D
        ON CAST(S.earned_date AS DATE) = D.full_date;

    /*========================================
    4. INSERT (New Only + Dedup)
    ========================================*/
    INSERT INTO FACT_TROPHIES
    (
        user_sk,
        game_sk,
        trophy_sk,
        Date_SK,
        Start_Date,
        End_Date
    )
    SELECT 
        S.user_sk,
        S.game_sk,
        S.trophy_sk,
        S.date_key,
        GETDATE(),
        '9999-12-31'
    FROM #final S
    WHERE S.row_state = 1
      
    /*========================================
    5. SOFT DELETE
    ========================================*/
    UPDATE F
    SET F.End_Date = GETDATE()
    FROM FACT_TROPHIES F
    JOIN #final S
        ON F.user_sk = S.user_sk
        AND F.game_sk = S.game_sk
        AND F.trophy_sk = S.trophy_sk
        AND F.Date_SK = S.date_key
    WHERE S.row_state = 3
      AND F.End_Date = '9999-12-31';

    /*========================================
    6. VALIDATION LOG - USER
    ========================================*/
    INSERT INTO #Validation_Log
    SELECT DISTINCT
        'DIM_User_Info',
        'FACT_TROPHIES',
        CAST(S.user_id AS VARCHAR),
        CAST(S.user_id AS VARCHAR)
    FROM #final S
    LEFT JOIN DIM_User_Info U
        ON S.user_id = U.user_id
    WHERE U.user_sk IS NULL;

    /*========================================
    7. VALIDATION LOG - GAME
    ========================================*/
    INSERT INTO #Validation_Log
    SELECT DISTINCT
        'DIM_Game',
        'FACT_TROPHIES',
        CAST(S.game_id AS VARCHAR),
        CAST(S.user_id AS VARCHAR)
    FROM #final S
    LEFT JOIN DIM_GAME_INFO GM
        ON S.game_id = GM.game_id
    LEFT JOIN DIM_GAME_INFO G
        ON GM.game_sk = G.game_sk
    WHERE G.game_sk IS NULL;

    /*========================================
    8. VALIDATION LOG - TROPHY
    ========================================*/
    INSERT INTO #Validation_Log
    SELECT DISTINCT
        'DIM_TROPHY_INFO',
        'FACT_TROPHIES',
        S.trophy_name + ' - ' + S.trophy_type,
        CAST(S.user_id AS VARCHAR)
    FROM #final S
    LEFT JOIN DIM_TROPHY_INFO T
        ON S.trophy_name = T.trophy_name
       AND S.trophy_type = T.trophy_type
    WHERE T.D_Trophy_SK IS NULL;

    /*========================================
    9. VALIDATION LOG - DATE
    ========================================*/
    INSERT INTO #Validation_Log
    SELECT DISTINCT
        'DIM_DATE',
        'FACT_TROPHIES',
        CAST(S.earned_date AS VARCHAR),
        CAST(S.user_id AS VARCHAR)
    FROM #final S
    LEFT JOIN Dim_Date D
        ON S.earned_date = D.full_date
    WHERE D.date_key IS NULL;

    /*========================================
    10. PUSH LOG
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

exec Load_FACT_TROPHIES
