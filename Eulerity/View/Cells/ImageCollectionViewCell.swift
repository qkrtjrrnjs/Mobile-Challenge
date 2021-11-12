//
//  ImageCollectionViewCell.swift
//  Eulerity
//
//  Created by Chris Park on 11/10/21.
//

import UIKit

var cachedImages = NSCache<AnyObject, ImageCache>()

class ImageCollectionViewCell: UICollectionViewCell {
    static let identifier = "ImageCollectionViewCell"
    private var task: URLSessionDataTask?

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private let shadowView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 4
        view.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(shadowView)
        shadowView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
        shadowView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configure(with urlString: String) {
        guard let url = URL(string: urlString) else {
            assertionFailure("Invalid URL")
            return
        }
    
        if let cachedImage = cachedImages.object(forKey: urlString as AnyObject) {
            self.imageView.image = cachedImage.image
            return
        }
                
        task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                assertionFailure("Failed to retrieve data")
                return
            }
        
            let imageCache = ImageCache()
            imageCache.image = image
            cachedImages.setObject(imageCache, forKey: urlString as AnyObject)
            
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
        task?.resume()
    }
}
