<p align="center">
  <img src="./assets/logo.png" alt="Tuteliq" width="200" />
</p>

<h1 align="center">Tuteliq Swift SDK</h1>

<p align="center">
  <strong>Official Swift SDK for the Tuteliq API</strong><br>
  AI-powered child safety analysis for iOS, macOS, tvOS, and watchOS
</p>

<p align="center">
  <a href="https://github.com/Tuteliq/swift/actions"><img src="https://img.shields.io/github/actions/workflow/status/Tuteliq/swift/ci.yml" alt="build status"></a>
  <img src="https://img.shields.io/badge/Swift-5.9+-orange.svg" alt="Swift 5.9+">
  <img src="https://img.shields.io/badge/Platforms-iOS%2015%2B%20%7C%20macOS%2012%2B-blue.svg" alt="Platforms">
  <a href="https://github.com/Tuteliq/swift/blob/main/LICENSE"><img src="https://img.shields.io/github/license/Tuteliq/swift.svg" alt="license"></a>
</p>

<p align="center">
  <a href="https://docs.tuteliq.ai">API Docs</a> •
  <a href="https://tuteliq.ai">Dashboard</a> •
  <a href="https://trust.tuteliq.ai">Trust</a> •
  <a href="https://discord.gg/7kbTeRYRXD">Discord</a>
</p>

---

## Installation

### Swift Package Manager

Add Tuteliq to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Tuteliq/swift.git", from: "1.0.0")
]
```

Or in Xcode: **File → Add Package Dependencies** → Enter:
```
https://github.com/Tuteliq/swift.git
```

---

## Quick Start

```swift
import Tuteliq

// At app launch — reads TuteliqAPIKey from Info.plist and stores it in the Keychain
try Tuteliq.configure()

// Anywhere in your app — creates a client from the Keychain-stored key
let tuteliq = try Tuteliq.withStoredAPIKey()

// Quick safety analysis
let result = try await tuteliq.analyze(content: "Message to check")

if result.riskLevel != .safe {
    print("Risk: \(result.riskLevel)")
    print("Summary: \(result.summary)")
}
```

> See [Security Best Practices](#security-best-practices) for the recommended `.xcconfig` setup.

---

## API Reference

### Initialization

```swift
// Simple
let tuteliq = Tuteliq(apiKey: "your-api-key")

// With options
let tuteliq = Tuteliq(
    apiKey: "your-api-key",
    timeout: 30,      // Request timeout in seconds
    maxRetries: 3,    // Retry attempts
    retryDelay: 1     // Initial retry delay in seconds
)
```

### Bullying Detection

```swift
let result = try await tuteliq.detectBullying(
    content: "Nobody likes you, just leave"
)

if result.isBullying {
    print("Severity: \(result.severity)")      // .low, .medium, .high, .critical
    print("Types: \(result.bullyingType)")     // ["exclusion", "verbal_abuse"]
    print("Confidence: \(result.confidence)")  // 0.92
    print("Rationale: \(result.rationale)")
}
```

### Grooming Detection

```swift
let result = try await tuteliq.detectGrooming(
    DetectGroomingInput(
        messages: [
            GroomingMessage(role: .adult, content: "This is our secret"),
            GroomingMessage(role: .child, content: "Ok I won't tell")
        ],
        childAge: 12
    )
)

if result.groomingRisk == .high {
    print("Flags: \(result.flags)")  // ["secrecy", "isolation"]
}

// Per-message breakdown (optional, returned on conversation-aware endpoints)
if let analysis = result.messageAnalysis {
    for m in analysis {
        print("Message \(m.messageIndex): risk=\(m.riskScore), flags=\(m.flags), summary=\(m.summary)")
    }
}
```

### Unsafe Content Detection

```swift
let result = try await tuteliq.detectUnsafe(
    content: "I don't want to be here anymore"
)

if result.unsafe {
    print("Categories: \(result.categories)")  // ["self_harm", "crisis"]
    print("Severity: \(result.severity)")      // .critical
}
```

### Voice Analysis

Transcribe audio and run safety analysis on the transcript:

```swift
let audioData = try Data(contentsOf: audioURL)
let result = try await tuteliq.analyzeVoice(
    AnalyzeVoiceInput(
        file: audioData,
        filename: "recording.mp3",
        analysisType: "all",      // "bullying", "unsafe", "grooming", "emotions", or "all"
        ageGroup: "11-13"
    )
)

print("Transcript: \(result.transcription.text)")
print("Duration: \(result.transcription.duration)s")
print("Segments: \(result.transcription.segments.count)")
print("Risk Score: \(result.overallRiskScore)")   // 0.0 - 1.0
print("Severity: \(result.overallSeverity)")
```

Supported audio formats: mp3, wav, m4a, ogg, flac, webm, mp4 (max 25MB).

### Image Analysis

Analyze images for visual safety concerns and extract text via OCR:

```swift
let imageData = try Data(contentsOf: imageURL)
let result = try await tuteliq.analyzeImage(
    AnalyzeImageInput(
        file: imageData,
        filename: "screenshot.png",
        analysisType: "all"       // "bullying", "unsafe", "emotions", or "all"
    )
)

print("OCR Text: \(result.vision.extractedText)")
print("Visual Severity: \(result.vision.visualSeverity)")
print("Categories: \(result.vision.visualCategories)")
print("Contains Text: \(result.vision.containsText)")
print("Risk Score: \(result.overallRiskScore)")
print("Severity: \(result.overallSeverity)")
```

Supported image formats: png, jpg, jpeg, gif, webp (max 10MB).

### Quick Analysis

Runs bullying and unsafe detection in parallel:

```swift
let result = try await tuteliq.analyze(content: "Message to check")

print("Risk Level: \(result.riskLevel)")  // .safe, .low, .medium, .high, .critical
print("Risk Score: \(result.riskScore)")  // 0.0 - 1.0
print("Summary: \(result.summary)")
print("Action: \(result.recommendedAction)")
```

### Emotion Analysis

```swift
let result = try await tuteliq.analyzeEmotions(
    content: "I'm so stressed about everything"
)

print("Emotions: \(result.dominantEmotions)")  // ["anxiety", "sadness"]
print("Trend: \(result.trend)")                // .improving, .stable, .worsening
print("Followup: \(result.recommendedFollowup)")
```

### Action Plan

```swift
let plan = try await tuteliq.getActionPlan(
    GetActionPlanInput(
        situation: "Someone is spreading rumors about me",
        childAge: 12,
        audience: .child,
        severity: .medium
    )
)

print("Steps: \(plan.steps)")
print("Tone: \(plan.tone)")
```

### Incident Report

```swift
let report = try await tuteliq.generateReport(
    GenerateReportInput(
        messages: [
            ReportMessage(sender: "user1", content: "Threatening message"),
            ReportMessage(sender: "child", content: "Please stop")
        ],
        childAge: 14
    )
)

print("Summary: \(report.summary)")
print("Risk: \(report.riskLevel)")
print("Next Steps: \(report.recommendedNextSteps)")
```

### Age Verification (Beta)

> **Pro tier ($99/mo)+ required** — 5 credits per request — `POST /v1/verification/age`

```swift
let ageResult = try await tuteliq.verifyAge(
    document: Data(contentsOf: URL(fileURLWithPath: "id-front.jpg")),
    selfie: Data(contentsOf: URL(fileURLWithPath: "selfie.jpg")),
    method: .combined // .document | .biometric | .combined
)

print(ageResult.verified)       // true
print(ageResult.estimatedAge)   // 15
print(ageResult.ageRange)       // "13-15"
print(ageResult.isMinor)        // true
print(ageResult.confidence)     // 0.97
```

### Identity Verification (Beta)

> **Business tier ($349/mo)+ required** — 10 credits per request — `POST /v1/verification/identity`

```swift
let identityResult = try await tuteliq.verifyIdentity(
    document: Data(contentsOf: URL(fileURLWithPath: "id-front.jpg")),
    selfie: Data(contentsOf: URL(fileURLWithPath: "selfie.jpg"))
)

print(identityResult.verified)               // true
print(identityResult.matchScore)             // 0.98
print(identityResult.livenessPassed)         // true
print(identityResult.documentAuthenticated)  // true
print(identityResult.isMinor)               // false
```

### Voice Streaming

Real-time voice streaming with live safety analysis over WebSocket. Uses `URLSessionWebSocketTask` — no external dependencies.

```swift
let session = tuteliq.voiceStream(
    config: VoiceStreamConfig(
        intervalSeconds: 10,
        analysisTypes: ["bullying", "unsafe"]
    ),
    handlers: VoiceStreamHandlers(
        onTranscription: { print("Transcript: \($0.text)") },
        onAlert: { print("Alert: \($0.category) (\($0.severity))") }
    )
)

try await session.connect()

// Send audio chunks as they arrive
try session.sendAudio(audioData)

// End session and get summary
let summary = try await session.end()
print("Risk: \(summary.overallRisk)")
print("Score: \(summary.overallRiskScore)")
print("Full transcript: \(summary.transcript)")
```

---

## Credits Tracking

Each response includes the number of credits consumed:

```swift
let result = try await tuteliq.detectBullying(content: "Test message")
print("Credits used: \(result.creditsUsed ?? 0)")  // 1
```

| Method | Credits | Notes |
|--------|---------|-------|
| `detectBullying()` | 1 | Single text analysis |
| `detectUnsafe()` | 1 | Single text analysis |
| `detectGrooming()` | 1 per 10 msgs | `ceil(messages / 10)`, min 1 |
| `analyzeEmotions()` | 1 per 10 msgs | `ceil(messages / 10)`, min 1 |
| `getActionPlan()` | 2 | Longer generation |
| `generateReport()` | 3 | Structured output |
| `analyzeVoice()` | 5 | Transcription + analysis |
| `analyzeImage()` | 3 | Vision + OCR + analysis |
| `verifyAge()` | 5 | Age verification (Beta, Pro+) |
| `verifyIdentity()` | 10 | Identity verification (Beta, Business+) |

---

## Tracking Fields

All methods support `externalId` and `metadata` for correlating requests:

```swift
let result = try await tuteliq.detectBullying(
    DetectBullyingInput(
        content: "Test message",
        externalId: "msg_12345",
        metadata: ["user_id": "usr_abc", "session": "sess_xyz"]
    )
)

// Echoed back in response
print(result.externalId)  // "msg_12345"
```

---

## Usage Tracking

```swift
let result = try await tuteliq.detectBullying(content: "test")

// Access usage stats after any request
if let usage = tuteliq.usage {
    print("Limit: \(usage.limit)")
    print("Used: \(usage.used)")
    print("Remaining: \(usage.remaining)")
}

// Request metadata
print("Request ID: \(tuteliq.lastRequestId ?? "N/A")")
print("Latency: \(tuteliq.lastLatency ?? 0)s")
```

---

## Error Handling

```swift
do {
    let result = try await tuteliq.detectBullying(content: "test")
} catch let error as TuteliqError {
    switch error {
    case .authenticationError(let message):
        print("Auth error: \(message)")
    case .rateLimitError(let message):
        print("Rate limited: \(message)")
    case .validationError(let message, let details):
        print("Invalid input: \(message)")
    case .serverError(let message, let statusCode):
        print("Server error \(statusCode): \(message)")
    case .timeoutError(let message):
        print("Timeout: \(message)")
    case .networkError(let message):
        print("Network error: \(message)")
    case .unknownError(let message):
        print("Error: \(message)")
    }
}
```

---

## SwiftUI Example

```swift
import SwiftUI
import Tuteliq

struct ContentView: View {
    @State private var message = ""
    @State private var warning: String?
    @State private var isChecking = false

    // Uses the API key stored in the Keychain (see Security Best Practices)
    let tuteliq = try Tuteliq.withStoredAPIKey()

    var body: some View {
        VStack {
            TextField("Message", text: $message)
                .textFieldStyle(.roundedBorder)

            if let warning = warning {
                Text(warning)
                    .foregroundColor(.red)
            }

            Button("Send") {
                Task { await checkAndSend() }
            }
            .disabled(isChecking)
        }
        .padding()
    }

    func checkAndSend() async {
        isChecking = true
        defer { isChecking = false }

        do {
            let result = try await tuteliq.analyze(content: message)

            if result.riskLevel != .safe {
                warning = result.summary
                return
            }

            // Safe to send
            warning = nil
            // ... send message
        } catch {
            warning = error.localizedDescription
        }
    }
}
```

---

## Requirements

- Swift 5.9+
- iOS 15+ / macOS 12+ / tvOS 15+ / watchOS 8+

---

## Best Practices

### Message Batching

The **bullying** and **unsafe content** methods analyze a single `text` field per request. If your app receives messages one at a time, concatenate a **sliding window of recent messages** into one string before calling the API. Single words or short fragments lack context for accurate detection and can be exploited to bypass safety filters.

```swift
// Bad — each message analyzed in isolation, easily evaded
for msg in messages {
    try await client.detectBullying(text: msg)
}

// Good — recent messages analyzed together
let window = recentMessages.suffix(10).joined(separator: " ")
try await client.detectBullying(text: window)
```

The **grooming** method already accepts a `messages` array and analyzes the full conversation in context.

### PII Redaction

Enable `PII_REDACTION_ENABLED=true` on your Tuteliq API to automatically strip emails, phone numbers, URLs, social handles, IPs, and other PII from detection summaries and webhook payloads. The original text is still analyzed in full — only stored outputs are scrubbed.

---

## Security Best Practices

**Never hardcode API keys** in your Swift source files. Strings embedded in the binary can be extracted with tools like `strings` — even from release builds. Instead, use the `.xcconfig` → Keychain flow described below.

### Recommended Setup

#### 1. Create a `Secrets.xcconfig` file (git-ignored)

```
// Secrets.xcconfig — DO NOT commit this file
TUTELIQ_API_KEY = sk_live_your_key_here
```

Add it to `.gitignore`:

```
Secrets.xcconfig
```

#### 2. Reference it in `Info.plist`

```xml
<key>TuteliqAPIKey</key>
<string>$(TUTELIQ_API_KEY)</string>
```

#### 3. Configure at app launch

```swift
// AppDelegate or @main App init
try Tuteliq.configure()  // reads TuteliqAPIKey from Info.plist → Keychain
```

#### 4. Use the stored key everywhere

```swift
let client = try Tuteliq.withStoredAPIKey()
let result = try await client.analyze(content: message)
```

### Quick Reference

```swift
// Store a key manually
try Tuteliq.storeAPIKey("sk_live_...")

// Read from Info.plist and store in Keychain
try Tuteliq.configure()

// Create a client from the stored key
let client = try Tuteliq.withStoredAPIKey()

// Remove the key from the Keychain (e.g. on logout)
try Tuteliq.removeAPIKey()
```

---

## Supported Languages

Tuteliq supports **27 languages** with automatic detection — no configuration required.

**English** (stable) and **26 beta languages**: Spanish, Portuguese, Ukrainian, Swedish, Norwegian, Danish, Finnish, German, French, Dutch, Polish, Italian, Turkish, Romanian, Greek, Czech, Hungarian, Bulgarian, Croatian, Slovak, Lithuanian, Latvian, Estonian, Slovenian, Maltese, and Irish.

All 24 EU official languages + Ukrainian, Norwegian, and Turkish. Each language includes culture-specific safety guidelines covering local slang, grooming patterns, self-harm coded vocabulary, and filter evasion techniques.

See the [Language Support docs](https://docs.tuteliq.ai/languages) for details.

---

## Support

- **API Docs**: [docs.tuteliq.ai](https://docs.tuteliq.ai)
- **Discord**: [discord.gg/7kbTeRYRXD](https://discord.gg/7kbTeRYRXD)
- **Email**: support@tuteliq.ai
- **Issues**: [GitHub Issues](https://github.com/Tuteliq/swift/issues)

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## Get Certified — Free

Tuteliq offers a **free certification program** for anyone who wants to deepen their understanding of online child safety. Complete a track, pass the quiz, and earn your official Tuteliq certificate — verified and shareable.

**Three tracks available:**

| Track | Who it's for | Duration |
|-------|-------------|----------|
| **Parents & Caregivers** | Parents, guardians, grandparents, teachers, coaches | ~90 min |
| **Young People (10–16)** | Young people who want to learn to spot manipulation | ~60 min |
| **Companies & Platforms** | Product managers, trust & safety teams, CTOs, compliance officers | ~120 min |

**Start here →** [tuteliq.ai/certify](https://tuteliq.ai/certify)

- 100% Free — no login required
- Verifiable certificate on completion
- Covers grooming recognition, sextortion, cyberbullying, regulatory obligations (KOSA, EU DSA), and more

---

## The Mission: Why This Matters

Before you decide to contribute or sponsor, read these numbers. They are not projections. They are not estimates from a pitch deck. They are verified statistics from the University of Edinburgh, UNICEF, NCMEC, and Interpol.

- **302 million** children are victims of online sexual exploitation and abuse every year. That is **10 children every second**. *(Childlight / University of Edinburgh, 2024)*
- **1 in 8** children globally have been victims of non-consensual sexual imagery in the past year. *(Childlight, 2024)*
- **370 million** girls and women alive today experienced rape or sexual assault in childhood. An estimated **240–310 million** boys and men experienced the same. *(UNICEF, 2024)*
- **29.2 million** incidents of suspected child sexual exploitation were reported to NCMEC's CyberTipline in 2024 alone — containing **62.9 million files** (images, videos). *(NCMEC, 2025)*
- **546,000** reports of online enticement (adults grooming children) in 2024 — a **192% increase** from the year before. *(NCMEC, 2025)*
- **1,325% increase** in AI-generated child sexual abuse material reports between 2023 and 2024. The technology that should protect children is being weaponized against them. *(NCMEC, 2025)*
- **100 sextortion reports per day** to NCMEC. Since 2021, at least **36 teenage boys** have taken their own lives because they were victimized by sextortion. *(NCMEC, 2025)*
- **84%** of reports resolve outside the United States. This is not an American problem. This is a **global emergency**. *(NCMEC, 2025)*

End-to-end encryption is making platforms blind. In 2024, platforms reported **7 million fewer incidents** than the year before — not because abuse stopped, but because they can no longer see it. The tools that catch known images are failing. The systems that rely on human moderators are overwhelmed. The technology to detect behavior — grooming patterns, escalation, manipulation — in real-time text conversations **exists right now**. It is running at [api.tuteliq.ai](https://api.tuteliq.ai).

The question is not whether this technology is possible. The question is whether we build the company to put it everywhere it needs to be.

**Every second we wait, another child is harmed.**

We have the technology. We need the support.

If this mission matters to you, consider [sponsoring our open-source work](https://github.com/sponsors/Tuteliq) so we can keep building the tools that protect children — and keep them free and accessible for everyone.

---

<p align="center">
  <sub>Built with care for child safety by the <a href="https://tuteliq.ai">Tuteliq</a> team</sub>
</p>
