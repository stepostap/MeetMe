//
//  PhotoGalleryVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 07.04.2022.
//

import UIKit
import PhotosUI

private let reuseIdentifier = "Cell"

class PhotoGalleryVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, PHPickerViewControllerDelegate {
    
    var photoURLs = [String]()
    var meeting: Meeting!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        self.collectionView.register(PhotoCollectionFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        //photoURLs.append(contentsOf: ["","","","","","",""])
        
        self.title = meeting.name
        
        let viewMeetingInfoButton = UIBarButtonItem(title: "О событии", style: .plain, target: self, action: #selector(showMeetingInfo))
        navigationItem.rightBarButtonItem = viewMeetingInfoButton
        // Do any additional setup after loading the view.
    }
    
  
    override func viewWillAppear(_ animated: Bool) {
        downloadPhotos()
    }
    
    
    @objc func showMeetingInfo() {
        let vc = MeetingInfoVC()
        vc.meeting = meeting
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func downloadPhotos() {
        ImageStoreRequests.shared.getImageLinks(meetingID: meeting.id, completion: getLinks(links:error:))
    }
    
    func getLinks(links: [String]?, error: Error?) {
        if let error = error {
            let alert = ErrorChecker.handler.getAlertController(error: error)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if let links = links {
            self.photoURLs = links
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: IndexPath(item: links.count - 1, section: 0), at: .bottom, animated: false)
        }
    }
    
    
    @objc func uploadPhotos() {
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
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoURLs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        cell.imageURL = URL(string: photoURLs[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 30) / 3 // In this example the width is the same as the whole view.
        return CGSize(width: width, height: width)
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
}
