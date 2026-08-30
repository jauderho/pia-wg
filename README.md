# pia-wg
A WireGuard configuration utility for Private Internet Access

This is a Python utility that generates WireGuard configuration files for the Private Internet Access VPN service. This allows you to take advantage of the WireGuard protocol without relying on PIA's proprietary client.

This was created by reverse engineering the [manual-connections](https://github.com/pia-foss/manual-connections) script released by PIA. At this stage, the tool is a quick and dirty attempt to get things working. It could break at any moment if PIA makes changes to their API.

pia-wg runs on both Windows and Linux.

Dependencies are managed with [uv](https://docs.astral.sh/uv/). uv reads `pyproject.toml` and `uv.lock`, then installs the exact locked versions into a project virtual environment. It also downloads the required Python interpreter, so you do not have to install Python yourself.

## Windows
* Install [uv](https://docs.astral.sh/uv/getting-started/installation/)
* Install [WireGuard](https://www.wireguard.com/install/)

Open a command prompt and navigate to the directory where you placed the pia-wg utility, then run the tool.

```
uv run generate-config.py
```

Follow the prompts.

The script generates a `PIA.conf` file that can be imported into the WireGuard utility.

## Linux (Debian/Ubuntu)
Install dependencies and clone the pia-wg project:
```
sudo apt install git wireguard openresolv
curl -LsSf https://astral.sh/uv/install.sh | sh
git clone https://github.com/jauderho/pia-wg.git
cd pia-wg
```

Run the tool, and follow the prompts
```
uv run generate-config.py
```

Copy the `.conf` file to `/etc/wireguard/`, and start the interface
```
sudo cp PIA.conf /etc/wireguard/wg0.conf
sudo wg-quick up wg0
```

You can shut down the interface with `sudo wg-quick down wg0`

## Check everything is working
Visit https://dnsleaktest.com/ to see your new IP and check for DNS leaks.
