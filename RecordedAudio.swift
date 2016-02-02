//
//  RecordedAudio.swift
//  PitchPerfect
//
//  Created by Lawrence Nyakiso on 2016/01/28.
//  Copyright © 2016 KisoCloud. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    var fileURL:NSURL!
    var fileTitle:String!
    init(fileURL:NSURL, fileTitle:String) {
        self.fileURL = fileURL
        self.fileTitle = fileTitle
    }
}