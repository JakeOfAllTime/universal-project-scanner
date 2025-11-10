![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Python](https://img.shields.io/badge/Python-3.8%2B-blue.svg)
![OS](https://img.shields.io/badge/OS-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)

# Universal Project Scanner

### 🧠 Universal Project Scanner
**Theme:** *Bridging human and AI understanding of codebases.*

> The Universal Project Scanner is a cross-platform introspection tool designed to generate **human- and AI-readable summaries** of entire projects.
>
> It scans directories, detects tech stacks, gathers statistics, samples key source files, and outputs structured, self-explanatory reports in text, Markdown, or JSON.
>
> The goal isn’t just analysis — it’s **translation**: turning raw codebases into context-rich overviews that any human or AI assistant can instantly interpret, explain, or extend.
>
> Whether you’re handing a project to another developer, onboarding an AI to assist with your code, or just documenting your own work, this tool produces a “snapshot” that *speaks fluently to both worlds.*

*“Readable by humans. Understandable by AI.”*

A lightweight, **project snapshot generator** that inspects a source folder, detects language & stack,
samples important files, and emits a timestamped report you can hand to an LLM or share with teammates.

This package includes two implementations:
- **PowerShell** (original): `complete-project-snapshot.ps1`
- **Python CLI** (cross‑platform): `universal_project_scanner.py`

The Python version runs on Windows/Mac/Linux without extra dependencies (Python 3.8+).

## Features
- Detects tech stack (Node/Next.js, Python/Flask/Django, C#/.NET, Java/Maven, Rust, etc.)
- Scans directory structure and computes basic stats (file counts, total size)
- Samples **first N lines** of source files (configurable)
- Identifies common features (Git, Dockerfile, GitHub Actions, tests, virtual envs)
- Outputs **Text** (default), **JSON**, or **Markdown**

## Quick Start (Python)
```bash
# Run in the project root you want to scan
python universal_project_scanner.py

# or point to a different path
python universal_project_scanner.py --path /path/to/project

# JSON output (to stdout)
python universal_project_scanner.py --format json --output -

# Markdown output to file
python universal_project_scanner.py --format markdown --output snapshot.md

# Increase preview lines per file (default 50)
python universal_project_scanner.py --max-lines 80
```

Tip: The default `--output auto` creates a timestamped file: `{folder}-snapshot-YYYY-mm-dd_HH-MM-SS.txt`

## Roadmap
- Syntax‑highlighted HTML export
- Optional redaction rules (e.g., .env)
- Pluggable detectors via JSON config
- Hash map of sampled files for diffs across snapshots


### Windows / PowerShell notes

On Windows PowerShell you may see a policy error when attempting to run `.ps1` scripts.

**Option A — (recommended)** set a per-user policy (persistent for your user; no admin usually required):
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Confirm:$false
.
complete-project-snapshot.ps1
```