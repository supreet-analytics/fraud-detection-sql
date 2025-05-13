
-- Creating table with matching columns

create table bank_transactions(
TransactionID varchar(50) primary key,
AccountID varchar(50),
TransactionAmount decimal(10,2),
TransactionDate varchar(50),
TransactionType varchar(50),
Location varchar(100),
DeviceID varchar(50),
IPAddress varchar(100),
MerchantID varchar(50), 
`Channel` varchar(50),
CustomerAge int,
CustomerOccupation varchar(100),
TransactionDuration int,
LoginAttempts int,
AccountBalance decimal(12,2),
PreviousTransactionDate varchar(50));

-- Taking a look at our dataset

select * from fraud_detection.bank_transactions;

-- Updating TransactionDate and PreviousTransactionDate Data Type

update bank_transactions
set 
TransactionDate = str_to_date(TransactionDate, '%m/%d/%Y %H:%i'),
PreviousTransactionDate = str_to_date(PreviousTransactionDate, '%m/%d/%Y %H:%i');

alter table bank_transactions
modify column TransactionDate datetime,
modify column PreviousTransactionDate datetime;

-- Creating final table with correct column names and order

create table fraud_alerts as
select 
	TransactionID,
    AccountID,
    TransactionAmount,
    PreviousTransactionDate as NextTransactionDate,
    TransactionDate as PreviousTransactionDate,
    TransactionType,
    Location,
    DeviceID,
    IPAddress,
    MerchantID,
    `Channel`,
    CustomerAge,
    CustomerOccupation,
    TransactionDuration,
    LoginAttempts,
    AccountBalance
from bank_transactions;

-- Q1: Total number of transactions and total transaction amount
-- Motive: For a quick overview of the dataset's volume and financial scale

create temporary table TransactionCount
select count(*) as TotalTransaction
from fraud_alerts;

create temporary table TransactionAmount 
select sum(TransactionAmount) as TotalTransactionAmount
from fraud_alerts;

select * 
from TransactionCount,
TransactionAmount;

-- Q2: Average transaction amount per customer
-- Motive: To identify average customer spending behaviour and to detect anomalies or outliers if any

create temporary table AverageCustomerSpending
select round(avg(TransactionAmount),3) as AverageCustomerSpending
from fraud_alerts;

select * from AverageCustomerSpending;

-- Q3: Count of each transaction type
-- Motive: So that it is easy to understand trasaction type trends and to identify if one type is more fraud-prone

select TransactionType, count(*) as TransactionTypeCount
from fraud_alerts
group by TransactionType
order by TransactionTypeCount desc;

-- Q4: Top 10 most active customers based on transactions
-- Motive: To identify high-frequency users who might be targets or sources of fraud

select AccountID, count(*) as TransactionFrequency
from fraud_alerts
group by AccountID
order by TransactionFrequency desc
limit 10;

-- Q5: Most used transaction channels (ATM, Mobile, Web etc)
-- Motive: To know which channels are more popular and hence need more security focus

select `Channel`, count(*) as ChannelCount
from fraud_alerts
group by `Channel`
order by ChannelCount desc;

-- Q6: Top 5 locations with highest transaction volume (both transaction count as well as transaction amount)
-- Motive: Locations with high transaction volumes are more prone to fraud; such locations require enhanced security measures.

create temporary table location_txs_count
select Location, count(*) as TransactionCount
from fraud_alerts
group by Location
order by TransactionCount desc, Location asc
limit 5;

select * from location_txs_count;

create temporary table location_txs_amount 
select Location, sum(TransactionAmount) as TotalTransactionAmount
from fraud_alerts
group by Location
order by TotalTransactionAmount desc
limit 5;

select * from location_txs_amount;

-- Let's see the common Locations with both highest transaction count and highest transaction amount which definitely require high security

with common_location as (
select a.Location, a.TransactionCount, b.TotalTransactionAmount
from location_txs_count as a
join location_txs_amount as b
on a.Location=b.Location)
select * from common_location;

-- Q7: Transactions with more than 3 login attempts before transactions
-- Motive: Because high login attempts could indicate brute-force login fraud

select AccountID, LoginAttempts
from fraud_alerts
where LoginAttempts >= 3
order by LoginAttempts desc, AccountID asc;

-- Q8: Transactions with high amount but low account balance
-- Motive: It may indicate overdrawing or fraudulent high-value withdrawals

-- Comparing transaction amount and account balance with their respective averages

select TransactionAmount, AccountBalance
from fraud_alerts
where TransactionAmount > (select * from AverageCustomerSpending)
and AccountBalance < 
	(select round(avg(AccountBalance),3) as AverageAccountBalance from fraud_alerts)
order by TransactionAmount desc, AccountBalance desc
limit 10;

-- Comparing transaction amount and account balance with specific numbers

select TransactionAmount, AccountBalance
from fraud_alerts
where TransactionAmount > 1000
and AccountBalance < 2000
order by TransactionAmount desc, AccountBalance desc;

-- Q9: Count of unique accounts accessed by the same DeviceID or IPAddress
-- Motive: This will identify if same device/IP is used to access multiple accounts — possible fraud ring

-- On the basis of same device id

select DeviceID, count(distinct AccountID) as UniqueAccounts
from fraud_alerts
group by DeviceID
having UniqueAccounts > 1
order by UniqueAccounts desc, DeviceID asc;

-- On the basis of same IP address

select IPAddress, count(distinct AccountID) as UniqueAccounts
from fraud_alerts
group by IPAddress
having UniqueAccounts > 1
order by UniqueAccounts desc, IPAddress asc;

-- Q10: Customers who made multiple transactions to the same merchant in a short time
-- Motive: Repeated rapid transactions to same merchant could indicate fraud bots or automation

select
    AccountID,
    MerchantID,
    count(*) as NumberOfTransactions,
    min(NextTransactionDate) as FirstTransactionTime,
    max(NextTransactionDate) as LastTransactionTime,
    timestampdiff(minute, min(NextTransactionDate), max(NextTransactionDate)) as TimeDifferenceInMinutes
from fraud_alerts 
group by AccountID, MerchantID
having NumberOfTransactions > 1 
AND TimeDifferenceInMinutes <= 10
order by NumberOfTransactions desc, TimeDifferenceInMinutes desc, AccountID asc;

-- Q11: First-time transactions (no PreviousTransactionDate)
-- Motive: To find out High-value first-time transactions as such transactions are often suspicious

select TransactionID
from fraud_alerts
where PreviousTransactionDate is null;

-- Q12: Transactions done during night/off hours (e.g., 12AM to 5AM)
-- Motive: As Night-time transactions may be more suspicious

select NextTransactionDate
from fraud_alerts
where 
	(time(NextTransactionDate) >= '00:00:00'
    and time(NextTransactionDate) <= '05:00:00');
    
select NextTransactionDate
from fraud_alerts
where hour(NextTransactionDate) between 0 and 5;

-- Q13: Average time gap between transactions per customer
-- Motive: To Identify unusual gaps or sudden activity after inactivity

select 
	AccountID, 
	NextTransactionDate, 
    PreviousTransactionDate, 
    datediff(NextTransactionDate,PreviousTransactionDate) as TimeGapInDays
from fraud_alerts
order by TimeGapInDays desc, AccountID asc;
    
-- Q14: Elderly customers making high-value transactions
-- Motive: Senior citizens are more vulnerable to online frauds.

select CustomerAge, TransactionAmount
from fraud_alerts
where CustomerAge >= 65
and TransactionAmount >= 900
order by CustomerAge desc, TransactionAmount desc;

-- Q15: Average transaction amount by customer occupation
-- Motive: It will help in profiling occupations with unusually high transaction volumes

select CustomerOccupation, round(avg(TransactionAmount),3) as AverageTransactionAmount
from fraud_alerts
group by CustomerOccupation
order by AverageTransactionAmount desc;

-- Q16: Count of missing/null values in key columns
-- Motive: Finally to ensure clean and usable data before running analysis

select 
    sum(case when TransactionID is null then 1 else 0 end) as MissingTransactionID,
    sum(case when AccountID is null then 1 else 0 end) as MissingAccountID,
    sum(case when TransactionAmount is null then 1 else 0 end) as MissingAmount,
    sum(case when NextTransactionDate is null then 1 else 0 end) as MissingDate
from fraud_alerts;

-- Q17: Check for duplicate transaction id
-- Motive: Because duplicate transaction records could indicate data issues or fraud attempts

select TransactionID, count(*) as TransactionIDCount
from fraud_alerts
group by TransactionID
having TransactionIDCount >= 2
order by TransactionID;









