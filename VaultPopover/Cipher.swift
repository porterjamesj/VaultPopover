//
//  Cipher.swift
//  VaultPopover
//
//  Created by James on 4/23/18.
//  Copyright © 2018 porterjamesj. All rights reserved.
//

import Foundation
import CryptoSwift

let UUID = "e87eb0f4-34cb-46b9-93ad-766c5ab063e7"
let WORK = 100
let MAC_SIZE = 32
let IV_SIZE = 16

func hexEncode<T: Sequence>(_ data: T) -> String where T.Iterator.Element == UInt8 {
    return data.reduce("") {$0 + String(format: "%02x", $1)}
}


class Cipher {
    let secret: String
    
    init(secret: String) {
        self.secret = secret
    }
    
    func deriveKeys() -> (Array<UInt8>, Array<UInt8>) {
        let keyBuf: Array<UInt8> = Array(secret.utf8)
        let saltBuf: Array<UInt8> = Array(UUID.utf8)
        let baseKey1 = try! PKCS5.PBKDF2(password: keyBuf, salt: saltBuf, iterations: WORK, keyLength: 16, variant: .sha1).calculate()
        let baseKey2  = try! PKCS5.PBKDF2(password: keyBuf, salt: saltBuf, iterations: 2*WORK, keyLength: 16, variant: .sha1).calculate()
        /* This merits some explanation
           The way the key derivation in vault (v0.3) works is that it uses PBKDF2 to derive 16 byte keys, which doesn't make
           much sense since the encryption algorithm is AWS-256 (which requires 256/8 = 32 byte keys).
           For some reason, rather than generating 16 byte keys in the first place, vault hex-encodes the 16 byte keys, and uses the
           decoded bytes of their UTF8 representation as the keys, which extends them to 32 bytes. (since one byte turns into two letters
           in the hex encoding, which are then decoded back into two bytes). This seems pretty weird and arbitrary to me compared to just
           generating 32 byte keys in the first place. I suspect it may just be a mistake, but oh well.
        */
        let key1 = Array(hexEncode(baseKey1).utf8)
        let key2 = Array(hexEncode(baseKey2).utf8)
        return (key1, key2)
    }
    
    func decrypt(ciphertext: String) -> Optional<String> {
        let key1, key2: Array<UInt8>
        (key1, key2) = deriveKeys()
        let buffer: Array<UInt8> = Array(Data(base64Encoded: ciphertext)!)
        let message = buffer[0..<max(buffer.count-MAC_SIZE,0)]
        let iv = message[0..<min(IV_SIZE, message.count)]
        let payload = message[min(IV_SIZE, message.count)...] // I think?
        let expectedMac = buffer[max(buffer.count - MAC_SIZE, 0)...]
        let aes = try! AES(key: key1, blockMode: .CBC(iv: Array(iv)), padding: .pkcs7)
        let decrypted = try! aes.decrypt(payload)
        
        

        let actualMac = try! HMAC(key: key2, variant: .sha256).authenticate(Array(hexEncode(message).utf8))
        
        if Array(expectedMac) != actualMac {
            // TODO figure out better error API, does Swift have something like a Result type?
            return nil
        }
        
        return String(data: Data(bytes: decrypted), encoding: .utf8)
    }
    
}
