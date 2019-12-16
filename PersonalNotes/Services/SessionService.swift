//
//  SessionService.swift
//  PersonalNotes
//
//  Created by maredlu1 on 16/12/2019.
//  Copyright © 2019 HomeWork. All rights reserved.
//

import UIKit

class SessionService: NSObject {
    static var global = SessionService()
    var session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
    var sessionDataTasks: [URL: URLSessionTask] = [:]
    
    func sendRequest(url: URL, httpMethod: String, httpBody: Data?, completionHandler: @escaping ((Data?, Error?, URLResponse?) -> Void)) {
        guard sessionDataTasks[url] == nil else {
            completionHandler(nil, NSError(domain: "SessionService", code: -1, userInfo: ["error":"Same request already running"]), nil)
            return
        }
        
        let request = NSMutableURLRequest(url: url)
        request.addValue("application/json;odata=verbose", forHTTPHeaderField: "Accept")
        request.httpMethod = httpMethod
        request.httpBody = httpBody
        
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            SessionService.global.sessionDataTasks[url] = nil
            completionHandler(data, error, response)
        }
        
        sessionDataTasks[url] = dataTask
        dataTask.resume()
    }
}

extension SessionService: URLSessionDelegate, URLSessionTaskDelegate {
    //in case of Authentication
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
    }
}
