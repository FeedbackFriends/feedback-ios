import AuthenticationServices
import CryptoKit
import FirebaseAuth
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

enum AuthServiceError: Error {
    case invalidState(String)
    case identityTokenMissing
    case tokenSerializationFailed
    case firebaseSignInFailed(String)
    case appleSignInError(Error)
}

class FirebaseService: NSObject, ASAuthorizationControllerDelegate {
    
    var currentNonce: String?
    private var continuation: CheckedContinuation<AuthCredential, Error>?
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow() async throws -> AuthCredential {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            authorizationController.performRequests()
        }
    }
    
    func startGoogleSignInFlow() async throws -> AuthCredential {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootViewController = windowScene.windows.first?.rootViewController
        else {
            throw AuthenticationError.couldNotFindWindow
        }
        
        guard let deviceId = FirebaseApp.app()?.options.clientID else {
            throw AuthenticationError.couldNotFindClientID
        }
        
        let config = GIDConfiguration(clientID: deviceId)
        GIDSignIn.sharedInstance.configuration = config
        let googleResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        guard let idToken = googleResult.user.idToken?.tokenString else {
            throw URLError(URLError.Code.unknown)
        }
        
        return GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: googleResult.user.accessToken.tokenString
        )
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let continuation = continuation else { return }

        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            do {
                guard let nonce = currentNonce else {
                    throw AuthServiceError.invalidState("A login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    throw AuthServiceError.identityTokenMissing
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    throw AuthServiceError.tokenSerializationFailed
                }
                let credential = OAuthProvider.credential(
                    providerID: .apple,
                    idToken: idTokenString,
                    rawNonce: nonce
                )
                continuation.resume(returning: credential)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Propagate the error
        continuation?.resume(throwing: AuthServiceError.appleSignInError(error))
    }
}
