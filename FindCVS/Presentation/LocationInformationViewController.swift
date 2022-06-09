//
//  LocationInformationViewController.swift
//  FindCVS
//
//  Created by 박지용 on 2022/06/09.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import SnapKit

class LocationInformationViewController: UIViewController {
    let dispseBag = DisposeBag()
    
    let locationManager = CLLocationManager()
    let mapView = MTMapView()
    let currentLocationButton = UIButton()
    let detailList = UITableView()
    let viewModel = LocationInformationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        bind(viewModel)
        attribute()
        layout()
    }
    
    private func bind(_ viewModel: LocationInformationViewModel) {
        viewModel.setMapCenter
            .emit(to: mapView.rx.setMapCenterPoint)
            .disposed(by: dispseBag)
        
        viewModel.errorMessage
            .emit(to: self.rx.presentAlert)
            .disposed(by: dispseBag)
        
        currentLocationButton.rx.tap
            .bind(to: viewModel.currentLocationButtonTapped)
            .disposed(by: dispseBag)
    }
    
    private func attribute() {
        title = "내 주변 편의점 찾기"
        view.backgroundColor = .white
        
        mapView.currentLocationTrackingMode = .onWithoutHeadingWithoutMapMoving
        
        currentLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        currentLocationButton.backgroundColor = .white
        currentLocationButton.layer.cornerRadius = 20
    }
    
    private func layout() {
        [mapView, currentLocationButton, detailList]
            .forEach { view.addSubview($0) }
        
        mapView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.snp.centerY).offset(100)
        }
        
        currentLocationButton.snp.makeConstraints {
            $0.bottom.equalTo(detailList.snp.top).offset(-12)
            $0.leading.equalToSuperview().offset(12)
            $0.width.height.equalTo(40)
        }
        
        detailList.snp.makeConstraints {
            $0.centerX.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            $0.top.equalTo(mapView.snp.bottom)
        }
    }
}

extension LocationInformationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways,
             .authorizedWhenInUse,
             .notDetermined:
            return
        default:
            viewModel.mapViewError.accept(MTMapViewError.locationAuthorizaationDenied.errorDescription)
            return
        }
    }
}

extension LocationInformationViewController: MTMapViewDelegate {
    func mapView(_ mapView: MTMapView!, updateCurrentLocation location: MTMapPoint!, withAccuracy accuracy: MTMapLocationAccuracy) {
        #if DEBUG
        viewModel.currentLocation.accept(MTMapPoint(geoCoord: MTMapPointGeo(latitude: 37.394225, longitude: 127.110341)))
        #else
         viewModel.currentLocation.accept(location)
        #endif
    }
    
    
    // 동작이 끝났을 때 센터 포인트를 지정해줌
    func mapView(_ mapView: MTMapView!, finishedMapMoveAnimation mapCenterPoint: MTMapPoint!) {
         viewModel.mapCenterPoint.accept(mapCenterPoint)
    }
    
    // 핀을 탭할때마다 MTMapPOIItem을 전달
    func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
         viewModel.selectPOIItem.accept(poiItem)
        return false
    }
    
    // 제대로 된 현재위치를 불러오지 못했을 때 에러를 반환해줌
    func mapView(_ mapView: MTMapView!, failedUpdatingCurrentLocationWithError error: Error!) {
         viewModel.mapViewError.accept(error.localizedDescription)
    }
}

extension Reactive where Base: MTMapView {
    var setMapCenterPoint: Binder<MTMapPoint> {
        return Binder(base) { base, point in
            base.setMapCenter(point, animated: true)
        }
    }
}

extension Reactive where Base: LocationInformationViewController {
    var presentAlert: Binder<String> {
        return Binder(base) { base, message in
            let alertController = UIAlertController(title: "문제가 발생했습니다.", message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        
            alertController.addAction(action)
            
            base.present(alertController, animated: true, completion: nil)
        }
    }
}
