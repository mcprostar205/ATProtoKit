//
//  ChatBskyConvoListConvosMethod.swift
//
//
//  Created by Christopher Jr Riley on 2024-05-31.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension ATProtoBlueskyChat {

    /// Lists various conversations the user account is participating in.
    /// 
    /// - SeeAlso: This is based on the [`chat.bsky.convo.listConvos`][github] lexicon.
    /// 
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/chat/bsky/convo/listConvos.json
    /// 
    /// - Parameters:
    ///   - limit: The number of items that can be in the list. Optional. Defaults to `50`.
    ///   - cursor: The mark used to indicate the starting point for the next set
    ///   of results. Optional.
    ///   - readState: The read state of conversation. Optional.
    ///   - status: The status of the conversation. Optional.
    /// - Returns: An array of conversations the user account is currently in, with an optional
    /// cursor for expanding the array.
    ///
    /// - Throws: An ``ATProtoError``-conforming error type, depending on the issue. Go to
    /// ``ATAPIError`` and ``ATRequestPrepareError`` for more details.
    public func listConversations(
        limit: Int? = 50,
        cursor: String? = nil,
        readState: ChatBskyLexicon.Conversation.ListConversations.ReadState? = nil,
        status: ChatBskyLexicon.Conversation.ListConversations.Status? = nil
    ) async throws -> ChatBskyLexicon.Conversation.ListConversationsOutput {
        guard let _ = try await self.getUserSession(),
              let keychain = sessionConfiguration?.keychainProtocol else {
            throw ATRequestPrepareError.missingActiveSession
        }

        let accessToken = try await keychain.retrieveAccessToken()
//        let sessionURL = session.serviceEndpoint.absoluteString

        guard let requestURL = URL(string: "\(APIHostname.bskyChat)/xrpc/chat.bsky.convo.listConvos") else {
            throw ATRequestPrepareError.invalidRequestURL
        }

        var queryItems = [(String, String)]()

        if let limit {
            let finalLimit = max(1, min(limit, 100))
            queryItems.append(("limit", "\(finalLimit)"))
        }

        if let cursor {
            queryItems.append(("cursor", cursor))
        }

        let queryURL: URL

        do {
            queryURL = try apiClientService.setQueryItems(
                for: requestURL,
                with: queryItems
            )

            let request = apiClientService.createRequest(
                forRequest: queryURL,
                andMethod: .get,
                acceptValue: "application/json",
                contentTypeValue: nil,
                authorizationValue: "Bearer \(accessToken)",
                isRelatedToBskyChat: true
            )
            let response = try await apiClientService.sendRequest(request,
                decodeTo: ChatBskyLexicon.Conversation.ListConversationsOutput.self)

            return response
        } catch {
            throw error
        }
    }
}
