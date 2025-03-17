//
//  AnimationToggleState.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 14.01.2025.
//

enum AnimationToggleState: Int {
    case fast = 1
    case normal = 3
    
    var isFast: Bool {
        self == .fast
    }
    
    init(isFast: Bool) {
        self = isFast ? .fast : .normal
    }
    
    var value: Int {
        return self.rawValue
    }
}
