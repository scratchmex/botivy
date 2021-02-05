from decouple import config
from github import Github


gh_token = config("GITHUB_TOKEN")

gh = Github(gh_token)

def deploy(repo_uri: str, ref: str, env="production") -> str:
    repo = gh.get_repo(repo_uri)

    # https://docs.github.com/en/rest/reference/repos#create-a-deployment
    repo.create_deployment(
        ref=ref,
        environment=env,
        description=f"Deploying {ref} to {env} via Ivy bot",
        auto_merge=False,  # allow to deploy past ref
    )

    msg = f"Deploying `{repo_uri}` @ `{ref}` to **{env}** [see here](https://github.com/{repo_uri}/deployments)"

    return msg