# Gaming Data Warehouse & Business Intelligence Project

Enterprise-style Gaming Data Warehouse and Analytics solution built using:

- Microsoft SQL Server
- SQL Server Integration Services (SSIS)
- SQL Server Analysis Services (SSAS)
- Microsoft Power BI

---

# 🚀 Project Overview

This project simulates a real-world gaming analytics platform that processes and analyzes:

- Game sales transactions
- Gameplay sessions
- Trophy achievements
- Player activity
- Revenue and refund analytics

The solution follows a complete Data Warehouse lifecycle starting from raw source data ingestion to interactive dashboards and analytical reporting.

---

# 🏗️ Architecture

```text
Source System
   ↓
ODS Layer
   ↓
STG Layer
   ↓
Data Warehouse (Star Schema)
   ↓
SSAS Semantic Model
   ↓
Power BI Dashboards
```

---

# 📂 Project Components

## 1. ODS Layer

Created Operational Data Store tables with:

- Incremental loading
- MERGE-based synchronization
- Row state tracking:
  - `1 = Insert`
  - `2 = Update`
  - `3 = Delete`
- Soft delete handling
- Change detection logic

ODS tables include:

- ODS_Countries 
- ODS_Cities
- ODS_States
- ODS_User_location
- ODS_User_Activity
- ODS_User_Contact
- ODS_User_Basic
- ODS_Game_Genres
- ODS_Game_Prices
- ODS_Game_Metadata
- ODS_Game_Titles
- ODS_Game_Sessions
- ODS_Orders
- ODS_Trophies


---

## 2. Source & Staging Layer (STG)

- Imported raw gaming platform datasets
- Created staging tables for:
  
  - STG_Countries 
  - STG_States
  - STG_CITIES
  - STG_User_Location
  - STG_User_Contact 
  - STG_User_Activity
  - STG_User_Basic 
  - STG_User_Info 
  - STG_GAME_TITLES
  - STG_GAME_genres
  - stg_game_prices
  - stg_game_metadata
  - STG_Game_Info 
  - stg_game_info_N   
  - STG_SALES 
  - STG_Payment_Method
  - STG_GAME_SESSIONS 
  - STG_Device_Type
  - stg_trophies
  - STG_D_Trophy

    
- Implemented data cleansing and standardization logic
- Handled:
  - NULL values
  - Empty strings
  - Duplicate records
  - Invalid values
  - Text trimming and formatting

---

## 3. Data Warehouse Layer (DWH)

Designed and implemented a complete Star Schema model.

### Dimensions

- DIM_User_Info
- DIM_Game_Info
- DIM_Trophy_Info
- DIM_Device_Type
- DIM_Payment_Method
- DIM_Date

### Fact Tables

- FACT_SALES
- FACT_GAME_PLAY
- FACT_TROPHIES

---

# ⚙️ ETL & Data Engineering Features

Implemented advanced ETL logic using SSIS and SQL Stored Procedures:

- Incremental loading
- MERGE operations
- Validation logging
- Soft delete implementation
- Start_Date / End_Date tracking
- Default/Unknown dimension members (`SK = -1`)
- Surrogate key generation using `IDENTITY`
- Data quality validation
- Lookup handling
- Fact-Dimension mapping
- Aggregation logic for gameplay and trophies

---

# 🧾 Validation & Logging

Implemented centralized validation logging using:

- `Dim_Validation_Log`

Logs include:
- Missing dimension references
- Invalid business keys
- ETL validation failures
- Fact-to-dimension mapping issues

---

# 📊 SSAS Semantic Model

Built analytical semantic models using SSAS including:

- Relationships
- Hierarchies
- Calculated columns
- KPIs
- Measures

---

# 📈 Power BI Dashboards

Created interactive dashboards for:

## Orders Dashboard
- Revenue analysis
- Refund analysis
- Payment method analysis
- Sales trends
- Revenue categories

## Gameplay Dashboard
- Gameplay hours analysis
- Active players tracking
- Device/platform analysis
- Player activity segmentation

## Trophies & Leaderboard Dashboard
- Trophy distribution analysis
- Trophy type analytics
- Player leaderboard
- Top games by trophies
- Average trophies per player

---

# 📌 Key DAX Measures

Implemented multiple analytical measures including:

- Total Sales Amount
- Net Revenue
- Average Order Value
- Refund Rate %
- Total Gameplay Hours
- Active Players
- Total Trophies Earned
- Players with Trophies
- Average Trophies per Player
- Revenue per User
- Distinct Trophy Types Earned

---

# 🎛️ Dashboard Features

Implemented advanced Power BI features:

- Bookmarks
- Navigation menus
- Hover effects
- Filter panel
- Dynamic slicers
- Interactive drill-downs
- Responsive layouts

---

# 🔍 Slicers & Filters

Implemented filtering by:

- Date
- Year / Quarter / Month
- Game Name
- Genre
- Platform
- Country
- State
- City
- User
- Refund Status
- Payment Method
- Trophy Type
- Trophy Name
- Player Activity Level
- Revenue Category

---

# 🛠️ Technologies Used

- SQL Server
- T-SQL
- SSIS
- SSAS
- Power BI
- DAX
- GitHub

---

# 📚 Concepts Applied

- Data Warehousing
- Star Schema Modeling
- Fact & Dimension Design
- ETL Pipelines
- Incremental Loading
- Data Validation
- Business Intelligence
- Semantic Modeling
- Data Visualization

---

# 🎯 Project Outcomes

- Built a complete enterprise-style BI solution
- Designed scalable ETL pipelines
- Implemented analytical reporting workflows
- Developed interactive business dashboards
- Applied real-world Data Warehouse concepts and best practices

---

# 👨‍💻 Author

Baher Hamada
