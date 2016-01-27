# TODAY ON TCP MYTHBUSTERS

HTTP and TLS  run over TCP.  Every time a new TCP
connection is created:

1. TCP protocol handshakes
2. TLS subsequently handshakes, if applicable
3. TCP slowstart

This can be expensive, especially when TLS is involved (which should be
all servers, in a perfect world), so care should
be taken to re-use existing TCP connections whenever possible.
Unfortunately, Ruby doesn't make this as easy as it should be.

I'm doing all of my tests on Ruby 2.3.0

## HOW TO DETERMINE WHEN TCP CONNECTIONS ARE MADE

We can tell when TCP connections are made by running the following
command:

`sudo tcpdump -i <interface_goes_here> -A -s 0 'tcp[tcpflags] & (tcp-syn|tcp-fin) != 0 and
dst port <port_goes_here>'`

The interface can be determined by running `tcpdump -D`; on my machine,
my loopback interface is `lo0`.

This command will print out each TCP packet that's either a SYN
(connection request) or a FIN (connection termination request).

### SHIT, THAT IS COMPLICATED

Yeah, I'm welcome to simpler suggestions.  You can see a simpler example
by running

`curl -v localhost:3005 localhost:3005`

cURL will tell you when it's re-using a connection or opening a new one.

## BUSTING MYTHS

Run the tcpdump monitoring, the mock webserver, and then run tests
individually.  Ex:

1. `sudo tcpdump -i lo0 -A -s 0 'tcp[tcpflags] & (tcp-syn|tcp-fin) != 0 and dst port 3005'`
2. in a separate window,
`rackup base_server.ru -p 3005`
3. in a separate window,
`ruby <test_file`

### INTERPRETING RESULTS

By looking at the output of the tcpdump command above, we can determine
if the connection is being re-used or not.  In situations where it is,
we see only a single SYN/FIN pair:

```
13:56:14.858605 IP localhost.59101 > localhost.geniuslm: Flags [S], seq
1240341411,
....
13:56:14.863307 IP localhost.59101 > localhost.geniuslm: Flags [F.],
....

```

But, if a new connection is being made per-request, you'll see multiple
SYN/FIN pairs:
```
13:54:11.233058 IP localhost.59095 > localhost.geniuslm: Flags [S], seq
907144824,
...
13:54:11.234127 IP localhost.59095 > localhost.geniuslm: Flags [F.], seq
907144954,
...
13:54:11.234728 IP localhost.59096 > localhost.geniuslm: Flags [S], seq
3385473565,
...
13:54:11.235496 IP localhost.59096 > localhost.geniuslm: Flags [F.],
...

```

## RECOMMENDATIONS

1. Servers should always include a `Content-Length` header, to ensure
clients are able to take advantage of persistent connections.
2. Ruby clients concerned about performance should use
[net-http-persistent](http://docs.seattlerb.org/net-http-persistent/) gem instead of `Net::HTTP`,
unless the entire transmission can be completed within a single
`Net::HTTP.start` block.  `Net::Http.new` does not perform as-described.

## MORE READING

* [TCP](https://en.wikipedia.org/wiki/Transmission_Control_Protocol)
