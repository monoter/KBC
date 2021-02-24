
----------------------------------------------------------------------
----------------------------------------------------------------------
------TASK 1 -------@MATUS BALUCH----02/2021--------------------------
--------------------FOR KBC HIRING PURPOSES---------------------------
----------------------------------------------------------------------

CREATE VIEW task1
AS
SELECT COMPANY_NUMBER, COMPANY_NAME, PRODUCT_NAME, PRODUCT_CODE
FROM (
SELECT PRODUCT_CODE, PRODUCT_NAME, COMPANY_NAME, COMPANY_NUMBER 
FROM (
    SELECT *
    FROM (
        SELECT DISTINCT * 
        FROM company
        ORDER BY EXTRACTION_DATE DESC
        )
    GROUP BY COMPANY_NUMBER
    )
     
JOIN
    (
    SELECT COMPANY_CODE AS COMPANY, PRODUCT_CODE AS PRODUCT
    FROM bridge 
    WHERE bridge.END_DATE >'2021-21-24' OR bridge.END_DATE IS NULL
    )    
    
ON COMPANY_NUMBER = COMPANY

JOIN
    (
    SELECT DISTINCT *
    FROM products
    WHERE END_DATE > '2021-21-02' OR END_DATE IS NULL
    )
ON PRODUCT_CODE = PRODUCT
    )
;



----------------------------------------------------------------------
----------------------------------------------------------------------
------TASK 2 -------@MATUS BALUCH----02/2021--------------------------
--------------------FOR KBC HIRING PURPOSES---------------------------
----------------------------------------------------------------------

--1----------------CREATE VIEW WITH ALL NECESSARY INFORMATION---------
----JOIN sales table &  (uptodate)company table & exchange rate table-
--------------------create a view-------------------------------------

CREATE VIEW company_sales_view
AS
SELECT PRODUCT_CODE, COMPANY_CODE, COMPANY_NAME, VOLUME,EXCH_RATE
FROM sales
JOIN (
    SELECT *
    FROM (
    SELECT DISTINCT * 
    FROM company
    ORDER BY EXTRACTION_DATE DESC
    )
    GROUP BY COMPANY_NUMBER
     )
ON COMPANY_CODE = COMPANY_NUMBER
JOIN exchange_rate_to_eur
ON sales.CURRENCY = exchange_rate_to_eur.CURRENCY
;
                

--2----------RECOUNT TO EUR FOR SINFULL TRESHOLDING------
------------------table for recounting definition-----------

CREATE TABLE company_sales_table (
PRODUCT_CODE STRING,
COMPANY_NUMBER STRING,
COMPANY_NAME STING,
VOLUME STRING,
EXCH_RATE
)
;



--3----------insert data from view into table-----------------

INSERT INTO company_sales_table
SELECT * FROM company_sales_view
; 

--4---------------recounting into EUR-----------------
UPDATE company_sales_table
SET VOLUME =
(CASE
    WHEN EXCH_RATE <> 1.0 THEN VOLUME*EXCH_RATE
    ELSE VOLUME
 END
)
;
 
--5-------------GROUP BY PRODUCT_CODE & COMPANY_NAME, AGGREGATE-------
CREATE VIEW grouped_sales_view
AS
SELECT PRODUCT_CODE, COMPANY_NUMBER, COMPANY_NAME, SUM(VOLUME) SELLS
FROM company_sales_table
GROUP BY PRODUCT_CODE, COMPANY_NAME
;

-----------------Table for sells update---------

--6---------------final-table-definition-------

CREATE TABLE company_sells (
PRODUCT_CODE STRING,
COMPANY_NUMBER STRING,
COMPANY_NAME STING,
SELLS STRING
)
;

--7--copy grouped view into

INSERT INTO company_sells
SELECT * FROM grouped_sales_view
; 


--8-------update-------------------

UPDATE company_sells
SET SELLS =
(CASE
   
    WHEN SELLS = 0 THEN 'No sells'   
    WHEN SELLS > 200000 THEN 'High sells' 
    WHEN SELLS < 4001 THEN 'Low sells'
    ELSE 'Medium sells'    
    
END
)
;

--9-----task 2 final retrieve----------

CREATE VIEW task2
AS 
SELECT COMPANY_NUMBER, COMPANY_NAME, PRODUCT_CODE, SELLS
FROM company_sells;
;


 
--X--delete temporary tables&views-----------

DROP TABLE company_sales_table;
DROP VIEW company_sales_view;
DROP VIEW grouped_sales_view;
--------------------------------------------------------
