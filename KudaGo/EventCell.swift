//
//  EventCell.swift
//  KudaGo
//
//  Created by Николай Игнатов on 16.01.2023.
//

import Foundation
import UIKit

final class EventCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
        layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
