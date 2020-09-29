-- select top 2 product prices
SELECT TOP(2) *
FROM Products
order by UnitPrice desc
-----
--select with ties order by
--select top 3 + the excact of last one
SELECT TOP(3) with ties *
FROM Products
order by UnitsOnOrder  desc

-----------
----- select into to copy whole atable to new one
select * into mmr from Products
----- select into to copy table structure only to new one
select * into mmr from Products
where 1=2
------------
----- select into to copy table records only to new one
insert into mmr(ProductName,UnitPrice,Discontinued)
select ProductName,UnitPrice,Discontinued
from Products where UnitPrice >50
---------------------
--- schema used for security reasons or filtering similar tables or creating more than one table withe the same name
---Creating Schema
create schema M
--alter tables to new schema
alter schema m transfer orders --[orders is atable withe default schema dbo]
--select data from table with new schema
select * from m.orders -- m is schema name
-- return table to default schema
alter schema dbo transfer m.orders
--  Deleting Schema [drop]
drop schema m
---------------------------
select ProductName,UnitPrice,Discontinued from mmr
------like 
select ProductName,UnitPrice,Discontinued from mmr
where ProductName  like 'm%'-- first char is m

select ProductName,UnitPrice,Discontinued from mmr
where ProductName  like '%e'-- last char is e

select ProductName,UnitPrice,Discontinued from mmr
where ProductName  like '%e%'-- Contain e

select ProductName,UnitPrice,Discontinued from mmr
where ProductName  like '%[s,e]'--  the last char is s or e [get both]

select ProductName,UnitPrice,Discontinued from mmr
where ProductName  like '%s_' --  the char before last one is s

select ProductName,UnitPrice,Discontinued from mmr
where ProductName  like '_i%' --  the second char before fist one is i

select ProductName,UnitPrice,Discontinued from mmr
where ProductName  like '%[%]' --  the last char is symbol

select ProductName,UnitPrice,Discontinued from mmr
where ProductName  like 'm%u' --  the First char is m & the last char is u

---------------------------
-- random records

select * from mmr order by newid()

-----------Date
--convert date format sql 2012
select FORMAT(getdate(),'dd/MM/yyyy')
select FORMAT(getdate(),'dddd MMMM yyyy')
select FORMAT(getdate(),'ddd MMM yy')
select FORMAT(getdate(),'dddd')
select FORMAT(getdate(),'MMMM')
select FORMAT(getdate(),'hh:mm:ss')
select FORMAT(getdate(),'hh:mm:ss tt')
select FORMAT(getdate(),'hh')
select FORMAT(getdate(),'dd/MM/yyyy hh:mm:ss')
select FORMAT(getdate(),'dd/MM/yyyy hh:mm:ss tt')

---------
select format(getdate(),'MM') --OUTPUT IS STRING
select month(GETDATE()) --OUTPUT IS ANUMBER
---------
-- end of month () , the last day of month

select EOMONTH(GETDATE()) -- the full date of last day of  month
select format(EOMONTH(getdate()),'dd') -- the number of last day of month
select format(EOMONTH(getdate()),'dddd') --the name of last day of month
select EOMONTH(getdate(),2) --the full date of last day of 2 months late
select EOMONTH(getdate(),-2) --the full date of last day of 2 months Earlier

-------------------------------------------
-------using case end
select o.EmployeeID, e.FirstName,rate= case 
when count(o.EmployeeID)>200 then 'top' 
when count(o.EmployeeID)>150 then 'high' 
when count(o.EmployeeID)>100 then 'med' 
when count(o.EmployeeID)>50 then 'low' 
else 'lose' end 
from orders o inner join Employees  e
on e.EmployeeID=o.EmployeeID
group by e.FirstName , o.EmployeeID
-------------
--update using case end
----------------- case statement based on condition > < =
update Employees set Extension = case 
when Extension<=3500 then Extension+10
when Extension>=5000 then Extension+10
else Extension*1.3 end
------------------
------------------case statement based on expression
select 
case Extension 
when 428 then 7000
when 452 then 3000
end
from Employees

------------
--iif  like ternary operator ? : in any other programing lang
----------------------------------condition		  , true	  ,false
update Employees set Extension=iif(Extension>3500,Extension*10,Extension*20)
---------------
--select max word lenth 
  select top(1) country from Employees
  order by len(country) desc
--------------------------------
--top unit price
select  max(UnitPrice)from products
select top(1) UnitPrice from Products order by UnitPrice desc
--------------------------------------------------
----------------------Ranking Functions
--1--Row_Number()
-- to get top second or third or any number
-- here it is top second quantity
-- using as after subquery to use it becase of from from
select * from(
select *,row_number() over (order by Quantity desc ) as RN
from [Order Details]
) as newtable
where rn=2

--2--Dense_Rank()
-- to get top second or third or any number with all of its duplicated (similars)
-- here it is top second quantities with all same quantities
select * from(
select *,dense_rank() over (order by Quantity desc ) as DR
from [Order Details]
) as new
where dr=2


--3--Ntile() number of tiles
-- take one argument at least 
-- the argument is nubmer of groups
-- ntile will split the table into number of groups
select * from(
select *,ntile(10) over (order by Quantity desc ) as NT
from [Order Details]
) as new
where nt=2 -- the second group


---------Rank()
--numbering RA according to quantity but if quantity is more than one it will 
--continue counting like 1,2,3,4,5,6, will be  1,1,3,3,3,6
--it will get all Ranking numbers 
select * from(
select *,Rank() over (order by Quantity desc ) as RA
from [Order Details]
) as newtable
where RA=3

------------------Using Prtitions
--1--Row_Number()
-- adding Partition by to group the RN with the same records of quantity
--if quantity is 10 takes 20 record & quantity is 5 takes 60 record
--so Rn will be 1 to 20 then start over 1 to 60 and so on  
-- on this query it will get second top quantity  of each group (sectors) grouping by discount
select * from(
select *,row_number() over (partition by Discount order by Quantity desc) as RN
from [Order Details]
) as newtable
where rn=2

--2--Dense_Rank()
-- adding Partition by to group the DR with the same records of quantity
--if quantity is 10 takes 20 record & quantity is 5 takes 60 record
--so DR will be 1 then start over 2 and so on 
-- on this query it will get second top quantity grouping by discount
--with all same quantities of each group (sectors)

select * from(
select *,dense_rank() over (partition by Discount order by Quantity desc ) as DR
from [Order Details]
) as new
where dr=2

---------
--3--Ntile() number of tiles
-- take one argument at least 
-- the argument is nubmer of groups
-- ntile will split the table into number of groups order by discount asccending
select * from(
select *,ntile(10) over ( partition by Discount order by Quantity desc ) as NT
from [Order Details]
) as new
where nt=2 

-----------
---------Rank()
-- the partition will split table into sectors & each sector will start counting
--numbering RA according to quantity but if quantity is more than one it will 
--continue counting like 1,2,3,4,5,6, will be  1,1,3,3,3,6
--it will get all Ranking numbers 
select * from(
select *,Rank() over (partition by Discount order by Quantity desc ) as RA
from [Order Details]
) as newtable
where RA=2

drop table MMR