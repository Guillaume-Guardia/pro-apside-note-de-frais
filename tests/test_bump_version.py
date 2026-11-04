import tomllib

from scripts.bump_version import bump_patch_version


def test_bump_patch_version_adds_patch_to_two_part_version(tmp_path):
    pyproject = tmp_path / "pyproject.toml"
    pyproject.write_text('[project]\nname = "pyndf"\nversion = "1.2"\n', encoding="utf-8")

    assert bump_patch_version(pyproject) == "1.2.1"
    assert tomllib.loads(pyproject.read_text(encoding="utf-8"))["project"]["version"] == "1.2.1"


def test_bump_patch_version_increments_existing_patch(tmp_path):
    pyproject = tmp_path / "pyproject.toml"
    pyproject.write_text('[project]\nversion = "1.2.9"\n', encoding="utf-8")

    assert bump_patch_version(pyproject) == "1.2.10"
