CREATE TABLE STG_Game_Info_N
(
    game_id INT,
    game_name NVARCHAR(255),
    genre NVARCHAR(100),
    price FLOAT,
    discount_percentage FLOAT,
    tax_percentage FLOAT,
    release_date DATE,
    platform NVARCHAR(100),
    rating FLOAT,
    Row_State INT
);
-----------------------------------------

CREATE OR ALTER PROCEDURE Load_Game_Info
AS
BEGIN
    SET NOCOUNT ON;

    MERGE STG_Game_Info_N AS target
    USING
    (
        SELECT 
            -- =====================
            -- KEY
            -- =====================
            t.game_id,

            -- =====================
            -- GAME BASIC
            -- =====================
            CASE 
                WHEN t.Row_State = 3 THEN 'N.A'
                ELSE ISNULL(t.game_name, 'N.A')
            END AS game_name,

            CASE 
                WHEN g.Row_State = 3 THEN 'N.A'
                ELSE ISNULL(g.genre, 'N.A')
            END AS genre,

            -- =====================
            -- PRICING
            -- =====================
            CASE 
                WHEN p.Row_State = 3 THEN 0
                ELSE ISNULL(p.price, 0)
            END AS price,

            CASE 
                WHEN p.Row_State = 3 THEN 0
                ELSE ISNULL(p.discount_percentage, 0)
            END AS discount_percentage,

            CASE 
                WHEN p.Row_State = 3 THEN 0
                ELSE ISNULL(p.tax_percentage, 0)
            END AS tax_percentage,

            -- =====================
            -- METADATA
            -- =====================
            CASE 
                WHEN m.Row_State = 3 THEN '1900-01-01'
                ELSE ISNULL(CONVERT(VARCHAR(10), m.release_date, 120), '1900-01-01')
            END AS release_date,

            CASE 
                WHEN m.Row_State = 3 THEN 'N.A'
                ELSE ISNULL(m.platform, 'N.A')
            END AS platform,

            CASE 
                WHEN m.Row_State = 3 THEN 0
                ELSE ISNULL(m.rating, 0)
            END AS rating,

            -- =====================
            -- FINAL ROW STATE
            -- =====================
            CASE 
                WHEN t.Row_State IN (1,2,3) THEN t.Row_State

                WHEN g.Row_State IN (1,2,3)
                  OR p.Row_State IN (1,2,3)
                  OR m.Row_State IN (1,2,3)
                THEN 2

                ELSE 0
            END AS Row_State

        FROM STG_Game_Titles t

        LEFT JOIN STG_Game_Genres g
            ON t.game_id = g.game_id

        LEFT JOIN STG_Game_Prices p
            ON t.game_id = p.game_id

        LEFT JOIN STG_Game_Metadata m
            ON t.game_id = m.game_id

        WHERE 
            t.Row_State IN (1,2,3)
            OR g.Row_State IN (1,2,3)
            OR p.Row_State IN (1,2,3)
            OR m.Row_State IN (1,2,3)

    ) AS src

    ON target.game_id = src.game_id

    WHEN MATCHED THEN
        UPDATE SET
            target.game_name           = src.game_name,
            target.genre               = src.genre,
            target.price               = src.price,
            target.discount_percentage = src.discount_percentage,
            target.tax_percentage      = src.tax_percentage,
            target.release_date        = src.release_date,
            target.platform            = src.platform,
            target.rating              = src.rating,
            target.Row_State           = src.Row_State

    WHEN NOT MATCHED THEN
        INSERT (
            game_id,
            game_name,
            genre,
            price,
            discount_percentage,
            tax_percentage,
            release_date,
            platform,
            rating,
            Row_State
        )
        VALUES (
            src.game_id,
            src.game_name,
            src.genre,
            src.price,
            src.discount_percentage,
            src.tax_percentage,
            src.release_date,
            src.platform,
            src.rating,
            src.Row_State
        );

END;
exec Load_Game_Info