# CLAUDE.md — Cart.Pay (Payment Intake Microservice)

**MemberMinder Pro, LLC**
**Last Updated:** May 26, 2026

---

## Stop — Read This First

This repository is a **legacy ColdFusion codebase**. It is **read-only reference material** for the CART Fund Rebuild project. Do not modify any file in this repository. Do not commit to this repository during the rebuild.

**The authoritative project instructions are in the `api` repository:**

```
~/workbench/mmp/clients/CART Fund/repositories/api/CLAUDE.md
```

Read that file before doing any work related to the CART Fund Rebuild. Everything here is context only.

---

## What This Repository Is

`Cart.Pay` is a **standalone payment intake microservice** for the CART Fund platform. It is a separate deployed web application — not a library included by the main `Cart` app. It handles:

- **Payment form submission** — the user-facing page that collects payment details
- **IPPay token flow** — tokenized credit card processing via IPPay (`IP/` directory)
- **Credit card transaction logging** — `CCLogDAO.cfc` (this table does not appear in the main `Cart` repo)
- **Contribution recording** — writing the resulting donation to the database after successful payment
- **Receipt generation** — `ReceiptDAO.cfc`

It is one of three legacy CF repositories that make up the CART Fund platform:

| Repository                | Purpose                                                    |
| ------------------------- | ---------------------------------------------------------- |
| `Cart`                    | Main web application                                       |
| `Cart.Sched`              | Scheduled job runner — EFT processing, data sync           |
| `Cart.Pay` ← you are here | Payment intake microservice — IPPay token flow, CC logging |

---

## Repository Layout

```
Cart.Pay/
├── CFC/                        # ColdFusion components — DAOs and business logic
│   ├── CCLogDAO.cfc            # Credit card transaction log — UNIQUE TO THIS REPO
│   ├── ConfigDAO.cfc           # App configuration
│   ├── ContributionDAO.cfc     # Contribution recording post-payment
│   ├── EFTRecurring.cfc        # Recurring EFT business logic
│   ├── EFTRecurringDAO.cfc     # Recurring EFT DB access
│   ├── GLBankAccountDAO.cfc    # GL bank account mapping
│   ├── ReceiptDAO.cfc          # Receipt storage
│   └── UserDAO.cfc             # User lookup
├── IP/                         # IPPay-specific payment flow
│   ├── Token.cfm               # IPPay tokenization — CRITICAL for payment integration
│   └── index.cfm               # IPPay payment form entry point
├── cfscript/
│   ├── Profile.cfm             # Session/user profile include
│   └── Profile_Inc.cfm
├── Images/
│   ├── logo.png
│   └── Problem.gif
├── Application.cfc             # App config, datasource definition
├── Index.cfm                   # Payment intake entry point
├── robots.txt
└── web.config                  # IIS configuration
```

---

## Critical Finding — CCLogDAO

`CFC/CCLogDAO.cfc` **only exists in this repository**. It does not appear in `Cart/` or `Cart.Sched/`. This means there is a credit card transaction log table in the database that is only written to by this microservice. Before building any payment endpoint in mmp-api, read `CCLogDAO.cfc` to understand:

- The CC log table name and schema
- What data is recorded per transaction (masked card number, processor response, status, etc.)
- Whether mmp-api needs to write to this table or simply read from it

This table must be accounted for in the payment endpoint design.

---

## Active Payment Processor — IPPay Confirmed

The presence of `IP/Token.cfm` and `IP/index.cfm` as a dedicated subdirectory confirms **IPPay is actively in use**. This is the tokenized payment flow:

1. User submits payment form (`Index.cfm`)
2. Card details are tokenized via IPPay (`IP/Token.cfm`)
3. Token is used to process the charge
4. Result is written to CCLog and Contribution tables
5. Receipt is generated

**Read `IP/Token.cfm` and `IP/index.cfm` before writing any donation intake endpoint in mmp-api.** The token flow must be replicated correctly or payments will fail.

The other two processors in the legacy `Cart/cfc-EFT/` directory (Authorize.Net, JetPay) do not have dedicated directories here. Confirm with Rob Moore whether they are active before building integrations for them.

---

## What to Read for Each Rebuild Feature

| Feature being built in mmp-api       | Read here                                         |
| ------------------------------------ | ------------------------------------------------- |
| Donation intake / payment processing | `Index.cfm`, `IP/Token.cfm`, `IP/index.cfm`       |
| IPPay token flow                     | `IP/Token.cfm`                                    |
| Credit card logging                  | `CFC/CCLogDAO.cfc`                                |
| Contribution recording               | `CFC/ContributionDAO.cfc`                         |
| Recurring EFT — payment context      | `CFC/EFTRecurring.cfc`, `CFC/EFTRecurringDAO.cfc` |
| Receipt generation                   | `CFC/ReceiptDAO.cfc`                              |
| GL bank account mapping              | `CFC/GLBankAccountDAO.cfc`                        |
| User lookup during payment           | `CFC/UserDAO.cfc`                                 |

---

## Duplicate DAOs — Important Warning

The following DAOs exist in **both this repo and in `Cart/` and/or `Cart.Sched/`**. They were likely copied and may have evolved independently:

- `ContributionDAO.cfc` — also in `Cart/cfc/` and `Cart.Sched/CFC/`
- `EFTRecurringDAO.cfc` — also in `Cart/cfc/` and `Cart.Sched/CFC/`
- `GLBankAccountDAO.cfc` — also in `Cart/cfc/` and `Cart.Sched/CFC/`
- `ReceiptDAO.cfc` — also in `Cart.Sched/CFC/`

**Always read all copies before writing any API endpoint that touches the corresponding table.** Diff them against each other. The Cart.Pay version may reflect payment-specific schema additions not present in the Cart/ version.

---

## Database

Same primary CART Fund SQL Server database as `Cart/` and `Cart.Sched/` — same `REQUEST.DSN` datasource. All three repos share one database.

---

## Do Not

- Modify any file in this repository
- Commit to this repository
- Take this application offline without confirming with Rob Moore — it is actively processing donations
- Assume this codebase's patterns represent current best practice — it is legacy code
