
QRCode Shelf
----

https://r.tiye.me/worktools/qrcode-shelf/

> List of QRCodes...

TODO

### Workflow

#### Calcit 0.41.1

升级 CLI 和 `@calcit/procs` 到 **0.41.1** 后，按 `deps.cirru` 安装并重新生成 JS。旧二维码、条码及备注继续使用原 Map 存档格式，空备注仍写为 `:note nil`。
内部条码格式操作使用具名 `BarcodeFormat`，存档仍保存原格式 Tag。格式菜单的 Clear 关闭菜单并保留当前格式。

应用操作使用具体的字符串 ID、`Option<String>` 备注、Tag 格式和 Respo `CoordKey` 路径。Reel 0.11.0 的面板和快捷键走独立的 `Control` 回调，控制操作不会增加业务历史。

#### Calcit 0.36.0 迁移记录

开发者请同步安装正式 Calcit CLI 和 `@calcit/procs` **0.36.0**，严格安装完整依赖图、重新生成 JS 并刷新。
正式模块为 Respo 0.19.4、UI 0.15.1、Reel 0.9.2、Feather 0.6.2、Alerts 0.14.0、JS-FFI 0.2.13，传递 Router 0.12.1。新增二维码和编辑备注的 Prompt 回调都接收 String。
原二维码/条码绘制、默认 CODE128、Map 存档、侧栏条码图标及开发模式的 Inspector/Reel 条件保留。
Calcit 0.36.0 不再允许把 Option 退回 nil：未选择时选中判断不会命中任何 id，空备注仍存成 `:note nil`，未设置格式按 CODE128；`dispatch!`、`updater` 和 `d!` 的操作类型从裸 `Enum` 改为 `app.schema/Op`。

本轮修复开发工具接线：[控制命令被记作业务操作 #36](https://github.com/worktools/qrcode-shelf/issues/36)。
派发入口先使用已发布的 typed/decode-control / typed/apply-control，业务 Enum 仍走原 updater/record-op。
旧路径实测 `:reel/toggle` 不改变 display? 却增加历史；新路径正确开关面板，且不增加业务历史或改变 Store。
已有控制命令现在按 Reel 协议执行，其非法参数由原库 decoder 拒绝；业务/存档协议不收窄，不增加编译器特例。

DOM 回调改用真实 RespoEvent，两个旧方向间距改为 space-x。模态菜单的异构结果和旧条码格式的 fallback 边界仍为 Dynamic。
原 26 个定义全部保留，只有三个组件和 dispatch! 的代码变化；所有原 schema/附带 metadata 不变。
unsafe 仍为 0、codeNil 22→20，schemaDynamic 仍为 29；统计仅用于定位，不新增或放宽门禁/预算。

本地完整 strict diagnostics=[]、全部 276 个定义、七个应用 namespace 的 26 个定义、原七项 Node、严格 Caps/toolchain、
immutable、canonical 和 Vite 构建通过。原测试输入及断言保留，只适配 managed memo frame，并在原 Reel 测试组内补真实应用
控制命令“不改变 Store/不增加记录”的回归；不增加 runner 或测试矩阵。没有附带 native 测试，不把空集算作通过。
独立 Chrome/全新回环来源实测合成二维码/条码图片解码、备注、侧栏图标条件、两条记录切换、Reel 快捷键开关及刷新恢复，
页面异常、console warn/error、资源失败均为空。不读取真实数据，不操作复制或删除；本轮未重新注入坏存档/编译错误或复验 HMR。
恢复顺序、异常 HUD 启动入口、reloader、SDK 和绘制实现均未改。仅创建原隔离 PR COS 预览，不合并/生产部署或发版。

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
公开定义、toolchain 和原七项业务测试，不新增独立迁移或诊断脚本。

现有 map 格式的本地存储保持兼容；事件使用单参数 Enum dispatch，
Reel 使用 typed State，查询结果显式处理 Option，DOM 与 Promise 操作使用 `js-ffi`。
条码格式的字面量分支使用原生 `match`，默认仍为 CODE128；侧栏通过
`distinct-values` 保留原有去重 Set 语义。删除后的 Set 转 List 改用公开 `.to-list`，直接对应原底层实现，不新增排序或改变去重语义。指针选择在已检查的 Map 上
调用 `.dissoc`，String 指针按原键移除，缺失或非 String 指针仍不移除任何键。
正常存档格式、派发协议、业务测试和部署路径保持，原热更新回调不改；启动异常通过现有 bottom-tip 在页面显示，并继续抛出以停止启动。存档恢复提前到首屏渲染/watch/定时与离页保存之前，解析或 Map 解码失败不再吞掉异常；不补默认存档，不添加验证脚本或安全豁免。
沿用 `defref` / `add-watch!` 和 Respo 的 `render-with!`；
原 Map 存档及空选择的 nil 保持不变。旧 Map 中的文本、时间与组件状态在使用边界
进行实际检查，模态框回调声明真实的 Enum dispatcher 合同，不以类型断言代替验证。

历史 0.34.1 验收：当时已完成合成解析坏存档与非 Map 存档的启动、刷新、离页及原 60 秒周期保护，错误 HUD 可见；这些是历史证据，不计为本轮重新执行。夹具不进入仓库或 dist。

### License

MIT
