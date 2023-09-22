//
//  ViewController.swift
//  CloudflareParse
//
//  Created by Pusuluru Sree Lakshman on 13/09/23.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDataFromAPI { result in
            switch result {
            case .success(let responseString):
                print("\(CFUtils.shared.parseConfigs(data: responseString, docType: "syst"))")
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
