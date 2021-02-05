# Ivy Bot

Hello there. I'm Ivy, a bot created by Ivan to help him automate some things. 
I'm intented to work via a chat and with an API interface.

## Integrations

Currently I'm build to work with Zulip but I can easily be extended to work with Slack also!

### Zulip

You need to make a Generic type bot.

## Deploy

Currently I can be deployed via an API interface or via AWS Lambda

### API Interface

It uses FastAPI framework and Uvicorn to run it:
```console
$ uvicorn ivy_bot.api:app
```

### AWS Lambda

The `Dockerfile` is [built](https://docs.aws.amazon.com/lambda/latest/dg/images-create.html) to be used with [AWS Lambda and its container image service](https://docs.aws.amazon.com/lambda/latest/dg/python-image.html).
```console
$ docker build -t ivy-bot-zulip .

$ docker tag ivy-bot-zulip:latest <account_id>.dkr.ecr.<region>.amazonaws.com/ivy-bot-zulip:latest

$ docker push <account_id>.dkr.ecr.<region>.amazonaws.com/ivy-bot-zulip:latest
```

To [test locally the image](https://docs.aws.amazon.com/lambda/latest/dg/images-test.html) run
```console
$ docker run -p 9000:8080 ivy-bot-zulip:latest 

$ curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"message": "this is the event object"}'
```

## Actions

This are the actions currently supported. 

In general the syntax is `<action> <args1> <arg2> ...`

* Zulip only triggers the outgoing webhook when you send me a message **mentioning me** `@**Ivy**` or when you send me a **private message**. For that, when you
  *  send me a **private message** the syntax is `<action> ...`
  *  **mention me** in a stream the syntax is `@**Ivy** <action> ...`

### Deploy

When you trigger this action I use the Github API to create a deployment.

#### Syntax

- `deploy <ref>` if you set `GITHUB_REPO` env variable
  - e.g. `deploy main`
- `deploy <repo> <ref>` otherwise
  - e.g. `deploy github/octopi main`

#### Config

- `GITHUB_TOKEN` the Github token with `repo` permissions ([create one here](https://github.com/settings/tokens/new))
- `GITHUB_REPO` the Github repo to deploy to, e.g. `github/octopi`

#### Github Actions

An example `.github/workflows/deploy.yaml` file to integrate the bot:

```yaml
name: Deploy

on: deployment

jobs:
  deploy:
    name: Deploy my app

    runs-on: ubuntu-latest

    steps:
      - name: Update deployment status (in progress)
        uses: avakar/set-deployment-status@v1
        with:
          state: in_progress
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          
      - uses: actions/checkout@v2
        with:
          ref: '${{ github.sha }}'

      - name: Deploy my app
        run: |
          echo 'Performing the deployment...'
          sleep 10

      - name: Update deployment status (success)
        if: success()
        uses: avakar/set-deployment-status@v1
        with:
          state: success
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Update deployment status (failure)
        if: failure()
        uses: avakar/set-deployment-status@v1
        with:
          state: failure
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

