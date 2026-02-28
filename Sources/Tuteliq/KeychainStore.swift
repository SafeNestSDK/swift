#if canImport(Security)
    import Foundation
    import Security

    /// Internal helper for storing and retrieving the API key in the system Keychain.
    ///
    /// Uses `kSecClassGenericPassword` with `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`
    /// so the key is available after first unlock but never backed up to other devices.
    enum KeychainStore {
        static let defaultService = "ai.tuteliq.api-key"

        /// Store or update an API key in the Keychain.
        static func save(apiKey: String, service: String = KeychainStore.defaultService) throws {
            guard let data = apiKey.data(using: .utf8) else {
                throw TuteliqError.validationError("API key could not be encoded")
            }

            // Try to update an existing item first.
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
            ]

            let update: [String: Any] = [
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            ]

            let updateStatus = SecItemUpdate(query as CFDictionary, update as CFDictionary)

            if updateStatus == errSecItemNotFound {
                // No existing item — add a new one.
                var addQuery = query
                addQuery[kSecValueData as String] = data
                addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

                let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
                guard addStatus == errSecSuccess else {
                    throw TuteliqError.validationError(
                        "Failed to save API key to Keychain (OSStatus \(addStatus))"
                    )
                }
            } else if updateStatus != errSecSuccess {
                throw TuteliqError.validationError(
                    "Failed to update API key in Keychain (OSStatus \(updateStatus))"
                )
            }
        }

        /// Retrieve the API key from the Keychain.
        ///
        /// Returns `nil` if no key is stored for the given service.
        static func retrieve(service: String = KeychainStore.defaultService) -> String? {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne,
            ]

            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)

            guard status == errSecSuccess, let data = result as? Data else {
                return nil
            }
            return String(data: data, encoding: .utf8)
        }

        /// Delete the API key from the Keychain.
        static func delete(service: String = KeychainStore.defaultService) throws {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
            ]

            let status = SecItemDelete(query as CFDictionary)
            guard status == errSecSuccess || status == errSecItemNotFound else {
                throw TuteliqError.validationError(
                    "Failed to delete API key from Keychain (OSStatus \(status))"
                )
            }
        }
    }
#endif
