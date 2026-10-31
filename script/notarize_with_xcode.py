#!/usr/bin/env python3
"""Submit a signed app using the Apple account already signed in to Xcode."""
import argparse
from datetime import datetime, timezone
from pathlib import Path
import plistlib
import shutil
import subprocess
import time

from build_app import ROOT, CONFIG, build_app, run


def submit(app, team, identity):
    work = ROOT / ".release-work"
    work.mkdir(exist_ok=True)
    archive = work / "CursorSwitch.xcarchive"
    if archive.exists():
        shutil.rmtree(archive)
    destination = archive / "Products/Applications/CursorSwitch.app"
    destination.parent.mkdir(parents=True)
    run("ditto", app, destination)
    with (archive / "Info.plist").open("wb") as file:
        plistlib.dump({
            "ArchiveVersion": 2, "Name": "CursorSwitch", "SchemeName": "CursorSwitch",
            "CreationDate": datetime.now(timezone.utc).replace(tzinfo=None),
            "ApplicationProperties": {
                "ApplicationPath": "Applications/CursorSwitch.app",
                "CFBundleIdentifier": CONFIG["bundle_id"],
                "CFBundleShortVersionString": CONFIG["version"],
                "CFBundleVersion": CONFIG["build"], "SigningIdentity": identity,
                "Team": team,
            }
        }, file)
    options = work / "ExportOptions-DeveloperID.plist"
    with options.open("wb") as file:
        plistlib.dump({"method": "developer-id", "destination": "upload", "teamID": team,
                      "signingStyle": "manual", "signingCertificate": identity}, file)
    run("xcodebuild", "-exportArchive", "-archivePath", archive, "-exportOptionsPlist", options,
        "-exportPath", work / "xcode-upload", "-allowProvisioningUpdates")
    return archive


def finish_export(archive, team, identity):
    # Export with the explicit team instead of -exportNotarizedApp, which can
    # fail when Xcode also contains a stale, unrelated Apple account.
    work = ROOT / ".release-work"
    options = work / "ExportOptions-DeveloperID-Local.plist"
    with options.open("wb") as file:
        plistlib.dump({"method": "developer-id", "destination": "export", "teamID": team,
                      "signingStyle": "manual", "signingCertificate": identity}, file)
    output = work / "notarized"
    if output.exists():
        shutil.rmtree(output)
    run("xcodebuild", "-exportArchive", "-archivePath", archive, "-exportOptionsPlist", options,
        "-exportPath", output, "-allowProvisioningUpdates")
    apps = list(output.glob("*.app"))
    if len(apps) != 1:
        raise RuntimeError("Expected one exported application")
    app = apps[0]
    for attempt in range(30):
        result = subprocess.run(["xcrun", "stapler", "staple", str(app)], capture_output=True, text=True)
        if result.returncode == 0:
            print(result.stdout, flush=True)
            run("xcrun", "stapler", "validate", app)
            run("spctl", "--assess", "--type", "execute", "--verbose=2", app)
            return app
        print(f"Waiting for Apple's notarization ticket ({attempt + 1}/30)…", flush=True)
        time.sleep(10)
    raise RuntimeError("Apple's ticket is not ready. Check notarization in Xcode, then rerun with --finish.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--team", default=CONFIG["team_id"])
    parser.add_argument("--identity", default=CONFIG["signing_identity"])
    parser.add_argument("--finish", action="store_true", help="Finish an existing submission without rebuilding or resubmitting")
    args = parser.parse_args()
    archive = ROOT / ".release-work/CursorSwitch.xcarchive"
    if not args.finish:
        app = build_app(ROOT / "release-dist/CursorSwitch.app", universal=True, updates=True, identity=args.identity)
        archive = submit(app, args.team, args.identity)
    print(finish_export(archive, args.team, args.identity))
