#| @meta
{
  "name": "twitter/following",
  "description": "获取 Following 时间线并返回结构化结果",
  "args": [
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回推文数量，默认 20，最大 50"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ count, tweets[] }"
  },
  "examples": [
    "openwalk exec twitter/following"
  ],
  "domains": [
    "x.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "twitter",
    "following",
    "timeline"
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
      const variables = JSON.stringify({
        count,
        includePromotedContent: false,
        latestControlAvailable: true,
        requestContext: 'launch',
        withCommunity: true,
      });
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

      const source =
        '/i/api/graphql/DiTkXJgLqBBxCs7zaYsbtA/HomeLatestTimeline?variables=' +
        encodeURIComponent(variables) +
        '&features=' +
        encodeURIComponent(features);
      const resp = await fetch(source, {headers, credentials: 'include'});
      if (!resp.ok) {
        return {
          error: 'HTTP ' + resp.status,
          hint: 'queryId may have changed',
          source: 'https://x.com' + source,
        };
      }

      const data = await resp.json();
      const instructions = data.data?.home?.home_timeline_urt?.instructions || [];
      const tweets = [];

      function extractTweet(itemContent, sourceText) {
        if (!itemContent || itemContent.promotedMetadata) return;
        const result = itemContent.tweet_results?.result;
        if (!result) return;

        const tweet = result.tweet || result;
        const legacy = tweet.legacy || {};
        if (!tweet.rest_id) return;

        const user = tweet.core?.user_results?.result;
        const noteText = tweet.note_tweet?.note_tweet_results?.result?.text;
        const screenName =
          user?.legacy?.screen_name || user?.core?.screen_name || '';
        const socialContext = itemContent.socialContext;
        const src = sourceText || socialContext?.text || null;
        const retweet = legacy.retweeted_status_result?.result;

        if (retweet) {
          const retweetTweet = retweet.tweet || retweet;
          const retweetLegacy = retweetTweet.legacy || {};
          const retweetUser = retweetTweet.core?.user_results?.result;
          const retweetNote =
            retweetTweet.note_tweet?.note_tweet_results?.result?.text;
          const tweetObj = {
            id: tweet.rest_id,
            type: 'retweet',
            author: screenName,
            url: 'https://x.com/' + (screenName || '_') + '/status/' + tweet.rest_id,
            rt_author:
              retweetUser?.legacy?.screen_name ||
              retweetUser?.core?.screen_name ||
              '',
            text: retweetNote || retweetLegacy.full_text || '',
            likes: retweetLegacy.favorite_count || 0,
            retweets: retweetLegacy.retweet_count || 0,
            created_at: legacy.created_at || '',
          };
          if (src) tweetObj.source = src;
          tweets.push(tweetObj);
        } else {
          const tweetObj = {
            id: tweet.rest_id,
            type: legacy.in_reply_to_status_id_str ? 'reply' : 'tweet',
            author: screenName,
            name: user?.legacy?.name || user?.core?.name || '',
            url: 'https://x.com/' + (screenName || '_') + '/status/' + tweet.rest_id,
            text: noteText || legacy.full_text || '',
            likes: legacy.favorite_count || 0,
            retweets: legacy.retweet_count || 0,
            in_reply_to: legacy.in_reply_to_status_id_str || undefined,
            created_at: legacy.created_at || '',
          };
          if (src) tweetObj.source = src;
          tweets.push(tweetObj);
        }
      }

      for (const inst of instructions) {
        for (const entry of inst.entries || []) {
          const content = entry.content;
          if (content?.items) {
            for (const item of content.items) {
              extractTweet(item.item?.itemContent, null);
            }
            continue;
          }
          extractTweet(content?.itemContent, null);
        }
      }

      return {
        source: 'https://x.com' + source,
        count: tweets.length,
        tweets,
      };
    "))
