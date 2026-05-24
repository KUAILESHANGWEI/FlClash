# flutter_distributor

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url] ![][visits-count-image] [![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos) [![All Contributors][all-contributors-image]](#contributors)

[pub-image]: https://img.shields.io/pub/v/flutter_distributor.svg?style=flat-square
[pub-url]: https://pub.dev/packages/flutter_distributor
[discord-image]: https://img.shields.io/discord/884679008049037342.svg?style=flat-square
[discord-url]: https://discord.gg/zPa6EZ2jqb
[visits-count-image]: https://img.shields.io/badge/dynamic/json?label=Visits%20Count&query=value&url=https://api.countapi.xyz/hit/leanflutter.flutter_distributor/visits
[all-contributors-image]: https://img.shields.io/github/all-contributors/leanflutter/flutter_distributor?color=ee8449&style=flat-square

一款全能的 [Flutter](https://flutter.dev) 应用打包和发布工具，为您提供一站式解决方案，满足各种分发需求。

---

[English](./README.md) | 简体中文

---

## 文档

完整的文档可以在 [distributor.leanflutter.dev](https://distributor.leanflutter.dev/zh-hans) 上找到。

## 功能

### 制作器

- [apk](./packages/flutter_app_packager/lib/src/makers/apk/) - 为你的应用创建一个 `apk` 包。
- [aab](./packages/flutter_app_packager/lib/src/makers/aab/) - 为你的应用创建一个 `aab` 包。
- [appimage](./packages/flutter_app_packager/lib/src/makers/appimage/) - 为你的应用创建一个 `AppImage` 包。
- [deb](./packages/flutter_app_packager/lib/src/makers/deb/) - 为你的应用创建一个 `deb` 包。
- [dmg](./packages/flutter_app_packager/lib/src/makers/dmg/) - 为你的应用创建一个 `dmg` 包。
- [exe](./packages/flutter_app_packager/lib/src/makers/exe/) - 为你的应用创建一个 `exe` 包。
- [ipa](./packages/flutter_app_packager/lib/src/makers/ipa/) - 为你的应用创建一个 `ipa` 包。
- [msix](./packages/flutter_app_packager/lib/src/makers/msix/) - 为你的应用创建一个 `msix` 包。
- [pkg](./packages/flutter_app_packager/lib/src/makers/pkg/) - 为你的应用创建一个 `pkg` 包。
- [rpm](./packages/flutter_app_packager/lib/src/makers/rpm/) - 为你的应用创建一个 `rpm` 包。
- [zip](./packages/flutter_app_packager/lib/src/makers/zip/) - 为你的应用创建一个 `zip` 包。

### 发布器

- [appcenter](./packages/flutter_app_publisher/lib/src/publishers/appcenter/) - 把你的应用发布到 `appcenter`.
- [appstore](./packages/flutter_app_publisher/lib/src/publishers/appstore/) - 把你的应用发布到 `appstore`.
- [fir](./packages/flutter_app_publisher/lib/src/publishers/fir/) - 把你的应用发布到 `fir`。
- [firebase](./packages/flutter_app_publisher/lib/src/publishers/firebase/) - 把你的应用发布到 `firebase`。
- [firebase_hosting](./packages/flutter_app_publisher/lib/src/publishers/firebase_hosting/) - 把你的应用发布到 `firebase_hosting`。
- [github](./packages/flutter_app_publisher/lib/src/publishers/github/) - 把你的应用发布到 `github` release。
- [pgyer](./packages/flutter_app_publisher/lib/src/publishers/pgyer/) - 把你的应用发布到 `pgyer`。
- [playstore](./packages/flutter_app_publisher/lib/src/publishers/playstore/) - Publish your app to `playstore`.
- [qiniu](./packages/flutter_app_publisher/lib/src/publishers/qiniu/) - 把你的应用发布到 `qiniu`。
- [vercel](./packages/flutter_app_publisher/lib/src/publishers/vercel/) - 把你的应用发布到 `vercel`。

## 立即开始

### 安装

```
dart pub global activate flutter_distributor
```

### 用法

将 `distribute_options.yaml` 添加到你的项目根目录。

```yaml
variables:
  PGYER_API_KEY: "your api key"
output: dist/
releases:
  - name: dev
    jobs:
      # 构建并发布您的 apk 包到 pgyer
      - name: release-dev-android
        package:
          platform: android
          target: apk
          build_args:
            target-platform: android-arm,android-arm64
            dart-define:
              APP_ENV: dev
        publish_to: pgyer
      # 构建并发布您的 ipa 包到 pgyer
      - name: release-dev-ios
        package:
          platform: ios
          target: ipa
          build_args:
            export-options-plist: ios/dev_ExportOptions.plist
            dart-define:
              APP_ENV: dev
        publish_to: pgyer
```

> `build_args` 是 `flutter build` 命令所支持的参数，请根据你的项目进行修改。

#### 发布你的应用

```
flutter_distributor release --name dev
```

## 谁在用使用它？

- [比译](https://biyidev.com/) - 一个便捷的翻译和词典应用。
- [钱迹](https://qianjiapp.com/) - 一款纯粹记账的应用。
- [Alga](https://github.com/laiiihz/alga/) - 一个开发者工具应用。
- [Airclap](https://airclap.app/) - 任何文件，任意设备，随意发送。简单好用的跨平台高速文件传输APP。

## 贡献者

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/lijy91"><img src="https://avatars.githubusercontent.com/u/3889523?v=4?s=100" width="100px;" alt="LiJianying"/><br /><sub><b>LiJianying</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=lijy91" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://juejin.cn/user/764915820276439"><img src="https://avatars.githubusercontent.com/u/8764899?v=4?s=100" width="100px;" alt="Zero"/><br /><sub><b>Zero</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=BytesZero" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/KRTirtho"><img src="https://avatars.githubusercontent.com/u/61944859?v=4?s=100" width="100px;" alt="Kingkor Roy Tirtho"/><br /><sub><b>Kingkor Roy Tirtho</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=KRTirtho" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/laiiihz"><img src="https://avatars.githubusercontent.com/u/35956195?v=4?s=100" width="100px;" alt="LAIIIHZ"/><br /><sub><b>LAIIIHZ</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=laiiihz" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ueki-tomohiro"><img src="https://avatars.githubusercontent.com/u/27331430?v=4?s=100" width="100px;" alt="Tomohiro Ueki"/><br /><sub><b>Tomohiro Ueki</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=ueki-tomohiro" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://cybrox.eu/"><img src="https://avatars.githubusercontent.com/u/2383736?v=4?s=100" width="100px;" alt="Sven Gehring"/><br /><sub><b>Sven Gehring</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=cybrox" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/GargantuaX"><img src="https://avatars.githubusercontent.com/u/14013111?v=4?s=100" width="100px;" alt="GargantuaX"/><br /><sub><b>GargantuaX</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=GargantuaX" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/hiperioncn"><img src="https://avatars.githubusercontent.com/u/6045710?v=4?s=100" width="100px;" alt="Hiperion"/><br /><sub><b>Hiperion</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=hiperioncn" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/GroovinChip"><img src="https://avatars.githubusercontent.com/u/4250470?v=4?s=100" width="100px;" alt="Reuben Turner"/><br /><sub><b>Reuben Turner</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=GroovinChip" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://animator.github.io"><img src="https://avatars.githubusercontent.com/u/615622?v=4?s=100" width="100px;" alt="Ankit Mahato"/><br /><sub><b>Ankit Mahato</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=animator" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://tienisto.com"><img src="https://avatars.githubusercontent.com/u/38380847?v=4?s=100" width="100px;" alt="Tien Do Nam"/><br /><sub><b>Tien Do Nam</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=Tienisto" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://zacksleo.top/"><img src="https://avatars.githubusercontent.com/u/3369169?v=4?s=100" width="100px;" alt="zacks"/><br /><sub><b>zacks</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=zacksleo" title="Code">💻</a></td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <td align="center" size="13px" colspan="7">
        <a href="https://all-contributors.js.org/docs/en/bot/usage">Add your contributions</a>
      </td>
    </tr>
  </tfoot>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

## 许可证

[MIT](./LICENSE)
