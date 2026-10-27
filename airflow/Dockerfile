FROM apache/airflow:3.3.2

# Isolated venv for dbt, kept separate from Airflow's own Python deps to avoid version conflicts.
RUN python -m venv /opt/dbt_venv && \
    /opt/dbt_venv/bin/pip install --no-cache-dir dbt-core==1.12.6 dbt-postgres==1.11.0
