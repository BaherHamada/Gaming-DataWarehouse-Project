-------------------------------------------------
--------------Load_ODS_Countries------------------
CREATE OR ALTER PROCEDURE Load_ODS_Countries
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        MERGE ODS_Countries AS TARGET
        USING (
            SELECT *
            FROM AZURE_DB.Gaming_Platform.dbo.countries
        ) AS SOURCE
        ON TARGET.country_id = SOURCE.country_id

        -- 1️ New
        WHEN NOT MATCHED THEN
            INSERT (country_id, country_name, region, Row_State)
            VALUES (SOURCE.country_id, SOURCE.country_name, SOURCE.region, 1)

        -- 2️ Updated
        WHEN MATCHED AND (
            ISNULL(TARGET.country_name,'') <> ISNULL(SOURCE.country_name,'')
       OR ISNULL(TARGET.region,'') <> ISNULL(SOURCE.region,'')
        ) THEN
            UPDATE SET
                TARGET.country_name = SOURCE.country_name,
                TARGET.region = SOURCE.region,
                TARGET.Row_State = 2

        -- 3️ Deleted
        WHEN NOT MATCHED BY SOURCE THEN
            UPDATE SET TARGET.Row_State = 3;

        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;

--------------Load_ODS_States------------------
CREATE OR ALTER PROCEDURE Load_ODS_States
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        MERGE ODS_States AS TARGET
        USING (
            SELECT *
            FROM AZURE_DB.Gaming_Platform.dbo.states
        ) AS SOURCE
        ON TARGET.state_id = SOURCE.state_id

        -- 1️ New
        WHEN NOT MATCHED THEN
            INSERT (state_id, state_name, country_id, Row_State)
            VALUES (SOURCE.state_id, SOURCE.state_name, SOURCE.country_id, 1)

        -- 2️ Updated
       WHEN MATCHED AND (
       ISNULL(TARGET.state_name,'') <> ISNULL(SOURCE.state_name,'')
       OR ISNULL(TARGET.country_id,'') <> ISNULL(SOURCE.country_id,'')
       )THEN
            UPDATE SET
                TARGET.state_name = SOURCE.state_name,
                TARGET.country_id = SOURCE.country_id,
                TARGET.Row_State = 2

        -- 3️ Deleted
        WHEN NOT MATCHED BY SOURCE THEN
            UPDATE SET TARGET.Row_State = 3;

        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;

--------------Load_ODS_States------------------
CREATE OR ALTER PROCEDURE Load_ODS_Cities
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        MERGE ODS_Cities AS TARGET
        USING (
            SELECT city_id, city_name, state_id
            FROM AZURE_DB.Gaming_Platform.dbo.cities
        ) AS SOURCE
        ON TARGET.city_id = SOURCE.city_id

        -- 1️⃣ New
        WHEN NOT MATCHED THEN
            INSERT (city_id, city_name, state_id, Row_State)
            VALUES (SOURCE.city_id, SOURCE.city_name, SOURCE.state_id, 1)

        -- 2️⃣ Updated
        WHEN MATCHED AND (
            ISNULL(TARGET.city_name,'') <> ISNULL(SOURCE.city_name,'')
            OR ISNULL(TARGET.state_id,'') <> ISNULL(SOURCE.state_id,'')
        ) THEN
            UPDATE SET
                TARGET.city_name = SOURCE.city_name,
                TARGET.state_id = SOURCE.state_id,
                TARGET.Row_State = 2

        -- 3️⃣ Deleted
        WHEN NOT MATCHED BY SOURCE THEN
            UPDATE SET TARGET.Row_State = 3;

        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;

--------------Load_ODS_User_Location------------------
CREATE OR ALTER PROCEDURE Load_ODS_User_Location
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        MERGE ODS_User_Location AS TARGET
        USING (
            SELECT *
            FROM AZURE_DB.Gaming_Platform.dbo.user_location
        ) AS SOURCE
        ON TARGET.user_id = SOURCE.user_id
           AND TARGET.city_id = SOURCE.city_id

        -- 1️ New relation
        WHEN NOT MATCHED THEN
            INSERT (user_id, city_id, Row_State)
            VALUES (SOURCE.user_id, SOURCE.city_id, 1)

        -- 2️ User changed city (important case)
        WHEN MATCHED AND ISNULL(TARGET.city_id,'') <> ISNULL(SOURCE.city_id,'') THEN
            UPDATE SET
                TARGET.city_id = SOURCE.city_id,
                TARGET.Row_State = 2

        -- 3️ Deleted relation
        WHEN NOT MATCHED BY SOURCE THEN
            UPDATE SET TARGET.Row_State = 3;

        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;

--------------Load_Ods_User_Contact------------------
CREATE OR ALTER PROCEDURE Load_ODS_User_Contact
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        MERGE ODS_User_Contact AS TARGET
        USING (
            SELECT user_id, email, phone
            FROM AZURE_DB.Gaming_Platform.dbo.user_contact
        ) AS SOURCE
        ON TARGET.user_id = SOURCE.user_id

        -- 1️ New user contact
        WHEN NOT MATCHED THEN
            INSERT (user_id, email, phone, Row_State)
            VALUES (SOURCE.user_id, SOURCE.email, SOURCE.phone, 1)

        -- 2️ Updated contact info
        WHEN MATCHED AND (
            ISNULL(TARGET.email,'') <> ISNULL(SOURCE.email,'')
            OR ISNULL(TARGET.phone,'') <> ISNULL(SOURCE.phone,'')
        ) THEN
            UPDATE SET
                TARGET.email = SOURCE.email,
                TARGET.phone = SOURCE.phone,
                TARGET.Row_State = 2

        -- 3️ Deleted user contact
        WHEN NOT MATCHED BY SOURCE THEN
            UPDATE SET TARGET.Row_State = 3;

        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;

--------------Load_Ods_User_Activity------------------
CREATE OR ALTER PROCEDURE Load_Ods_User_Activity
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        MERGE Ods_User_Activity AS TARGET
        USING (
            SELECT *
            FROM AZURE_DB.Gaming_Platform.dbo.user_activity
        ) AS SOURCE
        ON TARGET.user_id = SOURCE.user_id

        -- 1️ New user contact
        WHEN NOT MATCHED THEN
            INSERT (user_id, created_at, Row_State)
            VALUES (SOURCE.user_id, SOURCE.created_at, 1)

        -- 2️ Updated contact info
        WHEN MATCHED AND (
            ISNULL(TARGET.created_at,'') <> ISNULL(SOURCE.created_at,'')
        ) THEN
            UPDATE SET
                TARGET.created_at = SOURCE.created_at,
                TARGET.Row_State = 2

        -- 3️ Deleted user contact
        WHEN NOT MATCHED BY SOURCE THEN
            UPDATE SET TARGET.Row_State = 3;

        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;

--------------Load_Ods_Game_Genres------------------
CREATE OR ALTER PROCEDURE Load_ODS_Game_Genres
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        MERGE ODS_Game_Genres AS T
        USING (
            SELECT game_id, genre
            FROM AZURE_DB.Gaming_Platform.dbo.game_genres
        ) AS S
        ON T.game_id = S.game_id
        AND T.genre = S.genre

        -- 1️ New
        WHEN NOT MATCHED THEN
            INSERT (game_id, genre, Row_State)
            VALUES (S.game_id, S.genre, 1)

        -- 2 Soft Delete
        WHEN NOT MATCHED BY SOURCE THEN
            UPDATE SET 
                T.Row_State = 3;

        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;

--------------Load_ODS_Game_Prices------------------
CREATE OR ALTER PROCEDURE Load_ODS_Game_Prices
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        MERGE ODS_Game_Prices AS T
        USING (
            SELECT *
            FROM AZURE_DB.Gaming_Platform.dbo.game_prices
        ) AS S
        ON T.game_id = S.game_id

        -- 1️ New
        WHEN NOT MATCHED THEN
            INSERT (game_id, price, discount_percentage, tax_percentage, Row_State)
            VALUES (S.game_id, S.price, S.discount_percentage, S.tax_percentage, 1)

        -- 2️ Update (price or discount or tax changed)
        WHEN MATCHED AND (
            ISNULL(T.price,0) <> ISNULL(S.price,0)
            OR ISNULL(T.discount_percentage,'') <> ISNULL(S.discount_percentage,'')
            OR ISNULL(T.tax_percentage,'') <> ISNULL(S.tax_percentage,'')
        ) THEN
            UPDATE SET
                T.price = S.price,
                T.discount_percentage = S.discount_percentage,
                T.tax_percentage = S.tax_percentage,
                T.Row_State = 2

        -- 3️ Soft Delete
        WHEN NOT MATCHED BY SOURCE THEN
            UPDATE SET T.Row_State = 3;

        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;

--------------Load_Ods_Game_Metadata------------------
CREATE OR ALTER PROCEDURE Load_ODS_Game_Metadata
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        MERGE ODS_Game_Metadata AS T
        USING (
            SELECT *
            FROM AZURE_DB.Gaming_Platform.dbo.game_metadata
        ) AS S
        ON T.game_id = S.game_id

        -- 1️ New
        WHEN NOT MATCHED THEN
            INSERT (game_id, release_date, platform, rating, Row_State)
            VALUES (S.game_id, S.release_date, S.platform, S.rating, 1)

        -- 2️ Update (any attribute changed)
        WHEN MATCHED AND (
            ISNULL(T.release_date,'') <> ISNULL(S.release_date,'')
            OR ISNULL(T.platform,'') <> ISNULL(S.platform,'')
            OR ISNULL(T.rating,'') <> ISNULL(S.rating,'')
        ) THEN
            UPDATE SET
                T.release_date = S.release_date,
                T.platform = S.platform,
                T.rating = S.rating,
                T.Row_State = 2

        -- 3️ Soft Delete
        WHEN NOT MATCHED BY SOURCE THEN
            UPDATE SET T.Row_State = 3;

        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;

--------------Load_Ods_Game_Titles------------------
CREATE OR ALTER PROCEDURE Load_ODS_Game_Titles
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        MERGE ODS_Game_Titles AS T
        USING (
            SELECT *
            FROM AZURE_DB.Gaming_Platform.dbo.game_titles
        ) AS S
        ON T.game_id = S.game_id

        -- 1️ New
        WHEN NOT MATCHED THEN
            INSERT (game_id, game_name, Row_State)
            VALUES (S.game_id, S.game_name, 1)

        -- 2️ Update (game name changed)
        WHEN MATCHED AND (
            ISNULL(T.game_name,'') <> ISNULL(S.game_name,'')
        ) THEN
            UPDATE SET
                T.game_name = S.game_name,
                T.Row_State = 2

        -- 3️ Soft Delete
        WHEN NOT MATCHED BY SOURCE THEN
            UPDATE SET T.Row_State = 3;

        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;

--------------Load_Ods_Game_Sessions------------------
CREATE OR ALTER PROCEDURE Load_ODS_Game_Sessions
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        MERGE ODS_Game_Sessions AS T
        USING (
            SELECT *
            FROM AZURE_DB.Gaming_Platform.dbo.game_sessions
        ) AS S
        ON T.session_id = S.session_id

        -- 1️ New session
        WHEN NOT MATCHED THEN
            INSERT (
                session_id,
                user_id,
                game_id,
                hours_played,
                session_date,
                device_type,
                Row_State
            )
            VALUES (
                S.session_id,
                S.user_id,
                S.game_id,
                S.hours_played,
                S.session_date,
                S.device_type,
                1
            )

        -- 2️ Update 
        WHEN MATCHED AND (
            ISNULL(T.hours_played,'') <> ISNULL(S.hours_played,'')
            OR ISNULL(T.device_type,'') <> ISNULL(S.device_type,'')
        ) THEN
            UPDATE SET
                T.hours_played = S.hours_played,
                T.device_type = S.device_type,
                T.Row_State = 2

        -- 3️ Soft Delete (optional)
        WHEN NOT MATCHED BY SOURCE THEN
            UPDATE SET T.Row_State = 3;

        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;

--------------Load_Ods_Oredrs------------------
CREATE OR ALTER PROCEDURE Load_ODS_Orders
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        MERGE ODS_Orders AS T
        USING (
            SELECT *
            FROM AZURE_DB.Gaming_Platform.dbo.orders
        ) AS S
        ON T.order_id = S.order_id

        -- 1️ New
        WHEN NOT MATCHED THEN
            INSERT (
                order_id,
                user_id,
                game_id,
                game_name,
                genre,
                country,
                order_date,
                price,
                quantity,
                discount_amount,
                tax_amount,
                total_amount,
                is_refunded,
                refund_date,
                payment_method,
                Row_State
            )
            VALUES (
                S.order_id,
                S.user_id,
                S.game_id,
                S.game_name,
                S.genre,
                S.country,
                S.order_date,
                S.price,
                S.quantity,
                S.discount_amount,
                S.tax_amount,
                S.total_amount,
                S.is_refunded,
                S.refund_date,
                S.payment_method,
                1
            )

        -- 2️ Update (ANY column change)
        WHEN MATCHED AND (
            ISNULL(T.user_id,'') <> ISNULL(S.user_id,'')
            OR ISNULL(T.game_id,'') <> ISNULL(S.game_id,'')
            OR ISNULL(T.game_name,'') <> ISNULL(S.game_name,'')
            OR ISNULL(T.genre,'') <> ISNULL(S.genre,'')
            OR ISNULL(T.country,'') <> ISNULL(S.country,'')
            OR ISNULL(T.order_date,'') <> ISNULL(S.order_date,'')
            OR ISNULL(T.price,'') <> ISNULL(S.price,'')
            OR ISNULL(T.quantity,'') <> ISNULL(S.quantity,'')
            OR ISNULL(T.discount_amount,'') <> ISNULL(S.discount_amount,'')
            OR ISNULL(T.tax_amount,'') <> ISNULL(S.tax_amount,'')
            OR ISNULL(T.total_amount,'') <> ISNULL(S.total_amount,'')
            OR ISNULL(T.is_refunded,'') <> ISNULL(S.is_refunded,'')
            OR ISNULL(T.refund_date,'') <> ISNULL(S.refund_date,'')
            OR ISNULL(T.payment_method,'') <> ISNULL(S.payment_method,'')
        ) THEN
            UPDATE SET
                T.user_id = S.user_id,
                T.game_id = S.game_id,
                T.game_name = S.game_name,
                T.genre = S.genre,
                T.country = S.country,
                T.order_date = S.order_date,
                T.price = S.price,
                T.quantity = S.quantity,
                T.discount_amount = S.discount_amount,
                T.tax_amount = S.tax_amount,
                T.total_amount = S.total_amount,
                T.is_refunded = S.is_refunded,
                T.refund_date = S.refund_date,
                T.payment_method = S.payment_method,
                T.Row_State = 2

        -- 3️ Soft Delete
        WHEN NOT MATCHED BY SOURCE THEN
            UPDATE SET T.Row_State = 3;

        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;

--------------Load_Ods_Trophies------------------
CREATE OR ALTER PROCEDURE Load_ODS_Trophies
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        MERGE ODS_Trophies AS T
        USING (
            SELECT user_id, game_id, trophy_name, trophy_type, earned_date
            FROM AZURE_DB.Gaming_Platform.dbo.trophies
        ) AS S
        ON T.user_id = S.user_id
           AND T.game_id = S.game_id
           AND T.trophy_name = S.trophy_name

        -- 1️ New trophy earned
        WHEN NOT MATCHED THEN
            INSERT (
                user_id,
                game_id,
                trophy_name,
                trophy_type,
                earned_date,
                Row_State
            )
            VALUES (
                S.user_id,
                S.game_id,
                S.trophy_name,
                S.trophy_type,
                S.earned_date,
                1
            )

        -- 2️ Update (rare – correction in metadata/date)
        WHEN MATCHED AND (
            ISNULL(T.trophy_type,'') <> ISNULL(S.trophy_type,'')
            OR ISNULL(T.earned_date,'') <> ISNULL(S.earned_date,'')
        ) THEN
            UPDATE SET
                T.trophy_type = S.trophy_type,
                T.earned_date = S.earned_date,
                T.Row_State = 2

        -- 3️ Soft delete
        WHEN NOT MATCHED BY SOURCE THEN
            UPDATE SET T.Row_State = 3;

        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;

--------------Load_Ods_Trophies------------------
CREATE OR ALTER PROCEDURE Load_ODS_Trophies
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        MERGE ODS_Trophies AS T
        USING (
            SELECT user_id, game_id, trophy_name, trophy_type, earned_date
            FROM AZURE_DB.Gaming_Platform.dbo.trophies
        ) AS S
        ON  T.user_id = S.user_id
        AND T.game_id = S.game_id
        AND T.trophy_name = S.trophy_name
        AND T.trophy_type = S.trophy_type
        AND T.earned_date = S.earned_date

        -- 1️ New
        WHEN NOT MATCHED THEN
            INSERT (
                user_id,
                game_id,
                trophy_name,
                trophy_type,
                earned_date,
                Row_State
            )
            VALUES (
                S.user_id,
                S.game_id,
                S.trophy_name,
                S.trophy_type,
                S.earned_date,
                1
            )

        -- 2️ Soft Delete
        WHEN NOT MATCHED BY SOURCE THEN
            UPDATE SET 
                T.Row_State = 3;

        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;