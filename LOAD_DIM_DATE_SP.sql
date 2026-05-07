CREATE OR ALTER PROCEDURE Load_Dim_Date
AS
BEGIN
    SET NOCOUNT ON;

    /*========================================
    1. Create Table (if not exists)
    ========================================*/
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Dim_Date')
    BEGIN
        CREATE TABLE Dim_Date (
            date_key INT IDENTITY(1,1) PRIMARY KEY,
            full_date DATE UNIQUE,

            day INT,
            month INT,
            month_name VARCHAR(20),
            quarter INT,
            year INT,

            day_of_week INT,
            day_name VARCHAR(20),
            is_weekend BIT
        );
    END

    /*========================================
    2. Get Min & Max Dates from Sources
    ========================================*/
    DECLARE @min_date DATE,
            @max_date DATE;

    SELECT 
    @min_date = MIN(dt),
    @max_date = MAX(dt)
FROM (
    SELECT MIN(order_date) AS dt FROM GAMING_STG.dbo.STG_SALES
    UNION ALL
    SELECT MIN(session_date) FROM GAMING_STG.dbo.STG_Game_Sessions
    UNION ALL
    SELECT MIN(earned_date) FROM GAMING_STG.dbo.STG_Trophies

    UNION ALL

    SELECT MAX(order_date) FROM GAMING_STG.dbo.STG_SALES
    UNION ALL
    SELECT MAX(session_date) FROM GAMING_STG.dbo.STG_Game_Sessions
    UNION ALL
    SELECT MAX(earned_date) FROM GAMING_STG.dbo.STG_Trophies
) t;

    /*========================================
    3. Safety
    ========================================*/
    IF @min_date IS NULL OR @max_date IS NULL
    BEGIN
        SET @min_date = '2000-01-01';
        SET @max_date = '2030-12-31';
    END

    /*========================================
    4. Buffer
    ========================================*/
    SET @max_date = DATEADD(YEAR, 1, @max_date);

    /*========================================
    5. Generate Dates + Insert Incrementally
    ========================================*/
    ;WITH DateSeries AS (
        SELECT @min_date AS dt
        UNION ALL
        SELECT DATEADD(DAY, 1, dt)
        FROM DateSeries
        WHERE dt < @max_date
    )
    INSERT INTO Dim_Date (
        full_date,
        day,
        month,
        month_name,
        quarter,
        year,
        day_of_week,
        day_name,
        is_weekend
    )
    SELECT
        dt,
        DAY(dt),
        MONTH(dt),
        DATENAME(MONTH, dt),
        DATEPART(QUARTER, dt),
        YEAR(dt),
        DATEPART(WEEKDAY, dt),
        DATENAME(WEEKDAY, dt),
        CASE 
            WHEN DATENAME(WEEKDAY, dt) IN ('Friday','Saturday') THEN 1 
            ELSE 0 
        END
    FROM DateSeries ds
    WHERE NOT EXISTS (
        SELECT 1 
        FROM Dim_Date d 
        WHERE d.full_date = ds.dt
    )
    OPTION (MAXRECURSION 0);

END;

EXEC Load_Dim_Date;

