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
    static let api_key = "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"
    static let organization = "Personal"
}

final class APICaller {
    static let shared = APICaller()
    private var openAI: OpenAI?
    private weak var delegate: APICallerDelegate?
    
    public func set(delegate: APICallerDelegate) {
        self.delegate = delegate
    }
    
    func setup() {
        self.openAI = OpenAI(Configuration(organization: ConstantsAPI.organization, apiKey: ConstantsAPI.api_key))
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
