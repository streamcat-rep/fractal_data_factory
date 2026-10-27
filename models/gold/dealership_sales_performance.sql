select
    sold_by_dealer as dealership_name,
    sold_by_dealer_city as city,
    count(vin) as total_vehicles_sold,
    sum(base_price) as total_revenue_eur,
    round(avg(base_price), 2) as avg_ticket_eur

from {{ ref('vehicle_lifecycle') }}

-- sold_by_dealer viene de un LEFT JOIN resuelto vía sold_by_dealer_id (not_null en bronze);
-- no-nulo aquí significa "la venta tiene un dealer real", de forma más fiable que mirar sale_date.
where sold_by_dealer is not null

group by 1, 2
order by total_revenue_eur desc
