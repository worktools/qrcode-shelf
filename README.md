
QRCode Shelf
----

https://r.tiye.me/worktools/qrcode-shelf/

> List of QRCodes...

TODO

### Workflow

使用 Calcit / `@calcit/procs` 0.27.0、Node.js 24、Yarn 4.18.0。
源码只保留 `calcit.cirru`，依赖使用 `deps.cirru`。

```sh
caps --strict --ci
yarn install --immutable
caps verify --toolchain
yarn build
node --test scripts/qrcode-regression.test.mjs
```

GitHub Actions 为 `dist` 中的前端资源设置 COS/CDN base URL，使用
正式 `cos-upload-action` v1.2.0 内置 HTML 引用和公开访问校验，不增加独立验证脚本。
PR 前缀使用 `pr/<number>/<run-id>/<attempt>/`，按 PR 分组排队，生产独立排队，上传不取消。
原服务器 rsync 路径不变，服务代码不纳入 COS 上传。

`yarn build` 根据已有默认 JS 配置编译并构建一次；`yarn dev` 先编译再启动 Vite。
持续编辑时在另一终端运行 `calcit calcit.cirru -w`。CI 保留 canonical、入口与全部
公开定义、toolchain 和原六项业务测试，不反复运行迁移或诊断报告。

现有 map 格式的本地存储保持兼容；事件使用单参数 Enum dispatch，
Reel 使用 typed State，查询结果显式处理 Option，DOM 与 Promise 操作使用 `js-ffi`。

### License

MIT
