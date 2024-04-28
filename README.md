# linkedin.sh


### Use on GitHub Action

Firstly, run on your local machine the following command to generate a token:

```bash
linkedin.sh login
```

Then, create a GitHub secret called `LINKEDIN_ACCESS_TOKEN` and paste the token generated.

Finally, create a GitHub Action workflow file (e.g. `.github/workflows/linkedin.yml`) with the following content:

You must create a GitHub Personal Access Token with the `repo` and `admin` scope to keep the `LINKEDIN_ACCESS_TOKEN` secret and update it when it expires.

```yaml
name: Daily LinkedIn Post

on:
  push:
    branches:
      - main

jobs:
  refresh_access_token:
    runs-on: ubuntu-latest
    env:      
      GH_TOKEN: ${{ secrets.GH_TOKEN }}
      LINKEDIN_ACCESS_TOKEN: ${{ secrets.LINKEDIN_ACCESS_TOKEN }}      
    steps:
          
      - name: Install linkedin.sh
        run: |
          mkdir -p ./bin
          curl -sL https://raw.githubusercontent.com/francescobianco/linkedin.sh/main/bin/linkedin.sh > ./bin/linkedin.sh 
          chmod +x ./bin/linkedin.sh 

      - name: Refresh Access Token
        run: ./bin/linkedin.sh access-token-refresh | gh secret set LINKEDIN_ACCESS_TOKEN
          
      - name: New LinkedIn Post
        run: ./bin/linkedin.sh post my_post.txt 
```
