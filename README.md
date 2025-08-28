# Azure Sentinel: SSH Brute Force Detections + VM Power Correlation (KQL, SIEM, SOAR)

> **Stack used:** Microsoft Sentinel (SIEM), Microsoft Defender, Azure Monitor / Log Analytics, KQL, Logic Apps (SOAR), Linux (Ubuntu), Syslog (auth/authpriv), Azure Activity, AMA/DCR

I built a one‑day, cost‑free lab that demonstrates **cloud security monitoring** on Azure with **Microsoft Sentinel** and **KQL**. The project includes two detections, incident entity mapping, and a **SOAR playbook** that notifies on incidents. This repo captures my queries, scripts used for signal generation, and evidence (screenshots) of the end‑to‑end flow.

---

## Architecture I used

```mermaid
flowchart LR
  A[Attacker (Mac zsh)] --> B[Linux VM]
  A -. "sshpass & expect" .- B
  B --> C[AMA/DCR → Log Analytics Workspace]
  D[Azure Activity (Administrative)] --> C
  C --> E[Microsoft Sentinel]
  E --> F[Incidents]
  F --> G[Automation Rule]
  G --> H[Logic App Playbook (Notify)]
  H --> I[Email/Teams/Webhook]
```

**Data sources:** `Syslog` (Linux auth/authpriv) and `AzureActivity` (Administrative) into **Log Analytics Workspace (LAW)** via **AMA/DCR**.  
**Detection:** KQL scheduled analytics rules in **Sentinel**.  
**Response:** **Logic App** playbook invoked by **Automation Rule** on incident creation.

---

## What I built

- **KQL detections**
  - **SSH failed login bursts** — triggers on **≥3** failures in a **5‑minute** window; extracts client IP; maps Host + IP.
  - **SSH burst + VM power correlation** — checks for VM restart/deallocate near an SSH burst (±30 minutes); normalizes VM names via `Heartbeat`; maps Host + IP (+ optional Account from Azure Activity).
- **Sentinel Analytics rules** with **entity mapping** (IP, Host, Account).
- **SOAR Automation** (Logic App playbook) to notify when incidents are created.
- **Signal generation** via short zsh/expect scripts to simulate SSH failures.
- **Validation evidence**: incidents, alerts, and playbook run screenshots included.

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
├─ scripts/                # small utilities I used to generate signals in my lab
│  ├─ simulate_ssh_bruteforce.sh
│  └─ simulate_ssh_bruteforce_expect.exp
├─ playbooks/
│  ├─ PB-Notify-SSHBruteForce.sample.json   # placeholder skeleton; I exported my real playbook to JSON
│  └─ README.md
├─ screenshots/            # evidence of detections/incidents/playbook runs
└─ .github/workflows/
   └─ basic-lint.yml
```

---

## Detections I wrote (KQL)

### SSH Failed Login Bursts (≥3 in 5 minutes)

- Detects rapid SSH authentication failures from a single source IP against the VM.
- Extracts the client IP from Syslog and emits Host/IP entities for Sentinel.

File: [`queries/ssh_failed_bursts.kql`](queries/ssh_failed_bursts.kql)

### SSH Burst Correlated with VM Power Operations

- Associates an SSH failure burst with **VM restart/deallocate** operations within ±30 minutes.
- Uses `Heartbeat` for simple host normalization and maps Host/IP (+ optional `Caller`).

File: [`queries/ssh_burst_correlated_vm_power.kql`](queries/ssh_burst_correlated_vm_power.kql)

---

## Validation (what I confirmed)

1. **LAW ingestion**: `Syslog` showed failed SSH attempts; `AzureActivity` captured restart/deallocate operations.
2. **Analytics Rules**: scheduled every 5 minutes; lookup 10–60 minutes depending on rule; entity mapping populated IP/Host (and Account when available).
3. **Incidents**: created with **High** severity during tests; entities accurately reflected attacker IP and VM.
4. **SOAR**: my automation rule invoked the **PB‑Notify‑SSHBruteForce** Logic App; run history showed incident context.

Screenshots are under `/screenshots`:
- `screenshots/incidents/*.png`
- `screenshots/alerts/*.png`
- `screenshots/playbook/*.png`

---

## Notes

- This repository is a record of **what I built and verified**. It’s not a step‑by‑step guide; however, the KQL and playbook export (if shared) provide enough context to understand the implementation details.
- Resources were kept within free/low‑cost tiers; the VM was deallocated when idle.

---

## Resume/LinkedIn blurb

> Built Microsoft Sentinel detections for SSH brute force (**≥3 in 5 min**) and correlation with VM power operations; authored KQL, configured Analytics rules with entity mapping, and automated incident response with a Logic Apps playbook (SOAR). Validated end‑to‑end using Syslog and Azure Activity in Log Analytics.

**Keywords:** Microsoft Sentinel, KQL, Azure Security, SIEM, SOAR, Logic Apps, Azure Monitor, Log Analytics, Syslog, Azure Activity, Incident Response, Detection Engineering

---

## License

MIT — see [LICENSE](LICENSE).