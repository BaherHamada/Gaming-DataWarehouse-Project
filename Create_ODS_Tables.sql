-- Create ODS_Countries Table
CREATE TABLE ODS_Countries (
    country_id    VARCHAR(50) NOT NULL,
    country_name  VARCHAR(50) NULL,
    region        VARCHAR(50) NULL,
    Row_State     INT NULL DEFAULT 1
);
SELECT * FROM ODS_Countries

-- Create ODS_States Table
CREATE TABLE ODS_States (
    state_id    VARCHAR(50) NOT NULL,
    state_name  VARCHAR(50) NULL,
    country_id  VARCHAR(50) NULL,
    Row_State   INT NULL DEFAULT 1
);
SELECT * FROM ODS_States 

-- Create ODS_Cities Table
CREATE TABLE ODS_Cities (
    city_id    VARCHAR(50) NOT NULL,
    city_name  VARCHAR(50) NULL,
    state_id   VARCHAR(50) NULL,
    Row_State  INT NULL DEFAULT 1
);
SELECT * FROM ODS_Cities 

-- Create ODS_User_location Table
CREATE TABLE ODS_User_location (
    user_id    VARCHAR(50) NULL,
    city_id    VARCHAR(50) NULL,
    Row_State   INT NULL DEFAULT 1
);
SELECT * FROM ODS_User_location


-- Create ODS_User_Contact Table
CREATE TABLE ODS_User_Contact (
    user_id    VARCHAR(50) NULL,
    email      VARCHAR(50) NULL,
    phone      VARCHAR(50) NULL,
    Row_State  INT NULL DEFAULT 1
);
SELECT * FROM ODS_User_Contact 


-- Create ODS_User_Activity Table
CREATE TABLE ODS_User_Activity (
    user_id    VARCHAR(50) NULL,
    created_at VARCHAR(50) NULL,
    Row_State  INT NULL DEFAULT 1
);
SELECT * FROM ODS_User_Activity 

-- Create ODS_User_Basic Table
CREATE TABLE ODS_User_Basic (
    user_id    VARCHAR(50) NOT NULL,
    username  VARCHAR(50) NULL,
    status     VARCHAR(50) NULL,
    Row_State  INT NULL DEFAULT 1
);
SELECT * FROM ODS_User_Basic 

-- Create ODS_Game_Genres Table
CREATE TABLE ODS_Game_Genres (
    game_id    VARCHAR(50) NULL,
    genre      VARCHAR(50) NULL,
    Row_State  INT NULL DEFAULT 1
);
SELECT * FROM ODS_Game_Genres 

-- Create ODS_Game_Prices Table
CREATE TABLE ODS_Game_Prices (
    game_id             VARCHAR(50) NULL,
    price               VARCHAR(50) NULL,
    discount_percentage VARCHAR(50) NULL,
    tax_percentage      VARCHAR(50) NULL,
    Row_State           INT NULL DEFAULT 1
);
SELECT * FROM ODS_Game_Prices 

-- Create ODS_Game_Metadata Table
CREATE TABLE ODS_Game_Metadata (
    game_id      VARCHAR(50) NULL,
    release_date VARCHAR(50) NULL,
    platform     VARCHAR(50) NULL,
    rating       VARCHAR(50) NULL,
    Row_State    INT NULL DEFAULT 1
);
SELECT * FROM ODS_Game_Metadata 

-- Create ODS_Game_Titles Table
CREATE TABLE ODS_Game_Titles (
    game_id    VARCHAR(50) Not NULL,
    game_name      VARCHAR(50) NULL,
    Row_State  INT NULL DEFAULT 1
);
SELECT * FROM ODS_Game_Titles 

-- Create ODS_Game_Sessions Table
CREATE TABLE ODS_Game_Sessions (
    session_id    VARCHAR(50) Not NULL,
    user_id       VARCHAR(50) NULL,
    game_id       VARCHAR(50) NULL,
    hours_played  VARCHAR(50) NULL,
    session_date  VARCHAR(50) NULL,
    device_type   VARCHAR(50) NULL,
    Row_State     INT NULL DEFAULT 1
);
SELECT * FROM ODS_Game_Sessions 


-- Create ODS_Orders Table
CREATE TABLE ODS_Orders (
    order_id           VARCHAR(50) NOT NULL,
    user_id            VARCHAR(50) NULL,
    game_id            VARCHAR(50) NULL,
    game_name          VARCHAR(255) NULL,
    genre              VARCHAR(100) NULL,
    country            VARCHAR(100) NULL,
    order_date         VARCHAR(50) NULL,
    price              VARCHAR(50) NULL,
    quantity           VARCHAR(50) NULL,
    discount_amount    VARCHAR(50) NULL,
    tax_amount         VARCHAR(50) NULL,
    total_amount       VARCHAR(50) NULL,
    is_refunded        VARCHAR(10) NULL,
    refund_date        VARCHAR(50) NULL,
    payment_method     VARCHAR(50) NULL,
    Row_State          INT         NULL
);
SELECT * FROM ODS_Orders 

-- Create ODS_Trophies Table
CREATE TABLE ODS_Trophies (
    user_id       VARCHAR(50)  NULL,
    game_id       VARCHAR(50)  NULL,
    trophy_name   VARCHAR(255) NULL,
    trophy_type   VARCHAR(100) NULL,
    earned_date   VARCHAR(50)  NULL,
    Row_State     INT
);

SELECT * FROM ODS_Trophies

-- Valid the Bridge Table case
SELECT game_id, COUNT(*)
FROM ODS_Game_Genres
GROUP BY game_id