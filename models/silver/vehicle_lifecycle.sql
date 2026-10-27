select
    v.vin,
    m.vehicle_type,
    m.name as model,
    f.name as manufactured_at_factory,
    al.line_name as assembly_line,
    v.production_date,
    dist.dispatch_date,
    d_dist.name as distributed_to_dealer,
    s.sale_date,
    d_sale.name as sold_by_dealer,
    s.current_km

from {{ source('factory_ops', 'vehicles') }} as v
join {{ source('factory_ops', 'materials') }} as m on v.mat_cod = m.mat_cod
join {{ source('factory_ops', 'factories') }} as f on v.factory_id = f.factory_id
join {{ source('factory_ops', 'assembly_lines') }} as al on v.line_id = al.line_id
left join {{ source('factory_ops', 'distribution') }} as dist on v.vin = dist.vin
left join {{ source('factory_ops', 'dealerships') }} as d_dist on dist.dealer_id = d_dist.dealer_id
left join {{ source('factory_ops', 'sales_and_telemetry') }} as s on v.vin = s.vin
left join {{ source('factory_ops', 'dealerships') }} as d_sale on s.sold_by_dealer_id = d_sale.dealer_id

order by v.production_date desc
