# CallDixio — CLAUDE.md

## Project Overview

Swift Package Library that wraps the [Lexin](http://lexin.nada.kth.se) dictionary API from KTH. Provides word lookup with translations, phonetics, inflections, and illustrations, primarily targeting Swedish–Spanish queries. Intended to be imported by iOS/macOS apps.

| Component | Type | Purpose |
|-----------|------|---------|
| `Sources/CallDixio/Data.swift` | Data models | Codable structs for Lexin JSON response |
| `Sources/CallDixio/WordViewModel.swift` | ViewModel | `ObservableObject` + Combine, fetches words from Lexin API |
| `Tests/CallDixioTests/` | Unit tests | XCTest suite for `WordViewModel` |

**Frameworks:** Foundation, Observation  
**Platforms:** iOS 26+, macOS 26+  
**Swift tools version:** 6.0  
**Swift language mode:** 6 (strict concurrency: complete)  
**External APIs:** Lexin API (KTH) — `http://lexin.nada.kth.se/lexin/service`

---

## Targets

| Target | Type | Purpose |
|--------|------|---------|
| `CallDixio` | Library | Main package target |
| `CallDixioTests` | Test | Unit tests for the library |

---

## Architecture

### Data Flow

```
View (host app)
  └── WordViewModel (@Published results)
        └── fetchPosts(word:dir:)
              └── URLSession.dataTask → Lexin API
                    └── JSONDecoder → Words → [Result] → @Published results
```

### Data Model (`Data.swift`)

| Struct | Role |
|--------|------|
| `Words` | Root response — `status`, `wordbase`, `result: [Result]` |
| `Result` | One dictionary entry — `value`, `type`, `variantID`, `baseLang`, `targetLang` |
| `BaseLang` | Source language data — `phonetic`, `inflection`, `meaning`, `illustration`, `comment` |
| `TargetLang` | Target language data — `translation`, `synonym`, `comment` |
| `Phonetic` | Audio file path + phonetic transcription |
| `Inflection` | One inflected form of the word |
| `Illustration` | Image reference for the word |

All `CodingKeys` use `UpperCamelCase` to match the Lexin JSON schema.

### ViewModel (`WordViewModel.swift`)

`@Observable @MainActor final class WordViewModel` exposes:

```swift
var results: [Result]    // populated after a successful fetch
var error: LexinError?   // nil on success, typed error on failure

init(session: URLSession = .shared)               // injectable for testing
func fetchPosts(word: String, dir: String) async  // triggers a Lexin API call
```

`LexinError` cases:

| Case | Causa |
|------|-------|
| `.invalidURL` | La URL construida no es válida |
| `.invalidResponse` | HTTP status != 200 |
| `.noMatch` | JSON vacío o fallo al decodificar |
| `.networkError(String)` | Error de red inesperado |

Call from views using `Task { }` or `.task { }`:
```swift
Button("Buscar") {
    Task { await viewModel.fetchPosts(word: word, dir: "to") }
}
```

**`dir` values:**

| Value | Meaning |
|-------|---------|
| `"to"` | Search by Swedish base form |
| *(other)* | Other directions supported by the Lexin API |

**API URL pattern:**
```
http://lexin.nada.kth.se/lexin/service?searchinfo=<dir>,swe_spa,<word>&output=JSON
```

---

## Known Issues / Tech Debt

| File | Issue | Priority |
|------|-------|----------|
| `WordViewModel.swift` | ~~`ObservableObject` + Combine~~ — migrado a `@Observable @MainActor` | ✅ Done |
| `WordViewModel.swift` | ~~`URLSession.dataTask` + `DispatchQueue`~~ — migrado a `async/await` | ✅ Done |
| `WordViewModel.swift` | ~~`fatalError("Invalid URL")`~~ — reemplazado por `LexinError` | ✅ Done |
| `WordViewModel.swift` | ~~`errorMessage: String`~~ — reemplazado por `error: LexinError?` | ✅ Done |
| `WordViewModel.swift` | `URLSession` inyectado vía `init(session:)` para permitir mocks | ✅ Done |
| `CallDixioTests.swift` | ~~Tests con red real~~ — `MockURLProtocol` cubre todos los casos offline | ✅ Done |
| `Package.swift` | ~~Swift tools 5.7 / iOS 13~~ — actualizado a tools 6.0 / iOS 26 / Swift 6 | ✅ Done |

---

## Development Guidelines

### Concurrency (Swift 6)
- All `@Observable` classes que tocan UI deben ser `@MainActor`
- Llamadas de red usan `async throws`; llámalas con `Task { }` o `.task { }`
- Nunca usar `DispatchQueue`, `URLSession.dataTask`, ni Combine
- Nunca bloquear un hilo — usar `try await Task.sleep(for:)` en lugar de `Thread.sleep`

### Error Handling
- Nunca usar `fatalError` para errores recuperables
- Errores se propagan via `errorMessage: String` en el ViewModel (observable directamente por las vistas)

### Data Models
- All Codable structs must match the Lexin JSON exactly — `CodingKeys` use `UpperCamelCase`
- `Result` conforms to `Hashable` and `Identifiable`; keep that for SwiftUI list compatibility
- `id` in `Result` uses `UUID().uuidString` as a default — note this is not stable across decodes

### Testing
- Tests live in `CallDixioTests/CallDixioTests.swift`
- Current test is a network integration test (hits real Lexin API) — keep it optional or mock the session for CI

---

## File Reference Map

```
CallDixio/
├── Package.swift                          ← library product, iOS 13 / macOS 10.15
├── Sources/
│   └── CallDixio/
│       ├── Data.swift                     ← Codable data models for Lexin JSON
│       └── WordViewModel.swift            ← ObservableObject, fetchPosts(word:dir:)
└── Tests/
    └── CallDixioTests/
        └── CallDixioTests.swift           ← integration test for fetchPosts
```

---

## Next Steps

### Long-term
1. Soporte para pares de idiomas adicionales más allá de `swe_spa`
