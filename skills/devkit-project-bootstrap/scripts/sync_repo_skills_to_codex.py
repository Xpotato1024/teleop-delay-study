from __future__ import annotations

import argparse
import os
import shutil
import sys
from pathlib import Path


def default_repo_root() -> Path | None:
    script_path = Path(__file__).resolve()
    for parent in script_path.parents:
        if (parent / "SKILLs").is_dir() and (parent / "rust").is_dir():
            return parent
    return None


def paths_overlap(first: Path, second: Path) -> bool:
    try:
        return os.path.commonpath((first, second)) in {str(first), str(second)}
    except ValueError:
        return False


def copy_tree(source: Path, destination: Path) -> None:
    destination.mkdir(parents=True, exist_ok=True)
    for child in source.iterdir():
        target = destination / child.name
        if child.is_dir():
            if target.exists():
                shutil.rmtree(target)
            shutil.copytree(child, target)
        else:
            shutil.copy2(child, target)


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Sync Devkit source SKILLs into a destination. Existing destination "
            "skill directories are replaced; use --dry-run to inspect first."
        )
    )
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=None,
        help="Devkit source root containing SKILLs/ and rust/. Auto-detected only from those markers.",
    )
    parser.add_argument(
        "--codex-skills",
        type=Path,
        default=Path.home() / ".codex" / "skills",
        help="Destination directory; existing matching skill directories are replaced.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="List source skills and destination without changing the filesystem.",
    )
    args = parser.parse_args()

    repo_root = (args.repo_root or default_repo_root())
    if repo_root is None:
        print(
            "FAIL: Devkit source root was not found. Pass --repo-root to a checkout "
            "containing both SKILLs/ and rust/.",
            file=sys.stderr,
        )
        return 2

    repo_root = repo_root.resolve()
    codex_skills = args.codex_skills.resolve()
    source_root = repo_root / "SKILLs"

    missing_markers = []
    if not source_root.is_dir():
        missing_markers.append(source_root)
    if not (repo_root / "rust").is_dir():
        missing_markers.append(repo_root / "rust")
    if missing_markers:
        print("FAIL: not a Devkit source checkout; missing:", file=sys.stderr)
        for marker in missing_markers:
            print(f"- {marker}", file=sys.stderr)
        return 2
    if paths_overlap(repo_root, codex_skills):
        print(
            "FAIL: source and destination are identical or one contains the other; refusing replacement.",
            file=sys.stderr,
        )
        return 2

    skill_dirs = [
        skill_dir
        for skill_dir in sorted(source_root.iterdir())
        if skill_dir.is_dir() and (skill_dir / "SKILL.md").is_file()
    ]

    print(f"Source: {repo_root}")
    print(f"Destination: {codex_skills}")
    for skill_dir in skill_dirs:
        print(f"- {skill_dir.name}")

    if args.dry_run:
        print(f"DRY-RUN: no changes made; {len(skill_dirs)} skills would be synced.")
        return 0

    codex_skills.mkdir(parents=True, exist_ok=True)

    copied: list[str] = []
    for skill_dir in skill_dirs:
        copy_tree(skill_dir, codex_skills / skill_dir.name)
        copied.append(skill_dir.name)

    print(f"OK: synced {len(copied)} skills to {codex_skills}")
    for name in copied:
        print(f"- {name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
