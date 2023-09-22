//
//  CFUtils.swift
//  CloudflareParse
//
//  Created by Pusuluru Sree Lakshman on 19/09/23.
//

import Foundation
import SwiftyJSON

class CFUtils: NSObject {
    
    let DOCUMENT = "documents"
    let FIELDS = "fields"
    let NAME = "name"
    let STRING_VALUE = "stringValue"
    let INTEGER_VALUE = "integerValue"
    let DOUBLE_VALUE = "doubleValue"
    let BOOLEAN_VALUE = "booleanValue"
    let MAP_VALUE = "mapValue"
    let ARRAY_VALUE = "arrayValue"
    let VALUES = "values"
    let PRDT = "prdt"
    let SYST = "syst"
    let CUST = "cust"
    
    static let shared = CFUtils()
    
    private override init() {
        super.init()
    }
    
    func parseConfigs(data: String?, docType: String) -> JSON {
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
                    //segregate the response based on the document type i.e., syst, cust, prdt
                    switch docType {
                    case SYST:
                        if let docName = documentName, docName == docType {
                            return loopThroughFields(documentString: documentName, documentObject: documentObject, root: root)
                        }
                    case PRDT:
                        if let docName = documentName, docName == docType {
                            return loopThroughFields(documentString: documentName, documentObject: documentObject, root: root)
                        }
                    case CUST:
                        if let docName = documentName, docName == docType {
                            return loopThroughFields(documentString: documentName, documentObject: documentObject, root: root)
                        }
                    default:
                        print("document not found")
                        return root
                    }
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



























//    private func getJsonArray(data: JSON) -> JSON {
//        var valueArray = JSON()
//
//        do {
//            if data[VALUES].exists() {
//                let dataArray = data[VALUES].arrayValue
//                if dataArray.count > 0 {
//                    for valueObject in dataArray {
//                        let valueTypes = Set(valueObject.dictionaryValue.keys)
//                        for valueType in valueTypes {
//                            setValuesIntoArray(valueType: valueType, valueObject: valueObject, valueArray: &valueArray)
//                        }
//                    }
//                }
//            }
//        } catch {
//            print("failed to parse json array")
//        }
//        return valueArray
//    }

//    func parseConfigs(data: String?) -> JSON {
//        var root: JSON? = JSON()
//
//        guard let data = data else {
//            return root!
//        }
//
//        do {
//            let jsonData = try JSON(data: Data(data.utf8))
//
//            if jsonData.isEmpty {
//                return root!
//            }
//
//            if jsonData[DOCUMENT].exists() {
//                let documentArray = jsonData[DOCUMENT].arrayValue
//                if documentArray.count > 0 {
//                    // Multiple documents available and so traversing each document.
//                    for documentObject in documentArray {
//                        if let documentName = documentObject[NAME].string?.split(separator: "/").last {
//                            root = loopThroughFields(documentString: String(documentName), documentObject: documentObject, root: root)
//                        }
//                    }
//                }
//            } else {
//                // Only one document, so directly looping the fields.
//                if let documentName = jsonData[NAME].string?.split(separator: "/").last {
//                    root = loopThroughFields(documentString: String(documentName), documentObject: jsonData, root: root)
//                }
//            }
//        } catch {
//            print("failed parsing response")
//        }
//
//        return root!
//    }
//----------------------
//func parseConfigs(data: String?) -> JSON {
//    let root = JSON()
//    guard let data = data, !data.isEmpty else {
//        return JSON()
//    }
//    let firestoreData = JSON(parseJSON: data)
//    if (firestoreData[DOCUMENT].exists()) {
//        let documentArray = firestoreData[DOCUMENT].array
//        if (documentArray != nil && documentArray!.count > 0) {
//            for i in 0..<documentArray!.count {
//                let documentObject = documentArray![i]
//                let documentName = documentObject[NAME].stringValue.split(separator: "/").last
//            }
//        }
//    } else {
//        // only one document, so directly looping the fields.
//        let documentName = firestoreData[NAME].stringValue.split(separator: "/").last
//    }
//
//    return root
//}
//
//func loopThroughFields(documentString: String?, documentObject: JSON, root: JSON?) -> JSON {
//    let jsonFields = JSON()
//    let fields = documentObject[FIELDS]
//    if (fields != nil && fields.count > 0) {
//        let fieldNames = fields.dictionaryValue.keys
//        for fieldName in fieldNames {
//            let field = fields[fieldName].dictionaryValue
//            let fieldType = field.keys.first!
//            let fieldValue = field[fieldType]!
//        }
//        if let documentString = documentString, !documentString.isEmpty, var root = root {
//            root[documentString] = jsonFields
//        }
//
//    }
//    return jsonFields
//}
//
//func setFieldByType(fieldName: String, fieldType: String, data: JSON, fieldObject: JSON) {
//    var updateFieldObject = fieldObject
//    switch(fieldType) {
//    case STRING_VALUE:
//        updateFieldObject[fieldName].stringValue = data.stringValue
//    case INTEGER_VALUE:
//        updateFieldObject[fieldName].int = data.int
//    case DOUBLE_VALUE:
//        updateFieldObject[fieldName].doubleValue = data.doubleValue
//    case BOOLEAN_VALUE:
//        updateFieldObject[fieldName].boolValue = data.boolValue
//    case MAP_VALUE:
//        updateFieldObject[fieldName] = JSON(getJsonObject(data: data))
//    case ARRAY_VALUE:
//        updateFieldObject[fieldName] =
//    default:
//
//    }
//}
//
//func getJsonObject(data: JSON) -> JSON {
//    return loopThroughFields(documentString: nil, documentObject: data, root: nil)
//}
//
//func setValuesIntoArray(valueType: String, valueObject: JSON, valueArray: inout [Any]) {
//    switch valueType {
//    case STRING_VALUE:
//        if let stringValue = valueObject[STRING_VALUE].string {
//            valueArray.append(stringValue)
//        }
//    case INTEGER_VALUE:
//        if let intValue = valueObject[INTEGER_VALUE].int {
//            valueArray.append(intValue)
//        }
//    case DOUBLE_VALUE:
//        if let doubleValue = valueObject[DOUBLE_VALUE].double {
//            valueArray.append(doubleValue)
//        }
//    case BOOLEAN_VALUE:
//        if let boolValue = valueObject[BOOLEAN_VALUE].bool {
//            valueArray.append(boolValue)
//        }
//    case MAP_VALUE:
//        if let jsonObject = valueObject[MAP_VALUE].dictionaryObject {
//            let mappedValue = getJsonObject(data: jsonObject)
//            valueArray.append(mappedValue)
//        }
//    default:
//        break
//    }
//}
//
//func getJsonArray(data: JSON) -> JSON {
//    return JSON()
//}
//----------------------------------------------------------
//func parseConfigs(data: String?, docType: String) -> JSON {
//    var root = JSON()
//    guard let data = data, !data.isEmpty else {
//        return JSON()
//    }
//    let firestoreData = JSON(parseJSON: data)
//
//    if (firestoreData[DOCUMENT].exists()) {
//        let documentArray = firestoreData[DOCUMENT].array
//        if (documentArray != nil && documentArray!.count > 0) {
//            for i in 0..<documentArray!.count {
//                let documentObject = documentArray![i]
//                let documentName = documentObject[NAME].stringValue.split(separator: "/").last?.description
//                switch docType {
//                case SYST:
//                    if let docName = documentName, documentObject[docName].exists() {
//                        return loopThroughFields(documentString: documentName, documentObject: documentObject, root: root)
//                    }
//                case PRDT:
//                    if let docName = documentName, documentObject[docName].exists() {
//                        return loopThroughFields(documentString: documentName, documentObject: documentObject, root: root)
//                    }
//                case CUST:
//                    if let docName = documentName, documentObject[docName].exists() {
//                        return loopThroughFields(documentString: documentName, documentObject: documentObject, root: root)
//                    }
//                default:
//                    return root
//
//                }
//            }
//        }
//    } else {
//        // only one document, so directly looping the fields.
//        let documentName = firestoreData[NAME].stringValue
//        return loopThroughFields(documentString: documentName, documentObject: firestoreData, root: root)
//    }
//    return root
//}
//--------------------------

