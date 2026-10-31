"""Read optional local release settings; public builds need no personal defaults."""
import json
import os
from pathlib import Path

LOCAL_SETTINGS = Path(__file__).resolve().parents[1] / ".private/release-settings.json"
ENVIRONMENT_KEYS = {
    "team_id": "CURSOR_TEAM_ID",
    "signing_identity": "CURSOR_SIGNING_IDENTITY",
    "sparkle_key_account": "CURSOR_SPARKLE_KEY_ACCOUNT",
    "notary_profile": "CURSOR_NOTARY_PROFILE",
}


def load_release_settings(path=LOCAL_SETTINGS, environ=None):
    """Environment variables override optional owner-local JSON settings."""
    environ = os.environ if environ is None else environ
    data = json.loads(path.read_text()) if path.exists() else {}
    if not isinstance(data, dict):
        raise ValueError("Local release settings must be a JSON object.")
    settings = {}
    for key, environment_key in ENVIRONMENT_KEYS.items():
        value = environ.get(environment_key, data.get(key))
        if value is not None:
            if not isinstance(value, str) or not value.strip():
                raise ValueError(f"Release setting {key} must be a non-empty string.")
            settings[key] = value
    return settings
