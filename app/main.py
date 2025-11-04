from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse, HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.templating import Jinja2Templates
import os, pathlib, sqlite3

DB_DRIVER = os.environ.get("DB_DRIVER", "sqlite").lower()

oracledb = None
if DB_DRIVER == "oracle":
    import oracledb

BASE_DIR = pathlib.Path(__file__).parent
DB_PATH = os.environ.get("DB_PATH", str(BASE_DIR / "leaseledger.db"))

app = FastAPI(title="LeaseLedger Lite")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], allow_credentials=True,
    allow_methods=["*"], allow_headers=["*"],
)
templates = Jinja2Templates(directory=str(BASE_DIR / "templates"))

def get_conn():
    if DB_DRIVER == "sqlite":
        conn = sqlite3.connect(DB_PATH, check_same_thread=False)
        conn.row_factory = sqlite3.Row
        return conn
    else:
        dsn = os.environ.get("ORACLE_DSN", "localhost/FREEPDB1")
        user = os.environ.get("ORACLE_USER", "system")
        pwd = os.environ.get("ORACLE_PASSWORD", "oracle")
        return oracledb.connect(user=user, password=pwd, dsn=dsn)

def bootstrap_sqlite():
    need_seed = not os.path.exists(DB_PATH)
    if need_seed:
        with get_conn() as c:
            c.executescript((BASE_DIR / "schema.sql").read_text(encoding="utf-8"))
            c.executescript((BASE_DIR / "seed.sql").read_text(encoding="utf-8"))

@app.on_event("startup")
def _startup():
    if DB_DRIVER == "sqlite":
        bootstrap_sqlite()

RENT_ROLL_SQLITE = """
SELECT
  l.id AS lease_id, l.tenant_name, l.unit_no,
  printf('%.2f', COALESCE(SUM(CASE WHEN strftime('%Y-%m', c.due_date)=strftime('%Y-%m','now') THEN c.amount END),0)) AS monthly_charges,
  printf('%.2f', COALESCE(SUM(CASE WHEN strftime('%Y-%m', p.paid_date)=strftime('%Y-%m','now') THEN p.amount END),0)) AS monthly_payments,
  printf('%.2f',
    COALESCE(SUM(CASE WHEN strftime('%Y-%m', c.due_date)=strftime('%Y-%m','now') THEN c.amount END),0) -
    COALESCE(SUM(CASE WHEN strftime('%Y-%m', p.paid_date)=strftime('%Y-%m','now') THEN p.amount END),0)
  ) AS month_balance
FROM Leases l
LEFT JOIN Charges c ON c.lease_id=l.id
LEFT JOIN Payments p ON p.lease_id=l.id
WHERE date(l.start_date) <= date('now','start of month','+1 month','-1 day')
  AND (l.end_date IS NULL OR date(l.end_date) >= date('now','start of month'))
GROUP BY l.id, l.tenant_name, l.unit_no
ORDER BY l.unit_no;
"""

AGING_SQLITE = """
WITH due_totals AS (
  SELECT l.id AS lease_id,
         COALESCE(SUM(CASE WHEN date(c.due_date) <= date('now') THEN c.amount END),0) AS charges_due,
         MAX(CASE WHEN date(c.due_date) <= date('now') THEN c.due_date END) AS last_due_date
  FROM Leases l LEFT JOIN Charges c ON c.lease_id=l.id GROUP BY l.id
),
paid_totals AS (
  SELECT l.id AS lease_id,
         COALESCE(SUM(CASE WHEN date(p.paid_date) <= date('now') THEN p.amount END),0) AS payments_to_date
  FROM Leases l LEFT JOIN Payments p ON p.lease_id=l.id GROUP BY l.id
),
balances AS (
  SELECT d.lease_id,
         ROUND(d.charges_due - p.payments_to_date,2) AS balance,
         CAST(julianday('now') - julianday(d.last_due_date) AS INTEGER) AS days_past_due
  FROM due_totals d JOIN paid_totals p ON p.lease_id=d.lease_id
)
SELECT l.id AS lease_id, l.tenant_name, l.unit_no,
  printf('%.2f', CASE WHEN balance>0 AND days_past_due<=30 THEN balance ELSE 0 END) AS bucket_0_30,
  printf('%.2f', CASE WHEN balance>0 AND days_past_due BETWEEN 31 AND 60 THEN balance ELSE 0 END) AS bucket_31_60,
  printf('%.2f', CASE WHEN balance>0 AND days_past_due BETWEEN 61 AND 90 THEN balance ELSE 0 END) AS bucket_61_90,
  printf('%.2f', CASE WHEN balance>0 AND days_past_due>90 THEN balance ELSE 0 END) AS bucket_90_plus,
  printf('%.2f', COALESCE(balance,0)) AS total_due
FROM balances b JOIN Leases l ON l.id=b.lease_id
ORDER BY l.unit_no;
"""

RENT_ROLL_ORACLE = """
SELECT
  l.id AS lease_id, l.tenant_name, l.unit_no,
  TO_CHAR(NVL(SUM(CASE WHEN TO_CHAR(c.due_date,'YYYY-MM')=TO_CHAR(SYSDATE,'YYYY-MM') THEN c.amount END),0),'FM9999990.00') AS monthly_charges,
  TO_CHAR(NVL(SUM(CASE WHEN TO_CHAR(p.paid_date,'YYYY-MM')=TO_CHAR(SYSDATE,'YYYY-MM') THEN p.amount END),0),'FM9999990.00') AS monthly_payments,
  TO_CHAR(
    NVL(SUM(CASE WHEN TO_CHAR(c.due_date,'YYYY-MM')=TO_CHAR(SYSDATE,'YYYY-MM') THEN c.amount END),0) -
    NVL(SUM(CASE WHEN TO_CHAR(p.paid_date,'YYYY-MM')=TO_CHAR(SYSDATE,'YYYY-MM') THEN p.amount END),0),
    'FM9999990.00'
  ) AS month_balance
FROM Leases l
LEFT JOIN Charges c ON c.lease_id=l.id
LEFT JOIN Payments p ON p.lease_id=l.id
WHERE l.start_date <= LAST_DAY(SYSDATE)
  AND (l.end_date IS NULL OR l.end_date >= TRUNC(SYSDATE,'MM'))
GROUP BY l.id, l.tenant_name, l.unit_no
ORDER BY l.unit_no
"""

AGING_ORACLE = """
WITH due_totals AS (
  SELECT l.id AS lease_id,
         NVL(SUM(CASE WHEN c.due_date <= SYSDATE THEN c.amount END),0) AS charges_due,
         MAX(CASE WHEN c.due_date <= SYSDATE THEN c.due_date END) AS last_due_date
  FROM Leases l LEFT JOIN Charges c ON c.lease_id=l.id GROUP BY l.id
),
paid_totals AS (
  SELECT l.id AS lease_id, NVL(SUM(CASE WHEN p.paid_date <= SYSDATE THEN p.amount END),0) AS payments_to_date
  FROM Leases l LEFT JOIN Payments p ON p.lease_id=l.id GROUP BY l.id
),
balances AS (
  SELECT d.lease_id, ROUND(d.charges_due - p.payments_to_date,2) AS balance, TRUNC(SYSDATE - d.last_due_date) AS days_past_due
  FROM due_totals d JOIN paid_totals p ON p.lease_id=d.lease_id
)
SELECT l.id AS lease_id, l.tenant_name, l.unit_no,
  TO_CHAR(CASE WHEN balance>0 AND days_past_due<=30 THEN balance ELSE 0 END,'FM9999990.00') AS bucket_0_30,
  TO_CHAR(CASE WHEN balance>0 AND days_past_due BETWEEN 31 AND 60 THEN balance ELSE 0 END,'FM9999990.00') AS bucket_31_60,
  TO_CHAR(CASE WHEN balance>0 AND days_past_due BETWEEN 61 AND 90 THEN balance ELSE 0 END,'FM9999990.00') AS bucket_61_90,
  TO_CHAR(CASE WHEN balance>0 AND days_past_due>90 THEN balance ELSE 0 END,'FM9999990.00') AS bucket_90_plus,
  TO_CHAR(NVL(balance,0),'FM9999990.00') AS total_due
FROM balances b JOIN Leases l ON l.id=b.lease_id
ORDER BY l.unit_no
"""

def fetch_all(sql):
    conn = get_conn()
    cur = conn.cursor()
    cur.execute(sql)
    cols = [c[0] for c in cur.description]
    rows = [dict(zip(cols, r)) for r in cur.fetchall()]
    if DB_DRIVER == "sqlite":
        conn.close()
    else:
        cur.close(); conn.close()
    return rows

@app.get("/health")
def health():
    return {"ok": True, "driver": DB_DRIVER}

@app.get("/rent-roll")
def rent_roll():
    sql = RENT_ROLL_SQLITE if DB_DRIVER == "sqlite" else RENT_ROLL_ORACLE
    return JSONResponse(fetch_all(sql))

@app.get("/ar-aging")
def ar_aging():
    sql = AGING_SQLITE if DB_DRIVER == "sqlite" else AGING_ORACLE
    return JSONResponse(fetch_all(sql))

@app.get("/api/tenant-analysis")
def tenant_analysis():
    rent_sql = RENT_ROLL_SQLITE if DB_DRIVER == "sqlite" else RENT_ROLL_ORACLE
    aging_sql = AGING_SQLITE if DB_DRIVER == "sqlite" else AGING_ORACLE
    rent_data = fetch_all(rent_sql)
    aging_data = fetch_all(aging_sql)
    
    total_tenants = len(rent_data)
    active_leases = len([r for r in rent_data if float(r.get('month_balance', '0').replace('$', '') or 0) >= 0])
    at_risk = len([a for a in aging_data if float(a.get('total_due', '0').replace('$', '') or 0) > 0])
    
    # Top tenants by balance
    top_tenants = sorted(rent_data, key=lambda x: float(x.get('month_balance', '0').replace('$', '') or 0), reverse=True)[:3]
    
    # Payment behavior
    on_time_payments = len([r for r in rent_data if float(r.get('monthly_payments', '0').replace('$', '') or 0) >= float(r.get('monthly_charges', '0').replace('$', '') or 0) * 0.9])
    
    return JSONResponse({
        "summary": {
            "total_tenants": total_tenants,
            "active_leases": active_leases,
            "at_risk_count": at_risk,
            "on_time_payment_rate": round((on_time_payments / total_tenants * 100) if total_tenants > 0 else 0, 1)
        },
        "top_tenants": top_tenants,
        "aging_breakdown": {
            "total_overdue": sum(float(a.get('total_due', '0').replace('$', '') or 0) for a in aging_data),
            "by_bucket": {
                "0_30": sum(float(a.get('bucket_0_30', '0').replace('$', '') or 0) for a in aging_data),
                "31_60": sum(float(a.get('bucket_31_60', '0').replace('$', '') or 0) for a in aging_data),
                "61_90": sum(float(a.get('bucket_61_90', '0').replace('$', '') or 0) for a in aging_data),
                "90_plus": sum(float(a.get('bucket_90_plus', '0').replace('$', '') or 0) for a in aging_data)
            }
        }
    })

@app.get("/api/financial-insights")
def financial_insights():
    rent_sql = RENT_ROLL_SQLITE if DB_DRIVER == "sqlite" else RENT_ROLL_ORACLE
    rent_data = fetch_all(rent_sql)
    
    total_charges = sum(float(r.get('monthly_charges', '0').replace('$', '') or 0) for r in rent_data)
    total_payments = sum(float(r.get('monthly_payments', '0').replace('$', '') or 0) for r in rent_data)
    total_balance = total_charges - total_payments
    
    collection_rate = (total_payments / total_charges * 100) if total_charges > 0 else 0
    avg_lease_value = total_charges / len(rent_data) if rent_data else 0
    
    # Revenue trend (simulated - would come from historical data)
    projected_next_month = total_charges * 1.02  # 2% growth assumption
    
    return JSONResponse({
        "revenue": {
            "total_charges": round(total_charges, 2),
            "total_payments": round(total_payments, 2),
            "outstanding": round(total_balance, 2),
            "collection_rate": round(collection_rate, 1),
            "avg_lease_value": round(avg_lease_value, 2)
        },
        "projections": {
            "next_month_projected": round(projected_next_month, 2),
            "growth_rate": 2.0
        },
        "recommendations": [
            "Focus on collecting outstanding balances to improve cash flow",
            f"Collection rate of {round(collection_rate, 1)}% indicates {'good' if collection_rate > 90 else 'needs improvement'} payment behavior",
            "Consider incentives for early payments to improve collection rate"
        ]
    })

@app.get("/api/property-metrics")
def property_metrics():
    rent_sql = RENT_ROLL_SQLITE if DB_DRIVER == "sqlite" else RENT_ROLL_ORACLE
    rent_data = fetch_all(rent_sql)
    
    total_units = len(set(r.get('unit_no', '') for r in rent_data))
    occupied_units = len(rent_data)
    occupancy_rate = (occupied_units / total_units * 100) if total_units > 0 else 0
    
    # Revenue per unit
    total_revenue = sum(float(r.get('monthly_charges', '0').replace('$', '') or 0) for r in rent_data)
    revenue_per_unit = total_revenue / occupied_units if occupied_units > 0 else 0
    
    # Unit performance
    units = {}
    for r in rent_data:
        unit = r.get('unit_no', '')
        if unit not in units:
            units[unit] = {"charges": 0, "payments": 0, "balance": 0}
        units[unit]["charges"] += float(r.get('monthly_charges', '0').replace('$', '') or 0)
        units[unit]["payments"] += float(r.get('monthly_payments', '0').replace('$', '') or 0)
        units[unit]["balance"] += float(r.get('month_balance', '0').replace('$', '') or 0)
    
    top_performing = sorted(units.items(), key=lambda x: x[1]["payments"], reverse=True)[:3]
    
    return JSONResponse({
        "occupancy": {
            "total_units": total_units,
            "occupied": occupied_units,
            "vacant": total_units - occupied_units,
            "occupancy_rate": round(occupancy_rate, 1)
        },
        "revenue": {
            "total_monthly": round(total_revenue, 2),
            "per_unit": round(revenue_per_unit, 2),
            "annualized": round(total_revenue * 12, 2)
        },
        "top_units": [
            {"unit": unit, "revenue": round(data["payments"], 2), "balance": round(data["balance"], 2)}
            for unit, data in top_performing
        ],
        "insights": [
            f"Occupancy rate of {round(occupancy_rate, 1)}% is {'excellent' if occupancy_rate > 90 else 'good' if occupancy_rate > 75 else 'needs improvement'}",
            f"Average revenue per unit: ${round(revenue_per_unit, 2)}",
            f"Potential annual revenue: ${round(total_revenue * 12, 2)}"
        ]
    })

@app.get("/api/lease-details")
def lease_details():
    if DB_DRIVER == "sqlite":
        sql = """
        SELECT l.id, l.tenant_name, l.unit_no, l.start_date, l.end_date, l.monthly_rent,
               COUNT(DISTINCT c.id) as charge_count,
               COUNT(DISTINCT p.id) as payment_count,
               COALESCE(SUM(c.amount), 0) as total_charges,
               COALESCE(SUM(p.amount), 0) as total_payments
        FROM Leases l
        LEFT JOIN Charges c ON c.lease_id = l.id
        LEFT JOIN Payments p ON p.lease_id = l.id
        GROUP BY l.id, l.tenant_name, l.unit_no, l.start_date, l.end_date, l.monthly_rent
        ORDER BY l.unit_no
        """
    else:
        sql = """
        SELECT l.id, l.tenant_name, l.unit_no, l.start_date, l.end_date, l.monthly_rent,
               COUNT(DISTINCT c.id) as charge_count,
               COUNT(DISTINCT p.id) as payment_count,
               NVL(SUM(c.amount), 0) as total_charges,
               NVL(SUM(p.amount), 0) as total_payments
        FROM Leases l
        LEFT JOIN Charges c ON c.lease_id = l.id
        LEFT JOIN Payments p ON p.lease_id = l.id
        GROUP BY l.id, l.tenant_name, l.unit_no, l.start_date, l.end_date, l.monthly_rent
        ORDER BY l.unit_no
        """
    return JSONResponse(fetch_all(sql))

@app.get("/", response_class=HTMLResponse)
def home(request: Request):
    rent = fetch_all(RENT_ROLL_SQLITE if DB_DRIVER == "sqlite" else RENT_ROLL_ORACLE)
    aging = fetch_all(AGING_SQLITE if DB_DRIVER == "sqlite" else AGING_ORACLE)
    return templates.TemplateResponse("index.html", {"request": request, "rent": rent, "aging": aging})


