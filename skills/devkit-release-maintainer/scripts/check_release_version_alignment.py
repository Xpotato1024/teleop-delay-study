from __future__ import annotations

import argparse
import sys
from pathlib import Path


def default_repo_root() -> Path | None:
    script_path = Path(__file__).resolve()
    for parent in script_path.parents:
        if (parent / ".github" / "workflows" / "release.yml").is_file():
            return parent
    return None


def require_contains(path: Path, needle: str, label: str, failures: list[str]) -> None:
    if not path.is_file():
        failures.append(f"missing {label}: {path}")
        return
    text = path.read_text(encoding="utf-8")
    if needle not in text:
        failures.append(f"{label}: missing `{needle}` in {path}")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Check that devkit release metadata is aligned with tag-based version injection."
    )
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=None,
        help="Devkit source root containing release.yml and the devkit Rust crates.",
    )
    args = parser.parse_args()

    root = args.repo_root.resolve() if args.repo_root else default_repo_root()
    if root is None:
        print(
            "FAIL: Devkit source root was not found. Pass --repo-root to a checkout "
            "containing the release and Rust source markers.",
            file=sys.stderr,
        )
        return 2
    release_workflow = root / ".github" / "workflows" / "release.yml"
    cli_main = root / "rust" / "crates" / "devkit-cli" / "src" / "main.rs"
    installer_main = root / "rust" / "crates" / "devkit-installer" / "src" / "main.rs"

    failures: list[str] = []
    required_files = [
        (release_workflow, ".github/workflows/release.yml"),
        (cli_main, "rust/crates/devkit-cli/src/main.rs"),
        (installer_main, "rust/crates/devkit-installer/src/main.rs"),
    ]
    for path, relative_name in required_files:
        if not path.is_file():
            failures.append(f"missing {relative_name}: {path}")

    if failures:
        print("FAIL")
        for failure in failures:
            print(f"- {failure}")
        return 1

    require_contains(
        release_workflow,
        "DEVKIT_RELEASE_VERSION: ${{ github.ref_name }}",
        ".github/workflows/release.yml",
        failures,
    )
    require_contains(
        cli_main,
        'option_env!("DEVKIT_RELEASE_VERSION")',
        "rust/crates/devkit-cli/src/main.rs",
        failures,
    )
    require_contains(
        cli_main,
        "#[command(author, version = RELEASE_VERSION, about, long_about = None)]",
        "rust/crates/devkit-cli/src/main.rs",
        failures,
    )
    require_contains(
        installer_main,
        'option_env!("DEVKIT_RELEASE_VERSION")',
        "rust/crates/devkit-installer/src/main.rs",
        failures,
    )
    require_contains(
        installer_main,
        '#[command(author, version = RELEASE_VERSION, about = "Native Windows installer for devkit")]',
        "rust/crates/devkit-installer/src/main.rs",
        failures,
    )
    require_contains(
        installer_main,
        "version: RELEASE_VERSION.to_string()",
        "rust/crates/devkit-installer/src/main.rs",
        failures,
    )
    require_contains(
        installer_main,
        "installer_version: RELEASE_VERSION.to_string()",
        "rust/crates/devkit-installer/src/main.rs",
        failures,
    )

    if failures:
        print("FAIL")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("OK: release version alignment checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
