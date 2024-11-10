select * from maindata;

alter table maindata add column dates date;

update maindata set dates = concat(`year`,'-',month1,'-',day);

 set sql_safe_updates=0;
 
#   1A
SELECT EXTRACT(YEAR FROM dates) AS year FROM maindata;
#   1B
SELECT EXTRACT(month FROM dates) AS year
FROM maindata;
#   1C
alter table maindata add column Month_Full_Name varchar(10);
update maindata set month_full_name = monthname(dates);

#   1D
alter table maindata add column Quarters varchar(2);
update maindata set Quarters = concat('Q',quarter(dates));

#   1E
alter table maindata drop column `year-month`;

alter table maindata add column `year-month` varchar(10);
update maindata set `year-month` = concat(year(dates),'-',LEFT(month_full_name, 3));

#   1F
select * from maindata;

alter table maindata add column weekdayno varchar(10);
update maindata set weekdayno = weekday(dates);              # 0 -> monday, 6 -> sunday

#   1G
alter table maindata drop column weekdayname;

alter table maindata add column weekdayname varchar(10);
update maindata set weekdayname = dayname(dates);

#   1H
alter table maindata add column Financial_month varchar(10);
update maindata set Financial_month = CONCAT("F",IF(MONTH1 >= 4, MONTH1-3, MONTH1+9));

#   1I
alter table maindata add column Financial_Quarter varchar(10);
update maindata set Financial_Quarter =  CONCAT("FQ",IF(MONTH1 >=4,ROUND((MONTH1-3)/3, 0), 
ROUND((MONTH1+9)/3, 0)));


# 2. Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)
alter table maindata rename column `# Available Seats` to Available_seats;
alter table maindata rename column `# Transported Passengers` to Transported_Passengers;

select `year`,(sum(Transported_Passengers)/sum(Available_seats))*100 `Load_Factor by Year`from maindata group by `year`;
select month_full_name ,(sum(Transported_Passengers)/sum(Available_seats))*100 `Load_Factor by month`from maindata group by month_full_name ;
select quarters ,(sum(Transported_Passengers)/sum(Available_seats))*100 `Load_Factor by Quarter` from maindata group by quarters ;

#  KPI 3  
select `Carrier Name`,(sum(Transported_Passengers)/sum(Available_seats))*100 as `Load_Factor by CarrierNames`
from maindata group by  `Carrier Name`;

# 4. Identify Top 10 Carrier Names based passengers preference 
select * from  maindata;

select `carrier Name`, sum( Transported_Passengers) as Top10   from maindata group by `Carrier Name` order by Top10 desc limit 10;

# 5. Display top Routes ( from-to City) based on Number of Flights 

SELECT 
    `From - To City`,
    COUNT(DISTINCT (`%Airline ID`)) AS number_of_unique_flights
FROM
    maindata
GROUP BY `From - To City`
ORDER BY COUNT(DISTINCT (`%Airline ID`)) DESC
LIMIT 10;

# 6. Identify the how much load factor is occupied on Weekend vs Weekdays.

alter table maindata add column weekday_weekend varchar(10);

update  maindata set weekday_weekend = case 
                                            when weekday(dates) IN (5,6) THEN 'Weekend'  
                                             ELSE 'Weekday' 
									   end ;
select weekday_weekend,(sum(Transported_Passengers)/sum(Available_seats))*100 `Load_Factor by Year`from maindata group by weekday_weekend;

# 7. Identify number of flights based on Distance group

select `%Distance Group ID`, count((`%Airline ID`)) as total from maindata group by `%Distance Group ID`;

