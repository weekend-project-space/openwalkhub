#| @meta
{
  "name": "twitter/user",
  "description": "获取 Twitter 用户 profile 并返回结构化结果",
  "args": [
    {
      "name": "screen_name",
      "type": "string",
      "required": true,
      "description": "Twitter handle，不带 @"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ id, name, screen_name, bio, url, followers, following, tweets, verified }"
  },
  "examples": [
    "openwalk exec twitter/user -- yan5xu"
  ],
  "domains": [
    "x.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "twitter",
    "user",
    "profile"
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
          hint: 'Not logged into x.com. Open x.com and log in first.',
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

      const variables = JSON.stringify({
        screen_name: screenNameArg,
        withSafetyModeUserFields: true,
      });
      const features = JSON.stringify({
        hidden_profile_subscriptions_enabled: true,
        responsive_web_graphql_exclude_directive_enabled: true,
        verified_phone_label_enabled: false,
        responsive_web_graphql_skip_user_profile_image_extensions_enabled: false,
        responsive_web_graphql_timeline_navigation_enabled: true,
      });

      const source =
        '/i/api/graphql/pLsOiyHJ1eFwPJlNmLp4Bg/UserByScreenName?variables=' +
        encodeURIComponent(variables) +
        '&features=' +
        encodeURIComponent(features);
      const resp = await fetch(source, {headers, credentials: 'include'});
      if (!resp.ok) {
        return {
          error: 'HTTP ' + resp.status,
          hint: 'queryId may have changed. Check network tab.',
          source: 'https://x.com' + source,
        };
      }

      const data = await resp.json();
      const user = data.data?.user?.result;
      if (!user) {
        return {
          error: 'User not found',
          hint: 'Check spelling: @' + screenNameArg,
          source: 'https://x.com' + source,
        };
      }

      const legacy = user.legacy || {};
      const screenName =
        legacy.screen_name || user?.core?.screen_name || screenNameArg;

      return {
        source: 'https://x.com' + source,
        id: user.rest_id || '',
        name: legacy.name || user?.core?.name || '',
        screen_name: screenName,
        bio: legacy.description || '',
        url: 'https://x.com/' + screenName,
        followers: legacy.followers_count || 0,
        following: legacy.friends_count || 0,
        tweets: legacy.statuses_count || 0,
        verified: !!user.is_blue_verified,
      };
    "))
