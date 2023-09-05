create database p228;
use p228;
select * from Hr_1;
select * from hr_2;


create table copy_hr_1 as select * from hr_1;

select * from copy_hr_1;

alter table copy_hr_1 add column attrition_status varchar(30) after attrition;

update copy_hr_1 set attrition_status = 'No'
where attrition = "Current Employee";

update copy_hr_1 set attrition_status = 'Yes'
where attrition = "Ex Employee";

update copy_hr_1 set attrition = "Current Employee"
where attrition = 'no';
update copy_hr_1 set attrition = "Ex Employee"
where attrition = 'yes';

alter table hr_2 add column worklifebalance_status varchar(30) after WorkLifeBalance;

update hr_2 set
worklifebalance_status = case
when WorkLifeBalance = 1 then 'Bad'
when WorkLifeBalance = 2 then 'Average'
when WorkLifeBalance = 3 then 'Good'
else 'Excellent'
end;

select attrition,department ,count(attrition) `Number of attrition` 
from copy_hr_1 
where attrition = "Current Employee"
group by attrition,department;

alter table hr_1 add column `Attrition Status` varchar(30) after Attrition;
update hr_1 set `Attrition Status` = "Current Employee" 
where Attrition = 'No';
update hr_1 set `Attrition Status` = "Ex Employee" 
where Attrition = 'Yes';

# ----------------------------- KPI 1 ---------------------------------------

# Average Attrition rate for all Departments ----------------------------


select * from hr_1;
select Department,count(attrition) `Number of Attrition`from hr_1
where attrition = 'yes'
group by Department;


create view Dept_average as
select department, round(count(attrition)/(select sum(employeecount) from hr_1)*100,2)  as attrtion_rate
from hr_1
where attrition = "yes"
group by department;
select * from dept_average;


# ---------------------------------- KPI 2  --------------------------------------------

# Average Hourly rate of Male Research Scientist


DELIMITER //
create procedure emp_role (in input_gender varchar(20), in input_jobrole varchar(30))
begin
 select Gender, round(avg(HourlyRate),2) `Avg Hourly Rate` from hr_1
 where gender = input_gender and jobrole = input_jobrole
 group by gender;
end //
DELIMITER ;
drop procedure emp_role;
call emp_role('male',"Research Scientist");


# ------------------------------ KPI 3 ----------------------------------------------


# Attrition rate Vs Monthly income stats

select h1.department,
round(count(h1.attrition)/(select count(h1.employeenumber) from hr_1 h1)*100,2) `Attrtion rate`,
round(avg(h2.MonthlyIncome),2) average_incom from hr_1 h1 join hr_2 h2
on h1.EmployeeNumber = h2.`employee id`
where attrition = 'Yes'
group by h1.department;

create view Attrition_employeeincome as
select h1.department,
round(count(h1.attrition)/(select count(h1.employeenumber) from hr_1 h1)*100,2) `Attrtion rate`,
round(avg(h2.MonthlyIncome),2) average_income from hr_1 h1 join hr_2 h2
on h1.EmployeeNumber = h2.`employee id`
where attrition = 'Yes'
group by h1.department;

select * from attrition_employeeincome;

# ------------------------------------ KPI 4 ----------------------------------------------

# Average working years for each Department

select h1.department,Round(avg(h2.totalworkingyears),0) from hr_1 h1
join hr_2 h2 on h1.employeenumber = h2.`Employee ID`
group by h1.department;

Create view `Employee Age` as 
select h1.department,Round(avg(h2.totalworkingyears),0) from hr_1 h1
join hr_2 h2 on h1.employeenumber = h2.`Employee ID`
group by h1.department;

select * from `employee age`;


# --------------------------------------------- KPI 5 --------------------------------------------

# Job Role Vs Work life balance

select * from hr_2;

select h1.jobrole,h2.worklifebalance_status, count(h2.worklifebalance_status) Employee_count
from hr_1 h1 join hr_2 h2
on h1.employeenumber = h2.`Employee ID`
group by h1.jobrole,h2.worklifebalance_status
order by h1.jobrole;

DELIMITER //
Create procedure Get_Count (in job_role varchar(30),in Work_balance varchar(30),out Ecount int)
begin
select count(h2.worklifebalance_status)  Employee_count into ecount
from hr_1 h1 join hr_2 h2
on h1.employeenumber = h2.`Employee ID`
where h1.jobrole = job_role and h2.worklifebalance_status = Work_balance
group by job_role,work_balance;
end //
DELIMITER ;
 
 call get_count('developer','Good',@Ecount);
 select @Ecount;


# --------------------------------------------- KPI 6-------------------------------------------

# Attrition rate Vs Year since last promotion relation
select * from  hr_2;
alter table hr_2 add column `last promotion year range` varchar(20) after YearsSinceLastPromotion;
alter table hr_2 change column `last promotion year range` `last promotion year` varchar(20);
update hr_2 set 
`last promotion year` = case
when YearsSinceLastPromotion <= 10 then "1 - 10"
when YearsSinceLastPromotion <= 20 then "11 - 20"
when YearsSinceLastPromotion <= 30 then "21 -30"
else '30+'
end;

select h2.`last promotion year`,count(h1.attrition)  attrition_count
from hr_1 h1 join hr_2 h2 on h1.employeenumber = h2.`employee id`
where h1.attrition = 'Yes'
group by `last promotion year`
order by `last promotion year`;


# ------------------------------------------ EXTRA KPI ------------------------------------------
 alter table hr_1 add column distance_status varchar(20) after DistanceFromHome;
 select * from hr_1;
 update hr_1 set
 distance_status = case
 when DistanceFromHome <= 10 then "Near by"
 when DistanceFromHome <=20 then 'Near'
 when DistanceFromHome <=30 then 'Far'
 else "Very Far"
 end;
  
  # Distance vs Attrition -----------------------
  


Select distance_status, round(count(attrition)/(select count(employeenumber) from hr_1)*100,2) attrition_rate from hr_1
where attrition = 'Yes'
group by distance_status;


#  Education vs attrition

Select educationField, count(attrition) current_employee from hr_1
where attrition = 'yes'
group by educationfield;

