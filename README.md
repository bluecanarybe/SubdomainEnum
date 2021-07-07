# SubdomainEnum
Bash wrapper for multiple subdomain enumeration scripts

# Uses:
- [Amass](https://github.com/OWASP/Amass)
- [Turbolist3r](https://github.com/fleetcaptain/Turbolist3r)
- [Assetfinder](https://github.com/tomnomnom/assetfinder)
- [OneForAll](https://github.com/shmilylty/OneForAll)
- [HTTProbe](https://github.com/tomnomnom/httprobe)
- [Chaos](https://github.com/projectdiscovery/chaos-client) // you'll need an API key
- [HTTPResponseChecker](https://github.com/bluecanarybe/ResponseChecker)

The script will run all scripts independently, and merge & clean all results in one file. 
It also supports enumeration of secondlevel subdomains such as subdomain.target.example.com.

# Installation

```
git clone https://github.com/bluecanarybe/SubdomainEnum.git
```

Build the image with Docker

```
docker build -t subwrapper .
```

# Usage via Docker

Run Docker container replacing with your chaos API key as an environment variable and target
```
docker run -e CHAOS_KEY="$API_KEY_HERE" subwrapper ./subdomains.sh target.com
```
