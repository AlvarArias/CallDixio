# CallDixio

![Swift](https://img.shields.io/badge/Swift-6.0-orange?style=flat&logo=swift)
![SPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen?style=flat)
![iOS](https://img.shields.io/badge/iOS-26+-blue?style=flat&logo=apple)
![macOS](https://img.shields.io/badge/macOS-26+-blue?style=flat&logo=apple)
![License](https://img.shields.io/badge/license-MIT-lightgrey?style=flat)

A Swift package for querying the **Lexin dictionary API** — a Swedish–Spanish bilingual dictionary maintained by the Swedish Institute for Language and Folklore. Handles HTTP requests, JSON decoding, and error propagation so you can focus on your UI.

Used by [DiccionarioApp](https://github.com/AlvarArias/DiccionarioApp).

---

## Features

- Async/await networking with `URLSession` — no third-party dependencies
- Bidirectional lookup: Swedish → Spanish and Spanish → Swedish
- Fully typed response models (word value, phonetics, inflections, translations, synonyms)
- Structured error handling via `LexinError`
- `@Observable` view model ready to use with SwiftUI
- Swift 6 concurrency-safe (`@MainActor`)

---

## Requirements

| Requirement | Minimum version |
|-------------|----------------|
| Swift       | 6.0            |
| iOS         | 26+            |
| macOS       | 26+            |
| Xcode       | 16+            |

---

## Installation

### Swift Package Manager

In Xcode: **File → Add Package Dependencies**, then enter the repository URL:

```
https://github.com/AlvarArias/CallDixio
```

Or add it manually to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/AlvarArias/CallDixio.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["CallDixio"]
    )
]
```

---

## Usage

### Basic lookup

```swift
import CallDixio

let viewModel = WordViewModel()

// Swedish → Spanish
await viewModel.fetchPosts(word: "hund", dir: "swe-spa")

// Spanish → Swedish
await viewModel.fetchPosts(word: "perro", dir: "spa-swe")

for result in viewModel.results {
    print(result.value ?? "")                           // e.g. "hund"
    print(result.targetLang?.translation ?? "")        // e.g. "perro"
    print(result.baseLang?.phonetic?.content ?? "")    // e.g. "hund"
}
```

### SwiftUI integration

```swift
import SwiftUI
import CallDixio

struct SearchView: View {
    @State private var viewModel = WordViewModel()
    @State private var query = ""

    var body: some View {
        List(viewModel.results) { result in
            VStack(alignment: .leading) {
                Text(result.value ?? "").font(.headline)
                Text(result.targetLang?.translation ?? "").foregroundStyle(.secondary)
            }
        }
        .searchable(text: $query)
        .onSubmit(of: .search) {
            Task { await viewModel.fetchPosts(word: query, dir: "swe-spa") }
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
    }
}
```

---

## API Reference

### `WordViewModel`

| Member | Type | Description |
|--------|------|-------------|
| `results` | `[Result]` | Decoded dictionary entries |
| `error` | `LexinError?` | Non-nil when the last request failed |
| `fetchPosts(word:dir:)` | `async` | Performs the lookup and updates `results` |

**Direction values for `dir`:**

| Value | Direction |
|-------|-----------|
| `"swe-spa"` | Swedish → Spanish |
| `"spa-swe"` | Spanish → Swedish |

### Response models

```
Words
└── [Result]
    ├── value          — the word as entered
    ├── type           — grammatical type (noun, verb…)
    ├── BaseLang
    │   ├── phonetic   — pronunciation (text + audio file)
    │   ├── inflection — word forms
    │   └── meaning    — usage note
    └── TargetLang
        ├── translation — translated word
        └── synonym     — list of synonyms
```

### `LexinError`

| Case | Description |
|------|-------------|
| `.invalidURL` | The constructed URL was malformed |
| `.invalidResponse` | Server returned a non-200 status |
| `.noMatch` | Query returned zero results |
| `.networkError(String)` | Underlying network failure |

---

## Project Structure

```
Sources/
└── CallDixio/
    ├── Data.swift          # Codable models + LexinError
    └── WordViewModel.swift # @Observable fetch logic
Tests/
└── CallDixioTests/
```

---

## License

Available under the [MIT](LICENSE) license.

---

Developed by [Alvar Arias](https://github.com/AlvarArias) · [LinkedIn](https://www.linkedin.com/in/alvararias/) · [Portfolio](https://alvararias.github.io/)
