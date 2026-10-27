select
    m.name as model_name,
    f.name as factory_name,
    d.name as dealership_name,
    avg(dist.arrival_date - v.production_date)::int as avg_transit_days,
    avg(s.sale_date - dist.arrival_date)::int as avg_days_in_stock

from {{ source('factory_ops', 'vehicles') }} as v
join {{ source('factory_ops', 'distribution') }} as dist on v.vin = dist.vin
join {{ source('factory_ops', 'sales_and_telemetry') }} as s on v.vin = s.vin
join {{ source('factory_ops', 'materials') }} as m on v.mat_cod = m.mat_cod
join {{ source('factory_ops', 'factories') }} as f on v.factory_id = f.factory_id
join {{ source('factory_ops', 'dealerships') }} as d on dist.dealer_id = d.dealer_id

group by 1, 2, 3
order by avg_days_in_stock desc
