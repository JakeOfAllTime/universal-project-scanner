[README_Universal_Project_Scanner.md](https://github.com/user-attachments/files/23442686/README_Universal_Project_Scanner.md)
# Universal Project Scanner

A lightweight, **project snapshot generator** that inspects a source folder, detects language & stack,
samples important files, and emits a timestamped report you can hand to an LLM or share with teammates.

This package includes two implementations:
- **PowerShell** (original): `universal-project-scanner.ps1`
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
