# Azure Sentinel: SSH Brute Force Detections + VM Power Correlation (KQL, SIEM, SOAR)

> **Tech stack:** Microsoft Sentinel (SIEM), Microsoft Defender, Azure Monitor / Log Analytics, KQL, Logic Apps (SOAR), Linux (Ubuntu), Syslog (auth/authpriv), Azure Activity, AMA/DCR

[![Made with Microsoft Sentinel](https://img.shields.io/badge/Microsoft%20Sentinel-SIEM%2FSOAR-blue)](#)
[![KQL](https://img.shields.io/badge/KQL-queries-success)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

This repo packages a one-day, **cost-free** hands-on project that demonstrates **cloud security monitoring** on Azure with **Microsoft Sentinel** and **KQL**. It includes two working detections, incident entity mapping, and a **SOAR playbook** that notifies on incidents.

---

## What you’ll build (highlights)

- **KQL detections**
  - `SSH failed login bursts` (≥5 failures in 5 minutes)
  - `SSH burst + VM power operation correlation` (restart/deallocate within ±30 min)
- **Sentinel Analytics rules** with **entity mapping** (IP, Host, Account)
- **SOAR Automation**: Logic App playbook to notify when incidents are created
- **Attack simulation** scripts to generate signals (zsh/expect)
- **Portfolio-ready docs and screenshots**

---

## Architecture

```mermaid
flowchart LR
  A[Attacker (Mac zsh)] -->|sshpass / expect| B[Linux VM]
  B -->|Syslog auth/authpriv| C[AMA/DCR -> Log Analytics Workspace]
  D[Azure Activity (Administrative)] --> C
  C -->|KQL queries| E[Microsoft Sentinel]
  E -->|Analytics Rules| F[Incidents]
  F -->|Automation Rule| G[Logic App Playbook (Notify)]
  G --> H[Email/Teams/Webhook]
```

**Data sources:** `Syslog` (Linux auth/authpriv) and `AzureActivity` (Administrative) into **Log Analytics Workspace (LAW)** via **AMA/DCR**.  
**Detection:** KQL scheduled analytics rules in **Sentinel**.  
**Response:** **Logic App** playbook invoked by **Automation Rule** on incident creation.

---

## Repository structure

```
azure-sentinel-kql-ssh/
├─ README.md
├─ LICENSE
├─ .gitignore
├─ queries/
│  ├─ ssh_failed_bursts.kql
│  └─ ssh_burst_correlated_vm_power.kql
├─ scripts/
│  ├─ simulate_ssh_bruteforce.sh
│  └─ simulate_ssh_bruteforce_expect.exp
├─ playbooks/
│  ├─ PB-Notify-SSHBruteForce.sample.json   # optional: example skeleton
│  └─ README.md                              # export/import tips
├─ screenshots/
│  ├─ incidents/...
│  ├─ alerts/...
│  └─ playbook/...
└─ .github/workflows/
   └─ basic-lint.yml                         # optional repo hygiene
```

---

## Prerequisites (what I used)

- Azure subscription with **Microsoft Sentinel** enabled on a **Log Analytics Workspace**
- One **Linux VM** (Ubuntu/Debian) with `syslog` forwarding (**auth**, **authpriv**)
- **AMA/DCR** configured to send Syslog to the LAW
- **Azure Activity** (Administrative) exported to the same LAW

> **Tip:** Keep resources in the same region and stop/deallocate the VM when not testing to remain in free tier.

---

## KQL Detections

### 1) SSH Failed Login Bursts

- Triggers on ≥5 failed SSH logins within 5 minutes from a single IP
- Extracts client IP from `Syslog` message
- Maps entities: **Host**, **IP**

File: [`queries/ssh_failed_bursts.kql`](queries/ssh_failed_bursts.kql)

### 2) SSH Burst Correlated with VM Power Ops

- If an SSH failure burst occurs, checks whether the **VM was restarted/deallocated** within ±30 minutes
- Normalizes VM names via `Heartbeat`
- Maps entities: **Host**, **IP**, **Account** (optional from Azure Activity Caller)

File: [`queries/ssh_burst_correlated_vm_power.kql`](queries/ssh_burst_correlated_vm_power.kql)

---

## Sentinel: Analytics Rules

**Schedule suggestion:** run every 5 minutes, lookup 10 minutes (rule 1) / 60 minutes (rule 2).  
**Alert threshold:** trigger when results ≥ 3.  
**Entity mapping:** IP → `SourceIp`, Host → `HostName`/`Computer`, Account → `Caller` (rule 2).

> You can paste each KQL file into a **Scheduled query rule** wizard in Sentinel. For portability, keep the KQL here and optionally export rules from the portal into `playbooks/` or an `arm/` folder later.

---

## SOAR: Playbook (Logic App)

- Name: `PB-Notify-SSHBruteForce`
- Trigger: _When a response to an Azure Sentinel alert is triggered_
- Actions: Notify (email/Teams/webhook). Include incident title, severity, entities, and the query link.

You can export your working playbook from the portal and save it to `playbooks/` (see `playbooks/README.md`).

---

## Simulate the Attack (from macOS zsh)

> ⚠️ For **lab/demo** use only, against your own VM. Use a non-production, throwaway user.

- `scripts/simulate_ssh_bruteforce.sh` (uses `sshpass`)  
- `scripts/simulate_ssh_bruteforce_expect.exp` (Expect alternative)

These try multiple wrong passwords quickly to generate **Syslog** failures.

---

## Validation

1. **LAW**: verify `Syslog` shows failed SSH attempts; `AzureActivity` shows restart/deallocate.
2. **Sentinel**: confirm **Analytics rules** fire and **entities** are mapped.
3. **Incidents**: severity set to **High**, **Automation rule** calls playbook.
4. **Playbook runs**: visible under **Runs history** with payload including IP + VM.

Add **screenshots** to `screenshots/` and reference them below.

---

## Screenshots (add yours)

- Incidents list: `screenshots/incidents/incidents_list.png`
- Incident details: `screenshots/incidents/incident_details.png`
- Alert rule hit: `screenshots/alerts/alert_results.png`
- Playbook run: `screenshots/playbook/run_history.png`

---

## Cost & Cleanup

- Stop/deallocate the VM when idle.  
- Remove Analytics rules or lower frequency after demo.  
- Delete the resource group to avoid residual costs.

---

## Troubleshooting

- **No Syslog?** Confirm AMA/DCR includes `auth,authpriv` and VM is linked.
- **No AzureActivity?** Ensure export of `Administrative` category to LAW.
- **Entities not mapped?** Check the rule’s **Entity mapping** section matches column names.
- **Playbook not running?** Verify **Automation rule** is set to run the playbook on incident creation.

---

## Resume/LinkedIn blurb

> Built Microsoft Sentinel detections for SSH brute force and correlation with VM power operations; authored KQL, configured Analytics rules with entity mapping, and automated incident response with a Logic Apps playbook (SOAR). Verified end‑to‑end in Azure with Syslog + Azure Activity.

**Keywords:** Microsoft Sentinel, KQL, Azure Security, SIEM, SOAR, Logic Apps, Azure Monitor, Log Analytics, Syslog, Azure Activity, Incident Response, Detection Engineering

---

## How to use this repo

1. Clone, add your screenshots to `/screenshots`.
2. (Optional) Export your **Analytics rules** and **Playbook** and place JSON into `/playbooks`.
3. Push to your GitHub and link it on your resume.

---

## Attribution & License

MIT — see [LICENSE](LICENSE).