//
//  AuthManager.swift
//  SMKitUIDemoApp
//
//  Created by netanel-yerushalmi on 18/03/2024.
//

import Foundation

protocol AuthManagerDelegate:NSObject{
    func didFailAuth()
}

class AuthManager:ObservableObject{
    static let shared = AuthManager()
    
    @Published var didFinishAuth = false
    @Published var didFaildAuth = false{
        didSet{
            delegate?.didFailAuth()
        }
    }
    
    weak var delegate:AuthManagerDelegate?
}
