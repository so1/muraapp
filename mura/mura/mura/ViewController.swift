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
    private var monitoredRegion: CLCircularRegion?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.requestPrivasyAccess()
        self.startMonitoring()
        
        self.locationManager.delegate = self
        UNUserNotificationCenter.current().delegate = self
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
        
        self.setGeoFence("Chatwork", lat: 35.717704,   lng: 139.788931)
        self.setGeoFence("Project1", lat: 35.70692833, lng: 139.59999166)
        self.setGeoFence("Project2", lat: 35.70701166, lng: 139.59945500)
        self.setGeoFence("MyHome",   lat: 35.720316,   lng: 139.608254)

    }
    
    private func stopMonitoring() {
        if let monitoredRegion = self.monitoredRegion {
            self.locationManager.stopMonitoring(for: monitoredRegion)
        }
    }
    
    private func setGeoFence(_ name: String, lat: Double, lng: Double) {
        print("add \(name) -> \(lat), \(lng)")
        
        let center = CLLocationCoordinate2DMake(lat, lng)
        self.monitoredRegion = CLCircularRegion(center: center, radius: 1, identifier: name)
        self.locationManager.startMonitoring(for: self.monitoredRegion!)
    }
    
    // CoreLocation
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        self.sendNotification("Start", message: "\(region.identifier)の観測を開始しました", title: "観測開始")
        print("観測開始")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("観測の開始に失敗しました！")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        self.sendNotification("Enter", message: "\(region.identifier)に入りましたよ!!!!", title: "ジオフェンスのテストです")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.sendNotification("Exit", message: "\(region.identifier)からでましたよ!!!!", title: "ジオフェンスのテストです")
    }
    
    private func sendNotification(_ id: String, message: String, title: String) {
        let center = UNUserNotificationCenter.current()
        
        // NotificationContent
        let content = UNMutableNotificationContent()
        content.title = "title"
        content.subtitle = "サンプルのsubtitleです"
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
        print("送るよ \(notification)")
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("受け取ったよ")
    }
}

