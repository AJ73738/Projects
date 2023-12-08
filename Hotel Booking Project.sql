Select *
from SHG

"OBJECTIVES OF ANALYSIS ARE IN CAPITAL LETTERS"

--BOOKING PATTERNS ANALYSIS


--What is the trend in booking patterns overtime and are they specific months where bookings are higher?


SELECT  Year([Booking Date]) AS BOOKING_Year,COUNT([BOOKING ID]) AS TOTAL_BOOKINGS_Yearly
FROM SHG
GROUP BY Year([Booking Date]) 
ORDER BY Year([Booking Date]) 



SELECT  MONTH([Booking Date]) AS BOOKING_MONTH,COUNT([BOOKING ID]) AS TOTAL_BOOKINGS_Monthly
FROM SHG
GROUP BY MONTH([Booking Date]) 
ORDER BY MONTH([Booking Date])  

--How does lead time vary accross allbooking Channels?
--Is there a correlation between lead time and customer type

Select [Distribution Channel],avg([Lead Time])as average_Lead_Time,[Customer Type],COUNT([BOOKING ID]) As TotalBookings
from SHG
group by [Distribution Channel],[Customer Type]
order by [Distribution Channel],[Customer Type]

--CUSTOMER BEHAVIOUR ANALYSIS

--Which distribution channel contributes the most to bookings?

Select [Distribution Channel],COUNT([BOOKING ID]) As TotalBookings
from SHG
group by [Distribution Channel]
order by [Distribution Channel]

--How does the average daily rate differ across channels?


Select [Distribution Channel],avg([Avg Daily Rate])as average_daily_rate
from SHG
group by [Distribution Channel]
order by [Distribution Channel]

--Can we identify any patterns in the distribution of guests bassed on their country of origin an how does this affect the revenue

Select Country,Count(guests) AS Number_Of_Guests,Sum(revenue)As Total_Sum_Of_Revenue
from SHG
group by Country
ORDER BY Country

--CANCELLATION ANALYSIS

--What factors are most strongly correlated with cancellations?
--Can we pedict fututre cancellations based on certain variables?
 
 Select hotel,[Distribution Channel],[Deposit Type] type,COUNT([Cancelled (0/1)]) AS Number_Of_Cancellations
 from SHG
 group by hotel,[Distribution Channel],[Deposit Type]
 order by hotel,[Distribution Channel],[Deposit Type]

 --How does the revenue losss from cancellations compare across different customer segments and distribution channels
--Select *
--from SHG

 Select Country,[Distribution Channel],Sum([Revenue Loss])AS Total_Revenue_Loss
 from SHG
 where [Cancelled (0/1)]>0 and Country = 'sweden'
 Group by Country,[Distribution Channel]


-- REVENUE OPTIMISATION ANALYSIS

--What is the overall revenue trend and identify specific customer segments or countries contributing significally to revenue

 SELECT  MONTH([Booking Date]) AS Month,Sum([Revenue]) AS Total_Revenue,Country
 from SHG
 Group by MONTH([Booking Date]),Country
 Order by Month

 -- Can we identify optimal pricing strategies based on the average daily rate for different customer types and distribution channels

 Select AVG([Avg Daily Rate]) AS Avg_Daily_Rate,[Customer Type],[Distribution Channel]
 from SHG
Group by [Customer Type],[Distribution Channel]

--GEOGRAPHICAL ANALYSIS

--How does distribution of guests vary across coutries and are there specific countries that should be targeted for marketing efforts
  
  Select Country,Count([Booking ID]) As Guest_Count
  from SHG	
  Group by Country
  Order by Guest_Count desc
   
   --Is there any correlation between country of origin and the likelyhood of cancellations or extended stays
--Select *
--from SHG


   Select Country,Count([Cancelled (0/1)]) As Cancelllation_Count
   from SHG
   Where [Cancelled (0/1)] >0
   Group by Country

   --OPERATIONAL EFFICIENCY


   -- What is the average Length of stay for guests and how does it differ based on booking channels and customer type

   Select [Distribution Channel],[Customer Type],AVG(DATEDIFF(DAY,[Status Update],[Arrival Date])) As Avg_Length_Of_Stay
   from SHG
   Group by [Distribution Channel],[Customer Type]
   Order by [Distribution Channel],[Customer Type]


 ---Are there patterns in check-out dates that can inform staffling and resource allocation strategies
 SELECT CONVERT(date, [Status Update]) AS Check_Out_Date, COUNT([Booking ID]) AS Checkout_count
FROM SHG
GROUP BY CONVERT(date, [Status Update])
ORDER BY CONVERT(date, [Status Update]);


 --IMPACT OF DEPOSIT TYPES ANALYSIS

 ---How does the presence or abscence of a deposit impact the likelyhood of a cancellation
-- Select *
--from SHG

 Select [Deposit Type],Count([Cancelled (0/1)]) As count_of_cancellation
 from SHG
 Group by [Deposit Type]
 Order by [Deposit Type]

 --Can we identify any Patterns in the use of deposit types accross different customer segments

 Select [Distribution Channel],[Deposit Type],Count([Deposit Type]) As Count_of_deposit_type
 from SHG
 Group by [Distribution Channel],[Deposit Type]
 Order by [Distribution Channel],[Deposit Type]

 --ANALYSISOF CORPORATE BOOKINGS


-- What is the proportion of corporate bookings and how does their avegrage daily rate adr compare to their customer types?

SELECT [Distribution Channel],[Customer type],[Avg daily rate]
FROM SHG
where [Distribution Channel] = 'corporate'
group by [Distribution Channel],[Customer type],[Avg daily rate]
order by [Distribution Channel],[Customer type],[Avg daily rate]

--Are there specific trends or patterns related to corporate bookings that can inform business strategies?
--BY MONTH
SELECT MONTH([Arrival Date]) as month,Count([booking id]) as total_bookings
FROM SHG
where [Distribution Channel] = 'corporate'
group by MONTH([Arrival Date])
order by MONTH([Arrival Date])

--BY DAY
SELECT DATENAME(WEEKDAY,[Arrival Date]) as DAY,Count([booking id]) as total_bookings
FROM SHG
where [Distribution Channel] = 'corporate'
group by DATENAME(WEEKDAY,[Arrival Date])
order by DATENAME(WEEKDAY,[Arrival Date]) desc

--TIME-TO-EVENT ANALYSIS

--how does the time between booking and arrival date affect revenue and the likelyhood of cancellations
WITH CTE AS
(
    SELECT
        [Booking ID],
        [Arrival Date],
        [Booking Date],
        DATEDIFF(DAY, [Booking Date], [Arrival Date]) AS days_between_booking_and_arrival,
        CASE
            WHEN DATEDIFF(DAY, [Booking Date], [Arrival Date]) <= 7 THEN '0-7 days'
            WHEN DATEDIFF(DAY,  [Booking Date],[Arrival Date]) <= 30 THEN '8-30 days'
            WHEN DATEDIFF(DAY, [Booking Date], [Arrival Date]) <= 90 THEN '31-90 days'
            ELSE 'More than 90 days'
        END AS time_range,
        [Cancelled (0/1)] AS cancellation_status,
        [Revenue] AS revenue 
    FROM
        SHG
)


SELECT
    time_range,
    COUNT(*) AS total_bookings,
    SUM(revenue) AS total_revenue,
    SUM(CASE WHEN cancellation_status = 1 THEN 1 ELSE 0 END) AS cancellations,
    (SUM(CASE WHEN cancellation_status = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*)) * 100 AS cancellation_rate,
    AVG(revenue) AS average_revenue
FROM
    CTE
GROUP BY
    time_range;

--are there specific lead time ranges that are associated with higher customer satisfaction or revenue?	
    SELECT 
    CASE
        WHEN [Lead time] <= 7 THEN '0-7 days'
        WHEN [Lead time] <= 30 THEN '8-30 days'
        WHEN [Lead time] <= 90 THEN '31-90 days'
        ELSE 'More than 90 days'
    END AS lead_time_range,
    FORMAT(SUM([Revenue]), 'N2') AS total_revenue
FROM SHG
GROUP BY
    CASE
        WHEN [Lead time] <= 7 THEN '0-7 days'
        WHEN [Lead time] <= 30 THEN '8-30 days'
        WHEN [Lead time] <= 90 THEN '31-90 days'
        ELSE 'More than 90 days'
    END
ORDER BY lead_time_range;

--COMAPRISON OF ONLINE AND OFFLINE TRAVEL AGENTS

---What is the contriution of online travel agents compared to offline travel agents
SELECT
   [Distribution Channel],
    COUNT(*) AS TotalBookings,
    SUM(Revenue) AS TotalRevenue
FROM
    SHG
GROUP BY
      [Distribution Channel]
    


	-----How do cancellation rates and reveue vary between  bookings made through online and offline travel agents

SELECT
    [Distribution Channel],
    COUNT(*) AS TotalBookings,
    SUM(CASE WHEN [Cancelled (0/1)] = 1 THEN 1 ELSE 0 END) AS CanceledBookings,
    SUM(Revenue) AS TotalRevenue,
    AVG(Revenue) AS AverageRevenue,
    SUM(CASE WHEN [Cancelled (0/1)] = 1 THEN Revenue ELSE 0 END) AS CanceledRevenue,
    SUM(CASE WHEN [Cancelled (0/1)] = 0 THEN Revenue ELSE 0 END) AS CompletedRevenue,
    SUM(CASE WHEN [Cancelled (0/1)] = 1 THEN Revenue ELSE 0 END) / NULLIF(SUM(Revenue), 0) AS CancellationRate
FROM
    SHG
GROUP BY
    [Distribution Channel]


	


