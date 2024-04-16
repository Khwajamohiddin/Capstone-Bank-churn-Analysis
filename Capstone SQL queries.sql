CREATE DATABASE CAPSTONE;
USE CAPSTONE;
select * from Customerinfo;
-- --1.What is the distribution of account balance across different regions?--

select 
C.GeographyID ,ROUND(SUM(Bc.balance),2)as Account_balance
from Bank_Churn Bc
join Customerinfo C ON
Bc.CustomerId = C.CustomerId
GROUP BY C.GeographyID;

-- --2.Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)--

SELECT EstimatedSalary,CustomerId from Customerinfo
WHERE QUARTER(Bank_DOJ) = 4
ORDER BY EstimatedSalary desc
LIMIT 5;

-- --3.Calculate the average number of products used by customers who have a credit card. (SQL)--
SELECT AVG(NumOfProducts) AS AverageProducts
from Bank_Churn bc
WHERE HasCrCard = '1';



-- --4.Determine the churn rate by gender for the most recent year in the dataset.
With CTE AS
(SELECT c.GenderID,SUM(Exited) AS churncount
from Bank_Churn bc
join Customerinfo c ON c.CustomerId=bc.CustomerId
GROUP BY GenderID)

SELECT GenderID,SUM(Exited) * 100.0 / COUNT(*) as churnrate
from Bank_Churn bc
join Customerinfo c ON c.CustomerId=bc.CustomerId
GROUP BY GenderID;
 	 
-- --5.Compare the average credit score of customers who have exited and those who remain. (SQL)
SELECT Exited,AVG(CreditScore) AS Avg_credit_score
FROM Bank_Churn
GROUP BY Exited;

-- --6.Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)
SELECT GenderID,
Round(AVG(EstimatedSalary),2) as Avg_estimated_salary,
COUNT(IsActiveMember) as Active_members
FROM Customerinfo c
JOIN Bank_Churn bc ON bc.CustomerId=c.CustomerId
WHERE IsActiveMember ='1'
GROUP BY GenderID
Order by Avg_estimated_salary DESC;

-- --7.Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)???

SELECT 
CASE
WHEN CreditScore BETWEEN 350 AND 579 THEN 'Poor'
WHEN CreditScore BETWEEN 580 AND 669 THEN 'Fair'
WHEN CreditScore BETWEEN 670 AND 739 THEN 'Good'
WHEN CreditScore BETWEEN 740 AND 799 THEN 'Very good'
ELSE 'Excellent'
END AS Credit_Bucket,
ROUND((SUM(Exited)/COUNT(*))*100, 2) AS ExitRate
FROM bank_churn
GROUP BY Credit_Bucket
ORDER BY ExitRate DESC;

-- --8.Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)
SELECT c.GeographyID,COUNT(IsActiveMember) AS Highest_Activecustomer
FROM Customerinfo c
JOIN Bank_Churn bc ON c.CustomerId=bc.CustomerId
WHERE IsActiveMember ='1' AND Tenure >5
GROUP BY c.GeographyID
ORDER BY Highest_Activecustomer DESC;


-- --9.What is the impact of having a credit card on customer churn, based on the available data?
  SELECT HasCrCard,
	   SUM(Exited) * 100 / COUNT(*) AS ChurnRate
FROM bank_churn
GROUP BY HasCrCard
ORDER BY ChurnRate DESC;

-- --10.For customers who have exited, what is the most common number of products they had used?
SELECT NumOfProducts,COUNT(Exited)AS Exitedcust_count
FROM Bank_Churn
WHERE Exited = '1'
GROUP BY NumOfProducts
ORDER BY NumOfProducts ;

-- --11.Examine the trend of customer joining over time and identify any seasonal patterns (yearly or monthly). 
-- --Prepare the data through SQL and then visualize it.???
SELECT YEAR(Bank_DOJ) as 'Yearly',
COUNT(customerID) as CustomerCount,
ROUND(SUM(EstimatedSalary), 0) as Salary
FROM customerinfo
GROUP BY YEAR(Bank_DOJ)
ORDER BY CustomerCount DESC, Salary DESC;

-- --12.Analyze the relationship between the number of products and the account balance for customers who have exited.
SELECT NumOfProducts,ROUND(AVG(Balance),2) AS Avg_acc_balance
FROM Bank_Churn
WHERE Exited='1'
GROUP BY NumOfProducts
ORDER BY NumOfProducts ASC;

-- --13.Identify any potential outliers in terms of balance among customers who have remained with the bank.???
SELECT MAX(Balance) AS Max_outlier,MIN(Balance) AS Min_outlier FROM Bank_Churn
WHERE Exited='0';

-- --14.How many different tables are given in the dataset, out of these tables which table only consist of categorical variables?
-- --"The dataset consists of Two Tables and Bank_Churn table consist of categorial variables--

-- --15.Using SQL, write a query to find out the gender wise average income of male and female in each geography id.
-- --Also rank the gender according to the average value. (SQL)
SELECT 
RANK()OVER(PARTITION BY GeographyID ORDER BY AVG(EstimatedSalary) DESC) AS 'Salary_rank', 
GenderID,GeographyID,
ROUND(AVG(EstimatedSalary),2) AS Average_income
FROM Customerinfo
GROUP BY GenderID,GeographyID;

-- --16.Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).
WITH CTE AS (SELECT bc.Tenure,
CASE
WHEN Age BETWEEN 18 AND 30 THEN 'Young Adults'
WHEN Age BETWEEN 31 AND 50 THEN 'Middle-aged Adults'
ELSE 'Old-aged Adults'
END AS Age_brackets
FROM Customerinfo c
JOIN Bank_Churn bc ON c.CustomerId=bc.CustomerId
WHERE Exited='1')

SELECT AVG(Tenure) AS Avg_tenure,Age_brackets
FROM CTE
GROUP BY Age_brackets
ORDER BY Age_brackets;

-- 19.Rank each bucket of credit score as per the number of customers who have churned the bank.

WITH CTE AS (
SELECT CustomerID,
CASE 
WHEN CreditScore BETWEEN 350 AND 579 THEN 'Poor'
WHEN CreditScore BETWEEN 580 AND 669 THEN 'Fair'
WHEN CreditScore BETWEEN 670 AND 739 THEN 'Good'
WHEN CreditScore BETWEEN 740 AND 799 THEN 'Very good'
ELSE 'Excellent'
END AS Credit_bucket
FROM Bank_Churn)

SELECT COUNT(Exited) AS Exit_rate,CTE.Credit_bucket,
RANK() OVER( ORDER BY COUNT(Exited) DESC) AS 'Rank'
FROM Bank_churn bc
JOIN CTE ON CTE.CustomerId=bc.CustomerId
WHERE Exited = '1'
GROUP BY CTE.Credit_bucket;

-- --20.According to the age buckets find the number of customers who have a credit card.

WITH CTE AS
(SELECT CustomerID,
CASE 
WHEN c.Age BETWEEN 18 AND 30 THEN 'Young Adults'
WHEN c.Age BETWEEN 30 AND 50 THEN 'Middle-aged Adults'
ELSE 'Old-aged Adults'
END AS Agebucket
FROM Customerinfo c)

SELECT 
COUNT(c.CustomerId) AS Customercount,CTE.Agebucket
FROM  Customerinfo c
JOIN CTE ON c.CustomerId=CTE.CustomerId
JOIN Bank_churn bc ON CTE.CustomerId=bc.CustomerId
WHERE HasCrCard ='1'
GROUP BY CTE.Agebucket,HasCrCard;

-- --Also retrieve those buckets that have lesser than average number of credit cards per bucket.
WITH CTE AS
(SELECT CustomerID,
CASE 
WHEN c.Age BETWEEN 18 AND 30 THEN 'Young Adults'
WHEN c.Age BETWEEN 30 AND 50 THEN 'Middle-aged Adults'
ELSE 'Old-aged Adults'
END AS Agebucket
FROM Customerinfo c)
SELECT 
    Agebucket,
    SUM(bc.HasCrCard) AS Customercount
FROM  Bank_Churn bc
INNER JOIN 
    CTE ON CTE.CustomerId = bc.CustomerId
GROUP BY  AgeBucket
HAVING SUM(bc.HasCrCard) < (SELECT AVG(NumCards)
							FROM (SELECT Agebucket, SUM(HasCrCard) AS NumCards 
							FROM Bank_Churn bc INNER JOIN CTE ON CTE.CustomerId = bc.CustomerId
							GROUP BY Agebucket) AS subquery);

-- --21.Rank the Locations as per the number of people who have churned the bank and average balance of the learners.
SELECT 
RANK()OVER(ORDER BY COUNT(c.CustomerID) DESC) AS 'Location_rank',
GeographyID,
COUNT(c.CustomerID) AS Customer_Count,
ROUND(AVG(Balance),2) as AvgBalance
FROM CustomerInfo c
INNER JOIN Bank_Churn b
ON c.CustomerId = b.CustomerId
WHERE Exited = 1
GROUP BY GeographyID;

-- --22.As we can see that the “CustomerInfo” table has the CustomerID and Surname, 
-- --now if we have to join it with a table where the primary key is also a combination of CustomerID and Surname,
-- --come up with a column where the format is “CustomerID_Surname”.
SELECT 
	CustomerId,
	Surname,
	CONCAT(CustomerId,'_',Surname) AS CustomerId_Surname
FROM CustomerInfo;

-- --23. Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL
SELECT *,
(SELECT ExitCategory 
	FROM ExitCustomer E 
	WHERE E.ExitID = bc.Exited) AS ExitCategory
FROM Bank_Churn bc;

-- --24. Were there any missing values in the data, using which tool did you replace them and what are the ways to handle them?



-- --25. Write the query to get the customer ids, their last name and whether they are active or not for the customers whose surname  ends with “on”.
SELECT c.CustomerId,Surname,IsActiveMember,
(SELECT ActiveCategory FROM ActiveCustomer A WHERE A.ActiveID=bc.IsActiveMember) AS 'Member_status'
FROM CustomerInfo c
JOIN Bank_Churn bc
ON c.CustomerId = bc.CustomerId
WHERE Surname LIKE '%on';


-- ---SQ9.	Utilize SQL queries to segment customers based on demographics and account details.

WITH CTE AS (
SELECT CustomerID,
CASE 
WHEN CreditScore BETWEEN 350 AND 579 THEN 'Poor'
WHEN CreditScore BETWEEN 580 AND 669 THEN 'Fair'
WHEN CreditScore BETWEEN 670 AND 739 THEN 'Good'
WHEN CreditScore BETWEEN 740 AND 799 THEN 'Very good'
ELSE 'Excellent'
END AS Credit_bucket
FROM Bank_Churn)

SELECT Tenure,
NumOfProducts,Credit_bucket,
COUNT(CTE.CustomerId) AS CustomerCount,
ROUND(AVG(Balance), 2) AS AverageBalance
FROM Bank_Churn bc
JOIN CTE ON	bc.CustomerId=CTE.CustomerId
GROUP BY Credit_bucket,Tenure,NumOfProducts
ORDER BY Tenure,NumOfProducts;


-- --14.	In the “Bank_Churn” table how can you modify the name of “HasCrCard” column to “Has_creditcard”?
ALTER TABLE bank_churn RENAME COLUMN HasCrCard TO Has_creditcard;
