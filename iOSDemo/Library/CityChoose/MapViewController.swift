//
//  MapViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/11.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import MAMapKit
import AMapFoundationKit
import AMapLocationKit
// 后面加选择地点再更新地址功能

class MapViewController: UIViewController {
    
    var mapView: MAMapView!
    var locationManager = AMapLocationManager()
    var lblAddress = UILabel()
    var btnLocation = UIButton()
    let geoCoder = CLGeocoder()
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        // Do any additional setup after loading the view.
    }

    func initView() {
        let btnCityChoose = UIBarButtonItem(title: "选择城市", style: .plain, target: self, action: #selector(chooseCity))
        navigationItem.rightBarButtonItem = btnCityChoose
        navigationItem.title = "地图定位"
        
        configLocationManager()
        
         AMapServices.shared().enableHTTPS = true
        
        mapView = MAMapView()
        mapView.delegate = self
        mapView.showsUserLocation = true;
        mapView.userTrackingMode = .follow;
        mapView.zoomLevel = 15
        mapView.minZoomLevel = 7
        let r = MAUserLocationRepresentation()
        r.showsAccuracyRing = false;//
        r.locationDotFillColor = UIColor.gray
        mapView.update(r)
        
        self.view.addSubview(mapView)
        mapView.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        
        btnLocation.setImage(#imageLiteral(resourceName: "btn_location"), for: .normal)
        btnLocation.contentMode = .scaleAspectFit
        btnLocation.addTarget(self, action: #selector(toMyLoaction), for: .touchUpInside)
        self.view.addSubview(btnLocation)
        btnLocation.snp.makeConstraints { (m) in
            m.right.equalTo(-20)
            m.bottom.equalTo(-20)
            m.width.height.equalTo(40)
        }
        
        lblAddress.txtAlignment(ali: .center).color(color: UIColor.white).bgColor(color: UIColor(white: 0.5, alpha: 0.3)).addTo(view: view).snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.top.equalTo(70)
        }
    }
    
    
    func configLocationManager() {
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.distanceFilter = 50.0
        locationManager.startUpdatingLocation()
        
    }
    
    @objc func toMyLoaction() {
        locationManager.startUpdatingLocation()
    }

    
    @objc func chooseCity() {
        navigationController?.pushViewController(CityChooseViewController(), animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reverseLocation(location: CLLocation)  {
        geoCoder.reverseGeocodeLocation(location) { [weak self](places, err) in
            if places == nil || err != nil{
                return
            }
            if let detailAddress = places?.first{
                let country = detailAddress.country ?? ""
                let city = detailAddress.locality ?? ""
                let province = detailAddress.administrativeArea ?? ""
                let street = detailAddress.thoroughfare ?? ""
                self?.lblAddress.text = country + province + city + street
                
            }
            if let add = places!.first?.locality{
                
                if let city = CityDB.sharedInstance.searchCity(city: add).first{
                    if APPAreaInfo.Value!.areaId == 0{
                        city.longitude = location.coordinate.longitude
                        city.latitude = location.coordinate.latitude
                        APPAreaInfo.Value = city
                    }
                    else if city.areaId != APPAreaInfo.Value!.areaId{
                        UIAlertController.title(title: "切换城市", message: "系统定位到的城市是\(city.city),但是你所选的城市是\(APPAreaInfo.Value!.city),是否切换\(city.city)").action(title: "取消", handle: nil).action(title: "确定", handle: { (action) in
                            if action.title == "确定"{
                                city.longitude = location.coordinate.longitude
                                city.latitude = location.coordinate.latitude
                                APPAreaInfo.Value = city
                                
                            }
                        }).showAlert(viewController: self!)
                    }
                }
            }
        }
    }
}

extension MapViewController:AMapLocationManagerDelegate,MAMapViewDelegate{
    
    func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!) {
        locationManager.requestAlwaysAuthorization()
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error!) {
        let error = error as NSError
        NSLog("appdelegate --- didFailWithError:{\(error.code) - \(error.localizedDescription)}; 请检查是否开启定位功能")
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode!) {
        mapView.setCenter(location.coordinate, animated: true)
        reverseLocation(location: location)
    }
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
       
    }
    
    
    func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        reverseLocation(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }
    
}

