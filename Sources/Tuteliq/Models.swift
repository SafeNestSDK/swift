import Foundation

// MARK: - Common Types

/// Context for content analysis.
///
/// Provides optional metadata to improve analysis accuracy.
public struct AnalysisContext: Codable, Sendable {
    /// Language code (e.g., `"en"`).
    public var language: String?
    /// Age group range (e.g., `"11-13"`).
    public var ageGroup: String?
    /// Relationship between participants (e.g., `"classmates"`).
    public var relationship: String?
    /// Platform where the content originated (e.g., `"Discord"`).
    public var platform: String?

    public init(
        language: String? = nil,
        ageGroup: String? = nil,
        relationship: String? = nil,
        platform: String? = nil
    ) {
        self.language = language
        self.ageGroup = ageGroup
        self.relationship = relationship
        self.platform = platform
    }

    enum CodingKeys: String, CodingKey {
        case language
        case ageGroup = "age_group"
        case relationship
        case platform
    }
}

/// Monthly usage statistics, populated from response headers.
public struct Usage: Codable, Sendable {
    /// Total monthly API calls available.
    public let limit: Int
    /// API calls used this month.
    public let used: Int
    /// API calls remaining this month.
    public let remaining: Int
    /// Next monthly reset date (YYYY-MM-DD), if available.
    public let reset: String?
    /// Warning message when >80% of monthly limit used, if applicable.
    public let warning: String?
}

/// Rate limit information from response headers.
public struct RateLimitInfo: Sendable {
    /// Maximum requests per minute for your tier.
    public let limit: Int
    /// Remaining requests in current window.
    public let remaining: Int
    /// Unix timestamp (seconds) when rate limit resets.
    public let reset: TimeInterval
}

// MARK: - Bullying Detection

/// Input for bullying detection.
///
/// - Note: The ``content`` field maps to the API `text` field.
public struct DetectBullyingInput: Sendable {
    /// Text content to analyze.
    public var content: String
    /// Optional analysis context.
    public var context: AnalysisContext?
    /// Your external correlation ID (max 255 chars).
    public var externalId: String?
    /// Multi-tenant customer ID for webhook routing (max 255 chars).
    public var customerId: String?
    /// Arbitrary key-value metadata echoed back in the response.
    public var metadata: [String: AnyCodable]?

    public init(
        content: String,
        context: AnalysisContext? = nil,
        externalId: String? = nil,
        customerId: String? = nil,
        metadata: [String: Any]? = nil
    ) {
        self.content = content
        self.context = context
        self.externalId = externalId
        self.customerId = customerId
        self.metadata = metadata?.mapValues { AnyCodable($0) }
    }
}

/// Result from bullying detection.
public struct BullyingResult: Codable, Sendable {
    public let isBullying: Bool
    public let bullyingType: [String]
    public let confidence: Double
    public let severity: Severity
    public let rationale: String
    public let recommendedAction: String
    public let riskScore: Double
    public let language: String?
    public let languageStatus: String?
    public let creditsUsed: Int?
    public let externalId: String?
    public let customerId: String?
    public let metadata: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case isBullying = "is_bullying"
        case bullyingType = "bullying_type"
        case confidence, severity, rationale
        case recommendedAction = "recommended_action"
        case riskScore = "risk_score"
        case language
        case languageStatus = "language_status"
        case creditsUsed = "credits_used"
        case externalId = "external_id"
        case customerId = "customer_id"
        case metadata
    }
}

// MARK: - Grooming Detection

/// A single message in a grooming detection conversation.
public struct GroomingMessage: Codable, Sendable {
    /// Role of the message sender.
    public var role: MessageRole
    /// Message text content.
    public var content: String
    /// Optional timestamp.
    public var timestamp: Date?

    public init(role: MessageRole, content: String, timestamp: Date? = nil) {
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }

    enum CodingKeys: String, CodingKey {
        case role = "sender_role"
        case content = "text"
        case timestamp
    }
}

/// Input for grooming detection.
public struct DetectGroomingInput: Sendable {
    /// Array of conversation messages to analyze.
    public var messages: [GroomingMessage]
    /// Age of the child participant.
    public var childAge: Int?
    /// Optional analysis context.
    public var context: AnalysisContext?
    /// Your external correlation ID.
    public var externalId: String?
    /// Multi-tenant customer ID.
    public var customerId: String?
    /// Arbitrary key-value metadata.
    public var metadata: [String: AnyCodable]?

    public init(
        messages: [GroomingMessage],
        childAge: Int? = nil,
        context: AnalysisContext? = nil,
        externalId: String? = nil,
        customerId: String? = nil,
        metadata: [String: Any]? = nil
    ) {
        self.messages = messages
        self.childAge = childAge
        self.context = context
        self.externalId = externalId
        self.customerId = customerId
        self.metadata = metadata?.mapValues { AnyCodable($0) }
    }
}

/// Result from grooming detection.
public struct GroomingResult: Codable, Sendable {
    public let groomingRisk: GroomingRisk
    public let confidence: Double
    public let flags: [String]
    public let rationale: String
    public let riskScore: Double
    public let recommendedAction: String
    public let messageAnalysis: [MessageAnalysis]?
    public let language: String?
    public let languageStatus: String?
    public let creditsUsed: Int?
    public let externalId: String?
    public let customerId: String?
    public let metadata: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case groomingRisk = "grooming_risk"
        case confidence, flags, rationale
        case riskScore = "risk_score"
        case recommendedAction = "recommended_action"
        case messageAnalysis = "message_analysis"
        case language
        case languageStatus = "language_status"
        case creditsUsed = "credits_used"
        case externalId = "external_id"
        case customerId = "customer_id"
        case metadata
    }
}

// MARK: - Unsafe Content Detection

/// Input for unsafe content detection.
public struct DetectUnsafeInput: Sendable {
    /// Text content to analyze.
    public var content: String
    /// Optional analysis context.
    public var context: AnalysisContext?
    /// Your external correlation ID.
    public var externalId: String?
    /// Multi-tenant customer ID.
    public var customerId: String?
    /// Arbitrary key-value metadata.
    public var metadata: [String: AnyCodable]?

    public init(
        content: String,
        context: AnalysisContext? = nil,
        externalId: String? = nil,
        customerId: String? = nil,
        metadata: [String: Any]? = nil
    ) {
        self.content = content
        self.context = context
        self.externalId = externalId
        self.customerId = customerId
        self.metadata = metadata?.mapValues { AnyCodable($0) }
    }
}

/// Result from unsafe content detection.
public struct UnsafeResult: Codable, Sendable {
    public let unsafe: Bool
    public let categories: [String]
    public let severity: Severity
    public let confidence: Double
    public let riskScore: Double
    public let rationale: String
    public let recommendedAction: String
    public let language: String?
    public let languageStatus: String?
    public let creditsUsed: Int?
    public let externalId: String?
    public let customerId: String?
    public let metadata: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case unsafe, categories, severity, confidence, rationale
        case riskScore = "risk_score"
        case recommendedAction = "recommended_action"
        case language
        case languageStatus = "language_status"
        case creditsUsed = "credits_used"
        case externalId = "external_id"
        case customerId = "customer_id"
        case metadata
    }
}

// MARK: - Quick Analysis

/// Input for combined safety analysis.
///
/// Runs bullying and unsafe detection in parallel on the client side.
public struct AnalyzeInput: Sendable {
    /// Text content to analyze.
    public var content: String
    /// Optional analysis context.
    public var context: AnalysisContext?
    /// Which analysis types to include (defaults to bullying + unsafe).
    public var include: [AnalysisType]?
    /// Your external correlation ID.
    public var externalId: String?
    /// Multi-tenant customer ID.
    public var customerId: String?
    /// Arbitrary key-value metadata.
    public var metadata: [String: AnyCodable]?

    public init(
        content: String,
        context: AnalysisContext? = nil,
        include: [AnalysisType]? = nil,
        externalId: String? = nil,
        customerId: String? = nil,
        metadata: [String: Any]? = nil
    ) {
        self.content = content
        self.context = context
        self.include = include
        self.externalId = externalId
        self.customerId = customerId
        self.metadata = metadata?.mapValues { AnyCodable($0) }
    }
}

/// Result from combined safety analysis.
public struct AnalyzeResult: Codable, Sendable {
    public let riskLevel: RiskLevel
    public let riskScore: Double
    public let summary: String
    public let bullying: BullyingResult?
    public let unsafe: UnsafeResult?
    public let recommendedAction: String
    public let creditsUsed: Int?
    public let externalId: String?
    public let customerId: String?
    public let metadata: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case riskLevel = "risk_level"
        case riskScore = "risk_score"
        case summary, bullying, unsafe
        case recommendedAction = "recommended_action"
        case creditsUsed = "credits_used"
        case externalId = "external_id"
        case customerId = "customer_id"
        case metadata
    }
}

// MARK: - Emotion Analysis

/// A single message for emotion analysis.
public struct EmotionMessage: Codable, Sendable {
    /// Sender identifier (e.g., a name or role).
    public var sender: String
    /// Message text content.
    public var content: String
    /// Optional timestamp.
    public var timestamp: Date?

    public init(sender: String, content: String, timestamp: Date? = nil) {
        self.sender = sender
        self.content = content
        self.timestamp = timestamp
    }

    enum CodingKeys: String, CodingKey {
        case sender
        case content = "text"
        case timestamp
    }
}

/// Input for emotion analysis.
public struct AnalyzeEmotionsInput: Sendable {
    /// Single text content to analyze (wrapped as a message internally).
    public var content: String?
    /// Array of messages to analyze.
    public var messages: [EmotionMessage]?
    /// Optional analysis context.
    public var context: AnalysisContext?
    /// Your external correlation ID.
    public var externalId: String?
    /// Multi-tenant customer ID.
    public var customerId: String?
    /// Arbitrary key-value metadata.
    public var metadata: [String: AnyCodable]?

    public init(
        content: String? = nil,
        messages: [EmotionMessage]? = nil,
        context: AnalysisContext? = nil,
        externalId: String? = nil,
        customerId: String? = nil,
        metadata: [String: Any]? = nil
    ) {
        self.content = content
        self.messages = messages
        self.context = context
        self.externalId = externalId
        self.customerId = customerId
        self.metadata = metadata?.mapValues { AnyCodable($0) }
    }
}

/// Result from emotion analysis.
public struct EmotionsResult: Codable, Sendable {
    public let dominantEmotions: [String]
    public let emotionScores: [String: Double]
    public let trend: EmotionTrend
    public let summary: String
    public let recommendedFollowup: String
    public let creditsUsed: Int?
    public let externalId: String?
    public let customerId: String?
    public let metadata: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case dominantEmotions = "dominant_emotions"
        case emotionScores = "emotion_scores"
        case trend, summary
        case recommendedFollowup = "recommended_followup"
        case creditsUsed = "credits_used"
        case externalId = "external_id"
        case customerId = "customer_id"
        case metadata
    }
}

// MARK: - Action Plan

/// Input for generating an action plan.
public struct GetActionPlanInput: Sendable {
    /// Description of the situation.
    public var situation: String
    /// Age of the child involved.
    public var childAge: Int?
    /// Target audience for the plan (defaults to `.parent`).
    public var audience: Audience?
    /// Severity level for context.
    public var severity: Severity?
    /// Your external correlation ID.
    public var externalId: String?
    /// Multi-tenant customer ID.
    public var customerId: String?
    /// Arbitrary key-value metadata.
    public var metadata: [String: AnyCodable]?

    public init(
        situation: String,
        childAge: Int? = nil,
        audience: Audience? = nil,
        severity: Severity? = nil,
        externalId: String? = nil,
        customerId: String? = nil,
        metadata: [String: Any]? = nil
    ) {
        self.situation = situation
        self.childAge = childAge
        self.audience = audience
        self.severity = severity
        self.externalId = externalId
        self.customerId = customerId
        self.metadata = metadata?.mapValues { AnyCodable($0) }
    }
}

/// Result from action plan generation.
public struct ActionPlanResult: Codable, Sendable {
    public let audience: String
    public let steps: [String]
    public let tone: String
    public let readingLevel: String?
    public let creditsUsed: Int?
    public let externalId: String?
    public let customerId: String?
    public let metadata: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case audience, steps, tone
        case readingLevel = "approx_reading_level"
        case creditsUsed = "credits_used"
        case externalId = "external_id"
        case customerId = "customer_id"
        case metadata
    }
}

// MARK: - Incident Report

/// A single message for incident reports.
public struct ReportMessage: Codable, Sendable {
    /// Sender identifier.
    public var sender: String
    /// Message text content.
    public var content: String
    /// Optional timestamp.
    public var timestamp: Date?

    public init(sender: String, content: String, timestamp: Date? = nil) {
        self.sender = sender
        self.content = content
        self.timestamp = timestamp
    }

    enum CodingKeys: String, CodingKey {
        case sender
        case content = "text"
        case timestamp
    }
}

/// Input for generating an incident report.
public struct GenerateReportInput: Sendable {
    /// Array of conversation messages.
    public var messages: [ReportMessage]
    /// Age of the child involved.
    public var childAge: Int?
    /// Type of incident (e.g., `"bullying"`, `"grooming"`).
    public var incidentType: String?
    /// Conversation identifier for the meta block.
    public var conversationId: String?
    /// Timestamp range as `[start, end]` ISO strings.
    public var timestampRange: [String]?
    /// Your external correlation ID.
    public var externalId: String?
    /// Multi-tenant customer ID.
    public var customerId: String?
    /// Arbitrary key-value metadata.
    public var metadata: [String: AnyCodable]?

    public init(
        messages: [ReportMessage],
        childAge: Int? = nil,
        incidentType: String? = nil,
        conversationId: String? = nil,
        timestampRange: [String]? = nil,
        externalId: String? = nil,
        customerId: String? = nil,
        metadata: [String: Any]? = nil
    ) {
        self.messages = messages
        self.childAge = childAge
        self.incidentType = incidentType
        self.conversationId = conversationId
        self.timestampRange = timestampRange
        self.externalId = externalId
        self.customerId = customerId
        self.metadata = metadata?.mapValues { AnyCodable($0) }
    }
}

/// Result from incident report generation.
public struct ReportResult: Codable, Sendable {
    public let summary: String
    public let riskLevel: RiskLevel
    public let categories: [String]
    public let recommendedNextSteps: [String]
    public let creditsUsed: Int?
    public let externalId: String?
    public let customerId: String?
    public let metadata: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case summary, categories
        case riskLevel = "risk_level"
        case recommendedNextSteps = "recommended_next_steps"
        case creditsUsed = "credits_used"
        case externalId = "external_id"
        case customerId = "customer_id"
        case metadata
    }
}

// MARK: - Voice Analysis

/// A timestamped segment from audio transcription.
public struct TranscriptionSegment: Codable, Sendable {
    /// Start time in seconds.
    public let start: Double
    /// End time in seconds.
    public let end: Double
    /// Transcribed text for this segment.
    public let text: String
}

/// Result from audio transcription.
public struct TranscriptionResult: Codable, Sendable {
    /// Full transcribed text.
    public let text: String
    /// Detected language code.
    public let language: String
    /// Audio duration in seconds.
    public let duration: Double
    /// Timestamped segments.
    public let segments: [TranscriptionSegment]
}

/// Input for voice analysis.
///
/// Provide audio file data and an optional analysis type. The SDK handles
/// multipart encoding and MIME type detection from the filename extension.
///
/// ```swift
/// let audioData = try Data(contentsOf: audioURL)
/// let input = AnalyzeVoiceInput(file: audioData, filename: "recording.mp3")
/// let result = try await tuteliq.analyzeVoice(input)
/// ```
public struct AnalyzeVoiceInput: Sendable {
    /// Raw audio file data.
    public var file: Data
    /// Filename with extension (used for MIME type detection).
    public var filename: String
    /// Analysis type to run on the transcript. Defaults to `.all`.
    public var analysisType: VoiceAnalysisType?
    /// Customer-provided file reference echoed in the response.
    public var fileId: String?
    /// Age group range (e.g., `"11-13"`).
    public var ageGroup: String?
    /// Language code (e.g., `"en"`).
    public var language: String?
    /// Platform where the content originated.
    public var platform: String?
    /// Age of the child participant.
    public var childAge: Int?
    /// Your external correlation ID (max 255 chars).
    public var externalId: String?
    /// Multi-tenant customer ID for webhook routing (max 255 chars).
    public var customerId: String?
    /// Arbitrary key-value metadata as a JSON string map.
    public var metadata: [String: String]?

    public init(
        file: Data,
        filename: String,
        analysisType: VoiceAnalysisType? = nil,
        fileId: String? = nil,
        ageGroup: String? = nil,
        language: String? = nil,
        platform: String? = nil,
        childAge: Int? = nil,
        externalId: String? = nil,
        customerId: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.file = file
        self.filename = filename
        self.analysisType = analysisType
        self.fileId = fileId
        self.ageGroup = ageGroup
        self.language = language
        self.platform = platform
        self.childAge = childAge
        self.externalId = externalId
        self.customerId = customerId
        self.metadata = metadata
    }
}

/// Result from voice analysis.
public struct VoiceAnalysisResult: Codable, Sendable {
    /// Customer-provided file reference.
    public let fileId: String?
    /// Transcription with timestamped segments.
    public let transcription: TranscriptionResult
    /// Per-type analysis results (keys: `bullying`, `unsafe`, `grooming`, `emotions`).
    public let analysis: [String: AnyCodable]?
    /// Overall risk score (0.0–1.0).
    public let overallRiskScore: Double
    /// Overall severity level.
    public let overallSeverity: ContentSeverity
    /// Number of credits consumed by this request.
    public let creditsUsed: Int?
    /// Echoed external correlation ID.
    public let externalId: String?
    /// Echoed customer ID.
    public let customerId: String?

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case transcription, analysis
        case overallRiskScore = "overall_risk_score"
        case overallSeverity = "overall_severity"
        case creditsUsed = "credits_used"
        case externalId = "external_id"
        case customerId = "customer_id"
    }
}

// MARK: - Image Analysis

/// Visual analysis result from image safety classification and OCR.
public struct VisionResult: Codable, Sendable {
    /// Text extracted via OCR.
    public let extractedText: String
    /// Visual harm categories detected.
    public let visualCategories: [String]
    /// Visual content severity.
    public let visualSeverity: ContentSeverity
    /// Confidence score (0.0–1.0).
    public let visualConfidence: Double
    /// Description of visual content.
    public let visualDescription: String
    /// Whether the image contains readable text.
    public let containsText: Bool
    /// Whether the image contains faces.
    public let containsFaces: Bool

    enum CodingKeys: String, CodingKey {
        case extractedText = "extracted_text"
        case visualCategories = "visual_categories"
        case visualSeverity = "visual_severity"
        case visualConfidence = "visual_confidence"
        case visualDescription = "visual_description"
        case containsText = "contains_text"
        case containsFaces = "contains_faces"
    }
}

/// Input for image analysis.
///
/// Provide image file data and an optional analysis type. The SDK handles
/// multipart encoding and MIME type detection from the filename extension.
///
/// ```swift
/// let imageData = try Data(contentsOf: imageURL)
/// let input = AnalyzeImageInput(file: imageData, filename: "screenshot.png")
/// let result = try await tuteliq.analyzeImage(input)
/// ```
public struct AnalyzeImageInput: Sendable {
    /// Raw image file data.
    public var file: Data
    /// Filename with extension (used for MIME type detection).
    public var filename: String
    /// Analysis type to run on extracted text. Defaults to `.all`.
    public var analysisType: ImageAnalysisType?
    /// Customer-provided file reference echoed in the response.
    public var fileId: String?
    /// Age group range (e.g., `"11-13"`).
    public var ageGroup: String?
    /// Platform where the content originated.
    public var platform: String?
    /// Your external correlation ID (max 255 chars).
    public var externalId: String?
    /// Multi-tenant customer ID for webhook routing (max 255 chars).
    public var customerId: String?
    /// Arbitrary key-value metadata as a JSON string map.
    public var metadata: [String: String]?

    public init(
        file: Data,
        filename: String,
        analysisType: ImageAnalysisType? = nil,
        fileId: String? = nil,
        ageGroup: String? = nil,
        platform: String? = nil,
        externalId: String? = nil,
        customerId: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.file = file
        self.filename = filename
        self.analysisType = analysisType
        self.fileId = fileId
        self.ageGroup = ageGroup
        self.platform = platform
        self.externalId = externalId
        self.customerId = customerId
        self.metadata = metadata
    }
}

/// Result from image analysis.
public struct ImageAnalysisResult: Codable, Sendable {
    /// Customer-provided file reference.
    public let fileId: String?
    /// Vision analysis with OCR and visual classification.
    public let vision: VisionResult
    /// Per-type text analysis results from extracted OCR text (keys: `bullying`, `unsafe`, `emotions`).
    public let textAnalysis: [String: AnyCodable]?
    /// Overall risk score (0.0–1.0).
    public let overallRiskScore: Double
    /// Overall severity level.
    public let overallSeverity: ContentSeverity
    /// Number of credits consumed by this request.
    public let creditsUsed: Int?
    /// Echoed external correlation ID.
    public let externalId: String?
    /// Echoed customer ID.
    public let customerId: String?

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case vision
        case textAnalysis = "text_analysis"
        case overallRiskScore = "overall_risk_score"
        case overallSeverity = "overall_severity"
        case creditsUsed = "credits_used"
        case externalId = "external_id"
        case customerId = "customer_id"
    }
}

// MARK: - Unified Detection (Fraud + Safety Extended)

/// Input for all fraud detection and safety-extended endpoints.
public struct DetectionInput: Sendable {
    /// Text content to analyze.
    public var content: String
    /// Optional analysis context.
    public var context: AnalysisContext?
    /// Include evidence excerpts in the response.
    public var includeEvidence: Bool
    /// Your external correlation ID.
    public var externalId: String?
    /// Multi-tenant customer ID.
    public var customerId: String?
    /// Arbitrary key-value metadata.
    public var metadata: [String: AnyCodable]?

    public init(
        content: String,
        context: AnalysisContext? = nil,
        includeEvidence: Bool = false,
        externalId: String? = nil,
        customerId: String? = nil,
        metadata: [String: Any]? = nil
    ) {
        self.content = content
        self.context = context
        self.includeEvidence = includeEvidence
        self.externalId = externalId
        self.customerId = customerId
        self.metadata = metadata?.mapValues { AnyCodable($0) }
    }
}

/// Per-message analysis from conversation-aware detection.
public struct MessageAnalysis: Codable, Sendable {
    /// Index of the message in the input array.
    public let messageIndex: Int
    /// Risk score for this specific message (0.0–1.0).
    public let riskScore: Double
    /// Flags identified in this message.
    public let flags: [String]
    /// Brief summary of the message analysis.
    public let summary: String

    enum CodingKeys: String, CodingKey {
        case messageIndex = "message_index"
        case riskScore = "risk_score"
        case flags, summary
    }
}

/// A detected category with tag and confidence.
public struct DetectionCategory: Codable, Sendable {
    public let tag: String
    public let label: String
    public let confidence: Double
}

/// Evidence excerpt from the analyzed content.
public struct DetectionEvidence: Codable, Sendable {
    public let text: String
    public let tactic: String
    public let weight: Double
}

/// Age calibration details applied to risk scoring.
public struct AgeCalibration: Codable, Sendable {
    public let applied: Bool
    public let ageGroup: String?
    public let multiplier: Double?

    enum CodingKeys: String, CodingKey {
        case applied
        case ageGroup = "age_group"
        case multiplier
    }
}

/// Unified result from fraud detection and safety-extended endpoints.
public struct DetectionResult: Codable, Sendable {
    public let endpoint: String
    public let detected: Bool
    public let severity: Double
    public let confidence: Double
    public let riskScore: Double
    public let level: String
    public let categories: [DetectionCategory]
    public let recommendedAction: String
    public let rationale: String
    public let language: String
    public let languageStatus: LanguageStatus
    public let evidence: [DetectionEvidence]?
    public let ageCalibration: AgeCalibration?
    public let messageAnalysis: [MessageAnalysis]?
    public let creditsUsed: Int?
    public let processingTimeMs: Double?
    public let externalId: String?
    public let customerId: String?
    public let metadata: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case endpoint, detected, severity, confidence, categories, rationale, language, evidence, metadata
        case riskScore = "risk_score"
        case level
        case recommendedAction = "recommended_action"
        case languageStatus = "language_status"
        case ageCalibration = "age_calibration"
        case messageAnalysis = "message_analysis"
        case creditsUsed = "credits_used"
        case processingTimeMs = "processing_time_ms"
        case externalId = "external_id"
        case customerId = "customer_id"
    }
}

// MARK: - Multi-Endpoint Analysis

/// Input for multi-endpoint analysis.
public struct AnalyseMultiInput: Sendable {
    /// Text content to analyze.
    public var content: String
    /// Detection endpoints to run (max 10).
    public var detections: [Detection]
    /// Optional analysis context.
    public var context: AnalysisContext?
    /// Include evidence in individual results.
    public var includeEvidence: Bool
    /// Your external correlation ID.
    public var externalId: String?
    /// Multi-tenant customer ID.
    public var customerId: String?
    /// Arbitrary key-value metadata.
    public var metadata: [String: AnyCodable]?

    public init(
        content: String,
        detections: [Detection],
        context: AnalysisContext? = nil,
        includeEvidence: Bool = false,
        externalId: String? = nil,
        customerId: String? = nil,
        metadata: [String: Any]? = nil
    ) {
        self.content = content
        self.detections = detections
        self.context = context
        self.includeEvidence = includeEvidence
        self.externalId = externalId
        self.customerId = customerId
        self.metadata = metadata?.mapValues { AnyCodable($0) }
    }
}

/// Summary of multi-endpoint analysis results.
public struct AnalyseMultiSummary: Codable, Sendable {
    public let totalEndpoints: Int
    public let detectedCount: Int
    public let highestRisk: [String: AnyCodable]
    public let overallRiskLevel: String

    enum CodingKeys: String, CodingKey {
        case totalEndpoints = "total_endpoints"
        case detectedCount = "detected_count"
        case highestRisk = "highest_risk"
        case overallRiskLevel = "overall_risk_level"
    }
}

/// Result from multi-endpoint analysis.
public struct AnalyseMultiResult: Codable, Sendable {
    public let results: [DetectionResult]
    public let summary: AnalyseMultiSummary
    public let crossEndpointModifier: Double?
    public let creditsUsed: Int?
    public let externalId: String?
    public let customerId: String?
    public let metadata: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case results, summary, metadata
        case crossEndpointModifier = "cross_endpoint_modifier"
        case creditsUsed = "credits_used"
        case externalId = "external_id"
        case customerId = "customer_id"
    }
}

// MARK: - Video Analysis

/// A safety finding from a video frame.
public struct VideoSafetyFinding: Codable, Sendable {
    public let frameIndex: Int
    public let timestamp: Double
    public let description: String
    public let categories: [String]
    public let severity: Double

    enum CodingKeys: String, CodingKey {
        case frameIndex = "frame_index"
        case timestamp, description, categories, severity
    }
}

/// Input for video analysis.
public struct AnalyzeVideoInput: Sendable {
    /// Raw video file data.
    public var file: Data
    /// Filename with extension (used for MIME type detection).
    public var filename: String
    /// Customer-provided file reference echoed in the response.
    public var fileId: String?
    /// Age group range.
    public var ageGroup: String?
    /// Platform where the content originated.
    public var platform: String?
    /// Your external correlation ID.
    public var externalId: String?
    /// Multi-tenant customer ID.
    public var customerId: String?
    /// Arbitrary key-value metadata.
    public var metadata: [String: String]?

    public init(
        file: Data,
        filename: String,
        fileId: String? = nil,
        ageGroup: String? = nil,
        platform: String? = nil,
        externalId: String? = nil,
        customerId: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.file = file
        self.filename = filename
        self.fileId = fileId
        self.ageGroup = ageGroup
        self.platform = platform
        self.externalId = externalId
        self.customerId = customerId
        self.metadata = metadata
    }
}

/// Result from video analysis.
public struct VideoAnalysisResult: Codable, Sendable {
    public let fileId: String?
    public let framesAnalyzed: Int
    public let safetyFindings: [VideoSafetyFinding]
    public let overallRiskScore: Double
    public let overallSeverity: ContentSeverity
    public let creditsUsed: Int?
    public let externalId: String?
    public let customerId: String?
    public let metadata: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case framesAnalyzed = "frames_analyzed"
        case safetyFindings = "safety_findings"
        case overallRiskScore = "overall_risk_score"
        case overallSeverity = "overall_severity"
        case creditsUsed = "credits_used"
        case externalId = "external_id"
        case customerId = "customer_id"
        case metadata
    }
}

// MARK: - Verification

/// Input for creating a verification session.
public struct CreateVerificationSessionInput: Sendable {
    /// Verification mode (age or identity).
    public var mode: VerificationMode
    /// Document type to verify.
    public var documentType: DocumentType?

    public init(mode: VerificationMode, documentType: DocumentType? = nil) {
        self.mode = mode
        self.documentType = documentType
    }
}

/// Verification session details.
public struct VerificationSession: Codable, Sendable {
    public let sessionId: String
    /// URL to redirect the user for verification (mapped from API `mobile_url`).
    public let url: String
    public let expiresAt: String
    public let mode: VerificationMode
    public let verificationMode: String?

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case url = "mobile_url"
        case expiresAt = "expires_at"
        case mode
        case verificationMode = "verification_mode"
    }
}

/// Face match result from verification.
public struct FaceMatchResult: Codable, Sendable {
    public let matched: Bool
    public let confidence: Double
    public let distance: Double?
}

/// Liveness check result from verification.
public struct LivenessResult: Codable, Sendable {
    public let valid: Bool
    public let reason: String?
}

/// Result of age verification.
public struct AgeVerificationResult: Codable, Sendable {
    public let verificationId: String
    public let status: VerificationStatus
    public let ageBracket: String?
    public let isMinor: Bool?
    public let liveness: LivenessResult?
    public let faceMatch: FaceMatchResult?
    public let failureReasons: [String]?
    public let creditsUsed: Int?

    enum CodingKeys: String, CodingKey {
        case verificationId = "verification_id"
        case status
        case ageBracket = "age_bracket"
        case isMinor = "is_minor"
        case liveness
        case faceMatch = "face_match"
        case failureReasons = "failure_reasons"
        case creditsUsed = "credits_used"
    }
}

/// Result of identity verification.
public struct IdentityVerificationResult: Codable, Sendable {
    public let verificationId: String
    public let status: VerificationStatus
    public let fullName: String?
    public let dateOfBirth: String?
    public let documentType: String?
    public let countryCode: String?
    public let liveness: LivenessResult?
    public let faceMatch: FaceMatchResult?
    public let creditsUsed: Int?

    enum CodingKeys: String, CodingKey {
        case verificationId = "verification_id"
        case status
        case fullName = "full_name"
        case dateOfBirth = "date_of_birth"
        case documentType = "document_type"
        case countryCode = "country_code"
        case liveness
        case faceMatch = "face_match"
        case creditsUsed = "credits_used"
    }
}

/// Result of polling a verification session.
public struct VerificationSessionResult: Codable, Sendable {
    public let sessionId: String
    public let status: VerificationSessionStatus
    public let result: AnyCodable?
    public let createdAt: String?
    public let expiresAt: String?

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case status, result
        case createdAt = "created_at"
        case expiresAt = "expires_at"
    }
}

/// Result of retrieving an age verification by ID.
public struct VerificationRetrieveResult: Codable, Sendable {
    public let verificationId: String
    public let status: VerificationStatus
    public let ageBracket: String?
    public let isMinor: Bool?
    public let liveness: LivenessResult?
    public let faceMatch: FaceMatchResult?
    public let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case verificationId = "verification_id"
        case status
        case ageBracket = "age_bracket"
        case isMinor = "is_minor"
        case liveness
        case faceMatch = "face_match"
        case createdAt = "created_at"
    }
}

/// Result of retrieving an identity verification by ID.
public struct IdentityRetrieveResult: Codable, Sendable {
    public let verificationId: String
    public let status: VerificationStatus
    public let fullName: String?
    public let dateOfBirth: String?
    public let documentType: String?
    public let countryCode: String?
    public let liveness: LivenessResult?
    public let faceMatch: FaceMatchResult?
    public let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case verificationId = "verification_id"
        case status
        case fullName = "full_name"
        case dateOfBirth = "date_of_birth"
        case documentType = "document_type"
        case countryCode = "country_code"
        case liveness
        case faceMatch = "face_match"
        case createdAt = "created_at"
    }
}

/// Result of cancelling a verification session.
public struct CancelVerificationSessionResult: Codable, Sendable {
    public let message: String
}

// MARK: - Document Analysis

/// Input for document (PDF) analysis.
///
/// Provide PDF file data and optional detection endpoints. The SDK handles
/// multipart encoding and MIME type detection from the filename extension.
///
/// ```swift
/// let pdfData = try Data(contentsOf: pdfURL)
/// let input = AnalyzeDocumentInput(file: pdfData, filename: "report.pdf")
/// let result = try await tuteliq.analyzeDocument(input)
/// ```
public struct AnalyzeDocumentInput: Sendable {
    /// Raw PDF file data.
    public var file: Data
    /// Filename with extension (used for MIME type detection).
    public var filename: String
    /// Detection endpoints to run on each page. Defaults to `["unsafe", "coercive-control", "radicalisation"]`.
    public var endpoints: [DocumentEndpointName]?
    /// Customer-provided file reference echoed in the response.
    public var fileId: String?
    /// Age group range (e.g., `"11-13"`).
    public var ageGroup: String?
    /// Language hint (ISO 639-1).
    public var language: String?
    /// Platform where the content originated.
    public var platform: String?
    /// Minimum severity to include crisis helplines. Default: `"high"`.
    public var supportThreshold: String?
    /// Your external correlation ID (max 255 chars).
    public var externalId: String?
    /// Multi-tenant customer ID for webhook routing (max 255 chars).
    public var customerId: String?
    /// Arbitrary key-value metadata as a JSON string map.
    public var metadata: [String: String]?

    public init(
        file: Data,
        filename: String,
        endpoints: [DocumentEndpointName]? = nil,
        fileId: String? = nil,
        ageGroup: String? = nil,
        language: String? = nil,
        platform: String? = nil,
        supportThreshold: String? = nil,
        externalId: String? = nil,
        customerId: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.file = file
        self.filename = filename
        self.endpoints = endpoints
        self.fileId = fileId
        self.ageGroup = ageGroup
        self.language = language
        self.platform = platform
        self.supportThreshold = supportThreshold
        self.externalId = externalId
        self.customerId = customerId
        self.metadata = metadata
    }
}

/// Breakdown of text extraction results across document pages.
public struct DocumentExtractionSummary: Codable, Sendable {
    /// Pages where text was extracted from the PDF text layer.
    public let textLayerPages: Int
    /// Pages where OCR was used.
    public let ocrPages: Int
    /// Pages with insufficient text for analysis.
    public let failedPages: Int
    /// Average OCR confidence (0.0–1.0) across OCR pages.
    public let averageOcrConfidence: Double

    enum CodingKeys: String, CodingKey {
        case textLayerPages = "text_layer_pages"
        case ocrPages = "ocr_pages"
        case failedPages = "failed_pages"
        case averageOcrConfidence = "average_ocr_confidence"
    }
}

/// Category detected within a document page endpoint result.
public struct DocumentCategory: Codable, Sendable {
    /// Category tag identifier.
    public let tag: String
    /// Human-readable label.
    public let label: String
    /// Confidence score (0.0–1.0).
    public let confidence: Double
}

/// Evidence excerpt from a document page endpoint result.
public struct DocumentEvidence: Codable, Sendable {
    /// Relevant text excerpt.
    public let text: String
    /// Detected tactic or pattern.
    public let tactic: String
    /// Evidence weight (0.0–1.0).
    public let weight: Double
}

/// Detection result for a single endpoint on a single document page.
public struct DocumentPageEndpointResult: Codable, Sendable {
    /// Endpoint name.
    public let endpoint: String
    /// Whether a threat was detected.
    public let detected: Bool
    /// Severity score (0.0–1.0).
    public let severity: Double
    /// Confidence score (0.0–1.0).
    public let confidence: Double
    /// Risk score (0.0–1.0).
    public let riskScore: Double
    /// Risk level.
    public let level: String
    /// Detected categories.
    public let categories: [DocumentCategory]
    /// Evidence excerpts.
    public let evidence: [DocumentEvidence]
    /// Recommended action.
    public let recommendedAction: String
    /// Human-readable rationale.
    public let rationale: String
    /// Detected language.
    public let detectedLanguage: String?

    enum CodingKeys: String, CodingKey {
        case endpoint, detected, severity, confidence
        case riskScore = "risk_score"
        case level, categories, evidence
        case recommendedAction = "recommended_action"
        case rationale
        case detectedLanguage = "detected_language"
    }
}

/// Detection results for a single document page.
public struct DocumentPageResult: Codable, Sendable {
    /// Page number (1-indexed).
    public let pageNumber: Int
    /// First 200 characters of page text.
    public let textPreview: String
    /// How text was extracted (`"text_layer"` or `"ocr"`).
    public let extractionMethod: String
    /// OCR confidence if applicable.
    public let ocrConfidence: Double?
    /// Detection results per endpoint.
    public let results: [DocumentPageEndpointResult]
    /// Highest risk score on this page.
    public let pageRiskScore: Double
    /// Page severity level.
    public let pageSeverity: String

    enum CodingKeys: String, CodingKey {
        case pageNumber = "page_number"
        case textPreview = "text_preview"
        case extractionMethod = "extraction_method"
        case ocrConfidence = "ocr_confidence"
        case results
        case pageRiskScore = "page_risk_score"
        case pageSeverity = "page_severity"
    }
}

/// A flagged page with elevated risk.
public struct DocumentFlaggedPage: Codable, Sendable {
    /// Page number.
    public let pageNumber: Int
    /// Risk score.
    public let riskScore: Double
    /// Severity level.
    public let severity: String
    /// Endpoints that detected threats on this page.
    public let detectedEndpoints: [String]

    enum CodingKeys: String, CodingKey {
        case pageNumber = "page_number"
        case riskScore = "risk_score"
        case severity
        case detectedEndpoints = "detected_endpoints"
    }
}

/// Result from document (PDF) analysis.
public struct DocumentAnalysisResult: Codable, Sendable {
    /// Customer-provided file reference (if provided).
    public let fileId: String?
    /// SHA-256 hash of the uploaded PDF for chain-of-custody verification.
    public let documentHash: String
    /// Total pages in the document.
    public let totalPages: Int
    /// Pages with extractable text that were analyzed.
    public let pagesAnalyzed: Int
    /// Breakdown of text extraction results.
    public let extractionSummary: DocumentExtractionSummary
    /// Per-page detection results.
    public let pageResults: [DocumentPageResult]
    /// Highest risk score across all pages (0.0–1.0).
    public let overallRiskScore: Double
    /// Overall severity level.
    public let overallSeverity: String
    /// Unique list of endpoints that detected threats.
    public let detectedEndpoints: [String]
    /// Pages with risk score >= 0.3.
    public let flaggedPages: [DocumentFlaggedPage]
    /// Dynamic credit cost based on pages analyzed and endpoints used.
    public let creditsUsed: Int
    /// Processing time in milliseconds.
    public let processingTimeMs: Int
    /// Detected language.
    public let language: String?
    /// Language support status.
    public let languageStatus: String?
    /// Crisis support resources (if triggered).
    public let support: [String: AnyCodable]?
    /// Echoed external correlation ID.
    public let externalId: String?
    /// Echoed customer ID.
    public let customerId: String?
    /// Echoed metadata.
    public let metadata: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case documentHash = "document_hash"
        case totalPages = "total_pages"
        case pagesAnalyzed = "pages_analyzed"
        case extractionSummary = "extraction_summary"
        case pageResults = "page_results"
        case overallRiskScore = "overall_risk_score"
        case overallSeverity = "overall_severity"
        case detectedEndpoints = "detected_endpoints"
        case flaggedPages = "flagged_pages"
        case creditsUsed = "credits_used"
        case processingTimeMs = "processing_time_ms"
        case language
        case languageStatus = "language_status"
        case support
        case externalId = "external_id"
        case customerId = "customer_id"
        case metadata
    }
}

// MARK: - AnyCodable Helper

/// A type-erased `Codable` value for handling dynamic JSON fields.
///
/// Used for `metadata` dictionaries and other unstructured API fields.
/// Supports `Bool`, `Int`, `Double`, `String`, arrays, and dictionaries.
public struct AnyCodable: Codable, @unchecked Sendable {
    /// The underlying value.
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
}
