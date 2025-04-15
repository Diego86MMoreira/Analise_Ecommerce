-- Query 1
-- Consulta por Mês e Total de Visitas;
-- Colunas: Mês e Leads
select
	date_trunc('month', visit_page_date):: date as visit_page_month,
	count(*) as Total_de_Visitas

from sales.funnel
group by visit_page_month
order by visit_page_month

-- Query 2
-- Consulta por Mês por Vendas e o Total da Receita

select
	date_trunc('month', fun.paid_date)::date as paid_month,
	count(fun.paid_date) as paid_count,
	sum(pro.price * (1+fun.discount)) as receita


from sales.funnel as fun
left join sales.products as pro
	on fun.product_id = pro.product_id
where fun.paid_date is not null
group by paid_month
order by paid_month

-- Query 3
-- Conversão e Ticket Mèdio

with
   leads as (
	select
	date_trunc('month', visit_page_date):: date as visit_page_month,
		count(*) as visit_page_count
	from sales.funnel
	group by visit_page_month
	order by visit_page_month
	),
payments as (
	select
	date_trunc('month', fun.paid_date)::date as paid_month,
	count(fun.paid_date) as paid_count,
	sum(pro.price * (1+fun.discount)) as receita

from sales.funnel as fun
left join sales.products as pro
	on fun.product_id = pro.product_id
where fun.paid_date is not null
group by paid_month
order by paid_month
)

select
	leads.visit_page_month as "Mês",
	leads.visit_page_count as "Leads",
	payments.paid_count as "Vendas",
	(payments.receita/1000) as "Receita",
	(payments.paid_count::float/leads.visit_page_count::float) as "Conversão",
	(payments.receita/payments.paid_count/1000) as "Ticket Médio"
	
from leads
left join payments
on leads.visit_page_month = paid_month

-- Query 4
-- Estados que mais venderam

select
	'Brazil' as país,
	cus.state as estado,
	count(fun.paid_date) as "vendas (#)"

from sales.funnel as fun
left join sales.customers as cus
	on fun.customer_id = cus.customer_id
where paid_date between '2021-08-01' and '2021-08-31'
group by país, estado
order by "vendas (#)" desc

-- Query 5
-- Marcas que mais venderam

select
	pro.brand as marca,
	count(fun.paid_date) as "vendas (#)"

from sales.funnel as fun
left join sales.products as pro
	on fun.product_id = pro.product_id
where paid_date between '2021-08-01' and '2021-08-31'
group by marca
order by "vendas (#)" desc
limit 10

-- Query 6
-- Lojas que mais venderam

select
	sto.store_name as loja,
	count(fun.paid_date) as "vendas (#)"

from sales.funnel as fun
left join sales.stores as sto
	on fun.store_id = sto.store_id
where paid_date between '2021-08-01' and '2021-08-31'
group by loja
order by "vendas (#)" desc
limit 10

-- Query 7
-- Dia da semana com mais visitas ao site

select
	extract('dow' from visit_page_date) as dia_semana,
	case 
		when extract('dow' from visit_page_date)=0 then 'domingo'
		when extract('dow' from visit_page_date)=1 then 'segunda'
		when extract('dow' from visit_page_date)=2 then 'terça'
		when extract('dow' from visit_page_date)=3 then 'quarta'
		when extract('dow' from visit_page_date)=4 then 'quinta'
		when extract('dow' from visit_page_date)=5 then 'sexta'
		when extract('dow' from visit_page_date)=6 then 'sábado'
		else null end as "dia da semana",
	count(*) as "visitas (#)"

from sales.funnel
where visit_page_date between '2021-08-01' and '2021-08-31'
group by dia_semana
order by dia_semana

-- Query 8
-- Gênero dos Leads

select
	case
		when ibge.gender = 'male' then 'homens'
		when ibge.gender = 'female' then 'mulheres'
		end as "gênero",
	count(*) as "leads (#)"

from sales.customers as cus
left join temp_tables.ibge_genders as ibge
	on lower(cus.first_name) = lower(ibge.first_name)
group by ibge.gender

-- Query 8
-- Status Profissional

select
	case
		when professional_status = 'freelancer' then 'freelancer'
		when professional_status = 'retired' then 'aposentado(a)'
		when professional_status = 'clt' then 'clt'
		when professional_status = 'self_employed' then 'autônomo(a)'		
		when professional_status = 'other' then 'outro'
		when professional_status = 'businessman' then 'empresário(a)'
		when professional_status = 'civil_servant' then 'funcionário(a) público(a)'
		when professional_status = 'student' then 'estudante'
		end as "status profissional",
	(count(*)::float)/(select count(*) from sales.customers) as "leads (%)"

from sales.customers
group by professional_status
order by "leads (%)"

-- Query 9
-- Faixa etária dos Leads

SELECT
  CASE
    WHEN EXTRACT(YEAR FROM AGE(current_date, birth_date)) < 20 THEN '0-20'
    WHEN EXTRACT(YEAR FROM AGE(current_date, birth_date)) < 40 THEN '20-40'
    WHEN EXTRACT(YEAR FROM AGE(current_date, birth_date)) < 60 THEN '40-60'
    WHEN EXTRACT(YEAR FROM AGE(current_date, birth_date)) < 80 THEN '60-80'
    ELSE '80+'
  END AS "faixa etária",
  COUNT(*)::float / (SELECT COUNT(*) FROM sales.customers) AS "leads (%)"
FROM sales.customers
GROUP BY "faixa etária"
ORDER BY "faixa etária" DESC;

-- Query 10
-- Faixa salarial dos Leads

select
	case
		when income < 5000 then '0-5000'
		when income < 10000 then '5000-10000'
		when income < 15000 then '10000-15000'
		when income < 20000 then '15000-20000'
		else '20000+' end "faixa salarial",
		count(*)::float/(select count(*) from sales.customers) as "leads (%)",
	case
		when income < 5000 then 1
		when income < 10000 then 2
		when income < 15000 then 3
		when income < 20000 then 4
		else 5 end "ordem"

from sales.customers
group by "faixa salarial", "ordem"
order by "ordem" desc

-- Query 11
-- Classificação dos veículos
-- Regra de negócio: Veículos novos tem até 2 anos e seminovos acima de 2 anos

with
	classificacao_veiculos as (
	
		select
			fun.visit_page_date,
			pro.model_year,
			extract('year' from visit_page_date) - pro.model_year::int as idade_veiculo,
			case
				when (extract('year' from visit_page_date) - pro.model_year::int)<=2 then 'novo'
				else 'seminovo'
				end as "classificação do veículo"
		
		from sales.funnel as fun
		left join sales.products as pro
			on fun.product_id = pro.product_id	
	)

select
	"classificação do veículo",
	count(*) as "veículos visitados (#)"
from classificacao_veiculos
group by "classificação do veículo"

-- Query 12
-- Idade do veículo, veículos visitados (%), ordem

with
	faixa_de_idade_dos_veiculos as (
	
		select
			fun.visit_page_date,
			pro.model_year,
			extract('year' from visit_page_date) - pro.model_year::int as idade_veiculo,
			case
				when (extract('year' from visit_page_date) - pro.model_year::int)<=2 then 'até 2 anos'
				when (extract('year' from visit_page_date) - pro.model_year::int)<=4 then 'de 2 à 4 anos'
				when (extract('year' from visit_page_date) - pro.model_year::int)<=6 then 'de 4 à 6 anos'
				when (extract('year' from visit_page_date) - pro.model_year::int)<=8 then 'de 6 à 8 anos'
				when (extract('year' from visit_page_date) - pro.model_year::int)<=10 then 'de 8 à 10 anos'
				else 'acima de 10 anos'
				end as "idade do veículo",
			case
				when (extract('year' from visit_page_date) - pro.model_year::int)<=2 then 1
				when (extract('year' from visit_page_date) - pro.model_year::int)<=4 then 2
				when (extract('year' from visit_page_date) - pro.model_year::int)<=6 then 3
				when (extract('year' from visit_page_date) - pro.model_year::int)<=8 then 4
				when (extract('year' from visit_page_date) - pro.model_year::int)<=10 then 5
				else 6
				end as "ordem"

		from sales.funnel as fun
		left join sales.products as pro
			on fun.product_id = pro.product_id	
	)

select
	"idade do veículo",
	count(*)::float/(select count(*) from sales.funnel) as "veículos visitados (%)",
	ordem
from faixa_de_idade_dos_veiculos
group by "idade do veículo", ordem
order by ordem

-- Query 13
-- Veículos mais visitados por marca/modelo

select
	pro.brand,
	pro.model,
	count(*) as "visitas (#)"

from sales.funnel as fun
left join sales.products as pro
	on fun.product_id = pro.product_id
group by pro.brand, pro.model
order by pro.brand, pro.model, "visitas (#)"
limit 10

