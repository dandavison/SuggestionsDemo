//
//  ContentView.swift
//  SuggestionsDemo
//
//  Created by Stephan Michels on 16.09.20.
//

import SwiftUI

struct ContentView: View {
    @StateObject var model = DictionaryModel()
    
    var body: some View {
        SuggestionInput(text: self.$model.currentText,
                        suggestionGroups: self.model.suggestionGroups)
        .frame(width: 300)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
