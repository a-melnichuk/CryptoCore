Pod::Spec.new do |s|
    s.name = 'NEMCore'
    s.module_name = 'NEMCore'
    s.version = '0.0.2'
    s.swift_version = '5.0'
    s.summary = 'NEM crypto components for Paytomat Wallet'
    s.description = <<-DESC
    NEM address generation and transactions for Paytomat Wallet
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
        :tag => 'nem-' + s.version.to_s
    }
    s.source_files = [
        'NEMCore/*.h',
        'NEMCore/Sources/*.swift',
        'NEMCore/Sources/libs/paytomat_crypto_core/*.h',
        'NEMCore/Sources/libs/curve25519/**/*.h',
        'NEMCore/Sources/paytomat_nem_core/{include,src}/*.{h,c}'
    ]
    s.public_header_files = 'NEMCore/*.h'
    s.pod_target_xcconfig = {
        'SWIFT_INCLUDE_PATHS' => [
            '$(PODS_TARGET_SRCROOT)/NEMCore/Sources/**',
            '$(PODS_TARGET_SRCROOT)/NEMCore/Sources/libs',
            '$(PODS_ROOT)/NEMCore/Sources/**',
            '$(PODS_ROOT)/NEMCore/Sources/libs'
        ],
        'SYSTEM_HEADER_SEARCH_PATHS' => [
            '$(PODS_TARGET_SRCROOT)/NEMCore/Sources/libs',
            '$(PODS_ROOT)/NEMCore/Sources/libs'
        ].join(' '),
    }

    s.preserve_paths = 'NEMCore/Sources/module.modulemap'
    s.exclude_files = 'Examples/*'
    s.frameworks = 'Foundation'
    s.dependency 'CryptoCore'
end

