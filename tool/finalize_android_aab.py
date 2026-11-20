#!/usr/bin/env python3
"""Remove optional native symbol metadata and re-sign a Play upload AAB.

The normal Flutter release build must complete successfully first. This helper
archives the native symbol files from the bundle, removes only those optional
metadata entries, and re-signs the resulting AAB with the supplied upload key.
It does not remove or rewrite runtime libraries.

For a production artifact, supply the Play upload key. Passwords are read from
AAB_STORE_PASSWORD / AAB_KEY_PASSWORD or prompted without echoing.
"""

from __future__ import annotations

import argparse
import getpass
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
from zipfile import ZIP_DEFLATED, ZipFile


SYMBOL_PREFIX = "BUNDLE-METADATA/com.android.tools.build.debugsymbols/"
SIGNATURE_SUFFIXES = (".SF", ".RSA", ".DSA", ".EC")


def _is_old_signature_entry(name: str) -> bool:
    upper = name.upper()
    if upper == "META-INF/MANIFEST.MF":
        return True
    if not upper.startswith("META-INF/"):
        return False
    leaf = upper.rsplit("/", 1)[-1]
    return leaf.startswith("SIG-") or leaf.endswith(SIGNATURE_SUFFIXES)


def _password(env_name: str, prompt: str) -> str:
    value = os.environ.get(env_name)
    if value:
        return value
    return getpass.getpass(prompt)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--input",
        type=Path,
        default=Path("build/app/outputs/bundle/release/app-release.aab"),
    )
    parser.add_argument("--output", type=Path)
    parser.add_argument("--symbols", type=Path)
    parser.add_argument("--keystore", type=Path, required=True)
    parser.add_argument("--key-alias", required=True)
    args = parser.parse_args()

    source = args.input.resolve()
    output = (args.output or args.input).resolve()
    symbols = (
        args.symbols
        or Path("build/symbols/android/0.1.0/native-debug-symbols.zip")
    ).resolve()
    keystore = args.keystore.resolve()
    if not source.is_file():
        parser.error(f"AAB not found: {source}")
    if not keystore.is_file():
        parser.error(f"Keystore not found: {keystore}")

    output.parent.mkdir(parents=True, exist_ok=True)
    symbols.parent.mkdir(parents=True, exist_ok=True)
    store_password = _password(
        "AAB_STORE_PASSWORD", "Keystore password: "
    )
    key_password = _password("AAB_KEY_PASSWORD", "Upload key password: ")

    with tempfile.TemporaryDirectory(prefix="voice-recorder-aab-") as temp_dir:
        temp = Path(temp_dir)
        unsigned = temp / "upload-unsigned.aab"
        signed = temp / "upload-signed.aab"
        symbol_count = 0

        with ZipFile(source, "r") as bundle, ZipFile(
            unsigned, "w", compression=ZIP_DEFLATED, compresslevel=9
        ) as reduced, ZipFile(
            symbols, "w", compression=ZIP_DEFLATED, compresslevel=9
        ) as symbol_archive:
            for entry in bundle.infolist():
                data = bundle.read(entry.filename)
                if entry.filename.startswith(SYMBOL_PREFIX):
                    relative_name = entry.filename[len(SYMBOL_PREFIX) :]
                    if relative_name:
                        symbol_archive.writestr(relative_name, data)
                        symbol_count += 1
                    continue
                if _is_old_signature_entry(entry.filename):
                    continue
                reduced.writestr(entry, data)

        if symbol_count == 0:
            parser.error(
                "The input bundle has no native debug-symbol metadata to archive. "
                "Build it with release.ndk.debugSymbolLevel = SYMBOL_TABLE first."
            )

        jarsigner = shutil.which("jarsigner")
        if jarsigner is None:
            parser.error("jarsigner is required; install a JDK and put it on PATH.")

        signing_env = os.environ.copy()
        signing_env["AAB_STORE_PASSWORD"] = store_password
        signing_env["AAB_KEY_PASSWORD"] = key_password
        result = subprocess.run(
            [
                jarsigner,
                "-keystore",
                str(keystore),
                "-storepass:env",
                "AAB_STORE_PASSWORD",
                "-keypass:env",
                "AAB_KEY_PASSWORD",
                "-digestalg",
                "SHA-256",
                "-sigalg",
                "SHA256withRSA",
                "-signedjar",
                str(signed),
                str(unsigned),
                args.key_alias,
            ],
            capture_output=True,
            text=True,
            check=False,
            env=signing_env,
        )
        if result.returncode != 0:
            raise SystemExit(
                "Could not sign the reduced AAB. Check the keystore, alias, and "
                f"passwords.\n{result.stderr.strip()}"
            )

        verify = subprocess.run(
            [jarsigner, "-verify", str(signed)],
            capture_output=True,
            text=True,
            check=False,
        )
        if verify.returncode != 0:
            raise SystemExit(f"The signed AAB did not verify.\n{verify.stderr}")

        if output.exists():
            output.unlink()
        shutil.move(str(signed), output)

    with ZipFile(output, "r") as bundle:
        broken_entry = bundle.testzip()
        if broken_entry:
            raise SystemExit(f"Corrupt AAB entry after signing: {broken_entry}")

    print(f"Final upload AAB: {output} ({output.stat().st_size:,} bytes)")
    print(f"Native symbols archived: {symbols} ({symbol_count} entries)")
    print("Signature verified. Rebuild the artifact when source or version changes.")


if __name__ == "__main__":
    main()
