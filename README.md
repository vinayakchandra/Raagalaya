# Raagalaya

Raagalaya is an iOS app for exploring Indian classical music raags and related songs, with notation reading and time-aware discovery.

## Highlights

- Raag catalog with grouped browsing and search
- Song catalog grouped by raag with search
- Rich detail pages for raags and songs
- Notation viewer for bundled text/HTML assets
- Favorites and pinned groups
- Recently opened notation history
- Discover tab with **time-of-day raag recommendations**
- Dark/Light mode adaptive UI

## Project Structure

- `raagalaya/` app source
- `raagalaya/assets/raag/` raag data + notation files
- `raagalaya/assets/song/` song data + notation files
- `raagalaya.xcodeproj/` Xcode project

## Build

Open in Xcode:

1. Open `raagalaya.xcodeproj`
2. Select scheme `raagalaya`
3. Build and run on simulator/device

CLI build example:

```bash
xcodebuild \
  -project raagalaya.xcodeproj \
  -scheme raagalaya \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Data Notes

- Raags are loaded from `assets/raag/raagList.csv`
- Songs are loaded from `assets/song/songList.csv`
- Notations are loaded from corresponding files in `assets/raag` and `assets/song`
- Discover recommendations are based on each raag's stored `time` tag and current local time

## License

Add your preferred license details here.
