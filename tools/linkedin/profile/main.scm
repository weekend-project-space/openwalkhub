#| @meta
{
  "name": "linkedin/profile",
  "description": "获取 LinkedIn 用户 profile 并返回结构化结果",
  "args": [
    {
      "name": "username",
      "type": "string",
      "required": true,
      "description": "linkedin.com/in/<username> 中的用户名"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ firstName, lastName, headline, location, industry, profileUrl }"
  },
  "examples": [
    "openwalk exec linkedin/profile -- williamhgates"
  ],
  "domains": [
    "www.linkedin.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "linkedin",
    "profile",
    "people"
  ]
}
|#

(defun main (args)
  (open "https://www.linkedin.com")
  (js-call args
    " const username = args.username || '';
      if (!username) {
        return {
          error: 'Missing argument: username',
        };
      }

      const csrf = document.cookie
        .split(';')
        .map((cookie) => cookie.trim())
        .find((cookie) => cookie.startsWith('JSESSIONID='))
        ?.split('=')[1]
        ?.replace(/\"/g, '');
      if (!csrf) {
        return {
          error: 'Not logged in',
          hint: 'Please log in to https://www.linkedin.com first.',
        };
      }

      const source =
        '/voyager/api/identity/dash/profiles?q=memberIdentity&memberIdentity=' +
        encodeURIComponent(username) +
        '&decorationId=com.linkedin.voyager.dash.deco.identity.profile.WebTopCardCore-20';

      const resp = await fetch(source, {
        headers: {
          'csrf-token': csrf,
          'x-restli-protocol-version': '2.0.0',
        },
        credentials: 'include',
      });
      if (!resp.ok) {
        return {
          error: 'HTTP ' + resp.status,
          hint: resp.status === 404 ? 'User not found' : 'Check username',
          source: 'https://www.linkedin.com' + source,
        };
      }

      const data = await resp.json();
      const profile = data.elements?.[0];
      if (!profile) {
        return {
          error: 'Profile not found',
          source: 'https://www.linkedin.com' + source,
        };
      }

      const miniProfile = profile.miniProfile || profile;
      return {
        source: 'https://www.linkedin.com' + source,
        firstName: profile.multiLocaleFirstName?.en_US || miniProfile.firstName || '',
        lastName: profile.multiLocaleLastName?.en_US || miniProfile.lastName || '',
        headline:
          profile.multiLocaleHeadline?.en_US ||
          miniProfile.headline ||
          profile.headline ||
          '',
        location:
          profile.geoLocation?.geo?.defaultLocalizedName ||
          profile.location ||
          '',
        industry: profile.industryV2?.name?.locale?.en_US || '',
        profileUrl: 'https://www.linkedin.com/in/' + username,
      };
    "))
