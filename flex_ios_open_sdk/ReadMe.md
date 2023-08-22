#### 介绍

柔灵科技SDK http://openplatform.flexolinkai.com/

#### 软件架构

背景：柔灵科技专注于脑机接口技术的研发，为广大科研和企业用户提供脑机接口相关的API, 提供的服务有脑机接口设备的连接、脑电数据采集、存储、分析、睡眠闭环等相关接口。 目的：向对柔灵脑机接口 iOS SDk的客户提供二次开发的能力。



#### 快速接入SDK

\#购买柔灵产品 开发者可联系业务人员购买柔灵肌电产品与脑电产品。 #生成 App Key 每个应用程序都需要一个唯一的应用程序密钥(App Key)来初始化SDK。 

##### 1、请在真机下运行，SDK 不支持模拟器接入。

##### 2、将 SDK Demo 目录下的模型文件sleep_m_0310.b、sleep_m_0310.p 手动拖入工程，并且拖入到 build phases--copy bundle resource 下。

![](https://p.ipic.vip/7pdvyf.jpg)

##### 拷贝 flexPaster 目录到您的工程里，这是 SDK 运行需要用到的一些头文件和三方库 RNCryptor、AFNetworking（如果您的项目中已经使用到 AFNetworking，则可以不需要重复添加）。

![image-20230822230821353](https://p.ipic.vip/f867tu.jpg)

##### 3、导入 系统蓝牙框架 CoreBluetooth

![image-20230822213653314](https://p.ipic.vip/lk1vgx.jpg)

##### 4、请任意修改一处文件名后缀为 .mm ，以便能运行 SDK 里面的 c++ 代码

##### 5、在 info.plist 里添加蓝牙描述符，NSBluetoothAlwaysUsageDescription。

##### 6、SDKDemo 的入口处在 SceneDelegate.m。

##### 7、SDK 授权，工程启动后需要一次授权，您可在 appdelegate 或其他地方执行代码授权，Demo 的授权位置在 ViewController.m 中

