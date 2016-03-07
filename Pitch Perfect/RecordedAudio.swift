//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Robert Chynoweth on 9/29/15.
//  Copyright © 2015 Robert Chynoweth. All rights reserved.
//

import Foundation

public final class RecordedAudio: NSObject {
    public var filePathUrl: NSURL!
    public var title: String!
    
    init(filePathUrl: NSURL, title: String) {
        self.filePathUrl = filePathUrl
        self.title = title
    }
}
