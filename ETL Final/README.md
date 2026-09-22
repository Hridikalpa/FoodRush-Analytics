# FoodRush ETL & Data Quality

This folder documents the data-preparation layer used in the FoodRush Analytics case study.

## Structure

```text
ETL Final/
├── Production/
│   ├── etl_production_ticket1.sql
│   └── etl_production_ticket2.sql
└── Training/
    ├── Training_ETL_Ticket1.sql
    ├── Training_ETL_Ticket2.sql
    └── Training_ETL_Ticket3.sql
```

## Production-oriented work

### Ticket 1 — Extract source data
Creates a raw copy of the source orders data so the downstream ETL work can be rerun, audited and debugged without modifying the source.

### Ticket 2 — Data profiling
Profiles the raw orders data for completeness, duplicate keys, categorical distributions and potential data-quality issues before transformation.

## Training work

The training tickets build the same thinking in greater depth: assess the raw data, validate/clean invalid records, preserve rejected records for auditability, standardise fields and perform final QA checks.

The training material demonstrates checks for:

- missing and blank values
- duplicate order IDs
- invalid identifiers
- inconsistent text/category values
- numeric and date validation
- business-rule violations
- rejected-record handling
- post-cleaning QA

## Core ETL principle

**Profile before cleaning. Preserve rejected records. Validate again after transformation.**

The ETL layer is intentionally shown as an auditable workflow rather than a single opaque cleaning query.
