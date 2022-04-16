//
//  PhotoGalleryVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 07.04.2022.
//

import UIKit
import PhotosUI
import SwiftPhotoGallery
import Kingfisher

/// Контроллер, отвечающий за загрузку и отображение фотографий для посещенного пользователем мероприятия
class PhotoGalleryVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, PHPickerViewControllerDelegate, SwiftPhotoGalleryDataSource, SwiftPhotoGalleryDelegate {
    /// URL  фотографий
    private var loadedPhotoURLs = [String]()
    /// Мероприятия, фотографии которого отображаются
    var meeting: Meeting!
    /// Ширина одного изображения на экране
    private let imageWidth = (UIScreen.main.bounds.width - 20) / 2
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        self.collectionView.register(PhotoCollectionFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")

        self.title = meeting.name
        
        let viewMeetingInfoButton = UIBarButtonItem(title: "О событии", style: .plain, target: self, action: #selector(showMeetingInfo))
        navigationItem.rightBarButtonItem = viewMeetingInfoButton
        // Do any additional setup after loading the view.
    }
    
  
    override func viewWillAppear(_ animated: Bool) {
        downloadPhotos()
    }
    
    /// Переход на MeetingInfoVC, отобрающий информацию о текущем мероприятии
    @objc func showMeetingInfo() {
        let vc = MeetingInfoVC()
        vc.meeting = meeting
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Получение изображения из кэша
    private func getSingleImage(with urlString : String) -> UIImage? {
        guard let url = URL.init(string: urlString) else {
            return  nil
        }
        let resource = ImageResource(downloadURL: url)
        var image:  UIImage?
        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
            switch result {
            case .success(let value):
                image = value.image
            case .failure:
                image = nil
            }
        }
        return image
    }
    
    /// Отправка запроса на получение ссылок на изображения
    private func downloadPhotos() {
        ImageStoreRequests.shared.getImageLinks(meetingID: meeting.id, completion: getLinks(links:error:))
    }
    
    /// Обработка данных с массивом ссылок или кодом ошибки, полученных от сервера
    private func getLinks(links: [String]?, error: Error?) {
        if let error = error {
            let alert = ErrorChecker.handler.getAlertController(error: error)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if let links = links {
            self.loadedPhotoURLs = links
            self.collectionView.reloadData()
        }
    }
    
    /// Загрузка новых фотографий 
    @objc private func uploadPhotos() {
        var configuration = PHPickerConfiguration()
        configuration.filter = PHPickerFilter.images
        configuration.selectionLimit = 10
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        results.forEach {
            $0.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let image = image as? UIImage {
                    ImageStoreRequests.shared.uploadImage(meetingID: self.meeting.id, image: image, completion: self.getLinks(links:error:))
                }
            }
        }
    }
    
    // MARK: Image Gallery
    func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
        return loadedPhotoURLs.count
    }
    
    func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
        if let image = getSingleImage(with: loadedPhotoURLs[forIndex]) {
            return image
        } else {
            return UIImage(named: "placeholder")
        }
    }
    
    func galleryDidTapToClose(gallery: SwiftPhotoGallery) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loadedPhotoURLs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        cell.configure()
        cell.image.kf.indicatorType = .activity
        
        cell.image.kf.setImage(with: URL(string: self.loadedPhotoURLs[indexPath.row]), options: [.processor(DownsamplingImageProcessor(size: CGSize(width: imageWidth, height: imageWidth))), .scaleFactor(UIScreen.main.scale), .cacheOriginalImage])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: imageWidth, height: imageWidth)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath) as! PhotoCollectionFooter
            footer.addButton.addTarget(self, action: #selector(uploadPhotos), for: .touchUpInside)
        //}
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 20, height: 40)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
        
        gallery.backgroundColor = UIColor.black
        
        gallery.pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.5)
        gallery.currentPageIndicatorTintColor = UIColor.white
        gallery.hidePageControl = false
        present(gallery, animated: true, completion: { () -> Void in
            gallery.currentPage = indexPath.row
        })
    }
}
