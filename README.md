# Cloudflare IP 优选助手

这是一个公开众测版 Cloudflare 优选 IP 项目。

OpenWrt 用户安装 LuCI 插件后，填写昵称并设置测速时间。插件会自动运行 `cfst`，上传测速结果。Cloudflare Worker 会按省份和运营商聚合可信数据，并生成类似下面的域名：

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

## 功能

- OpenWrt / LuCI 插件自动测速并上传结果。
- 疑似代理数据会保留贡献记录，但不参与 DNS 优选。
- 按省份和运营商聚合最佳 IP。
- 自动更新 `省份缩写.运营商.6610000.xyz` DNS。
- Web 页面展示 IP、速度、延迟、贡献者和最后同步时间。
- 管理员 API 支持封禁设备、封禁昵称、维护昵称敏感词库。

## OpenWrt 安装

一键安装：

```sh
sh -c "$(wget -O- https://raw.githubusercontent.com/10000ge10000/cf-ip-speed-panel/main/scripts/install-openwrt.sh)"
```

也可以到 Release 手动下载对应版本的两个 IPK：

```text
https://github.com/10000ge10000/cf-ip-speed-panel/releases
```

必须安装这两个包：

```text
cf-ip-speed-client
luci-app-cf-ip-speed-client
```

手动安装示例：

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

填写昵称，选择测速方式，然后启用即可。建议每天定时测速选择凌晨 3 点到 5 点，减少对正常上网的影响。

## 版本说明

- IPK：适用于 OpenWrt 23、24 以及仍使用 `opkg` 的系统。
- APK：当前暂不发布，后续等 OpenWrt apk 包管理器生态稳定后再补。
- 已支持手动构建 x86、ARM64、ARMv7、MIPS 常见平台。
- OpenWrt 25 固定版本发布后，把 workflow 里的 snapshot 目标替换为官方 25.x SDK 目标即可。

## 手动编译

本项目不会在 push 或 tag 时自动编译 OpenWrt 包。

进入 GitHub：

```text
Actions -> Manual OpenWrt package build -> Run workflow
```

可选：

- `stable`：OpenWrt 23.05 / 24.10 常见架构。
- `snapshot`：OpenWrt snapshot，用于新平台和后续 25 版本。
- `all`：全部构建。

如果要上传到 Release，勾选 `publish_release` 并填写 `release_tag`。

## Worker 部署

```sh
npm install
npm run check
npx wrangler d1 migrations apply cf-ip-speed-panel --remote
npx wrangler secret put UPLOAD_TOKEN
npx wrangler secret put ADMIN_TOKEN
npx wrangler secret put DNS_API_TOKEN
npm run deploy
```

需要 Cloudflare：

- Workers
- D1
- KV
- DNS 编辑权限，仅限你的域名

密钥只放 Cloudflare Secret，不要写进源码。

## 管理员 API

管理员 API 使用：

```text
Authorization: Bearer <ADMIN_TOKEN>
```

常用接口：

```text
GET    /api/admin/uploads
POST   /api/admin/block-device
POST   /api/admin/block-nickname
GET    /api/admin/bad-words
POST   /api/admin/bad-words
DELETE /api/admin/bad-words?pattern=xxx
POST   /api/admin/rebuild
```

示例：

```sh
curl -H "Authorization: Bearer $ADMIN_TOKEN" https://cf.6610000.xyz/api/admin/uploads
```

## 注意事项

- 插件不会保存 Cloudflare Token。
- OpenWrt 本机会保存 `device_id/device_token`，用于识别设备。
- 服务端 D1 只保存设备 token 的哈希，不保存明文 token。
- 如果路由器被入侵，攻击者最多冒充该设备上传数据，不能操作 Cloudflare DNS。
- 疑似代理、云服务器出口、境外出口数据不会参与自动 DNS 优选。
- 昵称先到先得，`一万AI分享` 是项目测试昵称，允许存在多台测试设备。
