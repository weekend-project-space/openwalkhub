#| @meta
{
  "name": "bilibili/me",
  "description": "获取当前 Bilibili 登录用户信息并返回结构化结果",
  "args": [],
  "returns": {
    "type": "object",
    "description": "{ mid, username, url, level, coins, vip, follower, following }"
  },
  "examples": [
    "openwalk exec bilibili/me"
  ],
  "domains": [
    "www.bilibili.com",
    "api.bilibili.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "bilibili",
    "me",
    "profile"
  ]
}
|#

(defun main (args)
  (open "https://www.bilibili.com")
  (js-call args
    " const source = 'https://api.bilibili.com/x/web-interface/nav';
      const resp = await fetch(source, {credentials: 'include'});
      if (!resp.ok) {
        return {
          error: 'HTTP ' + resp.status,
          hint: 'Not logged in?',
          source,
        };
      }

      const data = await resp.json();
      if (data.code !== 0) {
        return {
          error: data.message || 'API error ' + data.code,
          hint: 'Not logged in?',
          source,
        };
      }

      if (!data.data?.isLogin) {
        return {
          error: 'Not logged in',
          hint: 'Please log in to bilibili.com first',
          source,
        };
      }

      const user = data.data;
      const result = {
        source,
        mid: user.mid || 0,
        username: user.uname || '',
        url: user.mid ? 'https://space.bilibili.com/' + user.mid : '',
        face: user.face || '',
        level: user.level_info?.current_level || 0,
        coins: user.money || 0,
        vip: user.vipType > 0,
        vip_type:
          user.vipType === 1
            ? 'monthly'
            : user.vipType === 2
              ? 'annual'
              : 'none',
        vip_label: user.vip_label?.text || null,
        moral: user.moral || 0,
        email_verified: user.email_verified === 1,
        tel_verified: user.mobile_verified === 1,
        follower: null,
        following: null,
      };

      try {
        const statSource = 'https://api.bilibili.com/x/web-interface/nav/stat';
        const statResp = await fetch(statSource, {credentials: 'include'});
        const statData = await statResp.json();
        if (statData.code === 0 && statData.data) {
          result.follower = statData.data.follower || 0;
          result.following = statData.data.following || 0;
        }
      } catch (error) {
      }

      return result;
    "))
