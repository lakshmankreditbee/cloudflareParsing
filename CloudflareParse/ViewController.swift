//
//  ViewController.swift
//  CloudflareParse
//
//  Created by Pusuluru Sree Lakshman on 13/09/23.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    private let WEBVIEW_ERROR = "webview_error_config"
    private let LOGIN = "login_config"
    private let LIVENESS = "liveness_config"
    private let LOCALE = "locale_config"
    private let URLS = "urls"
    private let EVENTS = "events_config"
    private let EAADHAAR = "eaadhaar_config"
    private let CONSENT = "consent_config"
    private let VKYC = "vkyc_config"
    private let LOCATION = "location_config"
    private let PDDB = "pddb_config"
    private let ENGG = "engg_urls"
    private let FEATURE = "feature_config"
    private let LOGS = "logs_config"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDataFromAPI { result in
            switch result {
            case .success(let responseString):
                let responseJSON = CFUtils.shared.parseConfigs(data: responseString)
                let configs = responseJSON.dictionaryValue
                for key in configs.keys.sorted() {
                    switch(key) {
                    case self.WEBVIEW_ERROR:
                        print("--------WEBVIEW_ERROR------")
                        if let webviewErrorConfig = configs[self.WEBVIEW_ERROR] {
                            print(webviewErrorConfig)
                        }
                        
                    case self.LOGIN:
                        print("--------LOGIN---------")
                        if let loginConfig = configs[self.LOGIN] {
                            print(loginConfig)
                        }
                        
                        
                    case self.LIVENESS:
                        print("--------LOGIN--------")
                        if let livenessConfig = configs[self.LIVENESS] {
                            print(livenessConfig)
                        }
                        
                    case self.LOCALE:
                        print("--------LOCALE--------")
                        if let localeConfig = configs[self.LOCALE] {
                            print(localeConfig)
                        }
                        
                    case self.URLS:
                        print("--------URLS--------")
                        if let urlsConfig = configs[self.URLS] {
                            print(urlsConfig)
                        }
                    
                    case self.EVENTS:
                        print("--------EVENTS--------")
                        if let eventsConfig = configs[self.EVENTS] {
                            print(eventsConfig)
                        }
                        
                    case self.EAADHAAR:
                        print("--------EAADHAAR--------")
                        if let eaadhaarConfig = configs[self.EAADHAAR] {
                            print(eaadhaarConfig)
                        }
                        
                    case self.CONSENT:
                        print("--------CONSENT--------")
                        if let consentConfig = configs[self.CONSENT] {
                            print(consentConfig)
                        }
                        
                    case self.VKYC:
                        print("--------VKYC--------")
                        if let vkycConfig = configs[self.VKYC] {
                            print(vkycConfig)
                        }
                        
                    case self.LOCATION:
                        print("--------LOCATION--------")
                        if let locationConfig = configs[self.LOCATION] {
                            print(locationConfig)
                        }
                        
                    case self.PDDB:
                        print("--------PDDB--------")
                        if let pddbConfig = configs[self.PDDB] {
                            print(pddbConfig)
                        }
                        
                    case self.ENGG:
                        print("--------ENGG--------")
                        if let enggConfig = configs[self.ENGG] {
                            print(enggConfig)
                        }
                    
                    case self.FEATURE:
                        print("--------FEATURE--------")
                        if let featureConfig = configs[self.FEATURE] {
                            print(featureConfig)
                        }
                        
                    case self.LOGS:
                        print("--------LOGS--------")
                        if let logsConfig = configs[self.LOGS] {
                            print(logsConfig)
                        }
                    
                    default:
                        break
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
                // Handle the error case here
            }
        }
    }
    
    func fetchDataFromAPI(completion: @escaping (Result<String, Error>) -> Void) {
        let apiUrl = "https://configsdk.mukesh-solanki.workers.dev/app_ios/"
        AF.request(apiUrl, method: .get).responseString { response in
            switch response.result {
            case .success(let value):
                let responseString = value
                completion(.success(responseString))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
