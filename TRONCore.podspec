Pod::Spec.new do |s|
    s.name = 'TRONCore'
    s.module_name = 'TRONCore'
    s.version = '0.0.1'
    s.swift_version = '5.0'
    s.summary = 'TRON crypto components for Paytomat Wallet'
    s.description = <<-DESC
    TRON address generation and transaction for Paytomat Wallet
    DESC

    s.homepage = 'https://paytomat.com/'
    s.license = { :type => 'MIT', :file => 'LICENSE.md' }
    s.author = { 'Vitalii Havryliuk' => 'v.havryliuk@noisyminer.com' }

    s.platform = :ios
    s.ios.deployment_target = '9.0'
    s.requires_arc = true
    s.source = {
        :git => 'https://github.com/a-melnichuk/CryptoCore.git',
        :branch => 'master',
        :tag => 'eth-' + s.version.to_s
    }
    s.source_files = [
        'TRONCore/*.h',
        'TRONCore/Sources/**/*.swift',
        'TRONCore/Sources/libs/paytomat_crypto_core/*.h',
        'TRONCore/Sources/paytomat_trx_core/{include,src}/*.{h,c}'
    ]
    s.public_header_files = 'TRONCore/*.h'
    s.pod_target_xcconfig = {
        'SWIFT_INCLUDE_PATHS' => [
            '$(PODS_TARGET_SRCROOT)/TRONCore/Sources/**',
            '$(PODS_TARGET_SRCROOT)/TRONCore/Sources/libs',
            '$(PODS_ROOT)/TRONCore/Sources/**',
            '$(PODS_ROOT)/TRONCore/Sources/libs'
        ],
        'SYSTEM_HEADER_SEARCH_PATHS' => [
            '$(PODS_TARGET_SRCROOT)/TRONCore/Sources/libs',
            '$(PODS_ROOT)/TRONCore/Sources/libs'
        ].join(' '),
    }

    s.preserve_paths = 'TRONCore/Sources/module.modulemap'
    s.exclude_files = 'Examples/*'
    s.frameworks = 'Foundation'
    s.dependency 'CryptoCore'
    s.dependency 'BigInt'
    s.dependency 'secp256k1-extended'
    s.dependency 'keccak.c', '~> 0.1'
end
