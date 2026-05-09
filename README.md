# openwalkhub

脚本文件编写参考 项目和 基于scheme r7rs 进行了浏览器自动化相关扩展[说明引用](./ref.md)

## 代码风格

### Scheme 库层

- 公共语法和公共入口放在 `lib/lib.scm`
- 对外暴露的能力使用简短直接的命名，比如 `def`、`defun`、`open`
- 函数定义优先使用 `defun`
- 不对外暴露的 helper 使用 `%` 前缀区分，比如 `%open-impl`
- 谓词函数保留 `?` 后缀，比如 `%browser-session-exists?`
- alist 取值统一使用 `alist-get`

### 工具文件

- 每个工具使用独立的 `main.scm`
- 文件开头先写 `@meta`，描述 `name`、`args`、`returns`、`domains`、`examples`
- 工具入口统一使用 `defun main (args)`
- 如果要兼容位置参数，可以保留一个很薄的 `%normalized-args`

### 实现风格

- Scheme 层尽量保持轻量，只做参数处理、少量校验和工具编排
- 取网页数据时，优先使用 `(open "https://目标站点")` 配合 `js-call`
- `js-call` 优先直接传一整段多行 JS，不要拆成很多个字符串片段
- 需要参数时优先写成 `(js-call args "...")`，在 JS 中直接通过 `args.xxx` 读取
- 需要兼容位置参数时，可以先在 Scheme 层归一化，再写成 `(js-call normalized-args "...")`
- 纯页面抓取优先使用 `open` + `js-wait` + `js-call`
- API 抓取优先使用 `open` + `js-call` + `fetch(...)`
- URL 拼接、`encodeURIComponent(...)`、返回结构组装，优先放在 JS 里完成
- 尽量避免通过打开 API 页面、读取页面文本、再 `page-goto` 的方式中转
- 除非是底层能力封装，否则不再优先使用 `js-eval`

### 推荐模版

列表类工具：

```scheme
(defun main (args)
  (open "https://example.com")
  (js-call args
    " const source = 'https://example.com/api/list';
      const limit = Math.min(50, Math.max(1, Number(args.count) || 20));

      const resp = await fetch(source);
      if (!resp.ok) {
        return {
          error: 'HTTP ' + resp.status,
          source,
        };
      }

      const data = await resp.json();
      const items = (data.items || [])
        .slice(0, limit)
        .map((item, index) => ({
          rank: index + 1,
          id: item.id || '',
          title: item.title || '',
        }));

      return {
        source,
        count: items.length,
        items,
      };
    "))
```

详情类工具：

```scheme
(defun main (args)
  (open "https://example.com")
  (js-call args
    " const source =
        'https://example.com/api/detail?id=' +
        encodeURIComponent(args.id);

      const resp = await fetch(source);
      if (!resp.ok) {
        return {
          error: 'HTTP ' + resp.status,
          source,
        };
      }

      const data = await resp.json();
      return {
        source,
        id: data.id || '',
        title: data.title || '',
        comments: (data.comments || []).map((comment, index) => ({
          rank: index + 1,
          author: comment.author || '',
          content: comment.content || '',
        })),
      };
    "))
```

### 返回数据风格

- 返回结构化对象，优先返回稳定字段，而不是原始页面文本
- 列表结果优先包含 `source`、`count` 和数据数组
- 多接口详情结果优先明确命名，比如 `topic_source`、`answers_source`
- 详情结果优先返回主体字段和子项数组
- 字段尽量补默认值，比如空字符串、`0` 或空数组，减少上层兼容成本
- 错误结果优先返回 `error`、`hint` 和相关 `source`
