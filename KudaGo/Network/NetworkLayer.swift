//
//  NetworkLayer.swift
//  KudaGo
//
//  Created by Николай Игнатов on 16.01.2023.
//

import Foundation

final class NetworkLayer {
    static let shared = NetworkLayer()
    let group = DispatchGroup()
    var eventDetails = [EventDetail]()
    
    private func getCurrentDateYYYYMMDD() -> String {
        let todaysDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.dateFormat
        let dateInFormat = dateFormatter.string(from: todaysDate as Date)
        return dateInFormat
    }
    
    func fetchEventList(completion: @escaping ([Result]) -> Void) {
        let url = URL(string: "\(Constants.baseURL)/events/?location=\(Constants.location)&actual_since=\(getCurrentDateYYYYMMDD())")!
        print(url)
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching event list: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let eventList = try decoder.decode(Event.self, from: data)
                completion(eventList.results)
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }
    
    func fetchEventDetail(id: Int, completion: @escaping (EventDetail?) -> Void) {
        group.enter()
        let url = URL(string: "\(Constants.baseURL)/events/\(id)")!
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            guard let data = data else {
                print(String(describing: error))
                self.group.leave()
                return
            }
            let eventDetail = try? JSONDecoder().decode(EventDetail.self, from: data)
            if let eventDetail = eventDetail {
                self.eventDetails.append(eventDetail)
            }
            completion(eventDetail)
            self.group.leave()
        }
        task.resume()
    }

    
    func fetchEventDetails(events: [Result], completion: @escaping ([EventDetail]) -> Void) {
        eventDetails = []
        for event in events {
            fetchEventDetail(id: event.id) { eventDetail in
                guard eventDetail != nil else { return }
                self.eventDetails.append(eventDetail!)
            }
        }
        group.notify(queue: .main) {
            completion(self.eventDetails)
        }
    }
}

private extension NetworkLayer {
    enum Constants{
        static let location: String = "msk"
        static let baseURL: String = "https://kudago.com/public-api/v1.4"
        static let dateFormat: String = "yyyy-MM-dd"
    }
}
