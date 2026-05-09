#| @meta
{
  "name": "twitter/tweets",
  "description": "获取用户最近推文并返回结构化结果",
  "args": [
    {
      "name": "screen_name",
      "type": "string",
      "required": true,
      "description": "Twitter handle，不带 @"
    },
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回推文数量，默认 20，最大 100"
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
    "description": "{ screen_name, user_id, count, next_cursor, tweets[] }"
  },
  "examples": [
    "openwalk exec twitter/tweets -- plantegg"
  ],
  "domains": [
    "x.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "twitter",
    "tweets",
    "timeline"
  ]
}
|#

(defun main (args)
  (open "https://x.com")
  (js-call args
    " const screenNameArg = args.screen_name || '';
      if (!screenNameArg) {
        return {
          error: 'Missing argument: screen_name',
          hint: 'Provide a Twitter handle',
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

      const userVars = JSON.stringify({
        screen_name: screenNameArg,
        withSafetyModeUserFields: true,
      });
      const userFeatures = JSON.stringify({
        hidden_profile_subscriptions_enabled: true,
        responsive_web_graphql_exclude_directive_enabled: true,
        verified_phone_label_enabled: false,
        responsive_web_graphql_skip_user_profile_image_extensions_enabled: false,
        responsive_web_graphql_timeline_navigation_enabled: true,
      });
      const userSource =
        '/i/api/graphql/pLsOiyHJ1eFwPJlNmLp4Bg/UserByScreenName?variables=' +
        encodeURIComponent(userVars) +
        '&features=' +
        encodeURIComponent(userFeatures);
      const userResp = await fetch(userSource, {headers, credentials: 'include'});
      if (!userResp.ok) {
        return {
          error: 'Failed to resolve user: HTTP ' + userResp.status,
          source: 'https://x.com' + userSource,
        };
      }

      const userData = await userResp.json();
      const userId = userData.data?.user?.result?.rest_id;
      if (!userId) {
        return {
          error: 'User not found',
          hint: 'Check spelling: @' + screenNameArg,
          source: 'https://x.com' + userSource,
        };
      }

      const count = Math.min(parseInt(args.count, 10) || 20, 100);
      const variables = {
        userId,
        count,
        includePromotedContent: false,
        withQuickPromoteEligibilityTweetFields: true,
        withVoice: true,
      };
      if (args.cursor) {
        variables.cursor = args.cursor;
      }

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
        freedom_of_speech_not_reach_fetch_enabled: true,
        standardized_nudges_misinfo: true,
        tweet_with_visibility_results_prefer_gql_limited_actions_policy_enabled: true,
        longform_notetweets_rich_text_read_enabled: true,
        longform_notetweets_inline_media_enabled: false,
        responsive_web_enhance_cards_enabled: false,
      });
      const fieldToggles = JSON.stringify({withArticlePlainText: false});
      const source =
        '/i/api/graphql/Y59DTUMfcKmUAATiT2SlTw/UserTweets?variables=' +
        encodeURIComponent(JSON.stringify(variables)) +
        '&features=' +
        encodeURIComponent(features) +
        '&fieldToggles=' +
        encodeURIComponent(fieldToggles);
      const resp = await fetch(source, {headers, credentials: 'include'});
      if (!resp.ok) {
        return {
          error: 'HTTP ' + resp.status,
          hint: 'queryId may have changed',
          source: 'https://x.com' + source,
        };
      }

      const data = await resp.json();
      const instructions =
        data.data?.user?.result?.timeline_v2?.timeline?.instructions ||
        data.data?.user?.result?.timeline?.timeline?.instructions ||
        [];

      const tweets = [];
      let next_cursor = null;
      for (const inst of instructions) {
        for (const entry of inst.entries || []) {
          if (entry.entryId?.startsWith('cursor-bottom-')) {
            next_cursor = entry.content?.value || null;
            continue;
          }

          const result = entry.content?.itemContent?.tweet_results?.result;
          if (!result) continue;
          const tweet = result.tweet || result;
          const legacy = tweet.legacy || {};
          if (!tweet.rest_id) continue;

          const user = tweet.core?.user_results?.result;
          const noteText = tweet.note_tweet?.note_tweet_results?.result?.text;
          const retweet = legacy.retweeted_status_result?.result;
          if (retweet) {
            const retweetTweet = retweet.tweet || retweet;
            const retweetLegacy = retweetTweet.legacy || {};
            const retweetUser = retweetTweet.core?.user_results?.result;
            const retweetNote =
              retweetTweet.note_tweet?.note_tweet_results?.result?.text;
            const authorName =
              user?.legacy?.screen_name || user?.core?.screen_name || '';

            tweets.push({
              id: tweet.rest_id,
              type: 'retweet',
              author: authorName,
              url: 'https://x.com/' + (authorName || '_') + '/status/' + tweet.rest_id,
              rt_author:
                retweetUser?.legacy?.screen_name ||
                retweetUser?.core?.screen_name ||
                '',
              text: retweetNote || retweetLegacy.full_text || '',
              likes: retweetLegacy.favorite_count || 0,
              retweets: retweetLegacy.retweet_count || 0,
              replies: retweetLegacy.reply_count || 0,
              created_at: legacy.created_at || '',
            });
          } else {
            const authorName =
              user?.legacy?.screen_name || user?.core?.screen_name || '';
            tweets.push({
              id: tweet.rest_id,
              type: 'tweet',
              author: authorName,
              url: 'https://x.com/' + (authorName || '_') + '/status/' + tweet.rest_id,
              text: noteText || legacy.full_text || '',
              likes: legacy.favorite_count || 0,
              retweets: legacy.retweet_count || 0,
              replies: legacy.reply_count || 0,
              in_reply_to: legacy.in_reply_to_status_id_str || undefined,
              created_at: legacy.created_at || '',
            });
          }
        }
      }

      const result = {
        source: 'https://x.com' + source,
        screen_name: screenNameArg,
        user_id: userId,
        count: tweets.length,
        tweets,
      };
      if (next_cursor) {
        result.next_cursor = next_cursor;
      }
      return result;
    "))
