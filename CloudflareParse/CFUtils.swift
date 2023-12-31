//
//  CFUtils.swift
//  CloudflareParse
//
//  Created by Pusuluru Sree Lakshman on 19/09/23.
//

import Foundation
import SwiftyJSON

/**
 CFUtils is a utility class in Swift that provides methods for parsing JSON data and extracting specific fields based on their types.
 
 The `parseConfigs` method is used to parse JSON data and extract the desired fields. It takes a JSON string as input and returns a JSON object containing the extracted values.
 
 Inputs:
 - data: A JSON string representing the data to be parsed.
 
 Outputs:
 - root: A JSON object containing the extracted values from the input data.
 */

class CFUtils: NSObject {
    
    private let DOCUMENT = "documents"
    private let FIELDS = "fields"
    private let NAME = "name"
    private let STRING_VALUE = "stringValue"
    private let INTEGER_VALUE = "integerValue"
    private let DOUBLE_VALUE = "doubleValue"
    private let BOOLEAN_VALUE = "booleanValue"
    private let MAP_VALUE = "mapValue"
    private let ARRAY_VALUE = "arrayValue"
    private let VALUES = "values"
    
    static let shared = CFUtils()
    
    private override init() {
        super.init()
    }
    
    func parseConfigs(data: String?) -> JSON {
        let root = JSON()
        
        guard let data = data, !data.isEmpty else {
            return JSON()
        }
        let firestoreData = JSON(parseJSON: data)
        
        if (firestoreData[DOCUMENT].exists()) {
            let documentArray = firestoreData[DOCUMENT].array
            if (documentArray != nil && documentArray!.count > 0) {
                for i in 0..<documentArray!.count {
                    let documentObject = documentArray![i]
                    let documentName = documentObject[NAME].stringValue.split(separator: "/").last?.description
                    return loopThroughFields(documentString: documentName, documentObject: documentObject, root: root)
                }
            }
        } else {
            // only one document, so directly looping the fields.
            let documentName = firestoreData[NAME].stringValue
            return loopThroughFields(documentString: documentName, documentObject: firestoreData, root: root)
        }
        return root
    }
    
    private func loopThroughFields(documentString: String?, documentObject: JSON, root:JSON?) -> JSON {
        var jsonFields = JSON()
        let fields = documentObject[FIELDS]
        if (fields.count > 0) {
            let fieldNames = fields.dictionaryValue.keys
            for fieldName in fieldNames {
                let field = fields[fieldName].dictionaryValue
                let fieldType = field.keys.first!
                let fieldValue = field[fieldType]!
                setFieldByType(fieldName: fieldName, fieldType: fieldType, data: fieldValue, fieldObject: &jsonFields)
            }
            if let documentString = documentString, !documentString.isEmpty, var root = root {
                root[documentString] = jsonFields
            }
        }
        return jsonFields
    }
    
    private func setFieldByType(fieldName: String, fieldType: String, data: JSON, fieldObject: inout JSON) {
        switch fieldType {
        case STRING_VALUE:
            fieldObject[fieldName].stringValue = data.stringValue
        case INTEGER_VALUE:
            fieldObject[fieldName].int64Value = data.int64Value
        case DOUBLE_VALUE:
            fieldObject[fieldName].doubleValue = data.doubleValue
        case BOOLEAN_VALUE:
            fieldObject[fieldName].boolValue = data.boolValue
        case MAP_VALUE:
            fieldObject[fieldName] = getJsonObject(data: data)
        case ARRAY_VALUE:
            fieldObject[fieldName].arrayObject = getJsonArray(data: data)
        default:
            fieldObject[fieldName].stringValue = data.stringValue
        }
    }
    
    private func getJsonObject(data: JSON) -> JSON {
        return loopThroughFields(documentString: nil, documentObject: data, root: nil)
    }
    
    private func setValuesIntoArray(valueType: String, valueObject: JSON, valueArray: inout [JSON]) {
        switch valueType {
        case STRING_VALUE:
            valueArray.append(valueObject[STRING_VALUE])
        case INTEGER_VALUE:
            valueArray.append(valueObject[INTEGER_VALUE])
        case DOUBLE_VALUE:
            valueArray.append(valueObject[DOUBLE_VALUE])
        case BOOLEAN_VALUE:
            valueArray.append(valueObject[BOOLEAN_VALUE])
        case MAP_VALUE:
            valueArray.append(getJsonObject(data: valueObject[MAP_VALUE]))
        default:
            break
        }
    }
    
    private func getJsonArray(data: JSON) -> [JSON] {
        var valueArray = [JSON]()
        
        if data[VALUES].exists() {
            let dataArray = data[VALUES].arrayValue
            if dataArray.count > 0 {
                for k in 0..<dataArray.count {
                    let valueObject = dataArray[k]
                    let valueTypes = valueObject.dictionaryValue.keys
                    for valueType in valueTypes {
                        setValuesIntoArray(valueType: valueType, valueObject: valueObject, valueArray: &valueArray)
                    }
                }
            }
        }
        return valueArray
    }
}
