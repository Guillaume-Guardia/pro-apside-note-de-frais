import re
import sys
import tomllib
from pathlib import Path


def bump_patch_version(pyproject_path: Path) -> str:
    content = pyproject_path.read_text(encoding="utf-8")
    current_version = tomllib.loads(content)["project"]["version"]
    match = re.fullmatch(
        r"(0|[1-9]\d*)\.(0|[1-9]\d*)(?:\.(0|[1-9]\d*))?",
        current_version,
    )
    if match is None:
        raise ValueError(f"Unsupported project version: {current_version}")

    major, minor, patch = match.groups()
    next_version = f"{major}.{minor}.{int(patch or 0) + 1}"
    version_line = re.compile(rf'(?m)^version\s*=\s*"{re.escape(current_version)}"\s*$')
    updated_content, replacements = version_line.subn(
        f'version = "{next_version}"',
        content,
        count=1,
    )
    if replacements != 1:
        raise ValueError("Could not locate the project version in pyproject.toml")

    pyproject_path.write_text(updated_content, encoding="utf-8")
    return next_version


if __name__ == "__main__":
    project_file = Path(__file__).resolve().parents[1] / "pyproject.toml"
    print(bump_patch_version(project_file))
