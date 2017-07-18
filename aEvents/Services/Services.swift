//
//  Services.swift
//  aEvents
//
//  Created by Dang Duc Nam on 2/3/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum Result<T> {
    case success(T)
    case failure(Error)
}

enum ServicesError: Error {
    case failed
}

struct Services {
    static let server: String = Bundle.main.infoDictionary!["EndpointURL"] as! String
    fileprivate enum Path: String {
        case upcoming = "/api/event/upcoming/"
        case event = "/api/event/"
        case login = "/auth/login"
        case register = "/api/users"
        case facebook = "/api/social/fb"
        case google = "/api/social/gg-ios"
        case userInfo = "/api/users/info"
        case updateJoin = "/api/users/update-join"
        case updateProfile = "/api/users/update"
        case joinEvent = "/api/enrollments/join"
        case enrollments = "/api/enrollments/"
        case upcomingTicket = "/api/enrollments/up-coming/"
        case passedTicket = "/api/enrollments/passing/"
        case myEventIds = "/api/event/id"
        case getUserFeedback = "/api/feedback/"
        case sendFeedback = "/api/feedback"
    }
    
    static func events(limit: Int, completion: @escaping (Result<[Event]>) -> Void) {
        Alamofire.request("\(Services.server)\(Path.upcoming.rawValue)\(limit)").responseJSON { responseData in
            guard let value = responseData.result.value, let eventsArray = JSON(value).arrayObject as? [[String: AnyObject]] else {
                completion(.failure(ServicesError.failed))
                return
            }
            
            let events = eventsArray.map {(event:[String:AnyObject]) -> Event in Event(dictionary: event) }
            completion(.success(events))
        }
    }
    
    static func events(latitude: Double, longitude: Double, limit: Int, completion: @escaping (Result<[Event]>) -> Void) {
        Alamofire.request("\(Services.server)\(Path.event.rawValue)\(latitude)/\(longitude)/\(limit)").responseJSON { responseData in
            guard let value = responseData.result.value, let eventsArray = JSON(value).arrayObject as? [[String: AnyObject]] else {
                completion(.failure(ServicesError.failed))
                return
            }
            
            let events = eventsArray.map {(event:[String:AnyObject]) -> Event in Event(dictionary: event) }
            completion(.success(events))
        }
    }
    
    static func event(eventID: Int, completion: @escaping (Result<Event>) -> Void) {
        Alamofire.request("\(Services.server)\(Path.event.rawValue)\(eventID)").responseJSON { responseData in
            guard let value = responseData.result.value, let event = JSON(value).object as? [String:AnyObject] else {
                completion(.failure(ServicesError.failed))
                return
            }
            completion(.success(Event(dictionary: event)))
        }
    }
    
    static func eventTopic(eventID: Int, completion: @escaping (Result<[Topic]>) -> Void) {
        Alamofire.request("\(Services.server)\(Path.event.rawValue)\(eventID)/topic").responseJSON { responseData in
            guard let value = responseData.result.value, let eventTopic = JSON(value).arrayObject as? [[String: AnyObject]] else {
                completion(.failure(ServicesError.failed))
                return
            }
            let topics = eventTopic.map {(topic:[String:AnyObject]) -> Topic in Topic(dictionary: topic) }
            completion(.success(topics))
        }
    }
    
    static func login(email: String, password: String, completion: @escaping (Result<String>) -> Void) {
        let headers = [
            "device" : "mobile"
        ]
        
        let parameters = [
            "email": email,
            "password": password
        ]
        Alamofire.request("\(Services.server)\(Path.login.rawValue)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON {
            responseData in
            guard let value = responseData.result.value, let result = JSON(value).object as? [String: AnyObject] else {
                completion(.failure(ServicesError.failed))
                return
            }
            let token: String = (result["token"] as? String) ?? ""
            completion(.success(token))
        }
    }
        
    static func socialLogin(token: String, type: Int, completion: @escaping (Result<String>) -> Void) {
        let headers = [
            "device" : "mobile"
        ]
        
        let parameters = [
            "accessToken": token
        ]
        
        let path: String = (type == 0) ? Path.facebook.rawValue : Path.google.rawValue
        
        Alamofire.request("\(Services.server)\(path)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON {
            responseData in
            guard let value = responseData.result.value, let result = JSON(value).object as? [String: AnyObject] else {
                completion(.failure(ServicesError.failed))
                return
            }
            let token: String = (result["token"] as? String) ?? ""
            completion(.success(token))
        }
    }
    
    static func register(fullName: String, email: String, password: String, completion: @escaping (Result<String>) -> Void) {
        let parameters = [
            "fullName" : fullName,
            "email" : email,
            "password" : password,
            "rePassword" : password
        ]
        
        Alamofire.request("\(Services.server)\(Path.register.rawValue)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON {responseData in
            guard let value = responseData.result.value, let result = JSON(value).object as? [String: AnyObject] else {
                completion(.failure(ServicesError.failed))
                return
            }
            print(value)
            let token: String = (result["token"] as? String) ?? ""
            completion(.success(token))
            
        }
    }
    
    static func getUserInfo(token: String, completion: @escaping (Result<User>) -> Void) {
        let headers = [
            "Authorization" : token
        ]
                
        Alamofire.request("\(Services.server)\(Path.userInfo.rawValue)", headers: headers).responseJSON {
            responseData in
            guard let value = responseData.result.value, let user = JSON(value).object as? [String: AnyObject] else {
                completion(.failure(ServicesError.failed))
                return
            }
            completion(.success(User(dictionary: user)))
        }
    }
    
    static func checkJoin(eventId: Int, token: String, completion: @escaping (Result<Int>) -> Void) {
        let headers = [
            "Authorization" : token
        ]
        
        Alamofire.request("\(Services.server)\(Path.event.rawValue)\(eventId)/check-join", headers: headers).responseJSON {
            responseData in
            guard let value = responseData.result.value, let type:Int = value as? Int else {
                completion(.failure(ServicesError.failed))
                return
            }
            completion(.success(type))
        }
    }

    
    static func joinEvent(eventId: Int, userId: Int, token: String, completion: @escaping (Result<String>) -> Void) {
        let headers = [
            "Authorization" : token
        ]
        
        let params = [
            "event" : eventId,
            "user" : userId
        ]
        
        Alamofire.request("\(Services.server)\(Path.joinEvent.rawValue)", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON {
            responseData in
            guard (responseData.result.value != nil) else {
                completion(.failure(ServicesError.failed))
                return
            }
            completion(.success("OK"))
        }
    }
    
    static func updateUser(user: User, token: String, completion: @escaping (Result<User>) -> Void) {
        let headers = [
            "Authorization" : token
        ]
        
        let params = [
            "id" : user.id,
            "fullName" : user.fullName,
            "gender" : user.gender,
            "rangeAge" : user.rangeAge,
            "email" : user.email,
            "phone": user.phone,
            "job": user.job,
            "company": user.company
        ] as [String : Any]
                
        Alamofire.request("\(Services.server)\(Path.updateJoin.rawValue)", method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON {
            responseData in
            guard let value = responseData.result.value, let user = JSON(value).object as? [String: AnyObject] else {
                completion(.failure(ServicesError.failed))
                return
            }
            completion(.success(User(dictionary: user)))
        }
    }
    
    static func updateProfile(user: User, image: UIImage?, token: String, completion: @escaping (Result<User>) -> Void) {
        let headers = [
            "Authorization" : token,
        ]
        
        let paramsProfile = [
            "id" : user.id,
            "fullName" : user.fullName,
            "gender" : user.gender,
            "birthday" : user.birthday,
            "email" : user.email,
            "phone": user.phone,
            "job": user.job,
            "address": user.address,
            "company": user.company
        ] as [String : Any]
        
        let paramsJSON = JSON(paramsProfile)
        let paramsStringProfile = paramsJSON.rawString()
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(paramsStringProfile!.data(using: .utf8)!, withName: "profile")
                if(image != nil){
                    multipartFormData.append(UIImageJPEGRepresentation(image!, 0.5)!, withName: "avatar", fileName: "picture.png", mimeType: "image/png")
                }
            },
            to: "\(Services.server)\(Path.updateProfile.rawValue)",
            method: .put,
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                         guard let value = response.result.value, let user = JSON(value).object as? [String: AnyObject] else {
                             completion(.failure(ServicesError.failed))
                         return
                         }
                         completion(.success(User(dictionary: user)))
                    }
                    upload.uploadProgress { progress in

                    }
                case .failure(_):
                    completion(.failure(ServicesError.failed))
                }
            }
        )
    }
    
    static func getQRCode(eventId: Int, userId: Int, token: String, completion: @escaping (Result<User>) -> Void) {
        let headers = [
            "Authorization" : token
        ]
        
        Alamofire.request("\(Services.server)\(Path.enrollments.rawValue)\(eventId)/qrcode", headers: headers).responseJSON {
            responseData in
            guard let value = responseData.result.value, let user = JSON(value).object as? [String: AnyObject] else {
                completion(.failure(ServicesError.failed))
                return
            }
            completion(.success(User(dictionary: user)))
        }
    
    }
    
    static func getUpcomingTicket(limit: Int, token: String, completion: @escaping (Result<[Enrollment]>) -> Void) {
        let headers = [
            "Authorization" : token
        ]
        
        Alamofire.request("\(Services.server)\(Path.upcomingTicket.rawValue)\(limit)", headers: headers).responseJSON { responseData in
            guard let value = responseData.result.value, let enrollmentsArray = JSON(value).arrayObject as? [[String: AnyObject]] else {
                completion(.failure(ServicesError.failed))
                return
            }
            
            UserDefaults.standard.setValue(value, forKey: "LiveTicket")
            UserDefaults.standard.synchronize()
            
            let enrollments = enrollmentsArray.map {(enrollment:[String:AnyObject]) -> Enrollment in Enrollment(dictionary: enrollment) }
            completion(.success(enrollments))
        }
    }
    
    static func getExpiredTicket(limit: Int, token: String, completion: @escaping (Result<[Enrollment]>) -> Void) {
        let headers = [
            "Authorization" : token
        ]
        
        Alamofire.request("\(Services.server)\(Path.passedTicket.rawValue)\(limit)", headers: headers).responseJSON { responseData in
            guard let value = responseData.result.value, let enrollmentsArray = JSON(value).arrayObject as? [[String: AnyObject]] else {
                completion(.failure(ServicesError.failed))
                return
            }
            
            UserDefaults.standard.setValue(value, forKey: "PassTicket")
            UserDefaults.standard.synchronize()
                        
            let enrollments = enrollmentsArray.map {(enrollment:[String:AnyObject]) -> Enrollment in Enrollment(dictionary: enrollment) }
            completion(.success(enrollments))
        }
    }
    
    static func getEventIds(token: String, completion: @escaping (Result<[Int]>) -> Void) {
        let headers = [
            "Authorization" : token
        ]
        
        Alamofire.request("\(Services.server)\(Path.myEventIds.rawValue)", headers: headers).responseJSON { responseData in
            guard let value = responseData.result.value, let eventIdArray = JSON(value).arrayObject as? [Int] else {
                completion(.failure(ServicesError.failed))
                return
            }
            let events = eventIdArray
            completion(.success(events))
        }
    }
    
    static func getFeedbackByUser(token: String, num: Int, completion: @escaping (Result<[Feedback]>) -> Void) {
        let headers = [
            "Authorization" : token
        ]
        
        Alamofire.request("\(Services.server)\(Path.getUserFeedback.rawValue)\(num)", headers: headers).responseJSON { responseData in
            guard let value = responseData.result.value, let feedbacksArray = JSON(value).arrayObject as? [[String: AnyObject]] else {
                completion(.failure(ServicesError.failed))
                return
            }
            
            let feedbacks = feedbacksArray.map {(fb:[String:AnyObject]) -> Feedback in Feedback(dictionary: fb) }
            completion(.success(feedbacks))
        }
    }
    
    static func sendFeedback(token: String, content: String, completion: @escaping (Result<Feedback>) -> Void) {
        let headers = [
            "Authorization" : token
        ]
        let parameters = [
            "content" : content,
            ] as [String : Any]
        
        Alamofire.request("\(Services.server)\(Path.sendFeedback.rawValue)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { responseData in
            guard let value = responseData.result.value, let arrayFb = JSON(value).object as? [String: AnyObject] else {
                completion(.failure(ServicesError.failed))
                return
            }
            completion(.success(Feedback(dictionary: arrayFb)))
            
        }
    }

}
