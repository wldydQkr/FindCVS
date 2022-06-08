//
//  KLDocument.swift
//  FindCVS
//
//  Created by 박지용 on 2022/06/09.
//

import Foundation

struct KLDocument: Decodable {
    let placeName: String
    let addressName: String
    let roadAddresName: String
    let x: String
    let y: String
    let distance: String
    
    enum CodingKeys: String, CodingKey {
        case x, y, distance
        case placeName = "place_name"
        case addressName = "address_name"
        case roadAdressName = "road_address_name"
    }
}
