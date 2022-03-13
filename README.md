# GitHub-to-Qiita

```yaml
name: "GitHub to Qiita"

on:
  push:
    branches: [ main ]

jobs:
  qiita:
    runs-on: ubuntu-latest
    steps:
      - name: "Publish to Qiita"
        uses: noraworld/github-to-qiita@v0.1.0
        with:
          dir: "articles"
          qiita_access_token: ${{ secrets.QIITA_ACCESS_TOKEN }}
```

## Setup
TBA

## How to contribute
TBA

## Important notes
The old implementation has moved to [noraworld/github-to-qiita-server](https://github.com/noraworld/github-to-qiita-server), and it is no longer supported.
