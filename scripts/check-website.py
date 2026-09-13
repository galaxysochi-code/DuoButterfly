#!/usr/bin/env python3
"""Check the public Pages bundle before uploading it; no third-party packages."""
from html.parser import HTMLParser
from pathlib import Path
import json
import subprocess
from urllib.parse import urlsplit

root = Path(__file__).resolve().parents[1]
site = root / 'website'
class Page(HTMLParser):
    def __init__(self):
        super().__init__(); self.ids=[]; self.references=[]; self.keys=set(); self.h1=0
    def handle_starttag(self, tag, attrs):
        attrs=dict(attrs)
        if 'id' in attrs: self.ids.append(attrs['id'])
        if 'data-i18n' in attrs: self.keys.add(attrs['data-i18n'])
        if tag=='h1': self.h1+=1
        if tag=='img':
            assert 'alt' in attrs, 'Image missing alt text'
            assert 'width' in attrs and 'height' in attrs, 'Image missing dimensions'
        self.references.extend(attrs[key] for key in ['src','href','poster','data-src'] if key in attrs)
p=Page(); p.feed((site/'index.html').read_text())
assert p.h1==1
assert len(p.ids)==len(set(p.ids)), 'Duplicate element IDs'
for ref in p.references:
    parsed=urlsplit(ref)
    if parsed.scheme or parsed.netloc: continue
    if parsed.path: assert (site/parsed.path).is_file(), f'Missing asset: {ref}'
    elif parsed.fragment: assert parsed.fragment in p.ids, f'Missing section: {ref}'
# Parse the authored dictionary without a browser or third-party dependencies.
prefix=(site/'app.js').read_text().split('const nodes =',1)[0]
dictionaries=json.loads(subprocess.check_output(['node','-e',prefix+'\nconsole.log(JSON.stringify(translations));'],text=True))
for language, values in dictionaries.items():
    assert not p.keys-values.keys(), f'Missing {language} translations: {p.keys-values.keys()}'
    assert all(isinstance(text,str) and text.strip() for text in values.values())
    for key in ['pause','duskCopy','mistCopy','videoAlt','appAlt','title','description']:
        assert key in values, f'Missing dynamic {language} translation: {key}'
for name in ['silk','dusk','mist']:
    assert (site/f'assets/{name}.webp').is_file()
for lang in ['en','ru','es','zh']:
    assert (site/f'assets/app-window-{lang}.webp').is_file()
assert not list(site.rglob('*.plist')), 'Private application configuration in public bundle'
assert not list(site.rglob('.env*')), 'Environment file in public bundle'
code_size=sum((site/name).stat().st_size for name in ['index.html','styles.css','app.js'])
assert code_size<300_000, f'Page exceeds the 300 KB code budget: {code_size}'
print(f'Website OK: {len(p.keys)} translated strings, 4 languages, all assets and anchors exist; HTML/CSS/JS {code_size:,} bytes.')
