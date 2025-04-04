//
//  Player.swift
//  GrabtheMic
//
//  Created by Kenneth Chen on 4/4/25.
//

// basic implementation of each player/user with points/score tracking system

import Foundation


struct Player: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var score: Int = 0
}
