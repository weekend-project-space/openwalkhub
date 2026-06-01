async (args) => {
  const BLOCK_TAGS = new Set([
    "address",
    "article",
    "aside",
    "blockquote",
    "dd",
    "div",
    "dl",
    "dt",
    "fieldset",
    "figcaption",
    "figure",
    "footer",
    "form",
    "header",
    "hr",
    "li",
    "main",
    "nav",
    "ol",
    "p",
    "pre",
    "section",
    "table",
    "ul",
  ]);

  const SKIP_TAGS = new Set([
    "canvas",
    "iframe",
    "noscript",
    "script",
    "style",
    "svg",
    "template",
  ]);

  const normalizeWhitespace = (text) =>
    String(text || "")
    .replace(/\u00a0/g, " ")
    .replace(/[ \t\f\v]+/g, " ")
    .replace(/ *\n */g, "\n")
    .replace(/\n{3,}/g, "\n\n")
    .trim();

  const escapeTableCell = (text) => normalizeWhitespace(text).replace(/\|/g, "\\|");

  const escapeInlineCode = (text) => {
    const value = String(text || "").replace(/\s+/g, " ").trim();
    if (!value) return "";
    const ticks = value.match(/`+/g) || [];
    const fence = "`".repeat(Math.max(1, ...ticks.map((item) => item.length)) + 1);
    return `${fence}${value}${fence}`;
  };

  const isElement = (node) => node && node.nodeType === Node.ELEMENT_NODE;

  const isHidden = (el) => {
    if (!isElement(el)) return false;
    if (el.hidden || el.getAttribute("aria-hidden") === "true") return true;
    const style = getComputedStyle(el);
    return (
      style.display === "none" ||
      style.visibility === "hidden" ||
      Number(style.opacity) === 0
    );
  };

  const absoluteUrl = (href) => {
    if (!href || href.startsWith("#") || href.startsWith("javascript:")) return "";
    try {
      return new URL(href, location.href).href;
    } catch (_) {
      return href;
    }
  };

  const childText = (node) =>
    Array.from(node.childNodes)
    .map((child) => inlineToMarkdown(child))
    .join("");

  const inlineToMarkdown = (node) => {
    if (!node) return "";

    if (node.nodeType === Node.TEXT_NODE) {
      return node.textContent.replace(/\s+/g, " ");
    }

    if (!isElement(node) || isHidden(node)) return "";

    const tag = node.tagName.toLowerCase();
    if (SKIP_TAGS.has(tag)) return "";
    if (tag === "br") return "\n";

    if (tag === "a") {
      const text = normalizeWhitespace(childText(node));
      const href = absoluteUrl(node.getAttribute("href"));
      if (!text) return "";
      return href ? `[${text}](${href})` : text;
    }

    if (tag === "strong" || tag === "b") {
      const text = normalizeWhitespace(childText(node));
      return text ? `**${text}**` : "";
    }

    if (tag === "em" || tag === "i") {
      const text = normalizeWhitespace(childText(node));
      return text ? `*${text}*` : "";
    }

    if (tag === "code" && node.parentElement.tagName.toLowerCase() !== "pre") {
      return escapeInlineCode(node.textContent);
    }

    if (tag === "img") {
      const alt = normalizeWhitespace(node.getAttribute("alt") || "");
      const src = absoluteUrl(node.getAttribute("src"));
      if (!alt && !src) return "";
      return src ? `![${alt}](${src})` : alt;
    }

    return childText(node);
  };

  const tableToMarkdown = (table) => {
    const rows = Array.from(table.querySelectorAll("tr"))
      .filter((row) => !isHidden(row))
      .map((row) =>
        Array.from(row.children)
        .filter((cell) => ["td", "th"].includes(cell.tagName.toLowerCase()))
        .map((cell) => escapeTableCell(inlineToMarkdown(cell)))
      )
      .filter((row) => row.length > 0);

    if (!rows.length) return "";

    const width = Math.max(...rows.map((row) => row.length));
    const normalizedRows = rows.map((row) =>
      row.concat(Array(Math.max(0, width - row.length)).fill(""))
    );

    const header = normalizedRows[0];
    const separator = Array(width).fill("---");
    const body = normalizedRows.slice(1);

    return [
      `| ${header.join(" | ")} |`,
      `| ${separator.join(" | ")} |`,
      ...body.map((row) => `| ${row.join(" | ")} |`),
    ].join("\n");
  };

  const listToMarkdown = (list, depth) => {
    const ordered = list.tagName.toLowerCase() === "ol";
    return Array.from(list.children)
      .filter((child) => child.tagName.toLowerCase() === "li" && !isHidden(child))
      .map((item, index) => {
        const marker = ordered ? `${index + 1}.` : "-";
        const prefix = "  ".repeat(depth);
        const directParts = Array.from(item.childNodes).filter(
          (child) =>
          !(
            isElement(child) && ["ol", "ul"].includes(child.tagName.toLowerCase())
          )
        );
        const directText = normalizeWhitespace(
          directParts.map((child) => inlineToMarkdown(child)).join("")
        );
        const nested = Array.from(item.children)
          .filter((child) => ["ol", "ul"].includes(child.tagName.toLowerCase()))
          .flatMap((child) => listToMarkdown(child, depth + 1));

        return [`${prefix}${marker} ${directText}`, ...nested]
          .filter((line) => normalizeWhitespace(line))
          .join("\n");
      })
      .filter(Boolean);
  };

  const blockToMarkdown = (el, depth = 0) => {
    if (!isElement(el) || isHidden(el)) return [];

    const tag = el.tagName.toLowerCase();
    if (SKIP_TAGS.has(tag)) return [];

    if (/^h[1-6]$/.test(tag)) {
      const text = normalizeWhitespace(inlineToMarkdown(el));
      return text ? [`${"#".repeat(Number(tag.slice(1)))} ${text}`] : [];
    }

    if (tag === "p") {
      const text = normalizeWhitespace(inlineToMarkdown(el));
      return text ? [text] : [];
    }

    if (tag === "blockquote") {
      const lines = Array.from(el.children).flatMap((child) =>
        blockToMarkdown(child, depth)
      );
      const fallback = lines.length ? lines : [normalizeWhitespace(inlineToMarkdown(el))];
      return fallback
        .filter(Boolean)
        .map((line) =>
          line
          .split("\n")
          .map((part) => `> ${part}`)
          .join("\n")
        );
    }

    if (tag === "pre") {
      const code = el.textContent.replace(/\n+$/g, "");
      return code ? [`\`\`\`\n${code}\n\`\`\``] : [];
    }

    if (tag === "ul" || tag === "ol") {
      return listToMarkdown(el, depth);
    }

    if (tag === "table") {
      const markdown = tableToMarkdown(el);
      return markdown ? [markdown] : [];
    }

    if (tag === "hr") {
      return ["---"];
    }

    const childBlocks = Array.from(el.children).flatMap((child) =>
      blockToMarkdown(child, depth)
    );
    if (childBlocks.length) return childBlocks;

    const text = normalizeWhitespace(inlineToMarkdown(el));
    return text ? [text] : [];
  };

  const chooseRoot = () =>
    document.querySelector("main") ||
    document.querySelector("article") ||
    document.querySelector('[role="main"]') ||
    document.body;

  const title = normalizeWhitespace(document.title);
  const root = chooseRoot();
  const body = blockToMarkdown(root)
    .map(normalizeWhitespace)
    .filter(Boolean);

  return [title ? `# ${title}` : "", ...body].filter(Boolean).join("\n\n");
}