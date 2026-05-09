#| @meta
{
  "name": "twitter/notifications",
  "description": "获取 Twitter 通知并返回结构化结果",
  "args": [
    {
      "name": "type",
      "type": "string",
      "required": false,
      "default": "all",
      "description": "通知类型：all、mentions、likes、retweets"
    },
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回通知数量，默认 20，最大 50"
    },
    {
      "name": "cursor",
      "type": "string",
      "required": false,
      "description": "分页 cursor"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ type, count, notifications[] } 或 { engagement, mentions, total }"
  },
  "examples": [
    "openwalk exec twitter/notifications",
    "openwalk exec twitter/notifications -- mentions"
  ],
  "domains": [
    "x.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "twitter",
    "notifications",
    "mentions"
  ]
}
|#

(defun main (args)
  (open "https://x.com")
  (js-call args
    " const ct0 = document.cookie
        .split(';')
        .map((cookie) => cookie.trim())
        .find((cookie) => cookie.startsWith('ct0='))
        ?.split('=')[1];
      if (!ct0) {
        return {
          error: 'No ct0 cookie',
          hint: 'Please log in to https://x.com first.',
        };
      }

      const bearer = decodeURIComponent(
        'AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs%3D1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA'
      );
      const headers = {
        Authorization: 'Bearer ' + bearer,
        'X-Csrf-Token': ct0,
        'X-Twitter-Auth-Type': 'OAuth2Session',
        'X-Twitter-Active-User': 'yes',
      };

      const count = Math.min(parseInt(args.count, 10) || 20, 50);
      const type = (args.type || 'all').toLowerCase();
      const features = JSON.stringify({
        rweb_video_screen_enabled: false,
        profile_label_improvements_pcf_label_in_post_enabled: true,
        responsive_web_profile_redirect_enabled: false,
        rweb_tipjar_consumption_enabled: false,
        verified_phone_label_enabled: false,
        creator_subscriptions_tweet_preview_api_enabled: true,
        responsive_web_graphql_timeline_navigation_enabled: true,
        responsive_web_graphql_skip_user_profile_image_extensions_enabled: false,
        premium_content_api_read_enabled: false,
        communities_web_enable_tweet_community_results_fetch: true,
        c9s_tweet_anatomy_moderator_badge_enabled: true,
        articles_preview_enabled: true,
        responsive_web_edit_tweet_api_enabled: true,
        graphql_is_translatable_rweb_tweet_is_translatable_enabled: true,
        view_counts_everywhere_api_enabled: true,
        longform_notetweets_consumption_enabled: true,
        responsive_web_twitter_article_tweet_consumption_enabled: true,
        tweet_awards_web_tipping_enabled: false,
        content_disclosure_indicator_enabled: true,
        content_disclosure_ai_generated_indicator_enabled: true,
        freedom_of_speech_not_reach_fetch_enabled: true,
        standardized_nudges_misinfo: true,
        tweet_with_visibility_results_prefer_gql_limited_actions_policy_enabled: true,
        longform_notetweets_rich_text_read_enabled: true,
        longform_notetweets_inline_media_enabled: false,
        responsive_web_enhance_cards_enabled: false,
      });
      const iconMap = {
        heart_icon: 'like',
        retweet_icon: 'retweet',
        person_icon: 'follow',
        reply_icon: 'reply',
        bell_icon: 'mention',
      };

      async function fetchEngagement(cursor) {
        const variables = {timeline_type: 'All', count};
        if (cursor) {
          variables.cursor = cursor;
        }
        const source =
          '/i/api/graphql/3Jx0YXHGICZsBxDlRrfQnw/NotificationsTimeline?variables=' +
          encodeURIComponent(JSON.stringify(variables)) +
          '&features=' +
          encodeURIComponent(features);
        const resp = await fetch(source, {headers, credentials: 'include'});
        if (!resp.ok) {
          return {
            items: [],
            next_cursor: null,
            error: 'HTTP ' + resp.status,
            source: 'https://x.com' + source,
          };
        }

        const data = await resp.json();
        const instructions =
          data.data?.viewer_v2?.user_results?.result?.notification_timeline?.timeline?.instructions ||
          [];
        const items = [];
        let next_cursor = null;
        for (const inst of instructions) {
          if (inst.type !== 'TimelineAddEntries') continue;
          for (const entry of inst.entries || []) {
            if (entry.entryId?.startsWith('cursor-bottom-')) {
              next_cursor = entry.content?.value || null;
              continue;
            }
            if (entry.entryId?.startsWith('cursor-top-')) continue;

            const itemContent = entry.content?.itemContent;
            if (!itemContent || itemContent.__typename !== 'TimelineNotification') continue;
            const icon = itemContent.notification_icon || '';
            const ntype =
              iconMap[icon] ||
              itemContent.clientEventInfo?.element ||
              icon.replace('_icon', '');
            const users = (itemContent.rich_message?.entities || [])
              .filter((entity) => entity.ref?.type === 'TimelineRichTextUser')
              .map((entity) => {
                const user = entity.ref?.user_results?.result;
                return user?.legacy?.screen_name || user?.core?.screen_name || '';
              })
              .filter(Boolean);
            items.push({
              type: ntype,
              users,
              message: itemContent.rich_message?.text || '',
              url: itemContent.notification_url?.url || '',
              id: itemContent.id || '',
            });
          }
        }

        return {items, next_cursor};
      }

      async function fetchMentions(cursor) {
        const variables = {timeline_type: 'Mentions', count};
        if (cursor) {
          variables.cursor = cursor;
        }
        const source =
          '/i/api/graphql/3Jx0YXHGICZsBxDlRrfQnw/NotificationsTimeline?variables=' +
          encodeURIComponent(JSON.stringify(variables)) +
          '&features=' +
          encodeURIComponent(features);
        const resp = await fetch(source, {headers, credentials: 'include'});
        if (!resp.ok) {
          return {
            items: [],
            next_cursor: null,
            error: 'HTTP ' + resp.status,
            source: 'https://x.com' + source,
          };
        }

        const data = await resp.json();
        const instructions =
          data.data?.viewer_v2?.user_results?.result?.notification_timeline?.timeline?.instructions ||
          [];
        const items = [];
        let next_cursor = null;
        for (const inst of instructions) {
          if (inst.type !== 'TimelineAddEntries') continue;
          for (const entry of inst.entries || []) {
            if (entry.entryId?.startsWith('cursor-bottom-')) {
              next_cursor = entry.content?.value || null;
              continue;
            }
            if (entry.entryId?.startsWith('cursor-top-')) continue;

            const result = entry.content?.itemContent?.tweet_results?.result;
            if (!result) continue;
            const tweet = result.tweet || result;
            const legacy = tweet.legacy || {};
            if (!tweet.rest_id) continue;
            const user = tweet.core?.user_results?.result;
            const noteText = tweet.note_tweet?.note_tweet_results?.result?.text;
            const screenName =
              user?.legacy?.screen_name || user?.core?.screen_name || '';
            items.push({
              type: 'mention',
              id: tweet.rest_id,
              author: screenName,
              text: noteText || legacy.full_text || '',
              url: 'https://x.com/' + (screenName || '_') + '/status/' + tweet.rest_id,
              likes: legacy.favorite_count || 0,
              retweets: legacy.retweet_count || 0,
              created_at: legacy.created_at || '',
            });
          }
        }

        return {items, next_cursor};
      }

      if (type === 'mentions') {
        const result = await fetchMentions(args.cursor);
        if (result.error) {
          return {
            error: result.error,
            hint: 'queryId may have changed',
            source: result.source,
          };
        }
        const response = {
          type: 'mentions',
          count: result.items.length,
          notifications: result.items,
        };
        if (result.next_cursor) {
          response.next_cursor = result.next_cursor;
        }
        return response;
      }

      if (type === 'likes' || type === 'retweets') {
        const result = await fetchEngagement(args.cursor);
        if (result.error) {
          return {
            error: result.error,
            hint: 'queryId may have changed',
            source: result.source,
          };
        }
        const filtered = result.items.filter(
          (item) => item.type === (type === 'likes' ? 'like' : 'retweet')
        );
        const response = {
          type,
          count: filtered.length,
          notifications: filtered,
        };
        if (result.next_cursor) {
          response.next_cursor = result.next_cursor;
        }
        return response;
      }

      const [engagement, mentions] = await Promise.all([
        fetchEngagement(args.cursor),
        fetchMentions(args.cursor),
      ]);
      if (engagement.error && mentions.error) {
        return {
          error: engagement.error + '; ' + mentions.error,
          hint: 'queryId may have changed',
        };
      }

      const response = {
        type: 'all',
        engagement: {
          count: engagement.items.length,
          notifications: engagement.items,
        },
        mentions: {
          count: mentions.items.length,
          notifications: mentions.items,
        },
        total: engagement.items.length + mentions.items.length,
      };
      if (engagement.next_cursor) {
        response.engagement_cursor = engagement.next_cursor;
      }
      if (mentions.next_cursor) {
        response.mentions_cursor = mentions.next_cursor;
      }
      return response;
    "))
