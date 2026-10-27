select
    vin,
    model as vehicle_model,
    current_km,
    km_to_next_service,
    estimated_km_to_breakdown,
    sold_by_dealer as dealership,
    manufactured_at_factory as factory_origin,
    case
        when estimated_km_to_breakdown < 1000 then 'CRITICAL: Avería inminente'
        when km_to_next_service < 0 then 'WARNING: Mantenimiento atrasado'
        else 'OK'
    end as status

from {{ ref('vehicle_lifecycle') }}

-- solo vehículos vendidos (ver nota de sold_by_dealer en dealership_sales_performance.sql)
where sold_by_dealer is not null
  and (km_to_next_service < 2000 or estimated_km_to_breakdown < 3000)

order by least(km_to_next_service, estimated_km_to_breakdown) asc
