//
//  LocalNetworkStub.swift
//  FindCVSTests
//
//  Created by 박지용 on 2022/06/12.
//

import Foundation
import RxSwift
import Stubber

@testable import FindCVS

class LocalNetworkStub: LocalNetwork {
    override func getLocation(by mapPoint: MTMapPoint) -> Single<Result<LocationData, URLError>> {
        return Stubber.invoke(getLocation, args: mapPoint)
    }
}
