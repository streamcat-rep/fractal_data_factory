select
    model as model_name,
    manufactured_at_factory as factory_name,
    distributed_to_dealer as dealership_name,
    avg(arrival_date - production_date)::int as avg_transit_days,
    avg(sale_date - arrival_date)::int as avg_days_in_stock

from {{ ref('vehicle_lifecycle') }}

-- solo vehículos que llegaron a un concesionario y además se vendieron
-- (distributed_to_dealer/sold_by_dealer resueltos vía dealer_id not_null en bronze)
where distributed_to_dealer is not null
  and sold_by_dealer is not null

group by 1, 2, 3
order by avg_days_in_stock desc
