//
//  APIManager.swift
//  elenaWeather
//
//  Created by 劉芳瑜 on 2018/2/10.
//  Copyright © 2018年 Fang-Yu. Liu. All rights reserved.
//

import Foundation

protocol ApiManagerDelegate: class {
    
    func ApiManager(_ manager: ApiManager, didGet data: WeatherResult)
    
    func ApiManager(_ manager: ApiManager, didFailWith error: ApiManagerError)
}



enum ApiManagerError: Error {
    
    case convertError
}

class ApiManager {
    
    static let share = ApiManager()
    
    weak var delegate: ApiManagerDelegate?
    
    func getWeatherInfo(city: String) {
        
        let url = URL(string: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22\(city)%22)&format=json")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            let decoder = JSONDecoder()
            
            if let error = error {
                return
            }
            
            if let data = data,
                let weatherResult = try? decoder.decode(WeatherResult.self, from: data)
            {
                print("1111\(weatherResult)")
//                self.delegate?.ApiManager(self, didGet: WeatherResult)
            }else {
                print(error?.localizedDescription)
//                self.delegate?.storeProvider(self, didFailWith: StoreProviderError.convertError)
            }
        }
        task.resume()
    }
}
