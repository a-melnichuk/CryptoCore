Pod::Spec.new do |s|
    s.name = 'BitcoinCore'
    s.module_name = 'BitcoinCore'
    s.version = '0.0.4'
    s.swift_version = '5.0'
    s.summary = 'Bitcoin crypto components for Paytomat Wallet'
    s.description = <<-DESC
    Bitcoin address generation and transaction for Paytomat Wallet
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
        :tag => 'btc-' + s.version.to_s
    }
    s.source_files = [
        'BitcoinCore/*.h',
        'BitcoinCore/Sources/**/*.swift',
        'BitcoinCore/Sources/libs/paytomat_crypto_core/*.h',
        'BitcoinCore/Sources/paytomat_btc_core/{include,src}/*.{h,c}'
    ]
    s.public_header_files = 'BitcoinCore/*.h'
    s.pod_target_xcconfig = {
        'SWIFT_INCLUDE_PATHS' => [
            '$(PODS_TARGET_SRCROOT)/BitcoinCore/Sources/**',
            '$(PODS_TARGET_SRCROOT)/BitcoinCore/Sources/libs',
            '$(PODS_ROOT)/BitcoinCore/Sources/**',
            '$(PODS_ROOT)/BitcoinCore/Sources/libs'
        ],
        'SYSTEM_HEADER_SEARCH_PATHS' => [
            '$(PODS_TARGET_SRCROOT)/BitcoinCore/Sources/libs',
            '$(PODS_ROOT)/BitcoinCore/Sources/libs'
        ].join(' '),
    }

    s.preserve_paths = 'BitcoinCore/Sources/module.modulemap'
    s.exclude_files = 'Examples/*'
    s.frameworks = 'Foundation'
    s.dependency 'CryptoCore'
    s.dependency 'secp256k1.c', '~> 0.1'
end

