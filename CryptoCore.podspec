Pod::Spec.new do |s|
  s.name = 'CryptoCore'
  s.module_name = 'CryptoCore'
  s.version = '0.0.1'
  s.swift_version = '5.0'
  s.summary = 'Common crypto components for Paytomat Wallet'
  s.description = <<-DESC
  Bundle of common Paytomat crypto components: hash functions, elliptic curve operations
  and utilities
                   DESC

  s.homepage = 'https://paytomat.com/'
  s.license = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author = { 'Alex Melnichuk' => 'a.melnichuk@noisyminer.com' }

  s.platform = :ios
  s.ios.deployment_target = '9.0'
  s.requires_arc = true
  s.source = {
    :git => 'https://github.com/a-melnichuk/CryptoCore.git',
    :branch => 'master',
    :tag => s.version.to_s
  }
  s.source_files = [
    'CryptoCore/*.h',
    'CryptoCore/Sources/*.swift',
    'CryptoCore/Sources/paytomat_crypto_core/{include,src}/*.{h,c}',
    'CryptoCore/Sources/libs/keccak-tiny/*.{h,c}',
    'CryptoCore/Sources/libs/blake2b/*.{h,c}',
    'CryptoCore/Sources/libs/openssl/*.{h}'
  ]
  s.public_header_files = 'CryptoCore/*.h'
  s.pod_target_xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)/CryptoCore/Sources/libs/openssl $(PODS_ROOT)/CryptoCore/Sources/libs/openssl',
    'SYSTEM_HEADER_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)/CryptoCore/Sources/libs $(PODS_ROOT)/CryptoCore/Sources/libs',
    'SWIFT_INCLUDE_PATHS' => [
        '$(PODS_TARGET_SRCROOT)/CryptoCore/Sources/paytomat_crypto_core/**',
        '$(PODS_ROOT)/CryptoCore/Sources/paytomat_crypto_core/**',
        '$(PODS_TARGET_SRCROOT)/CryptoCore/Sources/libs',
        '$(PODS_ROOT)/CryptoCore/Sources/libs'
    ]
  }
  s.vendored_libraries = 'CryptoCore/Sources/libs/openssl/libcrypto.a'
  s.preserve_paths = 'CryptoCore/Sources/paytomat_crypto_core/module.modulemap'
  s.exclude_files = 'Examples/*'
  s.frameworks = 'Foundation'
end
