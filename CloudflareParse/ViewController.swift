//
//  ViewController.swift
//  CloudflareParse
//
//  Created by Pusuluru Sree Lakshman on 13/09/23.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDataFromAPI { result in
            switch result {
            case .success(let responseString):
                let responseJSON = CFUtils.shared.parseConfigs(data: responseString)
                let dictionaryResp = responseJSON.dictionaryValue
                for key in dictionaryResp.keys.sorted() {
                    print(key)
                }
                print(responseJSON)
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
