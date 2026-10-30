# CX Data Reconciliation & Funnel Analytics (SQL)

## Overview
This repository contains end-to-end SQL scripts simulating enterprise Customer Experience (CX) data operations between CRM systems (Salesforce) and Survey platforms (Qualtrics). It focuses on identifying data quality defects, reconciling orphan/duplicate records, and aggregating key operational feedback metrics like Net Promoter Score (NPS).

## Relational Schema
The dataset models four core enterprise tables:
- **`accounts`**: Enterprise customer accounts and regional mapping.
- **`contacts`**: Customer contact records linked to account IDs.
- **`invites`**: Qualtrics survey invite logs with dispatch statuses (`delivered`, `bounced`, `sent`).
- **`responses`**: Survey score responses (0–10 scale).

## Key Data Reconciliation Focus Areas
1. **Duplicate Detection:** Identifying duplicate email entries using `GROUP BY` and `HAVING COUNT > 1`.
2. **Orphan Record Resolution:** Finding unlinked contact records using `LEFT JOIN` and `IS NULL` filters.
3. **CX Metrics Aggregation:** Calculating Net Promoter Score (NPS) programmatically via score conditional aggregation (`CASE WHEN`).
4. **Zero-Division Safeguards:** Utilizing `NULLIF()` to prevent division-by-zero errors during metric calculation.

## How to Run
Copy the contents of [`reconciliation_analysis.sql`](./reconciliation_analysis.sql) into any SQLite, PostgreSQL, or online SQL editor (e.g., [SQLiteOnline](https://sqliteonline.com/)) to execute the full schema setup, synthetic data seeding, and reconciliation queries.
