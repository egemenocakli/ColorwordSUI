//
//  RequestType.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 6.05.2025.
//

enum RequestType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

extension RequestType {
    init?(string: String) {
        switch string.uppercased(){
        case "GET":
            self = .get
        case "POST":
            self = .post
        case "PUT":
            self = .put
        case "DELETE":
            self = .delete
        default:
            return nil
        }

    }
}
