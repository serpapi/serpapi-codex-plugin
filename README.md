# <img src="plugins/serpapi/assets/logo.png" width="30" height="30"/> SerpApi for ChatGPT and Codex

Access live search results from over 100 different engines, powered by [SerpApi](https://serpapi.com/). Search Google, Bing, YouTube, Amazon, Google Maps, Google Scholar, and more directly from ChatGPT and Codex.

Research current events with source links, compare product prices, discover local businesses, or find academic papers. Describe what you need in plain language, and the plugin helps you find relevant results without writing API requests or choosing search parameters yourself.

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Install from GitHub

Run these commands in your terminal with Codex CLI installed:

```bash
codex plugin marketplace add serpapi/serpapi-codex-plugin --ref main
codex plugin add serpapi@serpapi
```

## Set up SerpApi

You'll need a SerpApi account and an API key from your [SerpApi dashboard](https://serpapi.com/dashboard).

After installation, open a new chat in Codex or start a new Codex CLI session, then paste this prompt:

```text
Set up SerpApi, verify access, and then search for recent OpenAI announcements.
```

Codex will guide you through connecting your account, check that search works, and continue with your request. Follow the setup prompts and enter your API key only through a secure input, not in chat.

## Search with SerpApi

Once setup is complete, ask for what you need in natural language. You can search for news, products, places, papers, videos, flights, and hotels. Here are a few prompts to try:

> Use SerpApi to find the latest OpenAI announcements and cite the strongest sources.

> Compare current AirPods Pro listings on Amazon, Walmart, and eBay.

> Find recent papers about retrieval-augmented generation in Google Scholar.

> Find well-reviewed coffee shops near Times Square.

Include details such as your location, travel dates, budget, or preferred sources to make the results more useful. Follow up to narrow the search, compare options, or explore a result in more detail.

## Support

Contact [SerpApi support](https://serpapi.com/#contact) for account or search issues. Report plugin issues in the [GitHub repository](https://github.com/serpapi/serpapi-codex-plugin/issues).

## License

MIT. See [LICENSE](LICENSE).
