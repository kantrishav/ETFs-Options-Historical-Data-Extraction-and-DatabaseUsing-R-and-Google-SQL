# Option-Historical-Data-Extraction-and-Using-Google-Cloud-and-R
This project aims to develop a robust data extraction and storage system for historical options data related to 33 Exchange Traded Funds (ETFs). The data will be sourced from the Chicago Board Options Exchange (CBOE) website, processed using the R programming language, and stored in a Google Cloud SQL database for efficient analysis and retrieval.

![image](https://github.com/kantrishav/Options-Historical-Data-Extraction-and-DatabaseUsing-Google-Cloud-and-R/assets/28995985/dfcb44e8-39f2-46bb-8520-c1254a7a5f93)

# Data Extraction from CBOE:

Developed a web scraping solution using R to systematically extract historical options data from the CBOE website.
Customized the scraping script to target the options data of 33 specified ETFs.

![image](https://github.com/kantrishav/Options-Historical-Data-Extraction-and-DatabaseUsing-Google-Cloud-and-R/assets/28995985/a4c608ff-9d1a-4ef1-97d4-ef75c473b5b4)


# Data Cleaning and Transformation:

Implemented data cleaning and transformation procedures in R to ensure the accuracy and integrity of the extracted options data.
Handle missing values, outliers, and any anomalies in the data to enhance its quality.
Integration with Google Cloud SQL:

Set up and configure a Google Cloud SQL instance to serve as the central database for storing historical options data.
Establish secure connections between the R environment and Google Cloud SQL using appropriate credentials.

# Database Schema Design:

Designed an efficient database schema that accommodates the structure of historical options data for the selected 33 ETFs.
Define appropriate tables to store essential information, including date, strike price, implied volatility, and other relevant metrics.

# Automation and Scheduling:

Implement automation scripts in R to regularly update the options data in the Google Cloud SQL database.
Utilize scheduling tools to ensure timely and consistent updates, allowing for the availability of the latest information for analysis.
Documentation and Logging:
