Pod::Spec.new do |s|
    s.name = 'WavesCore'
    s.module_name = 'WavesCore'
    s.version = '0.0.5'
    s.swift_version = '5.0'
    s.summary = 'Waves crypto components for Paytomat Wallet'
    s.description = <<-DESC
    Waves address generation and transaction for Paytomat Wallet
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
        :tag => 'waves-' + s.version.to_s
    }
    s.source_files = [
        'WavesCore/*.h',
        'WavesCore/Sources/*.swift',
        'WavesCore/Sources/libs/paytomat_crypto_core/*.h',
        'WavesCore/Sources/paytomat_waves_core/{include,src}/*.{h,c}'
    ]
    s.public_header_files = 'WavesCore/*.h'
    s.pod_target_xcconfig = {
        'SWIFT_INCLUDE_PATHS' => [
            '$(PODS_TARGET_SRCROOT)/WavesCore/Sources/**',
            '$(PODS_TARGET_SRCROOT)/WavesCore/Sources/libs',
            '$(PODS_ROOT)/WavesCore/Sources/**',
            '$(PODS_ROOT)/WavesCore/Sources/libs'
        ],
        'SYSTEM_HEADER_SEARCH_PATHS' => [
            '$(PODS_TARGET_SRCROOT)/WavesCore/Sources/libs',
            '$(PODS_ROOT)/WavesCore/Sources/libs'
        ].join(' '),
    }

    s.preserve_paths = 'WavesCore/Sources/module.modulemap'
    s.exclude_files = 'Examples/*'
    s.frameworks = 'Foundation'
    s.dependency 'CryptoCore', '~> 0.0.8'
end