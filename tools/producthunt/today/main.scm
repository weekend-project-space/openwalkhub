#| @meta
{
  "name": "producthunt/today",
  "description": "获取 Product Hunt 今日产品并返回结构化结果",
  "args": [
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回产品数量，默认 20，最大 50"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ source, count, products[] }"
  },
  "examples": [
    "openwalk exec producthunt/today"
  ],
  "domains": [
    "www.producthunt.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "producthunt",
    "today",
    "products"
  ]
}
|#

(defun main (args)
  (open "https://www.producthunt.com")
  (js-call args
    " const count = Math.min(parseInt(args.count, 10) || 20, 50);

      try {
        const today = new Date();
        const dateStr =
          today.getFullYear() +
          '-' +
          String(today.getMonth() + 1).padStart(2, '0') +
          '-' +
          String(today.getDate()).padStart(2, '0');
        const csrfMeta = document.querySelector('meta[name=\"csrf-token\"]');
        const csrfToken = csrfMeta ? csrfMeta.getAttribute('content') : '';
        const headers = {
          'Content-Type': 'application/json',
          Accept: 'application/json',
        };
        if (csrfToken) {
          headers['X-CSRF-Token'] = csrfToken;
        }

        const query = `query HomefeedQuery($date: DateTime, $cursor: String) {
          homefeed(date: $date, after: $cursor, first: 50) {
            edges {
              node {
                ... on Post {
                  id
                  name
                  tagline
                  description
                  votesCount
                  commentsCount
                  createdAt
                  featuredAt
                  slug
                  url
                  website
                  reviewsRating
                  thumbnailUrl
                  topics(first: 5) {
                    edges {
                      node {
                        name
                        slug
                      }
                    }
                  }
                  makers {
                    name
                    username
                  }
                }
              }
            }
          }
        }`;

        const gqlResp = await fetch('/frontend/graphql', {
          method: 'POST',
          headers,
          credentials: 'include',
          body: JSON.stringify({
            query,
            variables: {date: dateStr + 'T00:00:00Z', cursor: null},
          }),
        });

        if (gqlResp.ok) {
          const gqlData = await gqlResp.json();
          const edges = gqlData?.data?.homefeed?.edges;
          if (edges && edges.length > 0) {
            const products = edges
              .map((edge) => edge.node)
              .filter((node) => node && node.name)
              .slice(0, count)
              .map((product, index) => ({
                rank: index + 1,
                id: product.id || '',
                name: product.name || '',
                tagline: product.tagline || '',
                description: (product.description || '').substring(0, 300),
                votes: product.votesCount || 0,
                comments: product.commentsCount || 0,
                url: product.url || `https://www.producthunt.com/posts/${product.slug || ''}`,
                website: product.website || '',
                rating: product.reviewsRating || null,
                thumbnail: product.thumbnailUrl || '',
                topics: (product.topics?.edges || [])
                  .map((item) => item.node?.name || '')
                  .filter(Boolean),
                makers: (product.makers || [])
                  .map((maker) => maker.name || maker.username || '')
                  .filter(Boolean),
                featured_at: product.featuredAt || product.createdAt || '',
              }));

            return {
              source: 'graphql',
              date: dateStr,
              count: products.length,
              products,
            };
          }
        }
      } catch (error) {
      }

      try {
        const feedSource = 'https://www.producthunt.com/feed';
        const feedResp = await fetch(feedSource, {credentials: 'include'});
        if (feedResp.ok) {
          const feedText = await feedResp.text();
          const xmlDoc = new DOMParser().parseFromString(feedText, 'application/xml');
          const entries = xmlDoc.querySelectorAll('entry');
          const products = [];

          for (const entry of entries) {
            const title = entry.querySelector('title')?.textContent?.trim() || '';
            const content = entry.querySelector('content')?.textContent?.trim() || '';
            const link =
              entry.querySelector('link[rel=\"alternate\"]')?.getAttribute('href') || '';
            const author =
              entry.querySelector('author name')?.textContent?.trim() || '';
            const published =
              entry.querySelector('published')?.textContent?.trim() || '';
            const id = entry.querySelector('id')?.textContent?.trim() || '';
            const postId = (id.match(/Post\\/(\\d+)/) || [])[1] || '';
            if (!title) continue;

            products.push({
              rank: products.length + 1,
              id: postId,
              name: title,
              tagline: content.replace(/<[^>]*>/g, '').trim().substring(0, 200),
              author,
              url: link,
              published,
              votes: null,
              topics: [],
              makers: [author].filter(Boolean),
            });

            if (products.length >= count) break;
          }

          if (products.length > 0) {
            return {
              source: 'atom_feed',
              note: 'Vote counts unavailable via feed. Open producthunt.com first for richer data.',
              count: products.length,
              products,
            };
          }
        }
      } catch (error) {
      }

      return {
        error: 'Could not fetch Product Hunt data',
        hint: 'Open https://www.producthunt.com first, then retry.',
      };
    "))
