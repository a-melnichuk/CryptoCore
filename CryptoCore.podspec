Pod::Spec.new do |s|
  s.name = 'CryptoCore'
  s.module_name = 'CryptoCore'
  s.version = '0.0.1'
  s.swift_version = '5.0'
  s.summary = 'Common crypto components for Paytomat Wallet'
  s.description = <<-DESC
Bundle of common crypto components needed by other Paytomat Wallet cryptocurrencies"
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
    'CryptoCore/Sources/libs/keccak-tiny/*.{h,c}'
  ]
  s.public_header_files = 'CryptoCore/*.h'
  s.pod_target_xcconfig = {
    'SYSTEM_HEADER_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)/CryptoCore/Sources/libs $(PODS_ROOT)/CryptoCore/Sources/libs',
    'SWIFT_INCLUDE_PATHS' => [
        '$(PODS_TARGET_SRCROOT)/CryptoCore/Sources/paytomat_crypto_core/**',
        '$(PODS_ROOT)/CryptoCore/Sources/paytomat_crypto_core/**',
        '$(PODS_TARGET_SRCROOT)/CryptoCore/Sources/libs',
        '$(PODS_ROOT)/CryptoCore/Sources/libs'
    ]
  }
  s.exclude_files = 'Examples/*'
  s.frameworks = 'Foundation'
end
