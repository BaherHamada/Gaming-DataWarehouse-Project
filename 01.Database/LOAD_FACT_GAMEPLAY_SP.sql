CREATE OR ALTER PROCEDURE Load_FACT_GAME_PLAY
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
    2. Temp Final Table
    ========================================*/
    IF OBJECT_ID('tempdb..#final_data') IS NOT NULL
        DROP TABLE #final_data;

    /*========================================
    3. Sessions Aggregation
    ========================================*/
    WITH session_data AS (
        SELECT 
            session_id,
            user_id,
            game_id,
            CAST(session_date AS DATE) AS play_date,
            SUM(hours_played) AS total_hours,
            device_type,
            MAX(row_state) AS row_state
        FROM GAMING_STG.dbo.STG_Game_Sessions
        WHERE row_state IN (1,2,3)
        GROUP BY 
            Session_ID,
            user_id,
            game_id,
            CAST(session_date AS DATE),
            device_type
    ),

    /*========================================
    4. Trophies Aggregation
    ========================================*/
    trophy_data AS (
        SELECT 
            user_id,
            game_id,
            CAST(earned_date AS DATE) AS earned_date,
            COUNT(*) AS trophies_count
        FROM GAMING_STG.dbo.STG_Trophies
        WHERE row_state IN (1,2,3)
        GROUP BY 
            user_id,
            game_id,
            CAST(earned_date AS DATE)
    )

    /*========================================
    5. Final Dataset
    ========================================*/
    SELECT 
        s.session_id,
        s.user_id,
        s.game_id,
        s.play_date,
        s.total_hours,
        s.device_type,
        ISNULL(t.trophies_count, 0) AS trophies_count,
        s.row_state
    INTO #final_data
    FROM session_data s
    LEFT JOIN trophy_data t
        ON s.user_id = t.user_id
       AND s.game_id = t.game_id
       AND s.play_date = t.earned_date;

    /*========================================
    6. UPDATE (Active only)
    ========================================*/
    UPDATE F
    SET 
        F.total_hours = S.total_hours,
        F.trophies_count = S.trophies_count
    FROM FACT_GAME_PLAY F
    JOIN #final_data S
        ON F.session_id = S.session_id
    WHERE S.row_state = 2
      AND F.End_Date = '9999-12-31';

    /*========================================
    7. SOFT DELETE
    ========================================*/
    UPDATE F
    SET End_Date = GETDATE()
    FROM FACT_GAME_PLAY F
    JOIN #final_data S
        ON F.session_id = S.session_id
    WHERE S.row_state = 3
      AND F.End_Date = '9999-12-31';

    /*========================================
    8. INSERT
    ========================================*/
    INSERT INTO FACT_GAME_PLAY
    (
        session_id,
        user_sk,
        game_sk,
        device_type_sk,
        date_key,
        total_hours,
        trophies_count,
        Start_Date,
        End_Date
    )
    SELECT 
        S.session_id,
        ISNULL(U.user_sk, -1),
        ISNULL(G.game_sk, -1),
        ISNULL(D.device_sk, -1),
        ISNULL(DD.date_key, -1),
        S.total_hours,
        S.trophies_count,
        GETDATE(),
        '9999-12-31'
    FROM #final_data S

    LEFT JOIN DIM_User_Info U
        ON S.user_id = U.user_id
        AND U.End_Date = '9999-12-31'

    LEFT JOIN DIM_GAME_INFO G
        ON S.game_id = G.game_id

    LEFT JOIN DIM_Device_Type D
        ON S.device_type = D.device_type

    LEFT JOIN Dim_Date DD
        ON S.play_date = DD.full_date

    WHERE S.row_state = 1;

    /*========================================
    9. VALIDATION LOG - USER
    ========================================*/
    INSERT INTO #Validation_Log
    SELECT DISTINCT
        'DIM_User_Info',
        'FACT_GAME_PLAY',
        CAST(S.user_id AS VARCHAR),
        CAST(S.session_id AS VARCHAR)
    FROM #final_data S
    LEFT JOIN DIM_User_Info U
        ON S.user_id = U.user_id
    WHERE U.user_sk IS NULL;

    /*========================================
    10. VALIDATION LOG - GAME
    ========================================*/
    INSERT INTO #Validation_Log
    SELECT DISTINCT
        'DIM_Game',
        'FACT_GAME_PLAY',
        CAST(S.game_id AS VARCHAR),
        CAST(S.session_id AS VARCHAR)
    FROM #final_data S
    LEFT JOIN DIM_GAME_INFO GM
        ON S.game_id = GM.game_id
    LEFT JOIN DIM_GAME_INFO G
        ON GM.game_sk = G.game_sk
    WHERE G.game_sk IS NULL;

    /*========================================
    11. VALIDATION LOG - DEVICE
    ========================================*/
    INSERT INTO #Validation_Log
    SELECT DISTINCT
        'DIM_Device_Type',
        'FACT_GAME_PLAY',
        S.device_type,
        CAST(S.session_id AS VARCHAR)
    FROM #final_data S
    LEFT JOIN DIM_Device_Type D
        ON S.device_type = D.device_type
    WHERE D.device_sk IS NULL;

    /*========================================
    12. PUSH LOG
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

EXEC Load_FACT_GAME_PLAY

