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
    var errorMessage: String = ""

    func fetchPosts(word: String, dir: String) async {
        guard let url = URL(string: "http://lexin.nada.kth.se/lexin/service?searchinfo=\(dir),swe_spa,\(word)&output=JSON") else {
            errorMessage = "Invalid URL"
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "Invalid response"
                return
            }
            let decoded = try JSONDecoder().decode(Words.self, from: data)
            results = decoded.result
            errorMessage = "OK"
        } catch {
            errorMessage = "No word match"
        }
    }
}
