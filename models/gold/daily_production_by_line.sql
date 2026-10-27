select
    v.production_date,
    f.name as factory_name,
    al.line_name,
    m.mat_cod,
    m.name as material_name,
    count(v.vin) as daily_produced_units

from {{ source('factory_ops', 'vehicles') }} as v
join {{ source('factory_ops', 'factories') }} as f on v.factory_id = f.factory_id
join {{ source('factory_ops', 'assembly_lines') }} as al on v.line_id = al.line_id
join {{ source('factory_ops', 'materials') }} as m on v.mat_cod = m.mat_cod

group by 1, 2, 3, 4, 5
order by v.production_date desc
