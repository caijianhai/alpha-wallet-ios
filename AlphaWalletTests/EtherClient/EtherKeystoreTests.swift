// Copyright SIX DAY LLC. All rights reserved.

import XCTest
import LocalAuthentication
@testable import AlphaWallet
import BigInt
import AlphaWalletFoundation
import Combine

class EtherKeystoreTests: XCTestCase {
    private var cancelable = Set<AnyCancellable>()

    func testInitialization() {
        let keystore = FakeEtherKeystore()

        XCTAssertNotNil(keystore)
        XCTAssertEqual(false, keystore.hasWallets)
    }

    func testCreateWallet() {
        let keystore = FakeEtherKeystore()
        let _ = keystore.importWallet(type: .newWallet)
        XCTAssertEqual(1, keystore.wallets.count)
    }

    func testEmptyPassword() throws {
        let keystore = try LegacyFileBasedKeystore(securedStorage: KeychainStorage.make())
        let password = keystore.getPassword(for: .make())
        XCTAssertNil(password)
    }

    func testImport() {
        let keystore = FakeEtherKeystore()
        let result = keystore.importWallet(type: .keystore(string: TestKeyStore.keystore, password: TestKeyStore.password))
        guard let wallet = try? result.get() else {
            XCTFail("Failure to import wallet")
            return
        }
        XCTAssertEqual("0x5E9c27156a612a2D516C74c7a80af107856F8539", wallet.address.eip55String)
        XCTAssertEqual(1, keystore.wallets.count)
    }

    func testImportDuplicate() {
        let keystore = FakeEtherKeystore()
        var address: AlphaWallet.Address?

        let result = keystore.importWallet(type: .keystore(string: TestKeyStore.keystore, password: TestKeyStore.password))
        guard let wallet = try? result.get() else {
            XCTFail("Failure to import wallet")
            return
        }
        address = wallet.address

        switch keystore.importWallet(type: .keystore(string: TestKeyStore.keystore, password: TestKeyStore.password)) {
        case .success:
            return XCTFail()
        case .failure(let error):
            if case KeystoreError.duplicateAccount = error {
                XCTAssertEqual("0x5E9c27156a612a2D516C74c7a80af107856F8539", address?.eip55String)
                XCTAssertEqual(1, keystore.wallets.count)
            } else {
                XCTFail()
            }
        }
    }

    func testImportFailInvalidPassword() {
        let keystore = FakeEtherKeystore()
        let result = keystore.importWallet(type: .keystore(string: TestKeyStore.keystore, password: "invalidPassword"))
        XCTAssertThrowsError(try result.get())

        XCTAssertEqual(0, keystore.wallets.count)
    }

    func testExportHdWalletToSeedPhrase() throws {
        let keystore = FakeEtherKeystore()
        let result = keystore.importWallet(type: .newWallet)
        let account = try result.get().address
        let expectation = self.expectation(description: "completion block called")
        keystore.exportSeedPhraseOfHdWallet(forAccount: account, context: .init(), prompt: KeystoreExportReason.backup.description)
            .sink { result in
                expectation.fulfill()
                guard let seedPhrase = try? result.get() else {
                    XCTFail("Failure to import wallet")
                    return
                }
                XCTAssertEqual(seedPhrase.split(separator: " ").count, 12)
            }.store(in: &cancelable)
        
        wait(for: [expectation], timeout: 600)
    }

    func testExportRawPrivateKeyToKeystoreFile() throws {
        let keystore = FakeEtherKeystore()
        let password = "test"

        XCTAssertEqual(keystore.wallets.count, 0)
        let result = keystore.importWallet(type: .privateKey(privateKey: Data(hexString: TestKeyStore.testPrivateKey)!))
        let wallet = try result.get()
        XCTAssertEqual(keystore.wallets.count, 1)

        let expectation = self.expectation(description: "completion block called")
        keystore.exportRawPrivateKeyForNonHdWalletForBackup(forAccount: wallet.address, prompt: R.string.localizable.keystoreAccessKeyNonHdBackup(), newPassword: password)
            .sink { result in
                let v = try? result.get()
                XCTAssertNotNil(v)

                expectation.fulfill()
            }.store(in: &cancelable)
        //NOTE: increase waiting time, latest version of iOS takes more time to decode encrypted data
        wait(for: [expectation], timeout: 600)
    }

    func testRecentlyUsedAccount() throws {
        let keystore = FakeEtherKeystore()

        XCTAssertNil(keystore.recentlyUsedWallet)

        let account = try keystore.importWallet(type: .newWallet).get()

        keystore.recentlyUsedWallet = account

        XCTAssertEqual(account, keystore.recentlyUsedWallet)
        XCTAssertEqual(account, keystore.currentWallet)

        keystore.recentlyUsedWallet = nil

        XCTAssertNil(keystore.recentlyUsedWallet)
    }

    func testDeleteAccount() throws {
        let keystore = FakeEtherKeystore()
        let wallet = try keystore.importWallet(type: .newWallet).get()

        XCTAssertEqual(1, keystore.wallets.count)

        let result = keystore.delete(wallet: wallet)

        guard case .success = result else { return XCTFail() }

        XCTAssertTrue(keystore.wallets.isEmpty)
    }

    func testConvertPrivateKeyToKeyStore() throws {
        let passphrase = "MyHardPassword!"
        let keystore = FakeEtherKeystore()
        let keyResult = (try! LegacyFileBasedKeystore(securedStorage: KeychainStorage.make())).convertPrivateKeyToKeystoreFile(privateKey: Data(hexString: TestKeyStore.testPrivateKey)!, passphrase: passphrase)
        let dict = try keyResult.get()
        let result = keystore.importWallet(type: .keystore(string: dict.jsonString!, password: passphrase))
        guard let wallet = try? result.get() else {
            XCTFail("Failure to import wallet")
            return
        }
        XCTAssertEqual(wallet.address.eip55String, "0x95fc7381950Db9d7ab116099c4E84AFD686e3e9C")
        XCTAssertEqual(1, keystore.wallets.count)
    }

    func testSignPersonalMessageWithRawPrivateKey() {
        let keystore = FakeEtherKeystore()

        let result = keystore.importWallet(type: .privateKey(privateKey: Data(hexString: "0x4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318")!))
        guard let wallet = try? result.get() else {
            XCTFail("Failure to import wallet")
            return
        }
        let signResult = keystore.signPersonalMessage("Some data".data(using: .utf8)!, for: wallet.address, prompt: R.string.localizable.keystoreAccessKeySign())
        guard let data = try? signResult.get() else {
            XCTFail("Failure to import wallet")
            return
        }
        let expected = Data(hexString: "0xb91467e570a6466aa9e9876cbcd013baba02900b8979d43fe208a4a4f339f5fd6007e74cd82e037b800186422fc2da167c747ef045e5d18a5f5d4300f8e1a0291c")
        XCTAssertEqual(expected, data)

        // web3.eth.accounts.sign('Some data', '0x4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318');
        // expected:
        // message: 'Some data',
        // messageHash: '0x1da44b586eb0729ff70a73c326926f6ed5a25f5b056e7f47fbc6e58d86871655',
        // v: '0x1c',
        // r: '0xb91467e570a6466aa9e9876cbcd013baba02900b8979d43fe208a4a4f339f5fd',
        // s: '0x6007e74cd82e037b800186422fc2da167c747ef045e5d18a5f5d4300f8e1a029',
        // signature: '0xb91467e570a6466aa9e9876cbcd013baba02900b8979d43fe208a4a4f339f5fd6007e74cd82e037b800186422fc2da167c747ef045e5d18a5f5d4300f8e1a0291c'
    }

    func testSignPersonalMessageWithHdWallet() {
        let keystore = FakeEtherKeystore()

        let result = keystore.importWallet(type: .mnemonic(words: ["nuclear", "you", "cage", "screen", "tribe", "trick", "limb", "smart", "dad", "voice", "nut", "jealous"], password: ""))
        guard let wallet = try? result.get() else {
            XCTFail("Failure to import wallet")
            return
        }
        let signResult = keystore.signPersonalMessage("Some data".data(using: .utf8)!, for: wallet.address, prompt: R.string.localizable.keystoreAccessKeySign())
        guard let data = try? signResult.get() else {
            XCTFail("Failure to import wallet")
            return
        }
        let expected = Data(hexString: "0x03f79a4efa290627cf3e134debd95f6effb60b1119997050fba7f6fd34db17144c8873b8a7a312797623f21a3e69e895d2afe3e1cb334f4bf46c58c5aaab9dac1c")
        XCTAssertEqual(expected, data)
    }

    func testSignMessage() {
        let keystore = FakeEtherKeystore()

        let result = keystore.importWallet(type: .privateKey(privateKey: Data(hexString: "0x4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318")!))
        guard let wallet = try? result.get() else {
            XCTFail("Failure to import wallet")
            return
        }
        let signResult = keystore.signPersonalMessage("0x3f44c2dfea365f01c1ada3b7600db9e2999dfea9fe6c6017441eafcfbc06a543".data(using: .utf8)!, for: wallet.address, prompt: R.string.localizable.keystoreAccessKeySign())
        guard let data = try? signResult.get() else {
            XCTFail("Failure to import wallet")
            return
        }
        let expected = Data(hexString: "0x619b03743672e31ad1d7ee0e43f6802860082d161acc602030c495a12a68b791666764ca415a2b3083595aee448402874a5a376ea91855051e04c7b3e4693d201c")
        XCTAssertEqual(expected, data)
    }

    func testAddWatchAddress() {
        let keystore = FakeEtherKeystore()
        let address: AlphaWallet.Address = .make()
        let _ = keystore.importWallet(type: ImportType.watch(address: address))

        XCTAssertEqual(1, keystore.wallets.count)
        XCTAssertEqual(address, keystore.wallets[0].address)
    }

    func testDeleteWatchAddress() {
        let keystore = FakeEtherKeystore()
        let address: AlphaWallet.Address = .make()

        // TODO. Move this into sync calls
        let result = keystore.importWallet(type: ImportType.watch(address: address))
        guard let wallet = try? result.get() else {
            XCTFail("Failure to import wallet")
            return
        }
        XCTAssertEqual(1, keystore.wallets.count)
        XCTAssertEqual(address, keystore.wallets[0].address)

        let _ = keystore.delete(wallet: wallet)

        XCTAssertEqual(0, keystore.wallets.count)
    }
}
