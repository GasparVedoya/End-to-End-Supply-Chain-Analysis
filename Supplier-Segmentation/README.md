# Supplier Segmentation Analysis

## Overview

This module focuses on classifying suppliers based on their strategic importance and operational complexity.

The goal is to support sourcing strategy decisions by identifying which vendors are:

- Strategic
- Bottleneck
- Leverage
- Routine

This segmentation is implemented using SQL-based scoring logic and visualized in Power BI.

---

## Analytical Framework

Suppliers are evaluated across two dimensions:

### 1. Importance Score
Measures business impact based on factors such as:
- Revenue contribution
- Spend concentration
- Profit impact

### 2. Complexity Score
Measures operational risk based on factors such as:
- Lead time
- Supply variability
- Dependency level

Each supplier is scored and plotted on a 2x2 sourcing matrix:

|                     | High Complexity | Low Complexity |
|---------------------|-----------------|----------------|
| **High Importance** | Strategic      | Leverage      |
| **Low Importance**  | Bottleneck     | Routine       |

---

## Contents

### `Supplier-Segmentation.sql`

Contains:
- Aggregation queries
- Importance score calculations
- Complexity score calculations
- Final master scorecard view combining both dimensions

This SQL layer creates the dataset used in Power BI.

---

### `sourcing_matrix_dashboard.png`

Screenshot of the Power BI sourcing matrix visualization.

The dashboard allows:
- Interactive supplier filtering
- Quadrant visualization
- Comparative analysis

---

## Key Insights Enabled

This segmentation allows decision-makers to:

- Identify high-risk suppliers
- Prioritize strategic vendor relationships
- Optimize negotiation leverage
- Reduce operational bottlenecks

---

## Role in Overall Project

Supplier segmentation represents the first analytical milestone in the broader Supply Chain Optimization framework.

It serves as the foundation for:

- Vendor profitability analysis
- Lead time risk modeling
- Inventory policy adjustments
- Performance monitoring

