Pod::Spec.new do |s|
    s.name = 'EthereumCore'
    s.module_name = 'EthereumCore'
    s.version = '0.0.1'
    s.swift_version = '5.0'
    s.summary = 'Ethereum crypto components for Paytomat Wallet'
    s.description = <<-DESC
    Ethereum address generation and transaction for Paytomat Wallet
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
        :tag => 'eth-' + s.version.to_s
    }
    s.source_files = [
        'EthereumCore/*.h',
        'EthereumCore/Sources/*.swift',
        'EthereumCore/Sources/libs/paytomat_crypto_core/*.h',
        'EthereumCore/Sources/paytomat_eth_core/{include,src}/*.{h,c}'
    ]
    s.public_header_files = 'EthereumCore/*.h'
    s.pod_target_xcconfig = {
        'SWIFT_INCLUDE_PATHS' => [
            '$(PODS_TARGET_SRCROOT)/EthereumCore/Sources/**',
            '$(PODS_TARGET_SRCROOT)/EthereumCore/Sources/libs',
            '$(PODS_ROOT)/EthereumCore/Sources/**',
            '$(PODS_ROOT)/EthereumCore/Sources/libs'
        ],
        'SYSTEM_HEADER_SEARCH_PATHS' => [
            '$(PODS_TARGET_SRCROOT)/EthereumCore/Sources/libs',
            '$(PODS_ROOT)/EthereumCore/Sources/libs'
        ].join(' '),
    }

    s.preserve_paths = 'EthereumCore/Sources/module.modulemap'
    s.exclude_files = 'Examples/*'
    s.frameworks = 'Foundation'
    s.dependency 'CryptoCore'
    s.dependency 'web3swift.pod'
end

