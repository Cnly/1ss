#! /usr/bin/env python3
# Generates PAC file

import urllib.request
import base64

gfwlist_url = 'https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt'

def obtain_gfwlist():
    return base64.standard_b64decode(urllib.request.urlopen(gfwlist_url).read()).decode('utf-8')

def wrap(string):
    return '"' + string + '", '

def generate_arrays():
    hosts = 'var hosts = ['
    host_wildcards = 'var host_wildcards = ['
    url_wildcards = 'var url_wildcards = ['

    gfwlist = obtain_gfwlist()
    gl_lines = gfwlist.splitlines()[1:]
    for line in gl_lines:
        if len(line) == 0 or line.startswith('!') or line.startswith('@@') or line.startswith('/'):
            # Ignore empty lines, comment lines, whitelists, and regexes.
            continue
        if line.startswith('||'):
            if '*' in line:
                host_wildcards += wrap(line[2:])
            else:
                hosts += wrap(line[2:])
        elif line.startswith('|'):
            url_wildcards += wrap(line[1:] + '*')
        else:
            url_wildcards += wrap('http://*' + line + '*')

    hosts += '];'
    host_wildcards += '];'
    url_wildcards += '];'

    # return hosts + '\n' + host_wildcards + '\n' + url_wildcards
    return hosts + '\n' + host_wildcards

proxy = \
"""\
var proxy = "PROXY ";

"""

whitelist = \
"""\
var whitelist = [
    ".cn",
    "alicdn.com",
    "aliyun.com",
    "baidu.com",
    "chinaz.com",
    "dangdang.com",
    "dl.google.com",
    "kh.google.com",
    "fonts.googleapis.com",
    "storage.googleapis.com",
    "cn.gravatar.com",
    "en.wikipedia.org",
    "csi.gstatic.com",
    "fonts.gstatic.com",
    "haosou.com",
    ".ifeng.com",
    "ifengimg.com",
    "jd.com",
    "jike.com",
    "gtimg.com",
    "http2.golang.org",
    "qq.com",
    "sogou.com",
    "so.com",
    "soso.com",
    "taobao.com",
    "weibo.com",
    "youdao.com",
];

"""

fast_list = \
"""\
var fastList = [
    "google.com",
    "google.com.hk",
    "google.co.jp",
    "youtube.com",
    "googleusercontent.com",
];

"""

func = \
"""\
function FindProxyForURL(url, host) {

    for (var i= 0; i < whitelist.length; i++) {
        if (host.endsWith(whitelist[i])) {
            return "DIRECT";
        }
    }

    for (var i= 0; i < fastList.length; i++) {
        if (host.endsWith(fastList[i])) {
            return proxy;
        }
    }

    for (var i= 0; i < host_wildcards.length; i++) {
        if (shExpMatch(host, host_wildcards[i])) {
            return proxy;
        }
    }

    for (var i= 0; i < hosts.length; i++) {
        if (host.endsWith(hosts[i])) {
            return proxy;
        }
    }

    return "DIRECT";
}

"""

def generate_pac():
    arrays = generate_arrays()
    file_contents = proxy + whitelist + fast_list + arrays + '\n\n' + func
    with open('zgm.pac', 'w') as fle:
        fle.write(file_contents)

if __name__ == '__main__':
    generate_pac()
