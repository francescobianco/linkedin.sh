# linkedin.sh


### Use on GitHub Action

Firstly, run on your local machine the following command to generate a token:

```bash
linkedin.sh github 
```

Finally, create a GitHub Action workflow file (e.g. `.github/workflows/linkedin.yml`) with the following content:

```yaml
name: Daily LinkedIn Post

on:
  schedule:
   - cron: '0 9 * * *'

jobs:
  refresh_access_token:
    runs-on: ubuntu-latest
    env:      
      LINKEDIN_ACCESS_TOKEN: ${{ secrets.LINKEDIN_ACCESS_TOKEN }}      
    steps:
          
      - name: Install linkedin.sh
        run: |
          mkdir -p ./bin
          curl -sL https://raw.githubusercontent.com/francescobianco/linkedin.sh/main/bin/linkedin.sh > ./bin/linkedin.sh 
          chmod +x ./bin/linkedin.sh 
          
      - name: New LinkedIn Post
        run: ./bin/linkedin.sh post my_post.txt 
```
