//
//  File.swift
//  
//
//  Created by ZainAnjum on 09/09/2020.
//

//import Combine
//    private var requests = Set<AnyCancellable>()
//    func fetch<T: Decodable>(_ url: URL, defaultValue: T, completion: @escaping (T) -> Void) {
//        let decoder = JSONDecoder()
//
//        URLSession.shared.dataTaskPublisher(for: url)
//        .retry(1)
//        .map(\.data)
//        .decode(type: T.self, decoder: decoder)
//        .replaceError(with: defaultValue)
//        .receive(on: DispatchQueue.main)
//        .sink(receiveValue: completion)
//        .store(in: &requests)
//    }
