from decouple import config
from github import Github
from pydantic import BaseModel


gh_token = config("GITHUB_TOKEN")

gh = Github(gh_token)

class DeployInfo(BaseModel):
    repo_uri: str
    ref: str
    env: str

def deploy(repo_uri: str, ref: str, env="production") -> DeployInfo:
    repo = gh.get_repo(repo_uri)

    # https://docs.github.com/en/rest/reference/repos#create-a-deployment
    repo.create_deployment(
        ref=ref,
        environment=env,
        description=f"Deploying {ref} to {env} via Ivy bot",
        auto_merge=False,  # allow to deploy past ref
    )
  
    return DeployInfo(
        repo_uri=repo_uri,
        ref=ref,
        env=env,
    )
