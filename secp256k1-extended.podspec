#
# Be sure to run `pod lib lint secp256k1.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'secp256k1-extended'
  s.version          = '0.0.1'
  s.summary          = 'secp256k1 bindings for swift. Cocoapods, Carthage and SPM support. Linux support.'

  s.description      = <<-DESC
This pod binds the bitcoin-core library, the ECDSA curve, secp256k1 into Swift. This curve is used for
Bitcoin, Ethereum and many other Cryptocurrency Signature generation and verification.
                       DESC

  s.homepage = 'https://paytomat.com/'
  s.license = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author = { 'Alex Melnichuk' => 'a.melnichuk@noisyminer.com' }
  s.source = {
    :git => 'https://github.com/a-melnichuk/CryptoCore.git',
    :branch => 'master',
    :tag => 'secp256k1-extended-' + s.version.to_s
}

  s.ios.deployment_target = '9.0'

  s.module_name = 'secp256k1'

  s.pod_target_xcconfig = {
    'SWIFT_INCLUDE_PATHS' => '${PODS_ROOT}',
    'OTHER_CFLAGS' => '-DHAVE_CONFIG_H=1 -pedantic -Wall -Wextra -Wcast-align -Wnested-externs -Wshadow -Wstrict-prototypes -Wno-shorten-64-to-32 -Wno-conditional-uninitialized -Wno-unused-function -Wno-long-long -Wno-overlength-strings -O3',
    'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/secp256k1/Classes"'
  }

  s.source_files = 'secp256k1-extended/secp256k1/Classes/secp256k1/{src,include,contrib}/*.{h,c}', 'secp256k1-extended/secp256k1/Classes/secp256k1/src/modules/{recovery,ecdh}/*.{h,c}', 'secp256k1-extended/secp256k1/Classes/secp256k1-config.h', 'secp256k1-extended/secp256k1/Classes/secp256k1_main.h', 'secp256k1-extended/secp256k1/Classes/secp256k1_ec_mult_static_context.h'
  s.public_header_files = 'secp256k1-extended/secp256k1/Classes/secp256k1/include/*.h'
  s.private_header_files = 'secp256k1-extended/secp256k1/Classes/secp256k1_ec_mult_static_context.h', 'secp256k1-extended/secp256k1/Classes/secp256k1/*.h', 'secp256k1-extended/secp256k1/Classes/secp256k1/{contrib,src}/*.h', 'secp256k1-extended/secp256k1/Classes/secp256k1/src/modules/{recovery, ecdh}/*.h'
  s.exclude_files = 'secp256k1-extended/secp256k1/Classes/secp256k1/src/test*.{c,h}', 'secp256k1-extended/secp256k1/Classes/secp256k1/src/gen_context.c', 'secp256k1-extended/secp256k1/Classes/secp256k1/src/*bench*.{c,h}', 'secp256k1-extended/secp256k1/Classes/secp256k1/src/modules/{recovery,ecdh}/*test*.{c,h}'
end
