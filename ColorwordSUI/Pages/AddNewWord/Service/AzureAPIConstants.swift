//
//  AzureAPIConstants.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 7.05.2025.
//

struct AzureAPIConstants {
    // Subscription Key for Azure
    static let subscriptionKeyHTTPHeaderField = "Ocp-Apim-Subscription-Key"

    // Region for Azure services
    static let regionHTTPHeaderField = "Ocp-Apim-Subscription-Region"
    static let regionValue = "westeurope"

    // Content-Type for the API request
    static let contentTypeHTTPHeaderField = "Content-Type"
    static let contentTypeValue = "application/json"
    
}
