//
//  AuthManager.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 16/1/2024.
//

import Foundation
class AuthenticationManager {
    private var refreshingToken = false
    struct Constants {
        static let clientID = "f438fbf858f84f168b1889e7d704512f"
        static let secretID = "1b6d9b63bf3f48bd932c535928ef0568"
        static let tokenApiURL = "https://accounts.spotify.com/api/token"
       static let redirectURI = "https://beta-developer.spotify.com"
        static let scopes = "user-read-private%20user-read-email%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read"

    }
    
    public var signInURL:URL? {
        
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=true"
        return URL(string: string)
    }
    
   static let shared  = AuthenticationManager()
    
    private init(){
        
    }
    var isSignedIn: Bool {
        return accessToken != nil
    }
    private var accessToken : String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    private var refreshToken : String? {
        return  UserDefaults.standard.string(forKey: "refresh_token")
    }
    private var tokenExpirationDate : Date? {
        return UserDefaults.standard.object(forKey: "ExpirationDate") as? Date
    }
    var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else {return false}
        let currentDate = Date()
        let fiveMinutes:TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    public func exchangeCodeForToken(code:String, completion:@escaping(Bool)->Void){
        //get token
        let basicToken = Constants.clientID+":"+Constants.secretID
        let data = basicToken.data(using: .utf8)
        guard  let base64String = data?.base64EncodedString() else {
            print("Failure to get base64 string")
            completion(false)
            return
        }
        guard let url = URL(string: Constants.tokenApiURL) else {return}
        var component = URLComponents()
        component.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI)
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        request.httpBody = component.query?.data(using: .utf8)
       let task =  URLSession.shared.dataTask(with: request) { [weak self ] data, _, err in
            guard let data = data , err == nil else {
                completion(false)
                return}
           do{
               // let json = try JSONSerialization.jsonObject(with: data,options: .allowFragments)

               let result = try JSONDecoder().decode(AuthResponse.self, from: data)
               self?.cacheToken(result: result)
              
               completion(true)
           }catch{
               print(error.localizedDescription)
               completion(false)
           }
        }
       
        task.resume()
    }
    
    private var onRefreshBlocks = [((String)->Void)]()
    
    public func withValidToken(completion:@escaping(String)->Void){
     
        guard !refreshingToken else {
            //append the completion once the execution completed
            onRefreshBlocks.append(completion)
            return
        }
        if shouldRefreshToken{
            refreshIfNeeded { [weak self] success in
             
                    if let token = self?.accessToken,success {
                        completion(token)
                    
                }
            }
            
        }else if let token = accessToken{
            completion(token)
        }
    }
    
    public func refreshIfNeeded(completion: ((Bool)->Void)?){
        
        guard !refreshingToken else {
           return
        }
        guard shouldRefreshToken else {
           completion?(true)
            return}
        guard let refreshToken = self.refreshToken else {return}
        //refresh the token
        
        let basicToken = Constants.clientID+":"+Constants.secretID
        let data = basicToken.data(using: .utf8)
        guard  let base64String = data?.base64EncodedString() else {
            print("Failure to get base64 string")
            completion?(false)
            return
        }
        guard let url = URL(string: Constants.tokenApiURL) else {return}
        
        refreshingToken = true
        var component = URLComponents()
        component.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        request.httpBody = component.query?.data(using: .utf8)
       let task =  URLSession.shared.dataTask(with: request) { [weak self ] data, _, err in
           self?.refreshingToken = false
            guard let data = data , err == nil else {
                completion?(false)
                return}
           do{
                let json = try JSONSerialization.jsonObject(with: data,options: .allowFragments)
               print(json)

               let result = try JSONDecoder().decode(AuthResponse.self, from: data)
               print("successfully refreshing token")
               self?.onRefreshBlocks.forEach{$0(result.access_token)}
               self?.onRefreshBlocks.removeAll()
               self?.cacheToken(result: result)
              
               completion?(true)
           }catch{
               print(error.localizedDescription)
               completion?(false)
           }
        }
       
        task.resume()
        
    }
    private func cacheToken(result : AuthResponse){
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refreshtoken = result.refresh_token {
            UserDefaults.standard.setValue(refreshtoken, forKey: "refresh_token")

        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "ExpirationDate")
    }
    
    public func signOut(completion : (Bool)->Void){
        UserDefaults.standard.setValue(nil, forKey: "access_token")
        
        UserDefaults.standard.setValue(nil, forKey: "refresh_token")
        
        
        UserDefaults.standard.setValue(nil, forKey: "ExpirationDate")
        
        completion(true)
    }
}
