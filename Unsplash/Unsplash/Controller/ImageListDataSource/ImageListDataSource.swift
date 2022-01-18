//
//  ImageListDataSource.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/22.
//

import Foundation
import UIKit

//MARK: Delegate
protocol ImageListDataSourceDelegate: AnyObject {
    func morePhotos()
    func didTapedLikeButton(photoId: String)
}

final class ImageListDataSource: NSObject {
    //MARK: Properties
    weak var delegate: ImageListDataSourceDelegate?
    private var photos: [Photo] = []
}


//MARK: - Configure Method
extension ImageListDataSource {
    func configure(_ photos: [Photo]) {
        self.photos = photos
    }
}

//MARK: - UITableView DataSource
extension ImageListDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageListTableViewCell.cellID,
                                                       for: indexPath) as? ImageListTableViewCell else {
            return UITableViewCell()
        }
        
        let photo = photos[indexPath.row]
        
        cell.delegate = self
        cell.configure(id: photo.id,
                       photographerName: photo.profile.userName,
                       likeCount: String(photo.likes),
                       isUserLike: photo.isUserLike,
                       imageUrl: photo.urls.regularURL)
        
        return cell
    }
}

//MARK: - Search TableView Cell Delegate(Like Button Tap)
extension ImageListDataSource: ImageListTableViewCellDelegate {
    func didTapedLikeButton(_ id: String) {
        delegate?.didTapedLikeButton(photoId: id)
    }
}

//MARK: - UITableView Delegate
extension ImageListDataSource: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let yOffset = scrollView.contentOffset.y
        let heightRemainBottomHeight = contentHeight - yOffset
        
        let frameHeight = scrollView.frame.size.height
        
        if heightRemainBottomHeight < frameHeight && photos.isEmpty == false  {
            delegate?.morePhotos()
        }
    }
}
