//
//  TrackManager.swift
//  Alfaia
//
//  Created by Bruno Barbosa on 7/10/16.
//  Copyright © 2016 Victor Leal Porto de Almeida Arruda. All rights reserved.
//

import Foundation
import UIKit

enum SongLevel {
    case LevelOne
    case LevelTwo
}

enum NotePattern {
    case Baque1
    case Baque2
}

class TrackManager {
    private var rightHandPattern: [Bool]!
    private var leftHandPattern: [Bool]!
    
    private(set) var songTime: Double
    private(set) var songStruct: [NotePattern]
    private(set) var gestureStruct: [NotePattern]
    
    init(level: SongLevel) {
        switch level {
        case .LevelOne:
            self.songTime = 93
            self.songStruct = [NotePattern.Baque1, NotePattern.Baque2, NotePattern.Baque2, NotePattern.Baque1, NotePattern.Baque2]
            self.gestureStruct = [NotePattern.Baque1, NotePattern.Baque2, NotePattern.Baque1, NotePattern.Baque2]
        default:
            self.songTime = 60
            self.songStruct = [NotePattern.Baque1, NotePattern.Baque1]
            self.gestureStruct = [NotePattern.Baque1]
        }
    }
    
    func nextBumpPattern() -> [String: [Bool]]? {
        if self.songStruct.count <= 0 {
            return nil
        }
        let pattern = self.songStruct.removeFirst()
        switch pattern {
        case .Baque1:
            self.rightHandPattern = [true, false, true, true, true, true, false, true, false, true, false, true, true, false, true]
            self.leftHandPattern = [true, false, true, true, true, true, false, true, false, true, false, true, true, false, true]
        case .Baque2:
            self.rightHandPattern = [true, true, true, false, true, true, true]
            self.leftHandPattern = [true, true, false, false, true, true, false]
        default:
            self.rightHandPattern = []
            self.leftHandPattern = []
        }
        return ["right":self.rightHandPattern, "left":self.leftHandPattern]
    }
    
    func nextGesturePattern() -> [UISwipeGestureRecognizerDirection]? {
        if self.gestureStruct.count <= 0 {
            return nil
        }
        let pattern = self.gestureStruct.removeFirst()
        switch pattern {
        case .Baque1:
            let pattern = [UISwipeGestureRecognizerDirection.Up, UISwipeGestureRecognizerDirection.Right, UISwipeGestureRecognizerDirection.Up]
            return pattern
        case .Baque2:
            let pattern = [UISwipeGestureRecognizerDirection.Right, UISwipeGestureRecognizerDirection.Left, UISwipeGestureRecognizerDirection.Down]
            return pattern
        default:
            let pattern = [UISwipeGestureRecognizerDirection.Down, UISwipeGestureRecognizerDirection.Left, UISwipeGestureRecognizerDirection.Right]
            return pattern
        }
    }
    
    
    
    
}