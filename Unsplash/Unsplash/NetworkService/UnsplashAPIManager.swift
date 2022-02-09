//
//  NetworkService.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/17.
//

import Foundation
import Alamofire
import RxSwift

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
                                    page: Int) -> Observable<T> {
        
        guard isFetching == false else { return Observable.empty() }
        
        isFetching = true
        
        return Observable.create { observer in
            let request =  self.sessionManager.request(UnsplashRouter.searchPhotos(query: query,
                                                                                   page: page))
                .responseData { responseData in
                    switch responseData.result {
                    case .success(let data):
                        do {
                            let decodedData = try PasingManager.decode(type: type, data: data)
                            observer.onNext(decodedData)
                            observer.onCompleted()
                        } catch (let error) {
                            observer.onError(error)
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
                    self.isFetching = false
                }
            return Disposables.create {
                request.cancel()
            }
        }
        .observe(on: CurrentThreadScheduler.instance)
    }
    
    func fetchAccessToken(accessCode: String) -> Observable<Bool> {
        return Observable.create { observer in
            self.sessionManager.request(UnsplashRouter.fetchAccessToken(accessCode: accessCode)).responseDecodable(of: UnsplashAccessToken.self) { reponseJson in
                guard let token = reponseJson.value else {
                    observer.onNext(false)
                    return
                }
                
                do {
                    try TokenManager.shared.saveAccessToken(unsplashToken: token)
                    observer.onNext(true)
                    observer.onCompleted()
                } catch (let saveError) {
                    observer.onError(saveError)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func photoLike(id: String) -> Observable<PhotoLike> {
        return Observable.create { observer in
            let request = self.sessionManager.request(UnsplashRouter.photoLike(id: id)).responseDecodable(of: PhotoLike.self) { responseJson in
                switch responseJson.result {
                case .success(let decodedPhoto):
                    observer.onNext(decodedPhoto)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    func photoUnlike(id: String) -> Observable<PhotoLike> {
        return Observable.create { observer in
            let request = self.sessionManager.request(UnsplashRouter.photoUnlike(id: id))
                .responseDecodable(of: PhotoLike.self) { responseJson in
                    switch responseJson.result {
                    case .success(let decodedPhoto):
                        observer.onNext(decodedPhoto)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    func fetchUserProfile() -> Observable<Profile> {
        return Observable.create { observer in
            let request = self.sessionManager.request(UnsplashRouter.myProfile)
                .responseDecodable(of: Profile.self) { responseJson in
                    switch responseJson.result {
                    case .success(let profile):
                        observer.onNext(profile)
                        observer.onCompleted()
                    case .failure(let error):
                        debugPrint(error)
                        observer.onError(error)
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    func fetchUserLikePhotos(userName: String, page: Int) -> Observable<([Photo], Int)> {
        guard isFetching == false else { return Observable.empty() }
        
        isFetching = true
        
        return Observable.create { observer in
            let request = self.sessionManager
                .request(UnsplashRouter.userLikePhotos(userName: userName,
                                                       page: page))
            
            request.responseDecodable(of: [Photo].self) { responseData in
                guard let headerValue = request.response?.value(forHTTPHeaderField: "x-total"),
                      let totalPage = Int(headerValue) else { return }
                
                switch responseData.result {
                case .success(let photos):
                    observer.onNext((photos, totalPage))
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
                
                self.isFetching = false
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    func updateProfile(_ profile: UpdateProfile) -> Observable<Profile> {
        let request = sessionManager.request(UnsplashRouter.updateProfile(profile))
        let successStatus = 200...299
        
        return Observable.create { observer in
            request
                .validate(statusCode: successStatus)
                .responseDecodable(of: Profile.self) { response in
                    switch response.result {
                    case .success(let profile):
                        observer.onNext(profile)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
                
            return Disposables.create {
                request.cancel()
            }
        }
    }
}

    
