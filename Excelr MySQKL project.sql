create database p193;
use	p193;
select * from finance_1;
select * from finance_2;

#------------------------------ Total loan amount   --------------------

select sum(loan_amnt) total_loan_amount from finance_1;
 
 #-------------------------- Total revol balance -------------------------
 select sum(f2.revol_bal) "total revol balance" from finance_1 f1 join finance_2 f2
 on f1.id = f2.id;
 
 #-------------------------------- total payment   -----------------------
 
 select  round(sum(total_pymnt),2) total_payment from finance_1 f1
 join finance_2 f2 on f1.id = f2.id;
 
 #----------------------total funded amount ----------------------------
 
 select sum(funded_amnt) total_funded_amount from finance_1 f1 
 join finance_2 f2 on f1.id = f2.id;
 


select year(issue_d) from finance_1;

select distinct year(last_pymnt_d) years from finance_2 where last_pymnt_d is not null order by years desc;
desc finance_1;


# KPI 1 : Year wise loan amount Stats   ---------------------------------

select year(issue_d) years, sum(issue_d) total_loan_amount from finance_1
group by years order by years desc;


# KPI 2 : Grade and sub grade wise revol_bal   ----------------------------------

DELIMITER //
create procedure input_grade(in enter_grade varchar(10))
begin
 select f1.sub_grade, f1.grade , sum(f2.revol_bal) "total revol balance" from finance_1 f1
 join finance_2 f2 on f1.id = f2.id
 where grade=enter_grade
 group by f1.sub_grade,f1.grade
 order by "total revol balance" desc;
end //
DELIMITER ;

call input_grade('B');


select f1.sub_grade,f1.grade ,sum(f2.revol_bal) "Total revol balance" from finance_1 f1
join finance_2 f2 on f1.id = f2.id
group by f1.sub_grade, f1.grade
order by f1.grade , "Total revol balance" desc;

# KPI 3 : Total Payment for Verified Status Vs Total Payment for Non Verified Status   -------------------------

select f1.verification_status, round(sum(f2.total_pymnt),2) "total Pyment" from finance_1 f1
join finance_2 f2 on f1.id = f2.id
group by f1.verification_status
order by "total pyment";


# KPI 4 : State wise and month wise loan status   -------------------------------------------------

Select loan_status,term, count(loan_status) "count of loan" from finance_1
group by loan_status,term
order by "count of loan" desc;


# KPI 5 : Home ownership Vs last payment date stats   ----------------------------

DELIMITER //
Create procedure input_home_ownership(in enter_home_ownership varchar(30),in enter_year int)
begin
select f1.home_ownership,monthname(f2.last_pymnt_d) month_name,count(F1.home_ownership) Number_of_ownership from finance_1 f1
join finance_2 f2 on f1.id = f2.id
where f1.home_ownership = enter_home_ownership and year(f2.last_pymnt_d) = enter_year
group by f1.home_ownership,month_name
order by Number_of_ownership desc ,month_name;
end //
DELIMITER ;
call input_home_ownership('rent',2012);


select f1.home_ownership,monthname(f2.last_pymnt_d) month_name,count(F1.home_ownership) Number_of_ownership from finance_1 f1
join finance_2 f2 on f1.id = f2.id
where monthname(f2.last_pymnt_d) is not null
group by f1.home_ownership,month_name
order by Number_of_ownership desc ,month_name;
;
