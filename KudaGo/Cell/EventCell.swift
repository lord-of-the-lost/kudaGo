//
//  EventCell.swift
//  KudaGo
//
//  Created by Николай Игнатов on 16.01.2023.
//

import Foundation
import UIKit

final class EventCell: UICollectionViewCell {
    
   private let imageView: UIImageView = {
       let imageView = UIImageView()
       imageView.contentMode = .scaleAspectFill
       imageView.layer.cornerRadius = Constants.cornerRadius
       imageView.clipsToBounds = true
       imageView.translatesAutoresizingMaskIntoConstraints = false
       return imageView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.backgroundColor = .white
        titleLabel.layer.cornerRadius = Constants.cornerRadius.half
        titleLabel.clipsToBounds = true
        titleLabel.font = UIFont.boldSystemFont(ofSize: Constants.titleFontSize)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = .zero
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .yellow
        self.layer.cornerRadius = Constants.cornerRadius
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        setConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(event: EventDetail) {
        let title = event.title
        let firstLetter = title!.prefix(1)
        let rest = title!.dropFirst()
        self.titleLabel.text = firstLetter.uppercased() + rest
        if let imageUrl = event.images?.first?.image {
            let url = URL(string: imageUrl)
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        } else {
            self.imageView.image = nil
        }
    }
}

private extension EventCell {
    func setConstraints(){
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.spasing),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constants.spasing.negative),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.spasing.negative)
        ])
    }
    enum Constants{
        static let spasing: CGFloat = 5
        static let cornerRadius: CGFloat = 10
        static let titleFontSize: CGFloat = 14
    }
}
