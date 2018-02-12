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
        
        setUpRefreshControl()
        
        setUpLocationManager()
        
    }
    
    func setUpLocationManager() {
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //get current location
        let location: CLLocation = locations.last!
        
        fetchLocationAndWeatherData(location: location)
    }
    
    func fetchLocationAndWeatherData(location: CLLocation) {
        
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
    
    func setUpRefreshControl() {
        
        let refreshControl = UIRefreshControl()
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)

        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Weather Data ...")
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        // Fetch Weather Data
        setUpLocationManager()
        //fetchLocationAndWeatherData()
    }
    
    func fetchCountryAndCity(location: CLLocation, completion: @escaping (String?, Error?) -> ()) {
        //座標換成placeMarker
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                completion(nil, error)
            } else if let city = placemarks?.first?.locality {
                //取出地址中的 City
                let cityOnlyName = city.split(separator: " ")
                
                if let some = cityOnlyName.first {
                    let value = String(some)
                    
                    completion(value, error)
                } else {
                    completion(city, error)
                }
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
                
                let statusCode: String = (item?.forecast[row].code)!
                switch statusCode {
                case "0", "1", "2":
                    cell.statusImageView.image = #imageLiteral(resourceName: "A")
                case "3", "4":
                    cell.statusImageView.image = #imageLiteral(resourceName: "B")
                case "5", "7", "35":
                    cell.statusImageView.image = #imageLiteral(resourceName: "C")
                case "8", "9", "10", "11", "12":
                    cell.statusImageView.image = #imageLiteral(resourceName: "D")
                case "13", "14", "15", "16":
                    cell.statusImageView.image = #imageLiteral(resourceName: "E")
                case "17", "18":
                    cell.statusImageView.image = #imageLiteral(resourceName: "F")
                case "19", "20", "21", "22":
                    cell.statusImageView.image = #imageLiteral(resourceName: "G")
                case "23", "24":
                    cell.statusImageView.image = #imageLiteral(resourceName: "H")
                case "25":
                    cell.statusImageView.image = #imageLiteral(resourceName: "I")
                case "26", "28", "30", "40":
                    cell.statusImageView.image = #imageLiteral(resourceName: "J")
                case "27", "29":
                    cell.statusImageView.image = #imageLiteral(resourceName: "L")
                case "31", "33":
                    cell.statusImageView.image = #imageLiteral(resourceName: "M")
                case "32", "34":
                     cell.statusImageView.image = #imageLiteral(resourceName: "N")
                case "36":
                    cell.statusImageView.image = #imageLiteral(resourceName: "O")
                case "37":
                    cell.statusImageView.image = #imageLiteral(resourceName: "P")
                case "38", "39":
                    cell.statusImageView.image = #imageLiteral(resourceName: "Q")
                case "40":
                    cell.statusImageView.image = #imageLiteral(resourceName: "R")
                case "41", "43":
                    cell.statusImageView.image = #imageLiteral(resourceName: "S")
                case "42", "46":
                    cell.statusImageView.image = #imageLiteral(resourceName: "T")
                case "45", "47":
                    cell.statusImageView.image = #imageLiteral(resourceName: "U")
                default:
                    print("Not available")
                }
//                cell.statusLabel.text = item?.forecast[row].text
                
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
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
        }
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
