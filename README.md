# Cloudflare IP 优选助手

这是一个公开众测版 Cloudflare 优选 IP 项目。

用户在 OpenWrt 路由器上安装 LuCI 插件后，填写昵称并设置测速时间。插件会自动运行 `cfst` 测速，把结果上传到 Cloudflare Worker。服务端会按省份和运营商聚合出当前可用的优选 IP，并生成类似下面的域名：

```text
sx.cu.6610000.xyz
sh.ct.6610000.xyz
gd.cm.6610000.xyz
```

项目页面：

```text
https://cf.6610000.xyz
```

GitHub：

```text
https://github.com/10000ge10000/cf-ip-speed-panel
```

## 能做什么

- OpenWrt / LuCI 插件自动测速并上传结果。
- 自动判断疑似代理出口，疑似代理数据会展示贡献，但不会参与 DNS 优选。
- 按省份和运营商聚合可信测速结果。
- 自动更新 `省份缩写.运营商.6610000.xyz` 这类 DNS 记录。
- Web 页面展示优选 IP、速度、延迟、贡献者和最后同步时间。

## OpenWrt 安装

到 Release 下载对应系统版本的两个 IPK：

```text
https://github.com/10000ge10000/cf-ip-speed-panel/releases
```

需要安装：

```text
cf-ip-speed-client
luci-app-cf-ip-speed-client
```

安装示例：

```sh
opkg install ./cf-ip-speed-client_*.ipk
opkg install ./luci-app-cf-ip-speed-client_*.ipk
/etc/init.d/rpcd restart
/etc/init.d/uhttpd restart
```

安装后进入 LuCI：

```text
服务 -> Cloudflare IP 优选助手
```

填写：

- 昵称
- 测速方式：每隔几小时测速，或每天固定时间测速
- 是否启用

建议每天定时测速选择凌晨 3 点到 5 点，尽量减少对正常上网和代理使用的影响。

## IPK / APK 版本说明

- IPK：适用于 OpenWrt 23、24 以及仍使用 `opkg` 的系统。
- APK：OpenWrt 未来使用 apk 包管理器的版本预留入口，当前项目暂不发布 APK。
- 目前 GitHub Actions 支持手动构建 x86、ARM64、ARMv7、MIPS 等主流平台。
- OpenWrt 25 固定版本发布后，可以在 workflow 里把 snapshot 目标替换为官方 25.x SDK 目标。

## 手动编译

本项目不会在 push 或 tag 时自动编译 OpenWrt 包。需要手动进入 GitHub Actions：

```text
Actions -> Manual OpenWrt package build -> Run workflow
```

可选构建范围：

- `stable`：OpenWrt 23.05 / 24.10 常见架构。
- `snapshot`：OpenWrt snapshot，面向后续 25 版本和新平台。
- `all`：全部构建。

如果需要把 IPK 上传到 Release，勾选 `publish_release` 并填写 `release_tag`。

## Worker 部署

```sh
npm install
npm run check
npx wrangler d1 migrations apply cf-ip-speed-panel --remote
npx wrangler secret put UPLOAD_TOKEN
npx wrangler secret put DNS_API_TOKEN
npm run deploy
```

需要的 Cloudflare 资源：

- Workers
- D1
- KV
- DNS 编辑权限，仅限 `6610000.xyz`

密钥只放 Cloudflare Secret，不要写进源码。

## 注意事项

- 插件不会保存 Cloudflare Token。
- OpenWrt 本机会保存设备上传凭据 `device_id/device_token`，用于识别这台设备。
- 服务端 D1 只保存设备 token 的哈希，不保存明文 token。
- 如果路由器被入侵，攻击者最多冒充该设备上传数据，不能操作 Cloudflare DNS。
- 疑似代理、云服务器出口、境外出口的数据不会参与自动 DNS 优选。
- 昵称先到先得，`一万AI分享` 作为项目测试昵称允许存在多台测试设备。

## 目录结构

```text
src/                 Cloudflare Worker 源码
migrations/          D1 数据库表结构
openwrt-packages/    OpenWrt 客户端和 LuCI 插件
scripts/             Windows / Linux 上传脚本
.github/workflows/   CI 和手动 OpenWrt 构建
```
