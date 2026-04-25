//
//  WordViewModel.swift
//  CallDixio
//
//  Created by Alvar Arias on 2023-03-19.
//

import Foundation
import Observation

@Observable
@MainActor
final class WordViewModel {

    var results: [Result] = []
    var error: LexinError? = nil

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPosts(word: String, dir: String) async {
        error = nil

        guard let url = URL(string: "http://lexin.nada.kth.se/lexin/service?searchinfo=\(dir),swe_spa,\(word)&output=JSON") else {
            error = .invalidURL
            return
        }

        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                error = .invalidResponse
                return
            }
            let decoded = try JSONDecoder().decode(Words.self, from: data)
            results = decoded.result
            if results.isEmpty { error = .noMatch }
        } catch is DecodingError {
            error = .noMatch
        } catch {
            self.error = .networkError(error.localizedDescription)
        }
    }
}
