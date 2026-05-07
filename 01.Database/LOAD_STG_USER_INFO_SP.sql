CREATE TABLE STG_User_Info (
    user_id        INT,
    user_name      NVARCHAR(100),
    email          NVARCHAR(100),
    phone          NVARCHAR(50),

    city_name      NVARCHAR(100),
    state_name     NVARCHAR(100),
    country_name   NVARCHAR(100),
    region         NVARCHAR(50),

    created_at     DATE,
    status         NVARCHAR(50),

    Row_State      INT
);

---------------------------------

CREATE OR ALTER PROCEDURE Load_User_Info
AS
BEGIN
    SET NOCOUNT ON;

    MERGE STG_User_Info AS target
    USING
    (
        SELECT 
            -- =====================
            -- USER BASIC
            -- =====================
            ub.user_id,
            CASE 
            WHEN ub.Row_State = 3 THEN 'N.A'
            ELSE ISNULL(ub.user_name, 'N.A')
            END AS UserName,

            CASE 
            WHEN ub.Row_State = 3 THEN 'N.A'
            ELSE ISNULL(ub.status, 'N.A')
            END AS Status,


            -- =====================
            -- CONTACT
            -- =====================
            CASE 
            WHEN uc.Row_State = 3 THEN 'N.A'
            ELSE ISNULL(uc.email, 'N.A')
            END AS Email,
            CASE 
            WHEN uc.Row_State = 3 THEN 'N.A'
            ELSE ISNULL(uc.phone, 'N.A')
            END AS Phone,

            -- =====================
            -- LOCATION
            -- =====================
            CASE 
                WHEN ci.Row_State = 3 THEN 'N.A'
                ELSE ISNULL(ci.city_name, 'N.A')
            END AS CityName,
            
            CASE 
                WHEN st.Row_State = 3 THEN 'N.A'
                ELSE ISNULL(st.state_name, 'N.A')
            END AS StateName,
            
            CASE 
                WHEN co.Row_State = 3 THEN 'N.A'
                ELSE ISNULL(co.country_name, 'N.A')
            END AS CountryName,
            
            CASE 
                WHEN co.Row_State = 3 THEN 'N.A'
                ELSE ISNULL(co.region, 'N.A')
            END AS Region,
            
            -- =====================
            -- ACTIVITY
            -- =====================
            CASE 
            WHEN ua.Row_State = 3 THEN '1900-01-01'
            ELSE ISNULL(CAST(ua.created_at AS DATE), '1900-01-01')
            END AS Created_At,

            -- =====================
            -- FINAL ROW STATE
            -- =====================
            CASE 
                WHEN ub.Row_State IN (1,2,3) THEN ub.Row_State

                WHEN ub.Row_State = 0 AND (
                        uc.Row_State IN (1,2,3)
                     OR ul.Row_State IN (1,2,3)
                     OR ci.Row_State IN (1,2,3)
                     OR st.Row_State IN (1,2,3)
                     OR co.Row_State IN (1,2,3)
                     OR ua.Row_State IN (1,2,3)
                )
                THEN 2

                ELSE 0
            END AS Row_State

        FROM STG_User_Basic ub

        LEFT JOIN STG_User_Contact uc
            ON ub.user_id = uc.user_id

        LEFT JOIN STG_User_Activity ua
            ON ub.user_id = ua.user_id

        LEFT JOIN STG_User_Location ul
            ON ub.user_id = ul.user_id

        LEFT JOIN STG_Cities ci
            ON ul.city_id = ci.city_id

        LEFT JOIN STG_States st
            ON ci.state_id = st.state_id

        LEFT JOIN STG_Countries co
            ON st.[Counrty_ID] = co.country_id

        -- Incremental filter
        WHERE 
            ub.Row_State IN (1,2,3)
            OR uc.Row_State IN (1,2,3)
            OR ul.Row_State IN (1,2,3)
            OR ci.Row_State IN (1,2,3)
            OR st.Row_State IN (1,2,3)
            OR co.Row_State IN (1,2,3)
            OR ua.Row_State IN (1,2,3)

    ) AS src

    ON target.user_id = src.user_id

    -- =====================
    -- UPDATE
    -- =====================
    WHEN MATCHED and src.row_state=2 THEN
        UPDATE SET
            target.user_name   = src.UserName,
            target.status      = src.Status,
            target.email       = src.Email,
            target.phone       = src.Phone,
            target.city_name   = src.CityName,
            target.state_name  = src.StateName,
            target.country_name= src.CountryName,
            target.region      = src.Region,
            target.created_at  = src.Created_At,
            target.Row_State   = src.Row_State

    -- =====================
    -- INSERT
    -- =====================
    WHEN NOT MATCHED THEN
        INSERT (
            user_id,
            user_name,
            status,
            email,
            phone,
            city_name,
            state_name,
            country_name,
            region,
            created_at,
            Row_State
        )
        VALUES (
            src.user_id,
            src.UserName,
            src.Status,
            src.Email,
            src.Phone,
            src.CityName,
            src.StateName,
            src.CountryName,
            src.Region,
            src.Created_At,
            src.Row_State
        );

END;

EXEC Load_User_Info;