//
//  DImageViewController.swift
//  Int20Drive
//
//  Created by Andrii Zinoviev on 21.02.2021.
//

import Foundation
import UIKit

class DImageViewController: UIViewController {
    
    public var deleteHandler: (() -> Void)?
    let imageView: UIImageView
    public let deleteButton = UIButton(type: .system)
    public let dismissButton = UIButton(type: .system)
    let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    init(image: UIImage) {
        imageView = UIImageView(image: image)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.addSubview(backgroundView)
        NSLayoutConstraint.activateConstraints(for: backgroundView, in: view)
        
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.backgroundColor = .black
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteAct), for: .touchUpInside)
        
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.setTitle("Dismiss", for: .normal)
        dismissButton.backgroundColor = .black
        dismissButton.setTitleColor(.white, for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissAct), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            dismissButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            deleteButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            dismissButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            deleteButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            dismissButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            
            deleteButton.heightAnchor.constraint(equalToConstant: 75),
            dismissButton.heightAnchor.constraint(equalToConstant: 75),
            
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: deleteButton.topAnchor),
        ])
    }
    
    @objc func dismissAct() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func deleteAct() {
        deleteHandler?()
        dismiss(animated: true, completion: nil)
    }
}
