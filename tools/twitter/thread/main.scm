#| @meta
{
  "name": "twitter/thread",
  "description": "获取推文对话线程并返回结构化结果",
  "args": [
    {
      "name": "tweet_id",
      "type": "string",
      "required": true,
      "description": "Tweet ID，或完整 URL"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ tweet_id, count, tweets[] }"
  },
  "examples": [
    "openwalk exec twitter/thread -- 2032478407146311850"
  ],
  "domains": [
    "x.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "twitter",
    "thread",
    "replies"
  ]
}
|#

(defun main (args)
  (open "https://x.com")
  (js-call args
    " const input = args.tweet_id || '';
      if (!input) {
        return {
          error: 'Missing argument: tweet_id',
          hint: 'Provide a tweet ID or URL',
        };
      }

      const ct0 = document.cookie
        .split(';')
        .map((cookie) => cookie.trim())
        .find((cookie) => cookie.startsWith('ct0='))
        ?.split('=')[1];
      if (!ct0) {
        return {
          error: 'No ct0 cookie',
          hint: 'Not logged into x.com',
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

      let tweetId = input;
      const urlMatch = tweetId.match(/\\/status\\/(\\d+)/);
      if (urlMatch) {
        tweetId = urlMatch[1];
      }

      const features = JSON.stringify({
        responsive_web_graphql_exclude_directive_enabled: true,
        verified_phone_label_enabled: false,
        creator_subscriptions_tweet_preview_api_enabled: true,
        responsive_web_graphql_timeline_navigation_enabled: true,
        responsive_web_graphql_skip_user_profile_image_extensions_enabled: false,
        longform_notetweets_consumption_enabled: true,
        longform_notetweets_rich_text_read_enabled: true,
        longform_notetweets_inline_media_enabled: true,
        freedom_of_speech_not_reach_fetch_enabled: true,
      });
      const fieldToggles = JSON.stringify({
        withArticleRichContentState: true,
        withArticlePlainText: false,
      });

      const tweets = [];
      const seen = new Set();
      let cursor = null;
      const maxPages = 5;

      function extractTweet(result) {
        if (!result) return;
        const tweet = result.tweet || result;
        const legacy = tweet.legacy || {};
        if (!tweet.rest_id || seen.has(tweet.rest_id)) return;
        seen.add(tweet.rest_id);
        const user = tweet.core?.user_results?.result;
        const noteText = tweet.note_tweet?.note_tweet_results?.result?.text;
        const screenName =
          user?.legacy?.screen_name || user?.core?.screen_name || '';

        tweets.push({
          id: tweet.rest_id,
          author: screenName,
          text: noteText || legacy.full_text || '',
          url: 'https://x.com/' + (screenName || '_') + '/status/' + tweet.rest_id,
          likes: legacy.favorite_count || 0,
          retweets: legacy.retweet_count || 0,
          in_reply_to: legacy.in_reply_to_status_id_str || undefined,
          created_at: legacy.created_at || '',
        });
      }

      for (let page = 0; page < maxPages; page += 1) {
        const variables = {
          focalTweetId: tweetId,
          referrer: 'tweet',
          with_rux_injections: false,
          includePromotedContent: false,
          rankingMode: 'Recency',
          withCommunity: true,
          withQuickPromoteEligibilityTweetFields: true,
          withBirdwatchNotes: true,
          withVoice: true,
        };
        if (cursor) {
          variables.cursor = cursor;
        }

        const source =
          '/i/api/graphql/nBS-WpgA6ZG0CyNHD517JQ/TweetDetail?variables=' +
          encodeURIComponent(JSON.stringify(variables)) +
          '&features=' +
          encodeURIComponent(features) +
          '&fieldToggles=' +
          encodeURIComponent(fieldToggles);
        const resp = await fetch(source, {headers, credentials: 'include'});
        if (!resp.ok) {
          return {
            error: 'HTTP ' + resp.status,
            hint: 'Tweet may not exist or queryId expired',
            source: 'https://x.com' + source,
          };
        }

        const data = await resp.json();
        const instructions =
          data.data?.threaded_conversation_with_injections_v2?.instructions ||
          data.data?.tweetResult?.result?.timeline?.instructions ||
          [];
        let nextCursor = null;

        for (const inst of instructions) {
          for (const entry of inst.entries || []) {
            if (
              entry.content?.entryType === 'TimelineTimelineCursor' ||
              entry.content?.__typename === 'TimelineTimelineCursor'
            ) {
              if (
                entry.content.cursorType === 'Bottom' ||
                entry.content.cursorType === 'ShowMore'
              ) {
                nextCursor = entry.content.value;
              }
              continue;
            }

            if (
              entry.entryId?.startsWith('cursor-bottom-') ||
              entry.entryId?.startsWith('cursor-showMore-')
            ) {
              const cursorValue =
                entry.content?.itemContent?.value || entry.content?.value;
              if (cursorValue) {
                nextCursor = cursorValue;
              }
              continue;
            }

            extractTweet(entry.content?.itemContent?.tweet_results?.result);
            for (const item of entry.content?.items || []) {
              extractTweet(item.item?.itemContent?.tweet_results?.result);
            }
          }
        }

        if (!nextCursor || nextCursor === cursor) {
          break;
        }
        cursor = nextCursor;
      }

      return {
        tweet_id: tweetId,
        count: tweets.length,
        tweets,
      };
    "))
