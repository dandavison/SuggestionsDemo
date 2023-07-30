//
//  ProjectsModel.swift
//  SuggestionsDemo
//
//  Created by Dan Davison on 7/30/23.
//

import Foundation
import Combine

final class ProjectsModel: ObservableObject {
    var englishWords: [String]
    var englishTranslations: [String:String]

    @Published var currentText: String = ""
    @Published var suggestionGroups: [SuggestionGroup<String>] = []
    @Published var currentTranslation: String?

    private var cancellables: Set<AnyCancellable> = []

    init() {
        let bundle = Bundle.main
        do {
            let url = bundle.url(forResource: "english_german", withExtension: "json")!
            let data = try! Data(contentsOf: url)
            self.englishTranslations = try! JSONDecoder().decode([String:String].self, from: data)
            self.englishWords = Array(self.englishTranslations.keys)
        }

        self.$currentText
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { text -> [SuggestionGroup<String>] in
                guard !text.isEmpty else {
                    return []
                }
                let englishSuggestions = self.englishWords.lazy.filter({ $0.hasPrefix(text) }).prefix(10).map { word -> Suggestion<String> in
                    Suggestion(text: word, value: word)
                }
                var suggestionGroups: [SuggestionGroup<String>] = []
                if !englishSuggestions.isEmpty {
                    suggestionGroups.append(SuggestionGroup<String>(title: "English", suggestions: Array(englishSuggestions)))
                }
                return suggestionGroups
            }
            .assign(to: \ProjectsModel.suggestionGroups, on: self)
            .store(in: &cancellables)

        self.$currentText
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { text -> String? in
                if let englishTranslation = self.englishTranslations[text] {
                    return englishTranslation
                }
                return nil
            }
            .assign(to: \ProjectsModel.currentTranslation, on: self)
            .store(in: &cancellables)
    }
}
