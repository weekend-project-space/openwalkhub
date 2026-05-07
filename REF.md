基于 scheme r7rs 标准，进行的扩展

**OpenWalk（openwalk）命令参考手册**

### 1.基于 scheme r7rs 标准

### 2. Scheme 运行时（Runtime）

OpenWalk 约定脚本入口为：

```scheme
(define (main args)
  ...)
```

运行脚本时，会额外注入以下绑定：

| 绑定                     | 语法                                      | 说明                                                 |
| ------------------------ | ----------------------------------------- | ---------------------------------------------------- |
| `openwalk-script-path`   | `openwalk-script-path`                    | 当前脚本路径字符串                                   |
| `openwalk-script-meta`   | `openwalk-script-meta`                    | 当前脚本元信息                                       |
| `openwalk-args`          | `openwalk-args`                           | 传给脚本的参数列表                                   |
| `openwalk-output-format` | `(openwalk-output-format value [format])` | 将任意 Scheme 值渲染成 `yaml` / `md` / `json` 字符串 |

说明：

- `openwalk-output-format` 是脚本内格式化工具，返回值是字符串
- CLI 最终输出格式仍由 `-f` / `--format` 控制
- 浏览器 host function 抛出的错误会以 `error-object` 形式进入 Scheme，可用 `with-exception-handler` 捕获

最小脚本示例：

```scheme
(define (main args)
  (if (null? args)
      "hello world"
      (string-append "hello " (car args))))
```

格式化示例：

```scheme
(define (main args)
  (openwalk-output-format
    (list
      (cons "name" "OpenWalk")
      (cons "args" openwalk-args))
    "yaml"))
```

异常捕获示例：

```scheme
(define (main args)
  (with-exception-handler
    (lambda (e)
      (if (error-object? e)
          (error-object-message e)
          "unexpected"))
    (lambda ()
      (open "https://example.com"))))
```

---

### 3. 浏览器与页面（Browser & Page）

下表中的语法默认写成 CLI 形式；在 Scheme 脚本中，对应为同名函数调用。  
例如 `page-goto <url>` 在脚本里写成 `(page-goto "https://example.com")`。

| 命令                   | 语法                               | 说明                           |
| ---------------------- | ---------------------------------- | ------------------------------ |
| `browser-open`         | `browser-open <url>`               | 打开浏览器并导航到指定 URL     |
| `browser-list`         | `browser-list`                     | 列出当前已记录的浏览器会话名称 |
| `browser-version`      | `browser-version`                  | 读取浏览器版本信息             |
| `browser-close`        | `browser-close`                    | 关闭当前浏览器会话             |
| `page-goto`            | `page-goto <url>`                  | 当前活动标签页跳转到指定 URL   |
| `page-back`            | `page-back`                        | 页面后退                       |
| `page-forward`         | `page-forward`                     | 页面前进                       |
| `page-reload`          | `page-reload`                      | 刷新当前页面                   |
| `page-wait-navigation` | `page-wait-navigation`             | 等待一次页面导航完成           |
| `page-scroll-to`       | `page-scroll-to <x> <y>`           | 滚动到指定页面坐标             |
| `page-scroll-by`       | `page-scroll-by <x> <y>`           | 按偏移量滚动页面               |
| `device-viewport`      | `device-viewport <width> <height>` | 设置页面视口尺寸               |
| `page-snapshot`        | `page-snapshot`                    | 获取页面结构化快照             |
| `page-screenshot`      | `page-screenshot <path>`           | 保存当前页面截图               |
| `page-pdf`             | `page-pdf <path>`                  | 导出当前页面为 PDF             |
| `performance-metrics`  | `performance-metrics`              | 读取页面性能指标               |

补充说明：

- 推荐在 Scheme 脚本里优先使用 `(open <url>)`，由库函数自动决定是 `browser-open` 还是 `tab-new`
- `browser-list` 返回的是会话名列表，不是标签页列表
- `page-snapshot` 返回结构化对象，通常包含标题、URL、文本摘要、交互元素与活动元素信息

---

### 4. 元素与 JavaScript（DOM & JS）

| 命令                   | 语法                                   | 说明                             |
| ---------------------- | -------------------------------------- | -------------------------------- |
| `element-click`        | `element-click <selector>`             | 点击匹配元素                     |
| `element-double-click` | `element-double-click <selector>`      | 双击匹配元素                     |
| `element-right-click`  | `element-right-click <selector>`       | 右键点击匹配元素                 |
| `element-type`         | `element-type <selector> <text>`       | 向可编辑元素输入文本             |
| `element-fill`         | `element-fill <selector> <text>`       | 清空并填充输入框内容             |
| `element-select`       | `element-select <selector> <value>`    | 选择下拉框选项                   |
| `element-check`        | `element-check <selector>`             | 勾选复选框或单选框               |
| `element-uncheck`      | `element-uncheck <selector>`           | 取消勾选                         |
| `element-exists`       | `element-exists <selector>`            | 检查元素是否存在                 |
| `element-hover`        | `element-hover <selector>`             | 鼠标悬停到元素上                 |
| `element-upload`       | `element-upload <selector> <file...>`  | 向文件输入框上传一个或多个文件   |
| `element-drag`         | `element-drag <source> <target>`       | 在两个元素之间执行拖拽           |
| `element-screenshot`   | `element-screenshot <selector> <path>` | 保存元素截图                     |
| `js-eval`              | `js-eval <expression>`                 | 在当前页面执行 JavaScript 表达式 |
| `js-wait`              | `js-wait <expression>`                 | 等待 JavaScript 条件成立         |
| `time-sleep`           | `time-sleep <ms>`                      | 等待指定毫秒数                   |

说明：

- `selector` 当前以 CSS 选择器为主，也支持部分 XPath 路径
- `js-eval` 的返回值会尽量结构化；数组、对象会进入 OpenWalk 的输出格式化流程
- `element-upload` 需要真实存在的本地文件路径

---

### 5. 键盘、鼠标与触摸（Keyboard, Mouse & Touch）

| 命令             | 语法                                      | 说明                   |
| ---------------- | ----------------------------------------- | ---------------------- |
| `keyboard-press` | `keyboard-press <key>`                    | 按下并释放一个按键     |
| `keyboard-type`  | `keyboard-type <text>`                    | 向当前焦点元素键入文本 |
| `keyboard-down`  | `keyboard-down <key>`                     | 按下按键但不释放       |
| `keyboard-up`    | `keyboard-up <key>`                       | 释放一个按键           |
| `mouse-move`     | `mouse-move <x> <y>`                      | 移动鼠标到坐标         |
| `mouse-click`    | `mouse-click <x> <y>`                     | 在坐标处点击鼠标       |
| `mouse-down`     | `mouse-down <x> <y> <button>`             | 在坐标处按下鼠标按键   |
| `mouse-up`       | `mouse-up <x> <y> <button>`               | 在坐标处释放鼠标按键   |
| `mouse-wheel`    | `mouse-wheel <x> <y> <delta-x> <delta-y>` | 滚动鼠标滚轮           |
| `touch-tap`      | `touch-tap <x> <y>`                       | 模拟触摸点击           |

鼠标按键值通常使用：

- `left`
- `right`
- `middle`

---

### 6. 标签页与存储（Tabs & Storage）

`tab-*` 系列依赖一个已打开的浏览器页面；如果当前没有页面，会提示先调用 `browser-open`。

**标签页（Tabs）**

| 命令         | 语法               | 说明                                 |
| ------------ | ------------------ | ------------------------------------ |
| `tab-list`   | `tab-list`         | 列出当前会话中的所有标签页           |
| `tab-new`    | `tab-new [url]`    | 新建标签页，可选直接打开 URL         |
| `tab-select` | `tab-select <tab>` | 切换到指定标签页                     |
| `tab-close`  | `tab-close [tab]`  | 关闭指定标签页；不传时关闭当前标签页 |

说明：

- `tab-list` 对外展示短 `id`，并返回 `id`、`url`、`title`、`active`
- `tab-select` / `tab-close` 建议优先使用 `tab-list` 返回的短 `id`
- 目前也兼容数字索引作为 fallback，但更推荐使用短 `id`

**localStorage**

| 命令                  | 语法                             | 说明                     |
| --------------------- | -------------------------------- | ------------------------ |
| `localstorage-list`   | `localstorage-list`              | 列出所有 localStorage 项 |
| `localstorage-get`    | `localstorage-get <key>`         | 获取指定键值             |
| `localstorage-set`    | `localstorage-set <key> <value>` | 写入键值                 |
| `localstorage-remove` | `localstorage-remove <key>`      | 删除指定键               |
| `localstorage-clear`  | `localstorage-clear`             | 清空所有项               |

**sessionStorage**

| 命令                    | 语法                               | 说明                       |
| ----------------------- | ---------------------------------- | -------------------------- |
| `sessionstorage-list`   | `sessionstorage-list`              | 列出所有 sessionStorage 项 |
| `sessionstorage-get`    | `sessionstorage-get <key>`         | 获取指定键值               |
| `sessionstorage-set`    | `sessionstorage-set <key> <value>` | 写入键值                   |
| `sessionstorage-remove` | `sessionstorage-remove <key>`      | 删除指定键                 |
| `sessionstorage-clear`  | `sessionstorage-clear`             | 清空所有项                 |

**Cookies**

| 命令            | 语法                                              | 说明                 |
| --------------- | ------------------------------------------------- | -------------------- |
| `cookie-list`   | `cookie-list`                                     | 列出当前页面 cookies |
| `cookie-get`    | `cookie-get <name>`                               | 获取单个 cookie      |
| `cookie-set`    | `cookie-set <name> <value> [url] [domain] [path]` | 设置 cookie          |
| `cookie-delete` | `cookie-delete <name> [url] [domain] [path]`      | 删除指定 cookie      |
| `cookie-clear`  | `cookie-clear`                                    | 清空当前页面 cookies |

---

### 7. 网络与调试（Network & DevTools）

| 命令                     | 语法                                   | 说明                               |
| ------------------------ | -------------------------------------- | ---------------------------------- |
| `network-list`           | `network-list`                         | 显示当前页面记录到的网络请求与响应 |
| `network-wait-response`  | `network-wait-response <url_contains>` | 等待 URL 片段匹配的响应出现        |
| `network-response-body`  | `network-response-body <url_contains>` | 读取最近一次匹配响应的 body        |
| `console`                | `console [min-level]`                  | 显示控制台日志，可按最低级别过滤   |
| `console-clear`          | `console-clear`                        | 清空已记录的控制台日志             |
| `inspect-info`           | `inspect-info <selector>`              | 读取元素诊断信息                   |
| `inspect-highlight`      | `inspect-highlight <selector>`         | 高亮匹配元素                       |
| `inspect-hide-highlight` | `inspect-hide-highlight`               | 关闭调试高亮                       |
| `inspect-pick`           | `inspect-pick [timeout-ms]`            | 交互式选择页面元素                 |
| `tracing-start`          | `tracing-start [categories]`           | 开始记录 tracing                   |
| `tracing-stop`           | `tracing-stop <path>`                  | 停止 tracing 并导出文件            |
| `cdp-call`               | `cdp-call <method> <params>`           | 直接调用 CDP 方法                  |

说明：

- `console` 返回按时间、级别、正文、来源位置格式化后的日志行
- `network-list` 适合排查请求顺序、状态码、资源类型
- `cdp-call` 的 `params` 需要传 JSON 字符串

---

### 8. 典型示例（Examples）

**1. 运行最小脚本**

```bash
cargo run -- run hello-word -- OpenWalk
```

```scheme
#| @meta
{
  "name": "hello-word",
  "description": "返回一个简单的问候语，适合验证 Scheme tool 是否工作正常",
  "args": [
    {
      "name": "name",
      "type": "string",
      "required": false,
      "default": "world",
      "description": "可选的人名或目标词，默认 world"
    }
  ],
  "returns": {
    "type": "string",
    "description": "hello <name> 格式的问候语"
  },
  "examples": [
    "openwalk exec hello-word",
    "openwalk exec hello-word -- OpenWalk"
  ],
  "domains": [],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "hello",
    "demo",
    "smoke-test"
  ]
}
|#
(define (main args)
  (if (null? args)
      "hello world"
      (string-append "hello " (car args))))
```

**2. 打开浏览器并搜索 Bing**

```scheme
#| @meta
{
  "name": "bing/search",
  "description": "Bing 搜索并返回结构化结果",
  "args": [
    {
      "name": "query",
      "type": "string",
      "required": true,
      "description": "搜索关键词"
    },
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 10,
      "description": "返回结果数量，默认 10"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ query, count, results[] }"
  },
  "examples": [
    "openwalk exec bing/search -- \"Claude Code\" 10"
  ],
  "domains": [
    "www.bing.com",
    "cn.bing.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "search",
    "bing"
  ]
}
|#

(define (main args)
  (define query
    (if (null? args) "OpenAI" (car args)))
  (open "https://www.bing.com")
  (js-wait "(() => !!document.querySelector('#sb_form_q'))()")
  (element-fill "#sb_form_q" query)
  (keyboard-press "Enter")
  (page-wait-navigation)
  (js-eval "({ title: document.title, url: location.href })"))
```
