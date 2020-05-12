# dodyndns

A simple utility to manage dynamic DNS records in Digital Ocean DNS.

## Usage

For all calls either the `DIGITALOCEAN_ACCESS_TOKEN` environment variable or the `--access-token` option needs to be set. In the examples below it is assumed that `DIGITALOCEAN_ACCESS_TOKEN` is set.

Set current public IPv4 and IPv6 records for `host.example.com`:

```sh
dodyndns --domain example.com --name host
```

Use `--no-ipv4` or `--no-ipv6` to explicitly disable either from being set.

To force setting the address to a custom IPv4 address and the automatically resolved IPv6 address use the following:

```sh
dodyndns --domain example.com --name host --ipv4 123.123.123.123
```

To force setting the address to a custom IPv6 address and the automatically resolved IPv4 address use the following:

```sh
dodyndns --domain example.com --name host --ipv6 2000:2001::1
```

To force setting the address to a custom IPv6 address and the not setting the IPv4 address use the following:

```sh
dodyndns --domain example.com --name host --ipv6 2000:2001::1 --no-ipv4
```

## Contributing

1. Fork it (<https://github.com/jeroenj/dodyndns/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [jeroenj](https://github.com/jeroenj) Jeroen Jacobs - creator, maintainer
