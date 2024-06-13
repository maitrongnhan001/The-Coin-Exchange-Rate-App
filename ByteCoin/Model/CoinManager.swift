//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didFailWithError(error: Error!)
    func didUpdateCoinRate(_ coinManager: CoinManager, coinModel: CoinModel)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "THE_SECRET_API_KEY"
    
    var delegate: CoinManagerDelegate!
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String) {
        performRequest(urlString: "\(baseURL)/\(currency)?apikey=\(apiKey)")
    }
    
    func performRequest(urlString: String) {
        if let url = URL(string: urlString) {
            let urlSession = URLSession(configuration: .default)
            let task = urlSession.dataTask(with: url) { (data, response, error) in
                if (error != nil) {
                    self.delegate.didFailWithError(error: error)
                    return
                }
                
                if let safeData = data {
                    let coinModel = parseJSON(data: safeData)
                    self.delegate.didUpdateCoinRate(self, coinModel: coinModel!)
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(data: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        
        do {
            let decoderData = try decoder.decode(coinData.self, from: data)
            let time = decoderData.time
            let asset_id_base = decoderData.asset_id_base
            let asset_id_quote = decoderData.asset_id_quote
            let rate = decoderData.rate

            return CoinModel(time: time, asset_id_base: asset_id_base, asset_id_quote: asset_id_quote, rate: rate)
        } catch {
            print(error)
            return nil
        }
    }
}
