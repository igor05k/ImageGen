//
//  APICaller.swift
//  ImageGen
//
//  Created by Igor Fernandes on 14/12/22.
//

import Foundation
import OpenAIKit
import UIKit.UIImage

protocol APICallerDelegate: AnyObject {
    func startLoading()
    func stopLoading()
}

struct ConstantsAPI {
    static let organization = "Personal"
    static var apiKey: String {
      get {
        
        guard let filePath = Bundle.main.path(forResource: "OpenAI-Info", ofType: "plist") else {
          fatalError("Couldn't find file 'TMDB-Info.plist'.")
        }
        
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
          fatalError("Couldn't find key 'API_KEY' in 'OpenAI-Info.plist'.")
        }
        return value
      }
    }
}

final class APICaller {
    static let shared = APICaller()
    private var openAI: OpenAI?
    private weak var delegate: APICallerDelegate?
    
    public func set(delegate: APICallerDelegate) {
        self.delegate = delegate
    }
    
    func setup() {
        self.openAI = OpenAI(Configuration(organization: ConstantsAPI.organization, apiKey: ConstantsAPI.apiKey))
    }
    
    private init() {}
    
    func generateImage(input: String, completion: @escaping ((Result<UIImage, Error>) -> Void)) async {
        do {
            delegate?.startLoading()
            let imageParam = ImageParameters(
              prompt: input,
              resolution: .medium,
              responseFormat: .base64Json
            )
            
            // unwrap openai object
            guard let openAI else { return }
            let result = try await openAI.createImage(
              parameters: imageParam
            )
            let b64Image = result.data[0].image
            let image = try openAI.decodeBase64Image(b64Image)
            completion(.success(image))
            delegate?.stopLoading()
        } catch {
            delegate?.stopLoading()
            completion(.failure(error))
        }
    }
}
