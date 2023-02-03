//
//  APICaller.swift
//  PicAnswer
//
//  Created by Benjamin Sloutsky on 1/31/23.
//

import Foundation
import OpenAISwift

final class APICaller{
    static let shared = APICaller()
    
    @frozen enum Constants{
        static let key = "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"
    }
    
    private var client: OpenAISwift?
    private init() {}
    
    public func setup() {
        self.client = OpenAISwift(authToken: Constants.key)
    }
    
    public func getResponse(input: String, completion: @escaping (Result<String, Error>) -> Void){
        client?.sendCompletion(with: input, model: .gpt3(.davinci), maxTokens: 100, completionHandler: { result in
            switch result{
            case .success(let model):
                let output = model.choices.first?.text
                completion(.success(output!))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}
