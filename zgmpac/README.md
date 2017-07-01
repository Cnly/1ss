Edit the `proxy` string in zgm.py before executing.

E.g.
for HTTP proxies:

    proxy = \
    """\
    var proxy = "PROXY 1.2.3.4:5678";

    """

or if all your clients support SOCKS5 directly:

    proxy = \
    """\
    var proxy = "SOCKS5 1.2.3.4:5678";

    """