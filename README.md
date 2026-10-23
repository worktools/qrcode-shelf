
QRCode Shelf
----

https://r.tiye.me/worktools/qrcode-shelf/

> List of QRCodes...

Prompt 类型兼容补丁（0.30.1 候选维护分支）
----

新增二维码和编辑备注的 Prompt 回调明确接收 String、返回 Unit；运行逻辑、
原 Map 存档格式、空备注的 nil、二维码/条形码生成和服务器部署路径均不改变。
此分支基于进入 0.31 alpha 前的提交，不回退或覆盖当前 alpha main。

两处类型声明已在 Alerts 0.10.58 候选的正式 Calcit / procs 0.30.1 联合 CI 中
通过全部定义、完整 strict、构建及原六项业务测试。该联合测试显式使用本地
Alerts / Feather 候选，不代表已发布依赖的 Caps 安装验收；本项目原依赖声明
暂不改成尚未发布的版本，正式工具链升级仍待相关依赖发布后单独完成。
维护分支 PR 不上传 COS、不执行 rsync；本补丁不授权合并或部署应用。

TODO

### Workflow

本维护补丁暂保留原配对 Calcit / `@calcit/procs` 0.30.1-alpha.5、Node.js 24、Yarn 4.18.0。
正式 0.30.1 CLI/npm 已发布；本项目尚待 Alerts / Feather 的正式依赖交付，
随后应成对升级工具链并重新验收，不能把本补丁的原依赖图当作最新正式迁移已完成。
Respo、Reel、UI、Feather、Alerts 和 js-ffi 使用精确正式 tag。
源码只保留 `calcit.cirru`，依赖使用 `deps.cirru`。

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

`yarn build` 根据已有默认 JS 配置编译并构建一次；`yarn dev` 先编译再启动 Vite。
持续编辑时在另一终端运行 `calcit calcit.cirru -w`。CI 保留 canonical、完整 strict、全部
公开定义、toolchain 和原六项业务测试，不新增独立迁移或诊断脚本。

现有 map 格式的本地存储保持兼容；事件使用单参数 Enum dispatch，
Reel 使用 typed State，查询结果显式处理 Option，DOM 与 Promise 操作使用 `js-ffi`。
0.30.1 候选迁移使用 `defref` / `add-watch!` 和 Respo 的 `render-with!`；
原 Map 存档及空选择的 nil 保持不变。旧 Map 中的文本、时间与组件状态在使用边界
进行实际检查，模态框回调声明真实的 Enum dispatcher 合同，不以类型断言代替验证。

### License

MIT
