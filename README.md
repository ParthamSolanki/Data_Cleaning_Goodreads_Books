# Data cleaning project

This is a data cleaning project using goodreads books dataset from kaggle.

[Link for the dataset](https://www.kaggle.com/datasets/jealousleopard/goodreadsbooks)

We are going to go through the data and make it more workable. I will also describe the steps as I am going through the query.

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

This is all we are going to do in this project to get the data to a more usable format.
