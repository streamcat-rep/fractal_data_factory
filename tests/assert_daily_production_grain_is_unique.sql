-- Falla si hay más de una fila por día/fábrica/línea/material en la capa gold.
select
    production_date,
    factory_name,
    line_name,
    mat_cod,
    count(*) as row_count
from {{ ref('daily_production_by_line') }}
group by 1, 2, 3, 4
having count(*) > 1
