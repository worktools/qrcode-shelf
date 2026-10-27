
QRCode Shelf
----

https://r.tiye.me/worktools/qrcode-shelf/

> List of QRCodes...

TODO

### Workflow

使用者影响：无效存档现在会明确报错并停止启动，保存回调不注册，原文不会被空状态覆盖；正常 Map 存档合同保持。候选将 CLI / `@calcit/procs` 从 alpha.7 成对升级到正式 **0.31.0**，使用真实已发布的 Respo **0.17.0-alpha.4**、UI **0.9.0-alpha.4**、Reel **0.7.0-alpha.4**、Feather **0.5.0-alpha.5**、Alerts **0.11.0-alpha.3**、JS-FFI **0.2.7**。开发者需整图更新、重新生成 JS 并重启服务；部分模块沿用既有 alpha 发布线，不称为整个图均稳定。

同时复用已有 Dependabot **#29** 的完整 min-document **2.19.2** 锁条目，不额外修改其版本或 checksum。Node 24、Yarn 4.18.0、JSBarcode 与 QRCode 包版本保持，App 仍为 0.1.0。只维护 calcit.cirru/deps.cirru，生成 js-out 不入库。

```sh
caps --strict --ci
yarn install --immutable
caps verify --toolchain
calcit --check-only --all-defs
calcit fix --workflow strict --verify
yarn build
node --test scripts/qrcode-regression.test.mjs
```

GitHub Actions 为 `dist` 中的前端资源设置 COS/CDN base URL，使用
正式 `cos-upload-action` v1.2.0 内置 HTML 引用和公开访问校验，不增加独立验证脚本。
PR 前缀使用 `pr/<number>/<run-id>/<attempt>/`，按 PR 分组排队，生产独立排队，上传不取消。
原服务器 rsync 路径不变，服务代码不纳入 COS 上传。
Dependabot 和 fork PR 保留完整检查、原测试与构建，但不使用普通 Actions secrets 上传 COS；
人工重跑也不扩大权限。普通同仓库 PR 预览和 main 的原部署条件不变。

`yarn build` 根据已有默认 JS 配置编译并构建一次；`yarn dev` 先编译再启动 Vite。
持续编辑时在另一终端运行 `calcit calcit.cirru -w`。CI 保留 canonical、完整 strict、全部
公开定义、toolchain 和原六项业务测试，不新增独立迁移或诊断脚本。

现有 map 格式的本地存储保持兼容；事件使用单参数 Enum dispatch，
Reel 使用 typed State，查询结果显式处理 Option，DOM 与 Promise 操作使用 `js-ffi`。
条码格式的字面量分支使用原生 `match`，默认仍为 CODE128；侧栏通过
`distinct-values` 保留原有去重 Set 语义。删除后的指针选择在已检查的 Map 上
调用 `.dissoc`，String 指针按原键移除，缺失或非 String 指针仍不移除任何键。
正常存档格式、派发协议、业务测试和部署路径保持，原热更新回调不改；启动异常通过现有 bottom-tip 在页面显示，并继续抛出以停止启动。存档恢复提前到首屏渲染/watch/定时与离页保存之前，解析或 Map 解码失败不再吞掉异常；不补默认存档，不添加验证脚本或安全豁免。
沿用 `defref` / `add-watch!` 和 Respo 的 `render-with!`；
原 Map 存档及空选择的 nil 保持不变。旧 Map 中的文本、时间与组件状态在使用边界
进行实际检查，模态框回调声明真实的 Enum dispatcher 合同，不以类型断言代替验证。

本轮正式发布图通过完整 strict、全部/公共定义、不可变安装、原 7 项 Node 回归及构建。实际隔离页面通过合成二维码/条码切换、备注与正常刷新恢复；合成解析坏存档和非 Map 存档均经过启动、刷新及离页检查，跨过原 60 秒保存周期后原文保留，错误 HUD 在页面可见。未操作真实数据、复制或删除；这些夹具不进入仓库或 dist。

### License

MIT
