#!/usr/bin/env python3
import argparse, json, os, sys
from pathlib import Path
from datetime import datetime

IGNORES = {
    ".git", ".cache", ".next", "node_modules", "__pycache__", ".venv", "venv", "env",
    ".DS_Store", ".idea", ".vscode", ".pytest_cache", "dist", "build", ".terraform"
}

def human_bytes(n: int) -> str:
    step = 1024.0
    units = ["B", "KB", "MB", "GB", "TB"]
    i = 0
    x = float(n)
    while x >= step and i < len(units) - 1:
        x /= step
        i += 1
    return f"{x:.1f} {units[i]}"

def detect_stack(root: Path) -> dict:
    info = {"project_type":"Unknown","tech_stack":[],"flags":[]}
    def has(p): return (root / p).exists()
    def read(p):
        try: return (root / p).read_text(encoding="utf-8", errors="ignore")
        except: return ""

    pkg = read("package.json")
    if pkg:
        info["project_type"] = "Node.js/JavaScript"
        info["tech_stack"].append("Node.js")
        if ("next" in pkg) or has("pages") or has("app"):
            info["project_type"] = "Next.js Web App"
            info["tech_stack"].append("Next.js")
        if "react" in pkg: info["tech_stack"].append("React")
        if "tailwind" in pkg: info["tech_stack"].append("Tailwind CSS")
        if "ffmpeg" in pkg: info["tech_stack"].append("Video Processing")
        if "supabase" in pkg: info["tech_stack"].append("Supabase Database")
        if has("src"): info["tech_stack"].append("Frontend")
        if has("public"): info["tech_stack"].append("Web App")

    py_files = list(root.rglob("*.py"))
    if py_files:
        info["tech_stack"].append("Python")
        if info["project_type"] == "Unknown":
            info["project_type"] = "Python"
        else:
            info["project_type"] = f"Hybrid Python + {info['project_type']}"
        if has("requirements.txt"): info["tech_stack"].append("pip")
        names = [p.name.lower() for p in py_files]
        if any("flask" in n for n in names) or has("app.py"):
            info["tech_stack"].append("Flask")
        if any("django" in n for n in names):
            info["tech_stack"].append("Django")

    if list(root.rglob("*.csproj")):
        info["project_type"] = "C#/.NET"; info["tech_stack"] += ["C#", ".NET"]
    if has("pom.xml"):
        info["project_type"] = "Java/Maven"; info["tech_stack"] += ["Java","Maven"]
    if list(root.rglob("*.java")) and "Java" not in info["tech_stack"]:
        info["tech_stack"].append("Java")
    if has("Cargo.toml"):
        info["project_type"] = "Rust"; info["tech_stack"] += ["Rust","Cargo"]

    if has(".git"): info["flags"].append("Git repository")
    if has("Dockerfile"): info["flags"].append("Dockerfile present")
    if has(".github"): info["flags"].append("GitHub Actions/workflows")
    if has("tests") or has("test"): info["flags"].append("Test folder present")
    if has("node_modules"): info["flags"].append("node_modules installed")
    if has(".venv") or has("venv") or has("env"): info["flags"].append("Python virtual environment")
    return info

def list_top_level(root: Path):
    rows = []
    for p in sorted(root.iterdir(), key=lambda x: (x.is_file(), x.name.lower())):
        if p.name in IGNORES: continue
        try:
            size = p.stat().st_size if p.is_file() else sum(f.stat().st_size for f in p.rglob('*') if f.is_file())
        except: size = 0
        try:
            mtime = datetime.fromtimestamp(p.stat().st_mtime).strftime("%Y-%m-%d %H:%M:%S")
        except: mtime = "?"
        rows.append({"name": p.name + ("/" if p.is_dir() else ""),
                     "size_bytes": size,
                     "size_human": human_bytes(size),
                     "last_modified": mtime})
    return rows

def collect_stats(root: Path):
    files = [p for p in root.rglob("*") if p.is_file() and not any(seg in IGNORES for seg in p.parts)]
    total_size = sum(p.stat().st_size for p in files) if files else 0
    code_files = [p for p in files if p.suffix.lower() in {".py",".js",".jsx",".ts",".tsx",".cs",".java",".cpp",".c"}]
    return {"total_files": len(files),
            "code_files": len(code_files),
            "project_size_bytes": total_size,
            "project_size_human": human_bytes(total_size)}

def sample_files(root: Path, max_lines: int):
    samples = []
    patterns = ["*.py","*.js","*.jsx","*.ts","*.tsx","package.json","requirements.txt","Dockerfile"]
    seen = set()
    for pat in patterns:
        for p in root.rglob(pat):
            if any(seg in IGNORES for seg in p.parts): continue
            rp = p.resolve()
            if rp in seen: continue
            seen.add(rp)
            try:
                with p.open("r", encoding="utf-8", errors="ignore") as f:
                    lines = f.readlines()
                head = "".join(lines[:max_lines])
                remainder = max(0, len(lines) - max_lines)
            except Exception as e:
                head, remainder = f"<<Unable to read file: {e}>>", 0
            samples.append({"path": str(p.relative_to(root)),
                            "bytes": p.stat().st_size,
                            "preview_lines": max_lines,
                            "remainder_lines": remainder,
                            "preview": head})
    return samples

def build_report(root: Path, fmt: str, max_lines: int):
    det = detect_stack(root)
    stats = collect_stats(root)
    top = list_top_level(root)
    samples = sample_files(root, max_lines=max_lines)
    now = datetime.now()
    data = {
        "project": root.name,
        "generated_at": now.strftime("%Y-%m-%d %H:%M:%S"),
        "location": str(root.resolve()),
        "overview": det,
        "top_level": top,
        "stats": stats,
        "samples": samples,
    }

    if fmt == "json":
        return json.dumps(data, indent=2, ensure_ascii=False)

    if fmt == "markdown":
        out = []
        out.append(f"# Project Snapshot: {root.name}")
        out.append(f"_Generated: {data['generated_at']} • Location: {data['location']}_\n")
        out.append("## Overview")
        out.append(f"- **Project Type:** " + data["overview"]["project_type"])
        out.append(f"- **Tech Stack:** " + (\", \".join(data['overview']['tech_stack']) or "—"))
        out.append(f"- **Flags:** " + (\", \".join(data['overview']['flags']) or "—"))
        out.append(\"\\n## Directory (Top Level)\")
        out.append(\"| Name | Size | Last Modified |\")
        out.append(\"|---|---:|---|\")
        for r in top:
            out.append(f\"| `{r['name']}` | {r['size_human']} | {r['last_modified']} |\")
        out.append(\"\\n## Stats\")
        out.append(f\"- Total Files: **{stats['total_files']}**\")
        out.append(f\"- Code Files: **{stats['code_files']}**\")
        out.append(f\"- Project Size: **{stats['project_size_human']}**\")
        out.append(\"\\n## Samples (first lines)\")
        for s in samples:
            out.append(f\"\\n**`{s['path']}`**  \\nBytes: {s['bytes']} • Preview lines: {s['preview_lines']} • Remainder: {s['remainder_lines']}\")
            out.append(\"\\n```\")
            out.append(s['preview'])
            out.append(\"```\")
        return \"\\n\".join(out)

    # default text output
    out = []
    out.append(\"=\"*80)
    out.append(f\"PROJECT SNAPSHOT: {root.name}\")
    out.append(f\"Generated: {data['generated_at']}\")
    out.append(f\"Location: {data['location']}\")
    out.append(\"=\"*80 + \"\\n\")
    out.append(\"=== PROJECT OVERVIEW ===\")
    out.append(f\"Project Type: {data['overview']['project_type']}\")
    out.append(\"Tech Stack: \" + (\", \".join(data['overview']['tech_stack']) or \"—\"))
    out.append(\"Flags: \" + (\", \".join(data['overview']['flags']) or \"—\"))
    out.append(\"\\n=== DIRECTORY (TOP LEVEL) ===\")
    for r in top:
        out.append(f\"{r['name']:<35} {r['size_human']:>10}   {r['last_modified']}\")
    out.append(\"\\n=== STATS ===\")
    out.append(f\"Total Files: {stats['total_files']}\")
    out.append(f\"Code Files: {stats['code_files']}\")
    out.append(f\"Project Size: {stats['project_size_human']}\")
    out.append(\"\\n=== SAMPLES (first lines) ===\")
    for s in samples:
        out.append(f\"\\n--- {s['path']} ---  [{s['bytes']} bytes; preview {s['preview_lines']} lines; remainder {s['remainder_lines']}]\")
        out.append(s['preview'])
        if s['remainder_lines'] > 0:
            out.append(\"... (file continues)\")
    return \"\\n\".join(out)

def main():
    parser = argparse.ArgumentParser(description=\"Universal Project Scanner (Python CLI)\")
    parser.add_argument(\"--path\", default=\".\", help=\"Project root to scan (default: current directory)\")
    parser.add_argument(\"--format\", choices=[\"text\",\"json\",\"markdown\"], default=\"text\", help=\"Output format\")
    parser.add_argument(\"--output\", default=\"auto\", help=\"'auto' for timestamped file, a filename, or '-' for stdout\")
    parser.add_argument(\"--max-lines\", type=int, default=50, help=\"Preview lines per file\")
    args = parser.parse_args()

    root = Path(args.path).resolve()
    if not root.exists() or not root.is_dir():
        print(f\"Invalid path: {root}\", file=sys.stderr)
        sys.exit(2)

    report = build_report(root, fmt=args.format, max_lines=args.max_lines)

    # Output
    if args.output == \"-\":
        print(report)
        return
    if args.output == \"auto\":
        ts = datetime.now().strftime(\"%Y-%m-%d_%H-%M-%S\")
        ext = \"txt\" if args.format == \"text\" else \"json\" if args.format == \"json\" else \"md\"
        fname = f\"{root.name}-snapshot-{ts}.{ext}\"
        out_path = Path(fname)
    else:
        out_path = Path(args.output)

    try:
        out_path.write_text(report, encoding=\"utf-8\")
        print(f\"Snapshot written to: {out_path}\")
    except Exception as e:
        print(f\"Failed to write output: {e}\", file=sys.stderr)
        print(report)

if __name__ == \"__main__\":
    main()
