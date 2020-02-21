import UIKit

import Firebase

fileprivate let baseRef = Database.database().reference()

class FirebaseDataHelper {

    static let instance = FirebaseDataHelper()
 
    let chatRef = baseRef.child("chat")
    
    let groupRef = baseRef.child("group")
    
    let messageRef = baseRef.child("message")
    
    var currentUserUid: String? {
        get {
            guard let uid = Auth.auth().currentUser?.uid else {
                return nil
            }
            return uid
        }
    }
    
    func createUserInfoFromAuth(uid:String, userData: Dictionary<String, String>) {
        chatRef.child(uid).updateChildValues(userData)
    }
    
    func signIn(email withEmail: String, password: String, completion: @escaping () -> Void) {
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: { (user, error) in
            guard error == nil else {
                print("Error al iniciar sesión")
                return
            }
            completion()
        })
    }
}
