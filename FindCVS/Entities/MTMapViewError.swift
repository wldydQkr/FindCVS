//
//  MTMapViewError.swift
//  FindCVS
//
//  Created by 박지용 on 2022/06/09.
//

import Foundation

enum MTMapViewError: Error {
    case faileUpdatingCurrentLocation
    case locationAuthorizaationDenied
    
    var errorDescription: String {
        switch self {
        case .faileUpdatingCurrentLocation:
            return "현재 위치를 불러오지 못했습니다. 잠시 후 다시 시도해주세요."
        case .locationAuthorizaationDenied:
            return "위치 정보를 비활성화하면 사용자의 현재 위치를 알 수 없습니다."
        }
    }
}
