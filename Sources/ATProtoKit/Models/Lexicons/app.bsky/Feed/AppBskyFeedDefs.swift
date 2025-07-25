//
//  AppBskyFeedDefs.swift
//
//
//  Created by Christopher Jr Riley on 2024-05-18.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension AppBskyLexicon.Feed {

    /// A definition model for a post view.
    ///
    /// - SeeAlso: This is based on the [`app.bsky.feed.defs`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/defs.json
    public struct PostViewDefinition: Sendable, Codable, Equatable, Hashable {

        /// The URI of the post.
        public let uri: String

        /// The CID hash of the post.
        public let cid: String

        /// The author of the post. This will give the basic details of the post author.
        public let author: AppBskyLexicon.Actor.ProfileViewBasicDefinition

        /// The record data itself.
        public let record: UnknownType

        /// An embed view of a specific type. Optional.
        public var embed: EmbedUnion?

        /// The number of replies in the post. Optional.
        public let replyCount: Int?

        /// The number of reposts in the post. Optional.
        public let repostCount: Int?

        /// The number of likes in the post. Optional.
        public let likeCount: Int?

        /// The number of quote posts in the post. Optional.
        public let quoteCount: Int?

        /// The last time the post has been indexed.
        public let indexedAt: Date

        /// The viewer's interaction with the post. Optional.
        public let viewer: ViewerStateDefinition?

        /// An array of labels attached to the post. Optional.
        public let labels: [ComAtprotoLexicon.Label.LabelDefinition]?

        /// The ruleset of who can reply to the post. Optional.
        public let threadgate: ThreadgateViewDefinition?

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.uri = try container.decode(String.self, forKey: .uri)
            self.cid = try container.decode(String.self, forKey: .cid)
            self.author = try container.decode(AppBskyLexicon.Actor.ProfileViewBasicDefinition.self, forKey: .author)
            self.record = try container.decode(UnknownType.self, forKey: .record)
            self.embed = try container.decodeIfPresent(EmbedUnion.self, forKey: .embed)
            self.replyCount = try container.decodeIfPresent(Int.self, forKey: .replyCount)
            self.repostCount = try container.decodeIfPresent(Int.self, forKey: .repostCount)
            self.likeCount = try container.decodeIfPresent(Int.self, forKey: .likeCount)
            self.quoteCount = try container.decodeIfPresent(Int.self, forKey: .quoteCount)
            self.indexedAt = try container.decodeDate(forKey: .indexedAt)
            self.viewer = try container.decodeIfPresent(AppBskyLexicon.Feed.ViewerStateDefinition.self, forKey: .viewer)
            self.labels = try container.decodeIfPresent([ComAtprotoLexicon.Label.LabelDefinition].self, forKey: .labels)
            self.threadgate = try container.decodeIfPresent(AppBskyLexicon.Feed.ThreadgateViewDefinition.self, forKey: .threadgate)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(self.uri, forKey: .uri)
            try container.encode(self.cid, forKey: .cid)
            try container.encode(self.author, forKey: .author)
            try container.encode(self.record, forKey: .record)
            try container.encodeIfPresent(self.embed, forKey: .embed)
            try container.encodeIfPresent(self.replyCount, forKey: .replyCount)
            try container.encodeIfPresent(self.repostCount, forKey: .repostCount)
            try container.encodeIfPresent(self.likeCount, forKey: .likeCount)
            try container.encodeIfPresent(self.quoteCount, forKey: .quoteCount)
            try container.encodeDateIfPresent(self.indexedAt, forKey: .indexedAt)
            try container.encodeIfPresent(self.viewer, forKey: .viewer)
            try container.encodeIfPresent(self.labels, forKey: .labels)
            try container.encodeIfPresent(self.threadgate, forKey: .threadgate)
        }

        enum CodingKeys: CodingKey {
            case uri
            case cid
            case author
            case record
            case embed
            case replyCount
            case repostCount
            case likeCount
            case quoteCount
            case indexedAt
            case viewer
            case labels
            case threadgate
        }

        // Unions
        /// An embed view of a specific type.
        public enum EmbedUnion: ATUnionProtocol, Equatable, Hashable {

            /// The view of an image embed.
            case embedImagesView(AppBskyLexicon.Embed.ImagesDefinition.View)

            /// The view of a video embed.
            case embedVideoView(AppBskyLexicon.Embed.VideoDefinition.View)

            /// The view of an external embed.
            case embedExternalView(AppBskyLexicon.Embed.ExternalDefinition.View)

            /// The view of a record embed.
            case embedRecordView(AppBskyLexicon.Embed.RecordDefinition.View)

            /// The view of a record embed alongside an embed of some compatible media.
            case embedRecordWithMediaView(AppBskyLexicon.Embed.RecordWithMediaDefinition.View)

            /// An unknown case.
            case unknown(String, [String: CodableValue])

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try container.decode(String.self, forKey: .type)

                switch type {
                    case "app.bsky.embed.images#view":
                        self = .embedImagesView(try AppBskyLexicon.Embed.ImagesDefinition.View(from: decoder))
                    case "app.bsky.embed.video#view":
                        self = .embedVideoView(try AppBskyLexicon.Embed.VideoDefinition.View(from: decoder))
                    case "app.bsky.embed.external#view":
                        self = .embedExternalView(try AppBskyLexicon.Embed.ExternalDefinition.View(from: decoder))
                    case "app.bsky.embed.record#view":
                        self = .embedRecordView(try AppBskyLexicon.Embed.RecordDefinition.View(from: decoder))
                    case "app.bsky.embed.recordWithMedia#view":
                        self = .embedRecordWithMediaView(try AppBskyLexicon.Embed.RecordWithMediaDefinition.View(from: decoder))
                    default:
                        let singleValueDecodingContainer = try decoder.singleValueContainer()
                        let dictionary = try Self.decodeDictionary(from: singleValueDecodingContainer, decoder: decoder)

                        self = .unknown(type, dictionary)
                }
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()

                switch self {
                    case .embedImagesView(let value):
                        try container.encode(value)
                    case .embedVideoView(let value):
                        try container.encode(value)
                    case .embedExternalView(let value):
                        try container.encode(value)
                    case .embedRecordView(let value):
                        try container.encode(value)
                    case .embedRecordWithMediaView(let value):
                        try container.encode(value)
                    default:
                        break
                }
            }

            enum CodingKeys: String, CodingKey {
                case type = "$type"
            }
        }
    }

    /// A definition model for a viewer state.
    ///
    /// - Note: According to the AT Protocol specifications: "Metadata about the requesting
    /// account's relationship with the subject content. Only has meaningful content for
    /// authed requests."
    ///
    /// - SeeAlso: This is based on the [`app.bsky.feed.defs`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/defs.json
    public struct ViewerStateDefinition: Sendable, Codable, Equatable, Hashable {

        /// The URI of the requesting account's repost of the subject account's post. Optional.
        public let repostURI: String?

        /// The URI of the requesting account's like of the subject account's post. Optional.
        public let likeURI: String?

        /// Indicates whether the thread has been muted.
        public let isThreadMuted: Bool

        /// Indicates whether the requesting account can reply to the account's post. Optional.
        public let areRepliesDisabled: Bool?

        /// Indicates whether the post can be embedded. Optional.
        public let isEmbeddingDisabled: Bool?

        /// Indicates whether the post record is pinned. Optional.
        public let isPinned: Bool?

        enum CodingKeys: String, CodingKey {
            case repostURI = "repost"
            case likeURI = "like"
            case isThreadMuted = "threadMuted"
            case areRepliesDisabled = "replyDisabled"
            case isEmbeddingDisabled = "embeddingDisabled"
            case isPinned = "pinned"
        }
    }

    /// A definition model for metadata about this post in the thread context.
    ///
    /// - Note: According to the AT Protocol specifications: "Metadata about this post within the context of the thread it is in."
    ///
    /// - SeeAlso: This is based on the [`app.bsky.feed.defs`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/defs.json
    public struct ThreadContextDefinition: Sendable, Codable, Equatable, Hashable {

        /// The URI of the root author's like record.
        public let rootAuthorLike: String?
    }

    /// A definition model for a feed's view.
    ///
    /// - SeeAlso: This is based on the [`app.bsky.feed.defs`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/defs.json
    public struct FeedViewPostDefinition: Sendable, Codable, Equatable, Hashable {

        /// The post contained in a feed.
        public let post: PostViewDefinition

        /// The reply reference for the post, if it's a reply. Optional.
        public let reply: ReplyReferenceDefinition?

        /// Determines whether the repost is a normal repost or pinned. Optional.
        public let reason: ReasonUnion?

        /// The feed generator's context. Optional
        ///
        /// - Important: Current maximum length is 2,000 characters (these are raw characters).
        ///
        /// - Note: According to the AT Protocol specifications: "Context provided by
        /// feed generator that may be passed back alongside interactions."
        public let feedContext: String?

        /// An interaction identifier that may be given upon an interaction.
        ///
        /// - Note: According to the AT Protocol specifications: "Unique identifier per request that may be
        /// passed back alongside interactions."
        public let requestID: String?

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(self.post, forKey: .post)
            try container.encodeIfPresent(self.reply, forKey: .reply)
            try container.encodeIfPresent(self.reason, forKey: .reason)
            try container.truncatedEncodeIfPresent(self.feedContext, forKey: .feedContext, upToCharacterLength: 300)
            try container.truncatedEncodeIfPresent(self.requestID, forKey: .requestID, upToCharacterLength: 100)
        }

        public enum CodingKeys: String, CodingKey {
            case post
            case reply
            case reason
            case feedContext
            case requestID = "reqId"
        }

        // Unions
        /// Determines whether the repost is a normal repost or pinned.
        public enum ReasonUnion: ATUnionProtocol, Equatable, Hashable {

            /// A very stripped down version of a repost.
            case reasonRepost(AppBskyLexicon.Feed.ReasonRepostDefinition)

            /// A marker for pinned posts.
            case reasonPin(AppBskyLexicon.Feed.ReasonPinDefinition)

            /// An unknown case.
            case unknown(String, [String: CodableValue])

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try container.decode(String.self, forKey: .type)

                switch type {
                    case "app.bsky.feed.defs#reasonRepost":
                        self = .reasonRepost(try AppBskyLexicon.Feed.ReasonRepostDefinition(from: decoder))
                    case "app.bsky.feed.defs#reasonPin":
                        self = .reasonPin(try AppBskyLexicon.Feed.ReasonPinDefinition(from: decoder))
                    default:
                        let singleValueDecodingContainer = try decoder.singleValueContainer()
                        let dictionary = try Self.decodeDictionary(from: singleValueDecodingContainer, decoder: decoder)

                        self = .unknown(type, dictionary)
                }
            }

            public func encode(to encoder: any Encoder) throws {
                var container = encoder.singleValueContainer()

                switch self {
                    case .reasonRepost(let value):
                        try container.encode(value)
                    case .reasonPin(let value):
                        try container.encode(value)
                    default:
                        break
                }
            }

            enum CodingKeys: String, CodingKey {
                case type = "$type"
            }
        }
    }

    /// A definition model for a reply reference.
    ///
    /// - SeeAlso: This is based on the [`app.bsky.feed.defs`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/defs.json
    public struct ReplyReferenceDefinition: Sendable, Codable, Equatable, Hashable {

        /// The original post of the thread.
        public let root: RootUnion

        /// The direct post that the user's post is replying to.
        ///
        /// If `parent` and `root` are identical, the post is a direct reply to the
        /// original post of the thread.
        public let parent: ParentUnion

        /// The author of the parent's post. Optional.
        ///
        /// - Note: According to the AT Protocol specifications: "When parent is a reply to another
        /// post, this is the author of that post."
        public let grandparentAuthor: AppBskyLexicon.Actor.ProfileViewBasicDefinition?

        // Unions
        /// The original post of the thread.
        public enum RootUnion: ATUnionProtocol, Equatable, Hashable {

            /// The view of a post.
            case postView(AppBskyLexicon.Feed.PostViewDefinition)

            /// The view of a post that may not have been found.
            case notFoundPost(AppBskyLexicon.Feed.NotFoundPostDefinition)

            /// The view of a post that's been blocked by the post author.
            case blockedPost(AppBskyLexicon.Feed.BlockedPostDefinition)

            /// An unknown case.
            case unknown(String, [String: CodableValue])

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try container.decode(String.self, forKey: .type)

                switch type {
                    case "app.bsky.feed.defs#postView":
                        self = .postView(try AppBskyLexicon.Feed.PostViewDefinition(from: decoder))
                    case "app.bsky.feed.defs#notFoundPost":
                        self = .notFoundPost(try AppBskyLexicon.Feed.NotFoundPostDefinition(from: decoder))
                    case "app.bsky.feed.defs#blockedPost":
                        self = .blockedPost(try AppBskyLexicon.Feed.BlockedPostDefinition(from: decoder))
                    default:
                        let singleValueDecodingContainer = try decoder.singleValueContainer()
                        let dictionary = try Self.decodeDictionary(from: singleValueDecodingContainer, decoder: decoder)

                        self = .unknown(type, dictionary)
                }
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()

                switch self {
                    case .postView(let value):
                        try container.encode(value)
                    case .notFoundPost(let value):
                        try container.encode(value)
                    case .blockedPost(let value):
                        try container.encode(value)
                    default:
                        break
                }
            }

            enum CodingKeys: String, CodingKey {
                case type = "$type"
            }
        }

        /// The direct post that the user's post is replying to.
        public enum ParentUnion: ATUnionProtocol, Equatable, Hashable {

            /// The view of a post.
            case postView(AppBskyLexicon.Feed.PostViewDefinition)

            /// The view of a post that may not have been found.
            case notFoundPost(AppBskyLexicon.Feed.NotFoundPostDefinition)

            /// The view of a post that's been blocked by the post author.
            case blockedPost(AppBskyLexicon.Feed.BlockedPostDefinition)

            /// An unknown case.
            case unknown(String, [String: CodableValue])

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try container.decode(String.self, forKey: .type)

                switch type {
                    case "app.bsky.feed.defs#postView":
                        self = .postView(try AppBskyLexicon.Feed.PostViewDefinition(from: decoder))
                    case "app.bsky.feed.defs#notFoundPost":
                        self = .notFoundPost(try AppBskyLexicon.Feed.NotFoundPostDefinition(from: decoder))
                    case "app.bsky.feed.defs#blockedPost":
                        self = .blockedPost(try AppBskyLexicon.Feed.BlockedPostDefinition(from: decoder))
                    default:
                        let singleValueDecodingContainer = try decoder.singleValueContainer()
                        let dictionary = try Self.decodeDictionary(from: singleValueDecodingContainer, decoder: decoder)

                        self = .unknown(type, dictionary)
                }
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()

                switch self {
                    case .postView(let value):
                        try container.encode(value)
                    case .notFoundPost(let value):
                        try container.encode(value)
                    case .blockedPost(let value):
                        try container.encode(value)
                    default:
                        break
                }
            }

            enum CodingKeys: String, CodingKey {
                case type = "$type"
            }
        }
    }

    /// A definition model for a very stripped down version of a repost.
    ///
    /// - SeeAlso: This is based on the [`app.bsky.feed.defs`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/defs.json
    public struct ReasonRepostDefinition: Sendable, Codable, Equatable, Hashable {

        /// The basic details of the user who reposted the post.
        public let by: AppBskyLexicon.Actor.ProfileViewBasicDefinition

        /// The URI of the repost. Optional.
        public let uri: String?

        /// The CID of the repost. Optional.
        public let cid: String?

        /// The date and time the repost was last indexed.
        public let indexedAt: Date

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.by = try container.decode(AppBskyLexicon.Actor.ProfileViewBasicDefinition.self, forKey: .by)
            self.uri = try container.decodeIfPresent(String.self, forKey: .uri)
            self.cid = try container.decodeIfPresent(String.self, forKey: .cid)
            self.indexedAt = try container.decodeDate(forKey: .indexedAt)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(self.by, forKey: .by)
            try container.encodeIfPresent(self.uri, forKey: .uri)
            try container.encodeIfPresent(self.cid, forKey: .cid)
            try container.encodeDate(self.indexedAt, forKey: .indexedAt)
        }

        enum CodingKeys: CodingKey {
            case by
            case uri
            case cid
            case indexedAt
        }
    }

    /// A definition model for a marker for pinned posts.
    ///
    /// - SeeAlso: This is based on the [`app.bsky.feed.defs`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/defs.json
    public struct ReasonPinDefinition: Sendable, Codable, Equatable, Hashable {}

    /// A definition model for a hydrated version of a repost.
    ///
    /// - SeeAlso: This is based on the [`app.bsky.feed.defs`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/defs.json
    public struct ThreadViewPostDefinition: Sendable, Codable, Equatable, Hashable {

        /// The post contained in a thread.
        public let post: PostViewDefinition

        /// The direct post that the user's post is replying to. Optional.
        public let parent: ParentUnion?

        /// An array of posts of various types. Optional.
        public let replies: [RepliesUnion]?

        /// The context of the thread view. Optional.
        public let threadContext: ThreadContextDefinition?

        // Unions
        /// The direct post that the user's post is replying to.
        public indirect enum ParentUnion: ATUnionProtocol, Equatable, Hashable {

            /// The view of a post.
            case threadViewPost(AppBskyLexicon.Feed.ThreadViewPostDefinition)

            /// The view of a post that may not have been found.
            case notFoundPost(AppBskyLexicon.Feed.NotFoundPostDefinition)

            /// The view of a post that's been blocked by the post author.
            case blockedPost(AppBskyLexicon.Feed.BlockedPostDefinition)

            /// An unknown case.
            case unknown(String, [String: CodableValue])

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try container.decode(String.self, forKey: .type)

                switch type {
                    case "app.bsky.feed.defs#threadViewPost":
                        self = .threadViewPost(try AppBskyLexicon.Feed.ThreadViewPostDefinition(from: decoder))
                    case "app.bsky.feed.defs#notFoundPost":
                        self = .notFoundPost(try AppBskyLexicon.Feed.NotFoundPostDefinition(from: decoder))
                    case "app.bsky.feed.defs#blockedPost":
                        self = .blockedPost(try AppBskyLexicon.Feed.BlockedPostDefinition(from: decoder))
                    default:
                        let singleValueDecodingContainer = try decoder.singleValueContainer()
                        let dictionary = try Self.decodeDictionary(from: singleValueDecodingContainer, decoder: decoder)

                        self = .unknown(type, dictionary)
                }
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()

                switch self {
                    case .threadViewPost(let value):
                        try container.encode(value)
                    case .notFoundPost(let value):
                        try container.encode(value)
                    case .blockedPost(let value):
                        try container.encode(value)
                    default:
                        break
                }
            }

            enum CodingKeys: String, CodingKey {
                case type = "$type"
            }
        }

        /// An array of posts of various types. Optional.
        public indirect enum RepliesUnion: ATUnionProtocol, Equatable, Hashable {

            /// The view of a post.
            case threadViewPost(AppBskyLexicon.Feed.ThreadViewPostDefinition)

            /// The view of a post that may not have been found.
            case notFoundPost(AppBskyLexicon.Feed.NotFoundPostDefinition)

            /// The view of a post that's been blocked by the post author.
            case blockedPost(AppBskyLexicon.Feed.BlockedPostDefinition)

            /// An unknown case.
            case unknown(String, [String: CodableValue])

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try container.decode(String.self, forKey: .type)

                switch type {
                    case "app.bsky.feed.defs#threadViewPost":
                        self = .threadViewPost(try AppBskyLexicon.Feed.ThreadViewPostDefinition(from: decoder))
                    case "app.bsky.feed.defs#notFoundPost":
                        self = .notFoundPost(try AppBskyLexicon.Feed.NotFoundPostDefinition(from: decoder))
                    case "app.bsky.feed.defs#blockedPost":
                        self = .blockedPost(try AppBskyLexicon.Feed.BlockedPostDefinition(from: decoder))
                    default:
                        let singleValueDecodingContainer = try decoder.singleValueContainer()
                        let dictionary = try Self.decodeDictionary(from: singleValueDecodingContainer, decoder: decoder)

                        self = .unknown(type, dictionary)
                }
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()

                switch self {
                    case .threadViewPost(let value):
                        try container.encode(value)
                    case .notFoundPost(let value):
                        try container.encode(value)
                    case .blockedPost(let value):
                        try container.encode(value)
                    default:
                        break
                }
            }

            enum CodingKeys: String, CodingKey {
                case type = "$type"
            }
        }
    }

    /// A definition model for a post that may not have been found.
    ///
    /// - SeeAlso: This is based on the [`app.bsky.feed.defs`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/defs.json
    public struct NotFoundPostDefinition: Sendable, Codable, Equatable, Hashable {

        /// The URI of the post.
        public let feedURI: String

        /// Indicates whether the post wasn't found. Defaults to `true`.
        public let isNotFound: Bool = true

        enum CodingKeys: String, CodingKey {
            case feedURI = "uri"
            case isNotFound = "notFound"
        }
    }

    /// A definition model for a post that may have been blocked.
    ///
    /// - SeeAlso: This is based on the [`app.bsky.feed.defs`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/defs.json
    public struct BlockedPostDefinition: Sendable, Codable, Equatable, Hashable {

        /// The URI of the post.
        public let feedURI: String

        /// Indicates whether this post has been blocked from the user. Defaults to `true`.
        public let isBlocked: Bool

        /// The author of the post.
        public let author: BlockedAuthorDefinition

        public init(feedURI: String, isBlocked: Bool, author: BlockedAuthorDefinition) {
            self.feedURI = feedURI
            self.isBlocked = isBlocked
            self.author = author
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.feedURI = try container.decode(String.self, forKey: .feedURI)
            self.isBlocked = (try? container.decode(Bool.self, forKey: .isBlocked)) ?? true
            self.author = try container.decode(BlockedAuthorDefinition.self, forKey: .author)
        }

        enum CodingKeys: String, CodingKey {
            case feedURI = "uri"
            case isBlocked = "blocked"
            case author
        }
    }

    /// A definition model for a blocked author.
    ///
    /// - SeeAlso: This is based on the [`app.bsky.feed.defs`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/defs.json
    public struct BlockedAuthorDefinition: Sendable, Codable, Equatable, Hashable {

        /// The decentralized identifier (DID)  of the author.
        public let did: String

        /// The viewer state of the user. Optional.
        public let viewer: AppBskyLexicon.Actor.ViewerStateDefinition?

        enum CodingKeys: CodingKey {
            case did
            case viewer
        }
    }

    /// A definition model for a feed geneator.
    ///
    /// - SeeAlso: This is based on the [`app.bsky.feed.defs`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/defs.json
    public struct GeneratorViewDefinition: Sendable, Codable, Equatable, Hashable {

        /// The URI of the feed generator.
        public let feedURI: String

        /// The CID hash of the feed generator.
        public let cid: String

        /// The decentralized identifier (DID) of the feed generator.
        public let feedDID: String

        /// The author of the feed generator.
        public let creator: AppBskyLexicon.Actor.ProfileViewDefinition

        /// The display name of the feed generator.
        public let displayName: String

        /// The description of the feed generator. Optional.
        ///
        /// - Important: Current maximum length is 300 characters.
        public let description: String?

        /// An array of the facets within the feed generator's description.
        public let descriptionFacets: [AppBskyLexicon.RichText.Facet]?

        /// The avatar image URL of the feed generator.
        public let avatarImageURL: URL?

        /// The number of likes for the feed generator.
        public let likeCount: Int?

        /// Indicates whether the feed generator can accept interactions.
        ///
        /// - Note: According to the AT Protocol specifications: "Context that will be passed
        /// through to client and may be passed to feed generator back alongside interactions."
        public let canAcceptInteractions: Bool?

        /// An array of labels. Optional.
        public let labels: [ComAtprotoLexicon.Label.LabelDefinition]?

        /// The viewer's state for the feed generator. Optional.
        public let viewer: GeneratorViewerStateDefinition?

        /// The content mode of the feed generator. Optional.
        public let contentMode: ContentMode?

        /// The last time the feed generator was indexed.
        public let indexedAt: Date

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.feedURI = try container.decode(String.self, forKey: .feedURI)
            self.cid = try container.decode(String.self, forKey: .cid)
            self.feedDID = try container.decode(String.self, forKey: .feedDID)
            self.creator = try container.decode(AppBskyLexicon.Actor.ProfileViewDefinition.self, forKey: .creator)
            self.displayName = try container.decode(String.self, forKey: .displayName)
            self.description = try container.decodeIfPresent(String.self, forKey: .description)
            self.descriptionFacets = try container.decodeIfPresent([AppBskyLexicon.RichText.Facet].self, forKey: .descriptionFacets)
            self.avatarImageURL = try container.decodeIfPresent(URL.self, forKey: .avatarImageURL)
            self.likeCount = try container.decodeIfPresent(Int.self, forKey: .likeCount)
            self.canAcceptInteractions = try container.decodeIfPresent(Bool.self, forKey: .canAcceptInteractions)
            self.labels = try container.decodeIfPresent([ComAtprotoLexicon.Label.LabelDefinition].self, forKey: .labels)
            self.viewer = try container.decodeIfPresent(AppBskyLexicon.Feed.GeneratorViewerStateDefinition.self, forKey: .viewer)
            self.contentMode = try container.decodeIfPresent(ContentMode.self, forKey: .contentMode)
            self.indexedAt = try container.decodeDate(forKey: .indexedAt)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(self.feedURI, forKey: .feedURI)
            try container.encode(self.cid, forKey: .cid)
            try container.encode(self.feedDID, forKey: .feedDID)
            try container.encode(self.creator, forKey: .creator)
            try container.encode(self.displayName, forKey: .displayName)
            try container.truncatedEncodeIfPresent(self.description, forKey: .description, upToCharacterLength: 300)
            try container.encodeIfPresent(self.descriptionFacets, forKey: .descriptionFacets)
            try container.encodeIfPresent(self.avatarImageURL, forKey: .avatarImageURL)

            // Assuming `likeCount` is not nil, only encode it if it's 0 or higher
            if let likeCount = self.likeCount, likeCount >= 0 {
                try container.encode(likeCount, forKey: .likeCount)
            }
            try container.encodeIfPresent(self.canAcceptInteractions, forKey: .canAcceptInteractions)
            try container.encodeIfPresent(self.labels, forKey: .labels)
            try container.encodeIfPresent(self.viewer, forKey: .viewer)
            try container.encodeIfPresent(self.contentMode, forKey: .contentMode)
            try container.encodeDateIfPresent(self.indexedAt, forKey: .indexedAt)
        }

        enum CodingKeys: String, CodingKey {
            case feedURI = "uri"
            case cid
            case feedDID = "did"
            case creator
            case displayName
            case description
            case descriptionFacets = "descriptionFacets"
            case avatarImageURL = "avatar"
            case likeCount
            case canAcceptInteractions = "acceptsInteractions"
            case labels
            case viewer
            case contentMode
            case indexedAt
        }

        /// The content mode for the feed generator.
        public enum ContentMode: String, Sendable, Codable, Equatable, Hashable {

            /// Declares the feed generator supports any post type.
            case unspecified = "app.bsky.feed.defs#contentModeUnspecified"

            /// Declares the feed generator returns posts with embeds from `app.bsky.embed.video`.
            case video = "app.bsky.feed.defs#contentModeVideo"
        }
    }

    /// A definition model for the viewer's state of the feed generator.
    ///
    /// - SeeAlso: This is based on the [`app.bsky.feed.defs`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/defs.json
    public struct GeneratorViewerStateDefinition: Sendable, Codable, Equatable, Hashable {

        /// The URI of the viewer's like, if they liked the feed generator. Optional.
        public let likeURI: String?

        enum CodingKeys: String, CodingKey {
            case likeURI = "like"
        }
    }

    /// A definition model for a feed's skeleton.
    ///
    /// - SeeAlso: This is based on the [`app.bsky.feed.defs`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/defs.json
    public struct SkeletonFeedPostDefinition: Sendable, Codable {

        /// The URI of the post in the feed generator.
        ///
        /// - Note: This refers to the original post's URI. If the post is a repost, then `reason`
        /// will contain a value.
        public let postURI: String

        /// The indication that the post was a repost. Optional.
        public let reason: SkeletonReasonRepostUnion?

        /// The feed generator's context. Optional
        ///
        /// - Important: Current maximum length is 2,000 characters (these are raw characters).
        ///
        /// - Note: According to the AT Protocol specifications: "Context provided by
        /// feed generator that may be passed back alongside interactions."
        public let feedContext: String?

        enum CodingKeys: String, CodingKey {
            case postURI = "post"
            case reason
            case feedContext
        }

        // Unions
        /// The indication that the post was a repost.
        public enum SkeletonReasonRepostUnion: ATUnionProtocol {

            /// A very stripped down version of a repost.
            case skeletonReasonRepost(AppBskyLexicon.Feed.SkeletonReasonRepostDefinition)

            /// A pin in a feed generator.
            case skeletonReasonPin(AppBskyLexicon.Feed.SkeletonReasonPinDefinition)

            /// An unknown case.
            case unknown(String, [String: CodableValue])

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try container.decode(String.self, forKey: .type)

                switch type {
                    case "app.bsky.feed.defs#skeletonReasonRepost":
                        self = .skeletonReasonRepost(try AppBskyLexicon.Feed.SkeletonReasonRepostDefinition(from: decoder))
                    case "app.bsky.feed#.defs#skeletonReasonPin":
                        self = .skeletonReasonPin(try AppBskyLexicon.Feed.SkeletonReasonPinDefinition(from: decoder))
                    default:
                        let singleValueDecodingContainer = try decoder.singleValueContainer()
                        let dictionary = try Self.decodeDictionary(from: singleValueDecodingContainer, decoder: decoder)

                        self = .unknown(type, dictionary)
                }
            }

            public func encode(to encoder: any Encoder) throws {
                var container = encoder.singleValueContainer()

                switch self {
                    case .skeletonReasonRepost(let value):
                        try container.encode(value)
                    case .skeletonReasonPin(let value):
                        try container.encode(value)
                    default:
                        break
                }
            }

            enum CodingKeys: String, CodingKey {
                case type = "$type"
            }
        }
    }

    /// A definition model for a repost in a feed generator.
    ///
    /// - SeeAlso: This is based on the [`app.bsky.feed.defs`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/defs.json
    public struct SkeletonReasonRepostDefinition: Sendable, Codable {

        /// The URI of the repost.
        ///
        /// This property uniquely identifies the repost itself, separate from the original post's URI.
        public let uri: String

        enum CodingKeys: String, CodingKey {
            case uri = "repost"
        }
    }

    /// A definition model for a pin in a feed generator.
    ///
    /// - SeeAlso: This is based on the [`app.bsky.feed.defs`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/defs.json
    public struct SkeletonReasonPinDefinition: Sendable, Codable {}

    /// A definition model for a feed threadgate view.
    ///
    /// - SeeAlso: This is based on the [`app.bsky.feed.defs`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/defs.json
    public struct ThreadgateViewDefinition: Sendable, Codable, Equatable, Hashable {

        /// The URI of the feed's threadgate.
        public let threadgateURI: String

        /// The CID hash of the feed's threadgate.
        public let cid: String

        /// The record of the feed's threadgate
        public let record: UnknownType

        // TODO: Make sure this is correct.
        /// An array of user lists.
        public let lists: [AppBskyLexicon.Graph.ListViewBasicDefinition]

        enum CodingKeys: String, CodingKey {
            case threadgateURI = "uri"
            case cid
            case record = "record"
            case lists = "lists"
        }
    }

    /// A definition model for an interaction for an item in a feed generator.
    ///
    /// - SeeAlso: This is based on the [`app.bsky.feed.defs`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/defs.json
    public struct InteractionDefinition: Sendable, Codable {

        /// The URI of the item itself. Optional.
        public let itemURI: String?

        /// The interaction event of the feed generator. Optional.
        public let event: Event?

        /// An interaction identifier that may be given upon an interaction.
        ///
        /// - Note: According to the AT Protocol specifications: "Unique identifier per request that may be
        /// passed back alongside interactions."
        public let requestID: String?

        /// The feed generator's context. Optional.
        ///
        /// - Important: Current maximum length is 2,000 characters (these are raw characters).
        ///
        /// - Note: According to the AT Protocol specifications: "Context on a feed item that was
        /// originally supplied by the feed generator on getFeedSkeleton."
        public let feedContext: String?

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(self.itemURI, forKey: .itemURI)
            try container.encode(self.event, forKey: .event)
            try container.truncatedEncodeIfPresent(self.feedContext, forKey: .feedContext, upToCharacterLength: 300)
            try container.truncatedEncodeIfPresent(self.requestID, forKey: .requestID, upToCharacterLength: 100)
        }

        enum CodingKeys: String, CodingKey {
            case itemURI = "uri"
            case event
            case feedContext
            case requestID = "reqId"
        }

        // Enums
        /// A definition model for an interaction event.
        ///
        /// - SeeAlso: This is based on the [`app.bsky.feed.defs`][github] lexicon.
        ///
        /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/defs.json
        public enum Event: Sendable, Codable {

            /// Indicates the feed generator should request less content similar to the feed's item.
            ///
            /// - Note: According to the AT Protocol specifications: "Request that less content like the
            /// given feed item be shown in the feed."
            case requestLess

            /// Indicates the feed generator should request more content similar to the feed's item.
            ///
            /// - Note: According to the AT Protocol specifications: "Request that more content like the
            /// given feed item be shown in the feed."
            case requestMore

            /// Indicates the feed generator clicked on the feed's item.
            ///
            /// - Note: According to the AT Protocol specifications: "User clicked through to the
            /// feed item."
            case clickthroughItem

            /// Indicates the user clicked on the author of the feed's item.
            ///
            /// - Note: According to the AT Protocol specifications: "User clicked through to the author
            /// of the feed item."
            case clickthroughAuthor

            /// Indicates the user clicked on the reposter of the feed's item.
            ///
            /// - Note: According to the AT Protocol specifications: "User clicked through to the reposter
            /// of the feed item."
            case clickthroughReposter

            /// Indicates the user clicked on the embedded content of the feed's item.
            ///
            /// - Note: According to the AT Protocol specifications: "User clicked through to the embedded
            /// content of the feed item."
            case clickthroughEmbed

            /// Declares the feed generator supports any post type.
            ///
            /// - Note: According to the AT Protocol specifications: "Declares the feed generator
            /// returns any types of posts."
            case contentModeUnspecified

            /// Declares the feed generator returns posts with embeds from `app.bsky.embed.video`.
            ///
            /// - Note: According to the AT Protocol specifications: "Declares the feed generator
            /// returns posts containing app.bsky.embed.video embeds."
            case contentModeVideo

            /// Indicates the user has viewed the item in the feed.
            ///
            /// - Note: According to the AT Protocol specifications: "Feed item was seen by user."
            case interactionSeen

            /// Indicates the user has liked the item of the feed.
            ///
            /// - Note: According to the AT Protocol specifications: "User liked the feed item."
            case interactionLike

            /// Indicates the user has reposted the item of the feed.
            ///
            /// - Note: According to the AT Protocol specifications: "User reposted the feed item."
            case interactionRepost

            /// Indicates the user has replied to the item of the feed.
            ///
            /// - Note: According to the AT Protocol specifications: "User replied to the feed item."
            case interactionReply

            /// Indicates the user has quote posted the feed's item.
            ///
            /// - Note: According to the AT Protocol specifications: "User quoted the feed item."
            case interactionQuote

            /// Indicates the user has shared the feed's item.
            ///
            /// - Note: According to the AT Protocol specifications: "User shared the feed item."
            case interactionShare
        }
    }
}
