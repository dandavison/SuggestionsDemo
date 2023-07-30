//
//  ProjectsModel.swift
//  SuggestionsDemo
//
//  Created by Dan Davison on 7/30/23.
//

import Foundation
import Combine

final class ProjectsModel: ObservableObject {
    var projects: [String]

    @Published var currentText: String = ""
    @Published var projectGroups: [ProjectGroup<String>] = []
    @Published var currentProject: String?

    private var cancellables: Set<AnyCancellable> = []

    init() {
        let bundle = Bundle.main
        do {
            let url = bundle.url(forResource: "english_german", withExtension: "json")!
            let data = try! Data(contentsOf: url)
            let translations = try! JSONDecoder().decode([String:String].self, from: data)
            self.projects = Array(translations.keys)
        }

        self.$currentText
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { text -> [ProjectGroup<String>] in
                guard !text.isEmpty else {
                    return []
                }
                let projects = self.projects.lazy.filter({ $0.hasPrefix(text) }).prefix(10).map { word -> Project<String> in
                    Project(text: word, value: word)
                }
                var suggestionGroups: [ProjectGroup<String>] = []
                if !projects.isEmpty {
                    suggestionGroups.append(ProjectGroup<String>(title: "English", projects: Array(projects)))
                }
                return suggestionGroups
            }
            .assign(to: \ProjectsModel.projectGroups, on: self)
            .store(in: &cancellables)

        self.$currentText
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { text -> String? in
                return text
            }
            .assign(to: \ProjectsModel.currentProject, on: self)
            .store(in: &cancellables)
    }
}
