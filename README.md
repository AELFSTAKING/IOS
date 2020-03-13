# client（Staking Planet iOS 版本 APP）

## [介绍与使用文档](https://github.com/AELFSTAKING/Android#%E5%A6%82%E4%BD%95%E5%88%9B%E5%BB%BA%E6%88%96%E5%AF%BC%E5%85%A5%E8%B4%A6%E6%88%B7)


## 安装运行
- 安装依赖（必要）
```
cd AELFExchange
pod install
```


- 配置KofoCoreSDK（必要）
```
项目依赖KofoCoreSDK，运行模拟器/真机需要使用指定SDK，直接替换SDK文件即可（默认模拟器环境）
· SDK文件目录：AELFExchange/KofoCoreSDK/
· 工程运行SDK目录（即需要配置的SDK目录）：AELFExchange/Module/WalletCore
```


- 配置网络相关信息（必要）
```
文件：AELFExchange/Config/URLs.swift 第227行开始
总共三个环境，环境切换：Info.plist设置Config-Environment（值：Prod、Stage、Test分别对应URLs.swift配置环境）
domainProd：服务器域名，此值可同时配置于AppDelegate.swift[Line 27]
gatewayProd：兑换服务器（Gateway）域名
kofoMqttHostProd：MQTT地址
kofoMqttPortProd：MQTT端口
kofoSDKRestHostProd：KofoCoreSDK域名
ethBlockchainUrlProd：以太坊主网/测试网络地址
ignoreLogUrls：忽略日志打印接口路径列表
ignoreSSLURLHosts：忽略SSL校验接口路径列表
```


- 其他可选配置
```
Consts.swift[52] Bugly APP Key
AppDelegate.swift[27] Cookie清除域名
```
