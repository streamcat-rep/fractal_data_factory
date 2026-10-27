# data_factory

Proyecto dbt (Postgres/Supabase).

## Flujo de ramas

- `feat/*` → PR hacia `dev`. Al abrir/actualizar el PR, o al mergear, corre `dbt build` (tests esenciales) contra Supabase.
- `release/yyyy-mm-dd` → PR hacia `main`. Al mergear a `main`, se despliega (`dbt build`) contra Supabase (producción).

## Setup local

```powershell
py -3.11 -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
$env:DBT_POSTGRES_PASSWORD = "..."   # o carga desde .env local (no versionado)
dbt debug
```

El perfil (`data_factory`) se busca en `~/.dbt/profiles.yml`, no está en el repo.

## CI/CD (GitHub Actions)

`.github/workflows/dev-build.yml` y `.github/workflows/release-deploy.yml` usan el perfil de `ci/profiles.yml`
(basado en variables de entorno) y necesitan estos **repository secrets** en GitHub
(Settings → Secrets and variables → Actions):

- `DBT_HOST`
- `DBT_PORT`
- `DBT_USER`
- `DBT_PASSWORD`
- `DBT_DBNAME`
- `DBT_SCHEMA`
