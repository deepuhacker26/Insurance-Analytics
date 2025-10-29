create database Insuranceanalysis;
use Insuranceanalysis;
select*from brokerage;
select*from fees;
select*from budgets;
select*from invoice;
select*from meeting;
select*from opportunity;
-- KPI 1 - Number of invoice by Account Executive
select Account_Executive,
		sum(case when income_class = "Cross Sell" then 1 else 0 end) as Cross_Sell_Count,
        sum(case when income_class = "New" then 1 else 0 end) as New_Count,
        sum(case when income_class = "Renewal" then 1 else 0 end) as Renewal_Count,
        sum(case when income_class = "-" then 1 else 0 end) as NULL_invoice_Count,
        count(Invoice_number) as invoice_count
from invoice
group by Account_Executive
order by Invoice_count desc;

-- KPI 2 - Yearly Meeting Count
select year(meeting_date) as year,count(meeting_date) as Meeting_count
from meeting
group by year(meeting_date)
order by year;

-- KPI 4 - Stage funnel by revenue
select stage,sum(revenue_amount) as Revenue_Amount
from opportunity group by stage order by Revenue_Amount desc;
-- KPI 5 - Number of Meeting by Account Executive
select Account_Executive,count(*) as Meeting_count
from meeting
group by Account_Executive
order by Meeting_count desc;
-- KPI 6 - Top 5 Opportunity by Revenue
select opportunity_name,sum(revenue_amount) as Revenue_Amount
from opportunity
group by opportunity_name
order by Revenue_Amount desc limit 5;
## Opportunity - product distribution
select product_group,count(Account_Executive) as oppty_count,
concat(format((count(Account_Executive)*100.0/sum(count(Account_Executive)) over ()),2), '%') as Total_Percent
from opportunity
group by product_group;

ALTER TABLE budgets
RENAME COLUMN ï»¿Branch TO Branch;



-- KPI 3 - Target,Invoice,Achieved,Placed_Achivmt_percent,
# Invoice_Achvmt_percent by Income_Class
# (Cross sell,New,Renewal)
DELIMITER //
create procedure Data_by_IncomeClass (in IncomeClass varchar(20))
begin
	declare Budget_val double;
    set @Cross_Sell_Target = (select sum(Cross_Sell_Bugdet) from budgets);
	set @New_Target = (select sum(New_Budget) from budgets);
	set @Renewal_Target = (select sum(Renewal_Budget) from budgets);
    
    set @Invoice_val = (select sum(Amount) from invoice where income_class = IncomeClass);
    set @Achieved_val = ((select sum(Amount) from brokerage where income_class = IncomeClass) + 
						(select sum(Amount) from fees where income_class = IncomeClass));
	if IncomeClass = "Cross Sell" then set Budget_val = @Cross_Sell_Target;
		elseif IncomeClass = "New" then set Budget_val = @New_Target;
        elseif IncomeClass = "Renewal" then set Budget_val = @Renewal_Target;
        else set Budget_val = 0;
	end if;
    set @Placed_achvment = (select concat(format((@Achieved_val/Bubget_val)*100,2),'%'));
    set @Invoice_achvment = (select concat(format((@Invoice_val/Bubget_val)*100,2),'%'));
    select IncomeClass, format(Budget_val,0) as Target,format(@Invoice_val,0) as Invoice,
			format(@Achieved_val,2) as Achieved,@Placed_achvment as Placed_Achievement_Percentage,
            @Invoice_achvment as Invoice_Achievement_Percentage;
end//
    


    
    
        