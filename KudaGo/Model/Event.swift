//
//  Event.swift
//  KudaGo
//
//  Created by Николай Игнатов on 16.01.2023.
//

import Foundation

struct Event: Decodable {
    let next: String?
    let results: [Result]?
}

struct Result: Decodable {
    let id: Int?
}

struct EventDetail: Decodable {
    let id: Int?
    let dates: [DateElement]?
    let title: String?
    let description: String?
    let images: [EventDetailImage]?
}

struct DateElement: Decodable {
    let start: Int?
    let end: Int?
}

struct EventDetailImage: Decodable {
    let image: String?
}

