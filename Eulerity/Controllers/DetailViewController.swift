//
//  DetailViewController.swift
//  Eulerity
//
//  Created by Chris Park on 11/10/21.
//

import CoreGraphics
import UIKit

class DetailViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentMode = .scaleAspectFit
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isUserInteractionEnabled = true
        scrollView.backgroundColor = .white
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.zoomScale = 1
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(scale: .large)
        button.setImage(UIImage(systemName: "camera.filters", withConfiguration: configuration)?.withTintColor(.systemBlue), for: .normal)
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let overlayTextButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(scale: .large)
        button.setImage(UIImage(systemName: "character.textbox", withConfiguration: configuration)?.withTintColor(.systemBlue), for: .normal)
        button.addTarget(self, action: #selector(overlayTextButtonTapped), for: .touchUpInside)
        return button
    }()
        
    private let stackView = UIStackView()
    private let networkManager: NetworkManagerProtocol

    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    var imageURLString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpConstraints()
    }
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        scrollView.delegate = self
        view.addSubview(stackView)
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        stackView.addArrangedSubview(overlayTextButton)
        stackView.addArrangedSubview(filterButton)
            
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.distribution = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing = 40
                
        // Add edit button to nav bar
        let rightBarButton = UIBarButtonItem(customView: saveButton)
        navigationItem.rightBarButtonItem = rightBarButton
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        dismissKeyboard()
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 70),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stackView.topAnchor),
            
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1),
        ])
    }
    
    private func setFilter(action: UIAlertAction) {
        let filteredImage = image?.addFilter(filterString: action.title)
        imageView.image = filteredImage
        image = filteredImage
    }
    
    private func getEditedImage() -> UIImage? {
        view.endEditing(true)
        // If textview has placeholder, set its text to nil
        for subview in imageView.subviews {
            if let tView = subview as? OverlayTextView, tView.textColor == .darkGray {
                tView.text = nil
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, true, UIScreen.main.scale)
        let offset = scrollView.contentOffset
        guard let currentContext = UIGraphicsGetCurrentContext() else { return image }
        currentContext.translateBy(x: -offset.x, y: -offset.y)
        scrollView.layer.render(in: currentContext)
        let imageToSave = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageToSave
    }
    
    // MARK: - @objc methods
    @objc func saveButtonTapped() {
        guard let imageURLString = imageURLString else { return }
        networkManager.loadUploadURL { [weak self] result in
            switch result{
            case .success(let jsonResults):
                self?.networkManager.uploadImage(uploadURL: jsonResults.url, appid: "skpark1999@gmail.com", original: imageURLString, fileName: imageURLString.lastPathComponent, image: self?.getEditedImage()) { [weak self] result in
                    switch result{
                    case .success(let message):
                        self?.showAlert(message: message)
                    case .failure(let error):
                        self?.showAlert(message: error.rawValue)
                    }
                }
            case .failure(let error):
                self?.showAlert(message: error.rawValue)
            }
        }
    }
    
    @objc func overlayTextButtonTapped() {
        let textView = OverlayTextView(frame: .zero)
        textView.delegate = self
        imageView.addSubview(textView)
        textView.sizeToFit()
        textView.center = CGPoint(x: scrollView.frame.size.width / 2, y: scrollView.frame.size.height / 2)
    }
    
    @objc func filterButtonTapped() {
        let ac = UIAlertController(title: "Choose a filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Sephia", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Invert Color", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Process", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Mono", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}

extension DetailViewController: UIScrollViewDelegate {
    func centerScrollViewContents() {
        let boundSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundSize.width {
            contentsFrame.origin.x = (boundSize.width - contentsFrame.size.width) / 2
        } else {
            contentsFrame.origin.x = 0
        }
        
        if contentsFrame.size.height < boundSize.height {
            contentsFrame.origin.y = (boundSize.height - contentsFrame.size.height) / 2
        } else {
            contentsFrame.origin.y = 0
        }
        
        imageView.frame = contentsFrame
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
}

extension DetailViewController: UITextViewDelegate {
    func getSize(of text: String) -> CGSize {
        let dummyTextView = UITextView(frame: .zero)
        dummyTextView.font = UIFont(name: "Times New Roman", size: 27)
        dummyTextView.text = text
        dummyTextView.sizeToFit()
        return dummyTextView.frame.size
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let screenWidth = UIScreen.main.bounds.width
        let textWidth = getSize(of: textView.text).width
        let newSize = textView.sizeThatFits(CGSize(width: min(textWidth, screenWidth), height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: max(newSize.width, min(textWidth, screenWidth)), height: newSize.height)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.layer.borderColor = UIColor.systemBlue.cgColor
        textView.layer.borderWidth = 1
        if textView.textColor == .darkGray {
            textView.text = nil
            textView.textColor = .black
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        let trimmedString = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedString.isEmpty {
            textView.text = "Text"
            textView.textColor = .darkGray
            textView.frame.size.width = getSize(of: "Text").width
        }
        textView.layer.borderColor = UIColor.clear.cgColor
        return true
    }
}
