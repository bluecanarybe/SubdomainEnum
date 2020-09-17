# SubdomainEnum
Bash wrapper for multiple subdomain enumeration scripts

# Requirements
- [Amass](https://github.com/OWASP/Amass)
- [Turbolist3r](https://github.com/fleetcaptain/Turbolist3r)
- [Assetfinder](https://github.com/tomnomnom/assetfinder)
- [OneForAll](https://github.com/shmilylty/OneForAll) 
- [HTTProbe](https://github.com/tomnomnom/httprobe)
- [Chaos](https://github.com/projectdiscovery/chaos-client) // you'll need an API key
- [HTTPResponseChecker](https://github.com/bluecanarybe/ResponseChecker)

The script will run all scripts independently, and merge & clean all results in one file. 

# Usage

```
./subdomains.sh <domain>
```

Obviously you will need to fix your paths according to your installation.

# Disclaimer

My code probably sucks but it does the job for me. If you don't like it, go on or create a pull request.
