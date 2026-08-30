# Security Policy

## Supported versions

This repository is a fork of [hsand/pia-wg](https://github.com/hsand/pia-wg).
Only the current `master` branch gets fixes. There are no tagged releases and no
backports to earlier commits.

## Reporting a vulnerability

Report a suspected vulnerability through
[GitHub private vulnerability reporting](https://github.com/jauderho/pia-wg/security/advisories/new).
Do not open a public issue for a security problem.

Include the affected file or command, the steps that show the problem, and the
version of Python and of the operating system that you used.

Expect an initial answer in 7 days. If the report is valid, a fix goes to
`master` and an advisory is published.

## Scope

In scope:

* The Python code in this repository (`piawg.py`, `generate-config.py`).
* The dependency set recorded in `pyproject.toml` and `uv.lock`.
* The container image built from `Dockerfile`.

Out of scope:

* The Private Internet Access service and its API. Report those to
  [Private Internet Access](https://www.privateinternetaccess.com/).
* WireGuard itself. Report those to the
  [WireGuard project](https://www.wireguard.com/#contact).

## Handling of credentials

`generate-config.py` asks for the PIA user name and password, sends them to the
PIA authentication endpoint, and keeps the returned token in memory only. The
generated `PIA.conf` holds a WireGuard private key. Keep that file secret and do
not commit it; `.gitignore` excludes it.
