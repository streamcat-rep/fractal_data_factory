from __future__ import annotations

import pendulum

from airflow.providers.standard.operators.bash import BashOperator
from airflow.sdk import DAG, Param

with DAG(
    dag_id="dbt_run",
    description="Lanza dbt run contra Supabase. Por defecto corre todos los modelos.",
    schedule=None,
    start_date=pendulum.datetime(2026, 1, 1, tz="UTC"),
    catchup=False,
    tags=["dbt"],
    params={
        "select": Param(
            "",
            type="string",
            description=(
                "Argumento de dbt --select (ej: my_model, path:models/staging, "
                "tag:nightly). Vacío = todos los modelos."
            ),
        ),
    },
) as dag:
    BashOperator(
        task_id="dbt_run",
        cwd="/opt/airflow/dbt_project",
        bash_command=(
            "/opt/dbt_venv/bin/dbt run"
            "{% if params.select %} --select '{{ params.select }}'{% endif %}"
        ),
    )
