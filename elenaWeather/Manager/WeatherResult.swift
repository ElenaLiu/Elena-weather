//
//  WeatherResult.swift
//  elenaWeather
//
//  Created by 劉芳瑜 on 2018/2/10.
//  Copyright © 2018年 Fang-Yu. Liu. All rights reserved.
//

import Foundation

struct WeatherResult: Codable {
    var query: Query
    struct Query: Codable {
        var results: Results
        struct Results: Codable {
            var channel: Channel
            struct Channel: Codable {
                var item: Item
            }
        }
    }
}

struct Item: Codable {
    var condition: Condition
    struct Condition: Codable {
        var code: String
        var date: String
        var temp: String
        var text: String
    }
    var forecast: [Forecast]
    struct Forecast: Codable {
        var code: String
        var date: String
        var day: String
        var high: String
        var low: String
        var text: String
    }
}
