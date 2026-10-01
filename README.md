
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
calcit --check-only
yarn build
node --test scripts/qrcode-regression.test.mjs
```

GitHub Actions 为 `dist` 中的前端资源设置 COS/CDN base URL，使用
`cos-upload-action` 1.1.1 内置的公开访问校验；同一 PR 前缀的上传串行执行。
原服务器 rsync 路径不变，服务代码不纳入 COS 上传。

现有 map 格式的本地存储保持兼容；事件使用单参数 Enum dispatch，
Reel 使用 typed State，查询结果显式处理 Option，DOM 与 Promise 操作使用 `js-ffi`。

### License

MIT
