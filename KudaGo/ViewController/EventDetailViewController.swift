//
//  EventDetailViewController.swift
//  KudaGo
//
//  Created by Николай Игнатов on 17.01.2023.
//

import Foundation
import UIKit

final class EventDetailViewController: UIViewController {
    
    var eventDetail: EventDetail? {
        didSet {
            DispatchQueue.main.async {
                self.updateData()
                self.imageCollectionView.reloadData()
            }
        }
    }
    
    var eventId: Int?
    
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        return activityIndicator
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: Constants.titleFontSize)
        label.numberOfLines = .zero
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: Constants.textFontSize)
        label.numberOfLines = .zero
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: Constants.textFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        activityIndicator.center = view.center
        setupConstraints()
        loadEventDetail(by: eventId)
        updateData()
        
    }
    
    private func setupView() {
        view.backgroundColor = .white
        self.navigationItem.title = Constants.title
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(dateLabel)
        view.addSubview(imageCollectionView)
        view.addSubview(activityIndicator)
    }
    
    func loadEventDetail(by eventId: Int?) {
        guard let eventId = eventId else { return }
        activityIndicator.startAnimating()
        NetworkLayer.shared.fetchEventDetail(id: eventId) { eventDetail in
            if let eventDetail = eventDetail {
                self.eventDetail = eventDetail
            }
        }
    }
    
    private func updateData() {
        DispatchQueue.main.async {
            guard let event = self.eventDetail else { return }
            let title = event.title
            let firstLetter = title!.prefix(1)
            let rest = title!.dropFirst()
            self.titleLabel.text = firstLetter.uppercased() + rest
            let description = event.description!.replacingOccurrences(of: "<p>", with: Constants.emptyString).replacingOccurrences(of: "</p>", with: Constants.emptyString)
            self.descriptionLabel.text = description
            if let date = event.dates?.first {
                let startDate = Date(timeIntervalSince1970: TimeInterval(date.start ?? .zero))
                let endDate = Date(timeIntervalSince1970: TimeInterval(date.end ?? .zero))
                let formatter = DateFormatter()
                formatter.dateFormat = Constants.dateFormat
                let start = formatter.string(from: startDate)
                let end = formatter.string(from: endDate)
                self.dateLabel.text = "с: \(start) по: \(end)"
            } else {
                self.dateLabel.text = Constants.emptyString
            }
            self.activityIndicator.stopAnimating()
        }
    }
}

extension EventDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventDetail?.images?.count ?? .zero
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! ImageCollectionViewCell
        if let imageUrl = eventDetail?.images?[indexPath.item].image {
            let url = URL(string: imageUrl)
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.imageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.itemSize, height: Constants.itemSize)
    }
}

private extension EventDetailViewController{
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.spasing),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.spasing),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.spasing.negative),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.spasing),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.spasing),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.spasing.negative),
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Constants.spasing),
            dateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.spasing),
            dateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.spasing.negative),
            imageCollectionView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: Constants.spasing),
            imageCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.spasing),
            imageCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.spasing.negative),
            imageCollectionView.heightAnchor.constraint(equalToConstant: Constants.itemSize),
            imageCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.spasing.negative)
        ])
    }
    enum Constants{
        static let title: String = "Подробности о событии:"
        static let titleFontSize: CGFloat = 24
        static let textFontSize: CGFloat = 18
        static let itemSize: CGFloat = 200
        static let spasing: CGFloat = 16
        static let cellIdentifier: String = "ImageCell"
        static let emptyString: String = ""
        static let dateFormat: String = "dd-MM-yyyy"
    }
}
