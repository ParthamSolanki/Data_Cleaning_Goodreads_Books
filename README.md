# Data cleaning project

This project focuses on cleaning and standardizing the Goodreads Books dataset from Kaggle to make it more suitable for analysis. The process involves identifying and handling duplicates, standardizing text data, and converting data types for better usability.

## Dataset
The dataset used in this project can be found on Kaggle - [Goodreads Books dataset](https://www.kaggle.com/datasets/jealousleopard/goodreadsbooks)

## Tools
- MySQL for all data cleaning operations
- SQL for writing and executing the data manipulation queries

Steps taken on a whole, exact code can be found in the SQLScriptFile.
1. Create a copy table with name `books_c` of the raw file `books` to work with as we should not make changes directly to the source files.
2. Checking for the duplicates using a CTE where we make ROW_NUMBER by using PARTITION BY over unique entries, so every entry where row_num > 1 is a duplicate entry.
3. Checking some entries to see if they are actually duplicate and making change to the PARTITION BY clause to better adapt to the dataset.
4. Deleting the duplicate entries by 2 methods, either can be used.
- Creating a new table, and importing all the data from the books_c table along with a row_num table that was in the CTE, deleting the appropriate entries and then dropping the row_num column.
- Altering the books_c table by adding the row_num column using a self Join, deleting the duplicate entries, then dropping the row_num column.
5. Checking the table's column using DISTINCT and then altering gibberish content if possible.
6. Using TRIM to remove trailing or leading spaces in a couple of the string columns.
7. Checking for NULL and blank entries in a couple of the columns and populating them if needed or possible.
8. Checking datatype of columns and then changing the datatype and format of publication_date from text to date.

## Conclusion
By following these steps, the datasets was transformed into a cleaner and A more reliable format for further analysis, reporting or integration with other datasets.
