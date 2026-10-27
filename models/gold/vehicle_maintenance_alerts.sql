select
    v.vin,
    m.name as vehicle_model,
    s.current_km,
    s.km_to_next_service,
    s.estimated_km_to_breakdown,
    d.name as dealership,
    f.name as factory_origin,
    case
        when s.estimated_km_to_breakdown < 1000 then 'CRITICAL: Avería inminente'
        when s.km_to_next_service < 0 then 'WARNING: Mantenimiento atrasado'
        else 'OK'
    end as status

from {{ source('factory_ops', 'sales_and_telemetry') }} as s
join {{ source('factory_ops', 'vehicles') }} as v on s.vin = v.vin
join {{ source('factory_ops', 'materials') }} as m on v.mat_cod = m.mat_cod
join {{ source('factory_ops', 'dealerships') }} as d on s.sold_by_dealer_id = d.dealer_id
join {{ source('factory_ops', 'factories') }} as f on v.factory_id = f.factory_id

where s.km_to_next_service < 2000 or s.estimated_km_to_breakdown < 3000
order by least(s.km_to_next_service, s.estimated_km_to_breakdown) asc
