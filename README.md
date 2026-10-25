
QRCode Shelf
----

https://r.tiye.me/worktools/qrcode-shelf/

> List of QRCodes...

TODO

### Workflow

使用者影响：当前 0.31 线配对升级到已发布的 Calcit / `@calcit/procs`
`0.31.0-alpha.4`（仍为预发布），使用 Node.js 24、Yarn 4.18.0。消费方需
协调依赖图并重新生成 JS，不能与旧 CLI/runtime 混装。
Feather 使用已发布的 `0.5.0-alpha.2` 修复 SVG 宿主合同，其余模块 pin 不变；
这些 0.31 模块仍含预发布 tag，不能称为整张依赖图均为正式稳定版。
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
条码格式的字面量分支使用原生 `match`，默认仍为 CODE128；侧栏通过
`distinct-values` 保留原有去重 Set 语义。删除后的指针选择在已检查的 Map 上
调用 `.dissoc`，String 指针按原键移除，缺失或非 String 指针仍不移除任何键。
不改变存档、派发协议、HUD、业务测试或部署路径，不添加验证脚本或安全豁免。
0.30.1 候选迁移使用 `defref` / `add-watch!` 和 Respo 的 `render-with!`；
原 Map 存档及空选择的 nil 保持不变。旧 Map 中的文本、时间与组件状态在使用边界
进行实际检查，模态框回调声明真实的 Enum dispatcher 合同，不以类型断言代替验证。

### License

MIT
