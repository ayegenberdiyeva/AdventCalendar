import Foundation
import FirebaseAuth

class AuthManager {
    //MARK: singleton
    static let shared = AuthManager()
    private let auth = Auth.auth()
    
    private var authStateListener:
    AuthStateDidChangeListenerHandle?
    
    var currentUserId: String? {
        return auth.currentUser?.uid
    }
    
    var currentUser: User? {
        return auth.currentUser
    }
    
    var isAuthenticated: Bool {
        return auth.currentUser != nil
    }
    
    private init() {
        // private init to enforce singletin pattern
    }
    
    func signInAnonymously(completion: @escaping (Result<String, Error>) -> Void) {
        if let currentUser = auth.currentUser {
            completion(.success(currentUser.uid))
            return
        }
        
        auth.signInAnonymously { [weak self] authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = authResult?.user else {
                let unknownError = NSError(domain: "AuthManager", code: -1, userInfo:
                                            [NSLocalizedDescriptionKey : "Unknown error occurred"])
                
                completion(.failure(unknownError))
                return
            }
            
        }
    }
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try auth.signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func addAuthStateListener(completion: @escaping (User?) -> Void) {
        if let existingListener = authStateListener {
            auth.removeStateDidChangeListener(existingListener)
        }
        
        authStateListener = auth.addStateDidChangeListener { [weak self] _, user in
            completion(user)
        }
    }
    
    func removeAuthStateListener() {
        if let listener = authStateListener {
            auth.removeStateDidChangeListener(listener)
            authStateListener = nil
        }
    }
    
    func getCurrentUserID() -> String? {
        return auth.currentUser?.uid
    }
}
