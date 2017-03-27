//
//  ViewController.swift
//  mura
//
//  Created by chibatch on 2017/03/15.
//  Copyright © 2017年 kroon. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications


class ViewController: UIViewController, CLLocationManagerDelegate,UNUserNotificationCenterDelegate {

    private let locationManager = CLLocationManager()
    
    @IBOutlet weak var currentLatLabel: UILabel!
    @IBOutlet weak var currentLngLabel: UILabel!
    @IBOutlet weak var currentAreaLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Delegateの設定
        self.locationManager.delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        // 位置情報の許可をもらう
        self.requestPrivasyAccess()
        
        self.currentAreaLabel.text = ""
        
        // 取得済みのジオフェンスを消して再登録
//        self.stopMonitoring()
        self.startMonitoring()
        
        // テスト用に位置情報取得
        self.locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func requestPrivasyAccess() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.distanceFilter = 1
        self.locationManager.pausesLocationUpdatesAutomatically = true
    }
    
    private func startMonitoring() {
        let status = CLLocationManager.authorizationStatus()
        if status == .denied || status == .restricted {
            print("startMonitoring failed")
            return
        }
        
        self.setGeoFence("ChatWork", lat: 35.717704, lng: 139.788931)
        self.setGeoFence("MyHome", lat: 35.720316, lng: 139.608254)

        self.setGeoFence("Project",  lat: 35.704104, lng: 139.601802)
        self.setGeoFence("SevenEleven", lat: 35.704304, lng: 139.601663)
        self.setGeoFence("MiniStop", lat: 35.704082, lng: 139.609332)
        self.setGeoFence("Nishiogi1", lat: 35.704173, lng: 139.601244)
        self.setGeoFence("MyBasket", lat: 35.710814, lng: 139.601749)

        self.setGeoFence("JRKichijoji", lat: 35.703149, lng: 139.579809)
        self.setGeoFence("JRNishiogikubo", lat: 35.703788, lng: 139.599557)
        self.setGeoFence("JROgikubo",   lat: 35.704498, lng: 139.619058)
        
        self.setGeoFence("OsakaSakurai",   lat: 34.816792, lng: 135.460702)
        self.setGeoFence("OsakaFamilyMart", lat: 34.813948, lng: 135.452103)
        self.setGeoFence("Osaka1", lat: 34.817703, lng: 135.455069)
        self.setGeoFence("Osaka2", lat: 34.818459, lng: 135.456047)
        self.setGeoFence("Osaka3", lat: 34.817325, lng: 135.454817)

        // テスト用
        self.statusLabel.text = "観測中: \(self.locationManager.monitoredRegions.count)個のジオフェンス"
    }
    
    /**
     観測の停止
     */
    private func stopMonitoring() {
        self.locationManager.monitoredRegions.forEach { region in
            self.locationManager.stopMonitoring(for: region)
        }
    }
    
    // ジオフェンスの設定
    private func setGeoFence(_ name: String, lat: Double, lng: Double) {
        
        let center = CLLocationCoordinate2DMake(lat, lng)
        let region = CLCircularRegion(center: center, radius: 1, identifier: name)
        
        // 観測開始
        self.locationManager.startMonitoring(for: region)
        
        self.locationManager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch (state) {
        case .inside:
            self.currentAreaLabel.text = "\(region.identifier)"

            print("\(region.identifier): inside")
            break
        default:
            print("\(region.identifier): outside")
            break
        }
    }
    
    // CoreLocation
    
    // 観測開始
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("\(region.identifier) 観測開始")
        
//        manager.requestState(for: region)
    }
    
    // 観測終了
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("\(region?.identifier) 観測の開始に失敗しました！")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        self.currentAreaLabel.text = "\(region.identifier)"
        
        self.sendNotification("Enter", message: "\(region.identifier)に入りましたよ!!!!")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.currentAreaLabel.text = ""
        self.sendNotification("Exit", message: "\(region.identifier)からでましたよ!!!!")
    }
    
    // 位置情報取得：テスト用
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            self.currentLatLabel.text = "緯度：\(location.coordinate.latitude)"
            self.currentLngLabel.text = "経度：\(location.coordinate.longitude)"
        }
    }
    
    // 位置情報取得失敗：テスト用
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.statusLabel.text = "位置情報の取得に失敗しました"
    }
    
    // UserNotification
    private func sendNotification(_ id: String, message: String) {
        let center = UNUserNotificationCenter.current()
        
        // NotificationContent
        let content = UNMutableNotificationContent()
        content.title = id
        content.body = message
        content.badge = 0
        content.sound = .default()
        
        // NotificationTrigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // NotificationRequest
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        // 通知の追加
        center.add(request)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("受け取ったよ")
    }
}

