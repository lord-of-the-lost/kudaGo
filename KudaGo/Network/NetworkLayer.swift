//
//  NetworkLayer.swift
//  KudaGo
//
//  Created by Николай Игнатов on 16.01.2023.
//

import Foundation

final class NetworkLayer {
    
    static let shared = NetworkLayer()
    
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
        let url = URL(string: "\(Constants.baseURL)/events/\(id)/")!
        print(url)
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
             if let error = error {
                 print("Error fetching event detail: \(error)")
                 completion(nil)
                 return
             }
             
             guard let data = data else {
                 print("No data received")
                 completion(nil)
                 return
             }
             
             let decoder = JSONDecoder()
             
             do {
                 let eventDetail = try decoder.decode(EventDetail.self, from: data)
                 completion(eventDetail)
             } catch {
                 print("Error decoding JSON: \(error)")
                 completion(nil)
             }
         }
         task.resume()
     }
    
    func fetchEventDetails(events: [Result], completion: @escaping ([EventDetail]) -> Void) {
        var eventDetails = [EventDetail]()
        let group = DispatchGroup()
        for event in events {
            group.enter()
            fetchEventDetail(id: event.id) { eventDetail in
                guard eventDetail != nil else { return }
                eventDetails.append(eventDetail!)
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(eventDetails)
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
