//
//  FirestoreInterface.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 12.11.2024.
//

import Foundation

protocol FirestoreInterface {
    func readWords() async throws -> [Word] 
}
