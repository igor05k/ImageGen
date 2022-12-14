//
//  ViewController.swift
//  ImageGen
//
//  Created by Igor Fernandes on 14/12/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var promptImageView: UIImageView!
    @IBOutlet weak var promptTextField: UITextField!
    @IBOutlet weak var promptButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dall-E Image Gen"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        APICaller.shared.set(delegate: self)
        
        setGenerateButton()
        setTextField()
        setImageView()
    }
    
    func setImageView() {
        promptImageView.layer.cornerRadius = 10
        promptImageView.clipsToBounds = true
        promptImageView.contentMode = .scaleAspectFit
    }
    
    func setTextField() {
        promptTextField.placeholder = "Type any text..."
        promptTextField.layer.cornerRadius = 5
    }
    
    func setGenerateButton() {
        promptButton.setTitle("Generate Image", for: .normal)
        promptButton.layer.cornerRadius = 5
        promptButton.clipsToBounds = true
        promptButton.setTitleColor(.white, for: .normal)
        promptButton.backgroundColor = .systemBlue
        promptButton.addTarget(self, action: #selector(didTapGenerate), for: .touchUpInside)
    }
    
    @objc func didTapGenerate() {
        Task {
            await generate()
        }
    }
    
    func generate() async {
        guard let text = promptTextField.text?.trimmingCharacters(in: .whitespaces) else { return }
        print(text)
        await APICaller.shared.generateImage(input: text, completion: { result in
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    self.promptImageView.image = success
                }
                print(success)
            case .failure(let failure):
                print(failure)
            }
        })
    }
}

extension ViewController: APICallerDelegate {
    func startLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.promptButton.configuration?.showsActivityIndicator = true
            self?.promptButton.configuration?.title = nil
            self?.promptButton.isEnabled = false
        }
    }
    
    func stopLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.promptButton.configuration?.showsActivityIndicator = false
            self?.promptButton.configuration?.title = "Generate"
            self?.promptButton.isEnabled = true
        }
    }
}
