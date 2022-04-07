//
//  ImageDTO.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 31.03.2022.
//

import Foundation

struct ImageDTO:  Codable {
    internal init(image: Data) {
        self.image = image
    }    
    
    let image: Data
}
