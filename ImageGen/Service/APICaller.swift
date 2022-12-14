//
//  APICaller.swift
//  ImageGen
//
//  Created by Igor Fernandes on 14/12/22.
//

import Foundation
import OpenAIKit
import UIKit.UIImage

struct ConstantsAPI {
    static let api_key = "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"
    static let organization = "Personal"
}

final class APICaller {
    static let shared = APICaller()
    var openAI: OpenAI?
    
    func setup() {
        self.openAI = OpenAI(Configuration(organization: ConstantsAPI.organization, apiKey: ConstantsAPI.api_key))
    }
    
    private init() {}
    
    func generateImage(input: String, completion: @escaping ((Result<UIImage, Error>) -> Void)) async {
        do {
            let imageParam = ImageParameters(
              prompt: input,
              resolution: .small,
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
        } catch {
            completion(.failure(error))
        }
    }
}
