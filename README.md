# openwalkhub

脚本文件编写参考 项目和 基于scheme r7rs 进行了浏览器自动化相关扩展[说明引用](./ref.md)

## 代码风格

### Scheme 库层

- 公共语法和公共入口放在 `lib/lib.scm`
- 对外暴露的能力使用简短直接的命名，比如 `def`、`defun`、`open`
- 函数定义优先使用 `defun`
- 不对外暴露的 helper 使用 `%` 前缀区分，比如 `%open-impl`
- 谓词函数保留 `?` 后缀，比如 `%browser-session-exists?`

### 工具文件

- 每个工具使用独立的 `main.scm`
- 文件开头先写 `@meta`，描述 `name`、`args`、`returns`、`domains`、`examples`
- 工具入口统一使用 `defun main (args)`

### 实现风格

- Scheme 层尽量保持轻量，只做参数处理、少量字符串拼接和工具编排
- 取网页数据时，优先使用 `(open "https://目标站点")` 配合 `js-eval`
- 在 `js-eval` 中优先使用 `async` + `fetch(...)` 拉取数据
- 尽量避免通过打开 API 页面、读取页面文本、再 `page-goto` 的方式中转

### 返回数据风格

- 返回结构化对象，优先返回稳定字段，而不是原始页面文本
- 列表结果优先包含 `source`、`count` 和数据数组
- 详情结果优先返回主体字段和子项数组
- 字段尽量补默认值，比如空字符串、`0` 或空数组，减少上层兼容成本
