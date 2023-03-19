//
//  File.swift
//  CallDixio
//
//  Created by Alvar Arias on 2023-03-19.
//

import Foundation
import Combine

@available(macOS 10.15, *)
class WordViewModel: ObservableObject {
    
    // Errores con Combine
    private var cancellables = Set<AnyCancellable>()
    private let errorSubject = PassthroughSubject<String, Never>()
    
    var errorPublisher: AnyPublisher<String, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    @Published var results = [Result]()
    
    /// Fetches posts from a remote server.
    ///
    /// - Parameters:
    ///   - word: The word to search for.
    ///   - dir: The language direction to search in.
    ///
    /// - Note: The search direction should be specified as a comma-separated list of language codes in the format `source_lang-target_lang`.
    ///
    /// - Throws: An error if the URL is invalid or the server response is not valid JSON.
    ///
    /// - Returns: An array of `Result` objects representing the search results.
    func fetchPosts(word: String, dir: String) {
        
        guard let url = URL(string: "http://lexin.nada.kth.se/lexin/service?searchinfo=\(dir),swe_spa,\(word)&output=JSON") else {
            errorMje(mje: "Invalid URL")
            fatalError("Invalid URL")
            
        }
        // Send a data task to the API to fetch the data
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                // If there is an error during the data task, emit an error message
                print("Error fetching results: \(error.localizedDescription)")
                print(String(describing: error))
                errorMje(mje: "URL session error")
                
                return
            }
            // Check if the response is vali
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data else {
                // If the response is not valid, emit an error message
                print("Invalid response")
                errorMje(mje: "Invalid response")
                
                return
            }
            
            do {
                // Parse the fetched data using a JSONDecoder and update the results
                let myresults = try JSONDecoder().decode(Words.self, from: data)
                DispatchQueue.main.async {
                    self.results = myresults.result
                    print(myresults)
                    
                    errorMje(mje: "OK")
                    
                }
                
                
            } catch {
                // If there is an error during parsing, emit an error message
                print("Error decoding results: \(error.localizedDescription)")
                print(String(describing: error))
                
                errorMje(mje: "No word match")
                
                
            }
        }.resume()
        
        /**
         Emits an error message on the errorSubject.
         
         - Parameter mje: A `String` that represents the error message to be emitted.
         */
        func errorMje(mje: String) {
            
            DispatchQueue.main.async {
                self.errorSubject.send(mje)
            }
            
        }
        
    }
    
}
