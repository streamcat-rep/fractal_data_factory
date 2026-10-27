select
    d.name as dealership_name,
    d.city,
    count(s.vin) as total_vehicles_sold,
    sum(m.base_price) as total_revenue_eur,
    round(avg(m.base_price), 2) as avg_ticket_eur

from {{ source('factory_ops', 'sales_and_telemetry') }} as s
join {{ source('factory_ops', 'dealerships') }} as d on s.sold_by_dealer_id = d.dealer_id
join {{ source('factory_ops', 'vehicles') }} as v on s.vin = v.vin
join {{ source('factory_ops', 'materials') }} as m on v.mat_cod = m.mat_cod

group by 1, 2
order by total_revenue_eur desc
