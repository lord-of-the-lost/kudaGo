//
//  EventsViewController.swift
//  KudaGo
//
//  Created by Николай Игнатов on 15.01.2023.
//

import UIKit

final class EventsViewController: UIViewController {
    
    private var events = [EventDetail]()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        return activityIndicator
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = Constants.spasing
            layout.minimumLineSpacing = Constants.spasing
            layout.sectionInset = UIEdgeInsets(top: Constants.spasing,
                                               left: Constants.spasing,
                                               bottom: Constants.spasing,
                                               right: Constants.spasing)
        }
        collectionView.backgroundColor = .white
        collectionView.register(EventCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private func fetchEvents() {
        activityIndicator.startAnimating()
        NetworkLayer.shared.fetchEventList { [weak self] eventList in
            guard let self = self else { return }
            NetworkLayer.shared.fetchEventDetails(events: eventList) { eventDetails in
                self.events = eventDetails
                self.collectionView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.title
        view.backgroundColor = .white
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
        setConstraints()
        fetchEvents()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemWidth = collectionView.frame.width - layout.sectionInset.left - layout.sectionInset.right
            let itemHeight = itemWidth.half
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        }
    }
}

extension EventsViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! EventCell
        let event = events[indexPath.item]
        cell.configure(event: event)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let event = events[indexPath.item]
        let eventDetailViewController = EventDetailViewController()
        eventDetailViewController.eventId = event.id
        eventDetailViewController.loadEventDetail(by: event.id)
        navigationController?.pushViewController(eventDetailViewController, animated: true)
    }}

private extension EventsViewController{
    func setConstraints(){
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    enum Constants{
        static let title: String = "Cобытия в Москве"
        static let spasing: CGFloat = 16
        static let cellIdentifier: String = "eventCell"
    }
}
