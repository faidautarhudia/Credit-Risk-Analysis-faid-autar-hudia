
select * from credit_risk;

-- Tampilkan semua data dengan loan_status = 'Charged Off'.
select * from credit_risk
where loan_status = 1 ;
-- Hitung rata-rata person_income.
select avg(income_by_year) income_by_year
from credit_risk
where loan_status = 1;
-- Tampilkan jumlah pinjaman (nominal_loan) rata-rata untuk setiap loan_grade.
select loan_grade, sum(nominal_loan)
from credit_risk
group by loan_grade;
-- Tampilkan 5 peminjam dengan loan_rate tertinggi.
select person_age, ownership, loan_purpose, loan_rate, credit_years, loan_status
from credit_risk
where loan_status = 0
limit 5;

-- Tampilkan jumlah peminjam berdasarkan loan_purpose.
select loan_purpose, sum(nominal_loan)
from credit_risk
group by loan_purpose;
-- Tampilkan semua peminjam dengan loan_percent_income > 0.3.
select * from credit_risk
where loan_percent_income > 0.3;
-- Hitung jumlah person_income berdasarkan ownership.
select ownership, sum(income_by_year)
from credit_risk
group by ownership;

select * from credit_risk;
-- 1. Hitung rata-rata pinjaman (loan_nominal) untuk peminjam yang pendapatannya di atas rata-rata semua peminjam (subquery)
select avg(nominal_loan) as avg_loan_nominal
from credit_risk
	where income_by_year > (
		select avg(income_by_year)
		from credit_risk
	);
        
-- 2. Tampilkan status pendapatan: 'Tinggi' jika income > 100 juta, selain itu 'Rendah' (pakai CASE WHEN)
select 
	loan_purpose,
	floor(avg(income_by_year)/12) as rata_rata_income,
	Case 
		when FLOOR(AVG(income_by_year)) >= 90000000 then 'Tinggi'
		when FLOOR(AVG(income_by_year)) >= 66000000 then 'Normal'
        else 'Rendah'
	end as 'Status_Pendapatan'
from credit_risk
group by loan_purpose;

-- 3. Ambil 5 peminjam dengan rasio pinjaman terhadap income tertinggi dalam setiap loan_grade (pakai ROW_NUMBER dan PARTITION BY)
with ranked_loans as (
	select 
		person_age, ownership, employee_length, loan_purpose, loan_grade, loan_rate, loan_status, default_before, credit_years, income_by_year, nominal_loan, loan_percent_income,
        row_number() over (
			partition by loan_grade
            order by loan_percent_income desc
            ) as rn
		from credit_risk
        where loan_percent_income is not null
)
select *
from ranked_loans
where rn <= 5;

-- 4. Hitung total dan rata-rata pinjaman untuk setiap tujuan pinjaman, hanya untuk yang default = 'Yes' (pakai CTE)
with tujuan_pinjaman as (
	select loan_purpose, 
		sum(nominal_loan) as jumlah_pinjaman,
		avg(nominal_loan) as rata_rata_pinjaman
    from credit_risk
    where default_before = 'Y'
    group by loan_purpose
)
select * from tujuan_pinjaman;

with tujuan_pinjaman as (
	select loan_purpose, 
		sum(nominal_loan) as jumlah_pinjaman,
		avg(nominal_loan) as rata_rata_pinjaman
    from credit_risk
    where default_before = 'N'
    group by loan_purpose
)
select * from tujuan_pinjaman;

-- 5. Hitung selisih pinjaman tiap baris dibanding rata-rata pinjaman di grup loan_grade-nya (pakai window function AVG OVER)
select ownership, loan_purpose, nominal_loan,
	floor(avg(nominal_loan) over(partition by loan_purpose)) AS rata_rata_per_grade,
	nominal_loan - 
    floor(AVG(nominal_loan) OVER (PARTITION BY loan_purpose)) AS selisih_dengan_rata
from credit_risk;

select * from credit_risk;
select loan_purpose,
	floor(avg(nominal_loan)) as rata_rata_per_grade,
    floor(avg(income_by_year)) as rata_rata_income
from credit_risk
group by loan_purpose;

select person_age, default_before
from credit_risk
group by person_age;

select person_age, loan_rate, nominal_loan, default_before, loan_purpose
from credit_risk
where default_before = 'N'
order by loan_rate desc;

select person_age, loan_rate, nominal_loan, default_before, loan_purpose
from credit_risk
where default_before = 'Y'
order by loan_rate desc;

select loan_rate, loan_status,loan_purpose
from credit_risk
order by loan_rate desc;