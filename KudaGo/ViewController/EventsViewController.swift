//
//  EventsViewController.swift
//  KudaGo
//
//  Created by Николай Игнатов on 15.01.2023.
//

import UIKit

final class EventsViewController: UIViewController {
    
    private var events = [EventDetail]()
    
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
        NetworkLayer.shared.fetchEventList { [weak self] eventList in
            guard let self = self else { return }
            NetworkLayer.shared.fetchEventDetails(events: eventList) { eventDetails in
                self.events = eventDetails
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(collectionView)
        fetchEvents()
        setConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemWidth = (collectionView.frame.width - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing) / 2
            layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        }
    }
}

extension EventsViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! EventCell
        let event = events[indexPath.item]
        cell.configure(event: event)
        return cell
    }
}

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
        static let spasing: CGFloat = 16
        static let cellIdentifier: String = "eventCell"
    }
}

