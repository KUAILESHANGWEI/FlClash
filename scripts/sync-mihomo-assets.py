#!/usr/bin/env python3
"""Mirror Mihomo assets while keeping the published and preceding versions."""
import fnmatch
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile

TARGET = os.environ.get('TARGET_REPO', os.environ.get('GITHUB_REPOSITORY', 'KUAILESHANGWEI/FlClash'))
SOURCE = 'MetaCubeX/mihomo'
PATTERNS = ['mihomo-android-amd64-*.gz', 'mihomo-android-arm64-v8-*.gz',
            'mihomo-android-armv7-*.gz', 'mihomo-darwin-amd64-v[123]-*.gz',
            'mihomo-darwin-arm64-*.gz', 'mihomo-linux-amd64-v[123]-*.gz',
            'mihomo-linux-arm64-*.gz', 'mihomo-windows-amd64-v[123]-*.zip']
VERSION = re.compile(r'^[A-Za-z0-9._-]+$')
MANAGED = re.compile(r'^mihomo-.*-(alpha-[0-9a-f]+|v[0-9][A-Za-z0-9._-]*)\.(?:gz|zip)$')


def gh(*args, capture=True):
    p = subprocess.run(['gh', *map(str, args)], check=True, stdout=subprocess.PIPE if capture else None)
    return p.stdout.decode() if capture else ''


def release(repo, tag):
    args = ['release', 'view'] + ([] if tag == '__latest__' else [tag]) + ['-R', repo, '--json', 'tagName,databaseId']
    return json.loads(gh(*args))


def assets(repo, release_id):
    pages = json.loads(gh('api', '--paginate', '--slurp', f'repos/{repo}/releases/{release_id}/assets?per_page=100'))
    return [item for page in pages for item in page]


def version_of(name):
    if not any(fnmatch.fnmatchcase(name, pattern) for pattern in PATTERNS):
        return None
    m = MANAGED.fullmatch(name)
    return m.group(1) if m else None


def sync(selector, target_tag):
    source = release(SOURCE, selector)
    target = release(TARGET, target_tag)
    source_assets = assets(SOURCE, source['databaseId'])
    target_assets = assets(TARGET, target['databaseId'])
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        new = root / 'new'
        old = root / 'old'
        new.mkdir(); old.mkdir()
        gh('release', 'download', source['tagName'], '-R', SOURCE, '-p', 'version.txt', '-D', new)
        new_version = (new / 'version.txt').read_text().strip()
        if not VERSION.fullmatch(new_version):
            raise ValueError('Invalid upstream version.txt')
        old_version = None
        if any(a['name'] == 'version.txt' for a in target_assets):
            gh('release', 'download', target_tag, '-R', TARGET, '-p', 'version.txt', '-D', old)
            old_version = (old / 'version.txt').read_text().strip()
            if not VERSION.fullmatch(old_version):
                raise ValueError('Invalid target version.txt; refusing cleanup')
        selected = [a for a in source_assets if any(fnmatch.fnmatchcase(a['name'], p) for p in PATTERNS)
                    and version_of(a['name']) == new_version]
        for pattern in PATTERNS:
            if not any(fnmatch.fnmatchcase(a['name'], pattern) for a in selected):
                raise RuntimeError(f'Missing required upstream assets: {pattern}')
        for a in selected:
            gh('release', 'download', source['tagName'], '-R', SOURCE, '-p', a['name'], '-D', new)
            if (new / a['name']).stat().st_size != a['size']:
                raise RuntimeError(f'Incomplete download: {a["name"]}')
        # A missing version marker requires conservative recovery: retain the newest
        # two identifiable historical versions until the new mirror is complete.
        groups = {}
        for a in target_assets:
            v = version_of(a['name'])
            if v:
                groups[v] = max(groups.get(v, ''), a['created_at'])
        recent = sorted(groups, key=groups.get, reverse=True)
        previous = old_version if old_version and old_version != new_version else next((v for v in recent if v != new_version), None)
        keep = {new_version, previous} if old_version else {new_version, *recent[:2]}
        obsolete = [a for a in target_assets if version_of(a['name']) and version_of(a['name']) not in keep]
        existing = {a['name']: a for a in target_assets}
        needed = sum(a['name'] not in existing for a in selected) + (0 if 'version.txt' in existing else 1)
        # GitHub permits at most 1000 assets. Remove only verified obsolete versions.
        for a in obsolete:
            if len(target_assets) + needed <= 1000:
                break
            gh('api', '--method', 'DELETE', f"repos/{TARGET}/releases/assets/{a['id']}")
            target_assets.remove(a)
        if len(target_assets) + needed > 1000:
            raise RuntimeError('Insufficient space without deleting protected or unknown assets')
        for a in selected:
            prior = existing.get(a['name'])
            if prior:
                if prior['size'] != a['size']:
                    raise RuntimeError(f'Existing asset has unexpected size: {a["name"]}')
                continue
            gh('release', 'upload', target_tag, new / a['name'], '-R', TARGET)
        actual = {a['name']: a for a in assets(TARGET, target['databaseId'])}
        if any(a['name'] not in actual or actual[a['name']]['size'] != a['size'] for a in selected):
            raise RuntimeError('Uploaded assets failed verification')
        # Avoid clobbering an unchanged marker. GitHub has no atomic replacement;
        # restore the previous marker if publishing the new one fails.
        if old_version != new_version:
            if old_version is not None:
                gh('release', 'delete-asset', target_tag, 'version.txt', '-R', TARGET, '--yes')
            try:
                gh('release', 'upload', target_tag, new / 'version.txt', '-R', TARGET)
            except Exception:
                if old_version is not None:
                    gh('release', 'upload', target_tag, old / 'version.txt', '-R', TARGET)
                raise
        # Retain the former published version; if no marker was present, retain
        # the most recent historical group for recovery.
        keep = {new_version, previous}
        for a in assets(TARGET, target['databaseId']):
            v = version_of(a['name'])
            if v and v not in keep:
                gh('api', '--method', 'DELETE', f"repos/{TARGET}/releases/assets/{a['id']}")
        print(f'Synchronized {target_tag}: {new_version}', flush=True)


if __name__ == '__main__':
    sync('__latest__', 'third-party-mihomo-latest')
    sync('Prerelease-Alpha', 'third-party-mihomo-prerelease-alpha')
