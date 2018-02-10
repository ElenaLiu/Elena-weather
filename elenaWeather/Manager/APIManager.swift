//
//  APIManager.swift
//  elenaWeather
//
//  Created by 劉芳瑜 on 2018/2/10.
//  Copyright © 2018年 Fang-Yu. Liu. All rights reserved.
//

import Foundation

protocol ApiManagerDelegate: class {
    
    func manager(_ manager: ApiManager, didGet data: Item)
    
    func manager(_ manager: ApiManager, didFailWith error: ApiManagerError)
}

enum ApiManagerError: Error {
    
    case convertError
    case dataTaskError
}

class ApiManager {
    
    static let share = ApiManager()
    
    weak var delegate: ApiManagerDelegate?
    
    func getWeatherInfo(city: String) {
        
        let url = URL(string: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22\(city)%22)&format=json")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            let decoder = JSONDecoder()
            
            if error != nil {
                self.delegate?.manager(self, didFailWith: ApiManagerError.dataTaskError)
                return
            }
            
            if let data = data,
                let weatherResult = try? decoder.decode(WeatherResult.self, from: data)
            {
                self.delegate?.manager(self, didGet: weatherResult.query.results.channel.item)
            }else {
                self.delegate?.manager(self, didFailWith: ApiManagerError.convertError)
            }
        }
        task.resume()
    }
}
