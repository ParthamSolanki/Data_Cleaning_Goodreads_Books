# Create a copy of the raw data
CREATE TABLE books_c
LIKE books;

# Insert data from books to books_c
INSERT INTO books_c
SELECT *
FROM books;

# Checking if data is imported
SELECT *
FROM books_c;

# Checking for duplicates
WITH duplicate_cte AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY title, authors) AS row_num
FROM books_c
)
SELECT *
FROM duplicate_cte
WHERE row_num>1;

# Checking a couple of the entries to see if they are actually duplicates
SELECT *
FROM books_c
WHERE title = "Gravity's Rainbow";

# Checking one more
SELECT *
FROM books_c
WHERE title = "The Lovely Bones";

# We see that the books are from the same publisher, with same rating and just that the edition seems to be different by observing the publication date.
# So we can either include the publisher too in the PARTITION BY to account for this or just remove the older edition, but you need to confirm this with someone before actually deleing the rows.
# Also some titles have different publishers too. So we can either keep the entries separate or remove the ones with lower ratings and reviews count as they have lesser traction or you can also remove based on other parameters.
# Adding publisher too
WITH duplicate_cte AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY title, authors, publisher) AS row_num
FROM books_c
)
SELECT *
FROM duplicate_cte
WHERE row_num>1;

# By doing this we know that the book titled - Gravity's Rainbow is the only one with same publisher.
# So we will be deleting this using a query rather than just dropping this specific row which can also be done manually as there is only one entry.

# Deleting the one with lower ratings and review count here
DELETE
FROM books_c
WHERE bookID = '412';

# To do this stuff automatically using a query, say you just want to remove the ones where row_num is greater than 1. You can either create a new table with all the data and an additional row being row_num or just add this new column in this table.
# We can't delete straight from CTE as CTE is temporary and can't be used as a reference for updating the table.

WITH duplicate_cte AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY title, authors, publisher) AS row_num
FROM books_c
)
DELETE
FROM duplicate_cte
WHERE row_num>1;

# The code above will produce an error.

# Making a new table with row_num too and then deleting based on it.
CREATE TABLE books_2
LIKE books_c;

# Altering the table to have the row_num column.
ALTER TABLE books_2
ADD COLUMN row_num INT;

# Inserting data from the books_c to books_2 and populating the row_num
INSERT INTO books_2
SELECT *, ROW_NUMBER() OVER(PARTITION BY title, authors, publisher) AS row_num
FROM books_c;

# Deleting rows with roW_num > 1, you should also do SELECT * instead of DELETE to confirm that the data you are going to change is the correct one.
DELETE
FROM books_2
WHERE row_num > 1;

# Checking for duplicates to make sure.
SELECT *
FROM books_2
WHERE row_num>1;

# The other way was to self join the table and populate the row_num columns.

# Adding the column into the table
ALTER TABLE books_c
ADD COLUMN row_num INT;

# Populating the row_num column with data.
UPDATE books_c AS t1
JOIN (
SELECT bookID, ROW_NUMBER() OVER(PARTITION BY title, authors, publisher) AS row_num
FROM books_c
) AS t2 ON t1.bookID = t2.bookID
SET t1.row_num = t2.row_num;
# Here essentially we are self joining the table and updating the row_num with the newly created row_num

# Viewing if the changes have taken effect and checking for duplicated
SELECT *
FROM books_c
WHERE row_num > 1;

# You can delete the entries here too in the similar way as in the other method.
DELETE
FROM books_c
WHERE row_num > 1;

# Dropping the row_num table as it is no longer needed. Going forward we are going to work only with books_copy, as books_2 was just a copy to demonstrate the other method. You can also keep only the duplicate entries in other tables or the ones you are going to delete by doing DELETE WHERE row_num = 1.

ALTER TABLE books_c
DROP COLUMN row_num;

# From here one we are going to standardize the data, like removing trailing or leading spaces and stuff like that.

# Using the DISTINCT we can find if there are multiple names assigned to the same stuff.
SELECT DISTINCT authors
FROM books_c
ORDER BY authors;
# There are couple of entries where the author is repeated but they also have some accompanying authors so we will just leave them be.
# There are also a couple of entries with gibberish as a the name which may be due to the name being in some other language so we are quickly going to change them as we go.

SELECT authors, bookID
FROM books_c
WHERE authors LIKE 'Richard%'
OR authors LIKE 'Kahlil%'
OR authors LIKE 'Jean Gibran%'
OR authors LIKE 'Henry Miller%'; # Has some gibberish.

UPDATE books_c
SET authors = 'Richard Farina/Thomas Pynchon'
WHERE authors LIKE 'Richard%';

UPDATE books_c
SET authors = 'Khalil Gibran'
WHERE bookID = '290' OR bookID = '292';

UPDATE books_c
SET authors = 'Khalil Gibran/Anthony Rizcallah Ferris'
WHERE bookID = '291';

UPDATE books_c
SET authors = 'Henry Miller'
WHERE bookID = '249';

UPDATE books_c
SET authors = 'Jean Gibran/Khalil Gibran'
WHERE bookID = '288';

# Checking if some of the stuff is out of order.
SELECT bookID
FROM books_c
ORDER BY bookID;
SELECT bookID
FROM books_c
ORDER BY bookID DESC; # Looks fine.

SELECT DISTINCT average_rating
FROM books_c
ORDER BY average_rating; # Looks fine.

SELECT DISTINCT language_code
FROM books_c; # Looks good, can condense various english ones to one but not specifically needed.

# Trimming some columns just in case there are leading or trailing spaces.
UPDATE books_c
SET
	title = TRIM(title),
    authors = TRIM(authors),
    publisher = TRIM(publisher);

# Checking for NULL or blank values, one way is to use DISTINCT on each column and order by asc and desc and see or you can just use WHERE on each column and find out.
SELECT *
FROM books_c
WHERE bookID IS NULL OR bookID = ' '
OR title IS NULL OR title = ' '
OR authors IS NULL OR authors = ' '
OR language_code IS NULL OR language_code = ' '
OR num_pages IS NULL OR num_pages = ' '
OR publisher IS NULL OR publisher = ' ';
# No null rows so no need to update anything, you can also check other columns.

# Checking if dates are in correct datatype
DESCRIBE books_c;

# We find that the publication_date is in text datatype, so changing it to date datatype is advisable

# Checking format to change, the format seems to be MM/DD/YYYY
SELECT `publication_date`, STR_TO_DATE (`publication_date`, '%m/%d/%Y')
FROM books_c;
# I like the change of YYYY-MM-DD. So will UPDATE it to the table.

UPDATE books_c
SET `publication_date` = STR_TO_DATE (`publication_date`, '%m/%d/%Y');

# Now changing the data type of the column
ALTER TABLE books_c
MODIFY COLUMN `publication_date` DATE;

# Recheck using the DESCRIBE query.

# Most of the data cleaning is done.