# Familiar

A Swift package of shared UI, and the catalog app that shows it off. Built live in the workshop **Designing a design system for the future: delivering components for fun and profit**.

A familiar is the companion that goes everywhere with a witch and helps with the work. This package does that job for your UI: the same components, looking and behaving the same, in every app that uses them, without copying code between projects.

## What's inside

Familiar is organised as a ladder, from the rules up to whole sections of a screen. Dependencies only ever point down.

| Rung | What it holds | In this repo |
|---|---|---|
| **Physics** | The rules every component follows | Swatch, Typography, Spacing, glass, interaction states, VoiceOver |
| **Quarks** | The brand's own values | BrandColor, CatalogColor, BrandFont |
| **Atoms** | The smallest components | Icon, Label, Artwork, LoadingIndicator |
| **Molecules** | Atoms working together | Button, Chip, Rating, SectionHeader, LabeledImage |
| **Organisms** | Molecules composed into sections | Card, ChipRow, CardRow |

Jobs the host app owns stay behind protocols and come in through the SwiftUI Environment: analytics, feature flags and image loading. The package never learns which vendor you use.

**FamiliarDemo** is the catalog: every component on its own page, in every state, in light and dark, at accessibility sizes, with a caption showing what VoiceOver reads.

## Requirements

- Xcode 27 (Swift 6)
- iOS 26, macOS 26 or visionOS 26

## Following along

Clone the repo and start at the first checkpoint:

```bash
git clone https://github.com/iCalvin-Actual/Familiar.git
cd Familiar
git checkout step-0
open FamiliarDemo/FamiliarDemo.xcodeproj
```

Every demo starts at a tag and ends at the next one. At each starting tag, every file a snippet goes into already exists, with a `// icc-…` comment marking the spot. Select the comment and type the snippet, or just watch.

Fell behind, or something won't build? Catch up with:

```bash
git checkout -f step-N
```

The `-f` throws away what you typed and gives you the finished version of that step.

| Tag | Demo | What you have afterwards |
|---|---|---|
| `step-0` | 1 · Package | An empty demo app, and a package holding only its colour model and resources |
| `step-1` | 2 · Dependencies | The physics (palette, spacing, type, images) and an empty catalog |
| `step-2` | 3 · Components | Analytics, feature flags and image loading, through the Environment |
| `step-3` | 4 · Variations | Atoms, glass and molecules, at rest |
| `step-4` | 5 · Organisms | Every state: VoiceOver, the package's own strings, hover, press and focus |
| `step-5` | 6 · The Catalog, 7 · Ship It | Card, ChipRow and CardRow, and the full catalog |
| `step-6` | 9 · Write Once | The app icon, and TestFlight notes written from the commit log |
| `step-7` | | Buttons grow when pressed, the way glass does |

## Using it in your app

Add Familiar with Swift Package Manager. Apps that depend on it during the workshop follow a branch:

| Branch | Points at |
|---|---|
| `main` | `step-0`, the empty package |
| `finished` | `step-6`, everything from the workshop |
| `patched` | `step-7`, `finished` plus the press-effect fix |

Then set your app's own accent and services once, at the root:

```swift
import Familiar

ContentView()
    .accentSwatch(Color("AccentColor"))
    .analytics(MyAnalytics())
    .featureGate(MyFlags.shared)
```

## Fonts

Sharpie and Array are from the Indian Type Foundry, via Fontshare, under the ITF Free Font License. The licence ships with the fonts, in `Sources/Resources/Fonts/Licenses`.

## More

Slides, notes and links: [icalvin.dev/familiar](https://icalvin.dev/familiar)
