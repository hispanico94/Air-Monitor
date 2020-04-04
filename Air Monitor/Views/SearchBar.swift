//
//  SearchBar.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 01/04/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import SwiftUI

struct SearchBar: UIViewRepresentable {
  
  @Binding var text: String
  var placeholder: String?
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(text: $text)
  }
  
  func makeUIView(context: Context) -> UISearchBar {
    let searchBar = UISearchBar()
    searchBar.delegate = context.coordinator
    searchBar.searchBarStyle = .default
    searchBar.autocapitalizationType = .none
    searchBar.placeholder = placeholder
    return searchBar
  }
  
  func updateUIView(_ uiView: UISearchBar, context: Context) {
    uiView.text = text
  }
}

extension SearchBar {
  class Coordinator: NSObject, UISearchBarDelegate {
    @Binding var text: String
    
    init(text: Binding<String>) {
      _text = text
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      text = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
      searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
      text = ""
      searchBar.text = ""
      searchBar.endEditing(true)
      searchBar.setShowsCancelButton(false, animated: true)
    }
  }
}
