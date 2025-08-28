# Playbooks

This folder is for Logic App **playbooks** associated with the project.

## Export your working playbook

In the Azure portal (Logic Apps Designer):
- Open your playbook (e.g., `PB-Notify-SSHBruteForce`)
- **Export template** (ARM) and save it here as `PB-Notify-SSHBruteForce.json`

> Exported files may include connection references (e.g., Office 365, Teams). If you intend others to deploy them, redact secrets and add instructions to create connections after deployment.

## Sample skeleton (optional)

`PB-Notify-SSHBruteForce.sample.json` is a minimal, **non-functional** skeleton that illustrates a Sentinel trigger and a single action placeholder.