//
//  File.swift
//  
//
//  Created by Alvar Arias on 2023-03-19.
//

import Foundation

// MARK: - Words
struct Words: Codable {
    
    let status, wordbase: String
    let result: [Result]

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case wordbase = "Wordbase"
        case result = "Result"
    }
}

// MARK: - Result
struct Result: Hashable, Identifiable, Codable {
    
    var id: String = UUID().uuidString
   
    let variantID: String?
    let value : String?
    let type: String?

    let baseLang: BaseLang?
    let targetLang: TargetLang?
  
    enum CodingKeys: String, CodingKey {
            case value = "Value"
            case type = "Type"
            case variantID = "VariantID"
            case baseLang = "BaseLang"
            case targetLang = "TargetLang"
        }
   
    
    

    
}

// MARK: - BaseLang
struct BaseLang: Hashable, Codable {
    let phonetic: Phonetic?
    let inflection: [Inflection]?
    let meaning: String?
    let illustration: [Illustration]?
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case phonetic = "Phonetic"
        case inflection = "Inflection"
        case meaning = "Meaning"
        case illustration = "Illustration"
        case comment = "Comment"
    }
}

// MARK: - Illustration
struct Illustration: Hashable, Codable {
    let type: String?
    let value: String?

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case value = "Value"
    }
}

// MARK: - Inflection
struct Inflection: Hashable, Codable {
    let content: String?

    enum CodingKeys: String, CodingKey {
        case content = "Content"
    }
}

// MARK: - Phonetic
struct Phonetic: Hashable, Codable {
    let file: String?
    let content: String?

    enum CodingKeys: String, CodingKey {
        case file = "File"
        case content = "Content"
    }
}

// MARK: - TargetLang
struct TargetLang: Hashable, Codable {
    let translation: String?
    let synonym: [String]?
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case translation = "Translation"
        case synonym = "Synonym"
        case comment = "Comment"
    }
}

