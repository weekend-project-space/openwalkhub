async (args) => {
  const query = args.query || '';
  if (!query) {
    return {
      error: 'Missing argument: query',
      hint: 'Provide a search query',
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

  let __webpack_require__;
  const chunkId = '__bb_s_' + Date.now();
  window.webpackChunk_twitter_responsive_web.push([
    [chunkId],
    {},
    (req) => {
      __webpack_require__ = req;
    },
  ]);

  let genTxId = null;
  let queryId = null;
  for (const id of Object.keys(__webpack_require__.m)) {
    try {
      if (!genTxId) {
        const mod = __webpack_require__(id);
        if (mod?.jJ) {
          genTxId = mod.jJ;
        }
      }
      if (!queryId) {
        const sourceCode = __webpack_require__.m[id].toString();
        const match = sourceCode.match(
          /queryId:\s*\"([^\"]+)\",\s*operationName:\s*\"SearchTimeline\"/
        );
        if (match) {
          queryId = match[1];
        }
      }
      if (genTxId && queryId) {
        break;
      }
    } catch (error) {
    }
  }

  if (!genTxId) {
    return {
      error: 'Cannot find transaction-id generator',
      hint: 'x.com webpack structure may have changed',
    };
  }
  if (!queryId) {
    return {
      error: 'Cannot find SearchTimeline queryId',
      hint: 'x.com API structure may have changed',
    };
  }

  const bearer =
    'AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs%3D1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA';
  const path = '/i/api/graphql/' + queryId + '/SearchTimeline';
  const txId = await genTxId('x.com', path, 'GET');
  const headers = {
    Authorization: 'Bearer ' + bearer,
    'X-Csrf-Token': ct0,
    'X-Twitter-Auth-Type': 'OAuth2Session',
    'X-Twitter-Active-User': 'yes',
    'X-Client-Transaction-Id': txId,
  };

  const count = Math.min(parseInt(args.count, 10) || 20, 50);
  const product = args.type === 'top' ? 'Top' : 'Latest';
  const variables = JSON.stringify({
    rawQuery: query,
    count,
    querySource: 'typed_query',
    product,
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
    path +
    '?variables=' +
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
  const instructions =
    data.data?.search_by_raw_query?.search_timeline?.timeline?.instructions || [];
  const tweets = [];
  for (const inst of instructions) {
    for (const entry of inst.entries || []) {
      const result = entry.content?.itemContent?.tweet_results?.result;
      if (!result) continue;

      const tweet = result.tweet || result;
      const legacy = tweet.legacy || {};
      if (!tweet.rest_id) continue;

      const user = tweet.core?.user_results?.result;
      const noteText = tweet.note_tweet?.note_tweet_results?.result?.text;
      const screenName =
        user?.legacy?.screen_name || user?.core?.screen_name || '';
      tweets.push({
        id: tweet.rest_id,
        author: screenName,
        name: user?.legacy?.name || user?.core?.name || '',
        url: 'https://x.com/' + (screenName || '_') + '/status/' + tweet.rest_id,
        text: noteText || legacy.full_text || '',
        likes: legacy.favorite_count || 0,
        retweets: legacy.retweet_count || 0,
        in_reply_to: legacy.in_reply_to_status_id_str || undefined,
        created_at: legacy.created_at || '',
      });
    }
  }

  return {
    source: 'https://x.com' + source,
    query,
    product,
    count: tweets.length,
    tweets,
  };
}
