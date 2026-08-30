from __future__ import annotations

import csv
import json
import os
import subprocess
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]


class ProductContractTests(unittest.TestCase):
    def test_repository_has_one_fixed_target_contract(self) -> None:
        binding = json.loads(
            (REPO_ROOT / "hardware" / "binding.json").read_text(encoding="utf-8")
        )
        artifact = json.loads(
            (REPO_ROOT / "config" / "artifact.json").read_text(encoding="utf-8")
        )
        app = json.loads(
            (REPO_ROOT / "sources" / "gar-servo-pet" / "app.json").read_text(
                encoding="utf-8"
            )
        )
        self.assertEqual("gar-servo-pet", binding["product"])
        self.assertEqual("luckfox-rk3506", binding["target"])
        self.assertEqual("luckfox-rk3506", artifact["target"])
        self.assertEqual("gar-servo-pet", app["id"])
        self.assertTrue((REPO_ROOT / "scripts" / "target" / "package.sh").is_file())

    def test_runtime_i2c_matches_binding(self) -> None:
        binding = json.loads(
            (REPO_ROOT / "hardware" / "binding.json").read_text(encoding="utf-8")
        )["interfaces"][0]
        with (REPO_ROOT / "hardware" / "i2c.csv").open(
            encoding="utf-8", newline=""
        ) as handle:
            row = next(csv.DictReader(handle))
        self.assertEqual(binding["bus"], int(row["bus"]))
        self.assertEqual(binding["device"], row["dev"])
        self.assertEqual(int(binding["address"], 0), int(row["address"], 0))
        self.assertEqual("I2C1", binding["controller"])
        self.assertEqual({"SDA": "17:RM_IO11", "SCL": "19:RM_IO10"}, binding["pins"])

    def test_dispatcher_is_absent_and_foreign_target_is_rejected(self) -> None:
        self.assertFalse((REPO_ROOT / "scripts" / "package-target.sh").exists())
        self.assertFalse((REPO_ROOT / "scripts" / "package_target.py").exists())
        self.assertFalse(any((REPO_ROOT / "config" / "deployments").glob("*.json")))
        environment = dict(os.environ)
        environment["GAR_TARGET"] = "frdm-imx91s"
        result = subprocess.run(
            (str(REPO_ROOT / "scripts" / "product-target-build.sh"), "clean"),
            cwd=REPO_ROOT,
            env=environment,
            check=False,
            text=True,
            capture_output=True,
        )
        self.assertEqual(2, result.returncode)
        self.assertIn("fixed target luckfox-rk3506", result.stderr)


if __name__ == "__main__":
    unittest.main()
