//
//  WeatherTableViewController.swift
//  elenaWeather
//
//  Created by 劉芳瑜 on 2018/2/10.
//  Copyright © 2018年 Fang-Yu. Liu. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        ApiManager.share.delegate = self

        setUpLocationManager()
        
        let location = CLLocation(
            latitude:  (locationManager.location?.coordinate.latitude)!,
            longitude: (locationManager.location?.coordinate.longitude)!)
        
        fetchCountryAndCity(location: location) { city, error in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            guard let cityName = city else { return }
            ApiManager.share.getWeatherInfo(city: cityName)
            print("city:", cityName)
        }
    }
    
    func setUpLocationManager() {
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func fetchCountryAndCity(location: CLLocation, completion: @escaping (String?, Error?) -> ()) {
        //座標換成placeMarker
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                completion(nil, error)
            } else if let city = placemarks?.first?.locality {
                //取出地址中的 City
                completion(city, error)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        

        return cell
    }
}

extension WeatherTableViewController: ApiManagerDelegate {
    
    func ApiManager(_ manager: ApiManager, didGet data: WeatherResult) {
        
    }
    
    func ApiManager(_ manager: ApiManager, didFailWith error: ApiManagerError) {
        
    }
}
