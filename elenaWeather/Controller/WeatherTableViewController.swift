//
//  WeatherTableViewController.swift
//  elenaWeather
//
//  Created by 劉芳瑜 on 2018/2/10.
//  Copyright © 2018年 Fang-Yu. Liu. All rights reserved.
//

import UIKit
import CoreLocation

enum Section {
    case condition
    case forecast
}

class WeatherTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    let sections: [Section] = [.condition, .forecast]
    
    let locationManager = CLLocationManager()
    
    var cityName = ""
    
    var item: Item? = nil {
        didSet {
            self.condition = self.item!.condition
            self.forecast = self.item!.forecast
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var condition: Item.Condition? = nil
    var forecast: [Item.Forecast]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApiManager.share.delegate = self
        
        tableView.separatorStyle = .none

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
            self.cityName = cityName
            ApiManager.share.getWeatherInfo(city: cityName)
            
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
        
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch sections[section] {
        case .condition:
            return 1
        case .forecast:
            if item != nil {
                return (item?.forecast.count)! - 1
            }else {
                return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch sections[indexPath.section] {
        case .condition:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ConditionTableViewCell", for: indexPath) as! ConditionTableViewCell
            
            cell.cityLabel.text = cityName
            
            
            if item != nil {
                
                let highTemp = self.fahrenheitToCelsius(fahrenheit: (item?.forecast.first?.high)!)
                let lowTemp = self.fahrenheitToCelsius(fahrenheit: (item?.forecast.first?.low)!)
                let temp = self.fahrenheitToCelsius(fahrenheit: (item?.condition.temp)!)
                
                cell.dayLabel.text = item?.forecast.first?.day
                cell.statusLabel.text = item?.condition.text
                cell.highTempLabel.text = highTemp
                cell.lowTempLabel.text = lowTemp
                cell.tempLabel.text = temp
                cell.todayLabel.text = "Today"
            }
            
            return cell
        case .forecast:
             let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell", for: indexPath) as! ForecastTableViewCell
             if item != nil{
                let row = indexPath.row + 1
                cell.dayLabel.text = item?.forecast[row].day
                cell.statusLabel.text = item?.forecast[row].text
                
                let highTemp = self.fahrenheitToCelsius(fahrenheit: (item?.forecast[row].high)!)
                let lowTemp = self.fahrenheitToCelsius(fahrenheit: (item?.forecast[row].low)!)
                
                cell.highTempLabel.text = highTemp
                cell.lowTempLabel.text = lowTemp
             }
             return cell
        }
    }
}

extension WeatherTableViewController: ApiManagerDelegate {

    func manager(_ manager: ApiManager, didGet data: Item) {
    
        self.item = data
    }
    
    func manager(_ manager: ApiManager, didFailWith error: ApiManagerError) {
        
    }
    
    func fahrenheitToCelsius(fahrenheit: String) -> String {
        let numberFormatter = NumberFormatter()
        let number = numberFormatter.number(from: fahrenheit)
        let conversion = ((number?.floatValue)! - 32) / 1.8
        return String(Int(conversion)) + " ℃"
    }
}
