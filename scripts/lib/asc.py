#!/usr/bin/env python3
"""A tiny App Store Connect API client for scripts/ios_testflight.sh.

Shared with Pushup-Bro, readon, lucid_dream_now, giro, brave_tree, japanana.

Standard library only (plus the `openssl` command for the ES256 signature),
so it runs on the Python 3.9 that ships with Xcode's command line tools.

Commands:
  next-build-number            Prints the latest build number uploaded for the
                               app, plus one (1 if there is none yet).
  wait-processing VERSION      Waits until build VERSION is processed (VALID).
  expire-in-review             Expires builds waiting for or in beta review,
                               so a new one can be submitted (only one build
                               can be in beta review at a time).
  submit-beta-review VERSION   Submits build VERSION for external beta review.

Auth comes from the environment: ASC_KEY_ID, ASC_ISSUER_ID and ASC_KEY_PATH
(the .p8 file). The app is looked up by BUNDLE_ID. Only iOS builds count, so
an app that also ships on macOS keeps separate build numbers per platform.
"""

import base64
import json
import os
import re
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

API = "https://api.appstoreconnect.apple.com/v1"
PLATFORM = os.environ.get("ASC_PLATFORM", "IOS")


def _b64url(data):
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def _der_to_raw(der):
    """Turns openssl's DER ECDSA signature into JWT's raw r||s (64 bytes)."""

    def read_int(buf, pos):
        if buf[pos] != 0x02:
            raise ValueError("bad DER signature")
        length = buf[pos + 1]
        value = buf[pos + 2:pos + 2 + length]
        return value.lstrip(b"\x00").rjust(32, b"\x00"), pos + 2 + length

    if der[0] != 0x30:
        raise ValueError("bad DER signature")
    pos = 3 if der[1] & 0x80 else 2
    r, pos = read_int(der, pos)
    s, _ = read_int(der, pos)
    return r + s


def _token():
    key_id = os.environ["ASC_KEY_ID"]
    issuer = os.environ["ASC_ISSUER_ID"]
    key_path = os.path.expanduser(os.environ["ASC_KEY_PATH"])
    now = int(time.time())
    header = {"alg": "ES256", "kid": key_id, "typ": "JWT"}
    payload = {
        "iss": issuer,
        "iat": now,
        "exp": now + 15 * 60,
        "aud": "appstoreconnect-v1",
    }
    signing_input = (
        _b64url(json.dumps(header, separators=(",", ":")).encode())
        + "."
        + _b64url(json.dumps(payload, separators=(",", ":")).encode())
    )
    der = subprocess.run(
        ["openssl", "dgst", "-sha256", "-sign", key_path],
        input=signing_input.encode(),
        capture_output=True,
        check=True,
    ).stdout
    return signing_input + "." + _b64url(_der_to_raw(der))


def _request(method, path, params=None, body=None):
    url = API + path
    if params:
        url += "?" + urllib.parse.urlencode(params)
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", "Bearer " + _token())
    if data is not None:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=60) as res:
            raw = res.read()
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        detail = e.read().decode(errors="replace")
        sys.exit("App Store Connect %s %s failed (%s): %s"
                 % (method, path, e.code, detail))


def _app_id():
    bundle_id = os.environ.get("BUNDLE_ID")
    if not bundle_id:
        sys.exit("BUNDLE_ID isn't set.")
    apps = _request("GET", "/apps", {"filter[bundleId]": bundle_id})["data"]
    if not apps:
        sys.exit("No app with bundle id %s in App Store Connect." % bundle_id)
    return apps[0]["id"]


def _build(app_id, version):
    builds = _request("GET", "/builds", {
        "filter[app]": app_id,
        "filter[version]": version,
        "filter[preReleaseVersion.platform]": PLATFORM,
        "limit": 1,
    })["data"]
    return builds[0] if builds else None


def next_build_number():
    builds = _request("GET", "/builds", {
        "filter[app]": _app_id(),
        "filter[preReleaseVersion.platform]": PLATFORM,
        "sort": "-uploadedDate",
        "fields[builds]": "version",
        "limit": 200,
    })["data"]
    numbers = []
    for build in builds:
        # Keep only the leading integer: a build uploaded by hand may have a
        # dotted number such as 1.2.0 (as in codemagic.yaml).
        match = re.match(r"\d+", build["attributes"].get("version") or "")
        if match:
            numbers.append(int(match.group()))
    print(max(numbers) + 1 if numbers else 1)


def wait_processing(version, timeout_minutes=45):
    app_id = _app_id()
    deadline = time.time() + timeout_minutes * 60
    while time.time() < deadline:
        build = _build(app_id, version)
        state = build["attributes"]["processingState"] if build else "NOT_YET"
        if state == "VALID":
            print("Build %s is processed." % version)
            return
        if state in ("FAILED", "INVALID"):
            sys.exit("Build %s failed processing: %s" % (version, state))
        print("Build %s: %s, checking again in 30 s..." % (version, state),
              flush=True)
        time.sleep(30)
    sys.exit("Build %s wasn't processed within %d minutes."
             % (version, timeout_minutes))


def expire_in_review():
    builds = _request("GET", "/builds", {
        "filter[app]": _app_id(),
        "filter[betaAppReviewSubmission.betaReviewState]":
            "WAITING_FOR_REVIEW,IN_REVIEW",
        "filter[expired]": "false",
        "filter[preReleaseVersion.platform]": PLATFORM,
        "limit": 50,
    })["data"]
    for build in builds:
        _request("PATCH", "/builds/" + build["id"], body={"data": {
            "type": "builds",
            "id": build["id"],
            "attributes": {"expired": True},
        }})
        print("Expired build %s, which was in beta review."
              % build["attributes"]["version"])
    if not builds:
        print("No build is in beta review.")


def submit_beta_review(version):
    build = _build(_app_id(), version)
    if not build:
        sys.exit("Build %s isn't in App Store Connect yet." % version)
    _request("POST", "/betaAppReviewSubmissions", body={"data": {
        "type": "betaAppReviewSubmissions",
        "relationships": {
            "build": {"data": {"type": "builds", "id": build["id"]}},
        },
    }})
    print("Build %s is submitted for beta review." % version)


def main(argv):
    if not argv:
        sys.exit(__doc__)
    command, args = argv[0], argv[1:]
    if command == "next-build-number":
        next_build_number()
    elif command == "wait-processing" and len(args) == 1:
        wait_processing(args[0])
    elif command == "expire-in-review":
        expire_in_review()
    elif command == "submit-beta-review" and len(args) == 1:
        submit_beta_review(args[0])
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main(sys.argv[1:])
