//
//  NetworkService.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/17.
//

import Foundation
import Alamofire

final class UnsplashAPIManager {
    //MARK: Properties
    private var isFetching = false
    private let sessionManager: Session = {
        let interceptor = UnsplashInterceptor()
        let session = Session(interceptor: interceptor)
        
        return session
    }()
}

//MARK: - Method
extension UnsplashAPIManager {
    func searchPhotos<T: Decodable>(type: T.Type,
                                    query: String,
                                    page: Int,
                                    completion: @escaping (Result<T, Error>) -> Void) {
        
        guard isFetching == false else { return }
        
        self.isFetching = true
        sessionManager.request(UnsplashRouter.searchPhotos(query: query, page: page))
            .responseData { responseData in
                
                self.isFetching = false
                switch responseData.result {
                case .success(let data):
                    do {
                        let decodedData = try PasingManager.decode(type: type, data: data)
                        completion(.success(decodedData))
                    } catch (let error) {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func fetchAccessToken(accessCode: String, completion: @escaping (Bool) -> Void) {
        sessionManager.request(UnsplashRouter.fetchAccessToken(accessCode: accessCode)).responseDecodable(of: UnsplashAccessToken.self) { reponseJson in
            guard let token = reponseJson.value else { return completion(false) }
            
            do {
                try TokenManager.shared.saveAccessToken(unsplashToken: token)
                completion(true)
            } catch {
                completion(false)
            }
        }
    }
    
    func photoLike(id: String, completion: @escaping (Result<PhotoLike, Error>) -> Void) {
        sessionManager.request(UnsplashRouter.photoLike(id: id))
            .responseDecodable(of: PhotoLike.self) { responseJson in
                switch responseJson.result {
                case .success(let decodedPhoto):
                    completion(.success(decodedPhoto))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func photoUnlike(id: String, completion: @escaping (Result<PhotoLike, Error>) -> Void) {
        sessionManager.request(UnsplashRouter.photoUnlike(id: id))
            .responseDecodable(of: PhotoLike.self) { responseJson in
                switch responseJson.result {
                case .success(let decodedPhoto):
                    completion(.success(decodedPhoto))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func fetchUserProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        sessionManager.request(UnsplashRouter.myProfile)
            .responseDecodable(of: Profile.self) { responseJson in
                switch responseJson.result {
                case .success(let profile):
                    completion(.success(profile))
                case .failure(let error):
                    debugPrint(error)
                    completion(.failure(error))
                }
            }
    }
    
    func fetchUserLikePhotos(userName: String,
                             page: Int,
                             completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard isFetching == false else { return }
        
        self.isFetching = true
        sessionManager.request(UnsplashRouter.listUserLike(userName: userName, page: page))
            .responseDecodable(of: [Photo].self) { responseData in
                
                self.isFetching = false
                switch responseData.result {
                case .success(let photos):
                    completion(.success(photos))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
