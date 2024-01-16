//
//  APICaller.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 16/1/2024.
//

import Foundation
final class APICaller{
    static let shared = APICaller()
    private init(){
        
    }
    struct Constants {
        static let baseAPIUrl = "https://api.spotify.com/v1"
    }
    enum APIError : Error {
        case failedToGetData
    }
    //MARK: - Albums
    
    public func getCurrentUserAlbums(completion : @escaping(Result<[Album],Error>)->Void){
        createRequest(with: URL(string: Constants.baseAPIUrl + "/me/albums"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data , error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do{
                    
                   // let json = try JSONSerialization.jsonObject(with: data)
                   // print(json)
                    let result = try JSONDecoder().decode(LibraryAlbumsResponse.self, from: data)
                    completion(.success(result.items.compactMap({$0.album})))
                }catch{
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    public func saveAlbum(album : Album, completion : @escaping(Bool)->Void){
        createRequest(with: URL(string: Constants.baseAPIUrl + "/me/albums?ids=\(album.id)"), type: .PUT) { baseRequest in
            
            var request = baseRequest
            
          
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, response , err in
                
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode, err==nil else{
                    
                    completion(false)
                    return
                }
                
                completion(responseCode == 200)
                
                
              
                
            }
            task.resume()
            
        }
    }
    
    public func getAlbumDetails(for album:Album , completion: @escaping(Result<AlbumDetailsResponse,Error>)->Void){
        createRequest(with: URL(string: Constants.baseAPIUrl+"/albums/"+album.id), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _ , err in
                
                guard let data = data , err==nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(AlbumDetailsResponse.self, from: data)
                    completion(.success(result))
                }catch{
                    completion(.failure(error))
                }
                
            }
            task.resume()
        }
    }
    
    //MARK: - Playlists
    
    public func getCurrentUserPlaylists(completion: @escaping(Result<[Playlist], Error>)->Void){
        createRequest(with: URL(string: Constants.baseAPIUrl + "/me/playlists/?limit=50"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data , error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                    
                }
                do{
                    let result = try JSONDecoder().decode(LibraryPlaylistsResponse.self, from: data)
                    completion(.success(result.items))
                }catch{
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    public func createPlaylist(with name:String,completion : @escaping(Bool)->Void){
        getUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    let urlString = Constants.baseAPIUrl + "/users/\(user.id)/playlists"
                    self?.createRequest(with: URL(string: urlString), type: .POST) { baseRequest in
                        
                        var request = baseRequest
                        let json = [
                            "name":name
                        ]
                        request.httpBody = try? JSONSerialization.data(withJSONObject: json,options: .fragmentsAllowed)
                        let task = URLSession.shared.dataTask(with: request) { data, _, error in
                            guard let data = data , error == nil else {
                                completion(false)
                                return
                            }
                            
                            do{
                                let result = try JSONSerialization.jsonObject(with: data,options: .allowFragments)
                                if let response = result as? [String : Any],response["id"] as? String != nil {
                                    completion(true)

                                }else{
                                    completion(false)
                                }
                            }catch{
                                print(error.localizedDescription)
                                completion(false)
                            }
                        }
                        task.resume()

                    }
                    
                case .failure(let error):
                    break
                }
            }
        }
    }
    
    
    public func addTrackToPlaylist(track : AudioTrack, playlist:Playlist, completion : @escaping(Bool)->Void){
        
        createRequest(with: URL(string: Constants.baseAPIUrl + "/playlists/\(playlist.id)/tracks"), type: .POST) { baseRequest in
            var request = baseRequest
            
            let json = ["uris": ["spotify:track:\(track.id)"]]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json,options: .fragmentsAllowed)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data , error == nil else {
                    completion(false)
                    return
                }
                do{
                    let result = try JSONSerialization.jsonObject(with: data)
                    
                    if let response = result as? [String : Any], response["snapshot_id"]as? String != nil {
                        print("track successfully added to playlist ")
                        completion(true)
                    }else{
                        completion(false)
                    }
                    
                }catch{
                    print(error.localizedDescription)
                    completion(false)
                }
            }
            
            task.resume()
            
        }
        
    }
    
    
    public func removeTrackFromPlaylist(track: AudioTrack,playlist: Playlist, completion : @escaping(Bool)->Void){
        createRequest(with: URL(string: Constants.baseAPIUrl + "/playlists/\(playlist.id)/tracks"), type: .DELETE) { baseRequest in
            var request = baseRequest
            
            let json:[String : Any] = ["tracks": [["uri" : "spotify:track:\(track.id)" ]]]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json,options: .fragmentsAllowed)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data , error == nil else {
                    completion(false)
                    return
                }
                do{
                    let result = try JSONSerialization.jsonObject(with: data)
                    
                    if let response = result as? [String : Any], response["snapshot_id"]as? String != nil {
                        print("track Deleted  from playlist ")
                        completion(true)
                    }else{
                        completion(false)
                    }
                    
                }catch{
                    print(error.localizedDescription)
                    completion(false)
                }
            }
            
            task.resume()
            
        }
    }
    
    public func getPlayListDetails(for playlist:Playlist , completion: @escaping(Result<PlaylistDetailsResponse,Error>)->Void){
        createRequest(with: URL(string: Constants.baseAPIUrl+"/playlists/"+playlist.id), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _ , err in
                
                guard let data = data , err==nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(PlaylistDetailsResponse.self, from: data)
                    //let result = try JSONSerialization.jsonObject(with: data,options: .allowFragments)
                    completion(.success(result))
                }catch{
                    completion(.failure(error))
                }
                
            }
            task.resume()
        }
    }
    
    //MARK: - Profile
    public func getUserProfile(completion:@escaping(Result<UserProfile,Error>)->Void){
        createRequest(with: URL(string: Constants.baseAPIUrl+"/me"), type: HTTPMethod.GET) { baseRequest in
           // print(baseRequest.allHTTPHeaderFields)
            
            let task = URLSession.shared.dataTask(with: baseRequest) { data, responseCode, error in
                

                print("response code : \(responseCode)")
                guard let data = data , error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    print("failed to get data from api caller")
                    return}
                
                
                
                
                do {
                    print("trying calling result ")
                    
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                   // let result = try JSONSerialization.jsonObject(with: data,options: .allowFragments)
                    completion(.success(result))
                }catch {
                    
                    print("error converting json : \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }
    
    //MARK: - Category
    
    func getCategories(completion : @escaping(Result<[Category],Error>)->Void){
        createRequest(with: URL(string: Constants.baseAPIUrl+"/browse/categories?limit=50"), type: .GET) { request in
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data , error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(AllCategoriesResponse.self, from: data)
                    completion(.success(result.categories.items))
                }catch{
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    func getCategoryPlaylists(category:Category, completion : @escaping(Result<[Playlist],Error>)->Void){
        createRequest(with: URL(string: Constants.baseAPIUrl+"/browse/categories/\(category.id)/playlists?limit=50"), type: .GET) { request in
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data , error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(CategoryPlaylistsResponse.self, from: data)
                    completion(.success(result.playlists.items))
                }catch{
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    //MARK: - Search
    
    func search(with query:String , completion:@escaping(Result<[SearchResult],Error>)->Void){
        createRequest(with: URL(string: Constants.baseAPIUrl+"/search?limit=10&type=album,playlist,track,artist&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"), type: .GET) { request in
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                
                guard let data = data , error == nil
                    
                else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do{
                    let result = try JSONDecoder().decode(SearchResultResponse.self, from: data)
                    
                    var searchResults : [SearchResult] = []
                    searchResults.append(contentsOf:result.tracks.items.compactMap({
                        SearchResult.track(model: $0)
                    }))
                    searchResults.append(contentsOf:result.albums.items.compactMap({
                        SearchResult.album(model: $0)
                    }))
                    searchResults.append(contentsOf:result.playlists.items.compactMap({
                        SearchResult.playlist(model: $0)
                    }))
                    searchResults.append(contentsOf:result.artists.items.compactMap({
                        SearchResult.artist(model: $0)
                    }))
                    
                    completion(.success(searchResults))
                    
                }catch{
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    //MARK: - Browse
    
    public func getNewReleases(completion : @escaping(Result<NewReleasesResponse , Error>)->Void){
        createRequest(with: URL(string: Constants.baseAPIUrl+"/browse/new-releases?limit=50"), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data , error==nil else {
                    completion(.failure(APIError.failedToGetData))
                    return}
                do{
                    //let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(NewReleasesResponse.self, from: data)
                   // print(result)
                   // print(json)
                    completion(.success(result))
                }catch{
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }
    
    public func getFeaturedPlaylists(completion : @escaping(Result<FeaturedPlaylistsResponse, Error>)->Void){
        createRequest(with: URL(string: Constants.baseAPIUrl+"/browse/featured-playlists?limit=50"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data , error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return}
                do{
                    let result = try JSONDecoder().decode(FeaturedPlaylistsResponse.self, from: data)
                 //   let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    //print(result)
                    completion(.success(result))
                    
                }catch{
                    completion(.failure(error))
                }
                
            }
            task.resume()
            
        }
    }
    
    public func getRecommendations(genres : Set<String>,completion : @escaping(Result<RecommendationsResponse, Error>)->Void){
        let seeds = genres.joined(separator: ",")
        createRequest(with: URL(string: Constants.baseAPIUrl + "/recommendations?limit=40&seed_genres=\(seeds)"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data , error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return}
                do{
                    let result = try JSONDecoder().decode(RecommendationsResponse.self, from: data)
                    //let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            //    print(result)
                    completion(.success(result))
                    
                }catch{
                    completion(.failure(error))
                }
                
            }
            task.resume()
        }
    }
    
    public func getRecommendedGenres(completion : @escaping(Result<RecommendedGenresResponse, Error>)->Void){
        createRequest(with: URL(string: Constants.baseAPIUrl + "/recommendations/available-genre-seeds"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data , error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return}
                do{
                    let result = try JSONDecoder().decode(RecommendedGenresResponse.self, from: data)
                   // let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
               // print(result)
                    completion(.success(result))
                    
                }catch{
                    completion(.failure(error))
                }
                
            }
            task.resume()
        }
    }
    
    enum HTTPMethod: String {
        case POST
        case GET
        case DELETE
        case PUT
    }
    private func createRequest(with url:URL?,type: HTTPMethod,completion: @escaping(URLRequest)->Void){
        AuthenticationManager.shared.withValidToken { token in
          //  print("token is: \(token)")
            guard let apiUrl = url else {return}
            var request = URLRequest(url: apiUrl)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            
            completion(request)

        }
    }
}
