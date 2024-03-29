from __future__ import annotations
from abc import ABC, abstractmethod

import requests

from fastapi import Request
from decouple import config
from pydantic import BaseModel

from .actions import DeployInfo


class Parser(ABC):
    @abstractmethod
    async def get_action(self, msg: Request) -> tuple[str, list]:
        pass

    @abstractmethod
    def reply(self, info: DeployInfo | None, exp_msg: str | None) -> any:
        pass

class ZulipWebhookRequest(BaseModel):
    bot_email: str
    data: str
    message: dict
    token: str
    trigger: str

class Zulip(Parser):
    async def get_action(self, request: Request):
        req = ZulipWebhookRequest(**(await request.json()))
        msg = req.data

        msg = msg.split()
        if msg[0].startswith("@**"):
            msg = msg[1:]

        action, args = msg[0], msg[1:]

        return action, args

    def reply(self, info: DeployInfo):
        msg = f"Deploying `{info.repo_uri}` @ `{info.ref}` to **{info.env}** [see here](https://github.com/{info.repo_uri}/deployments)"
        return {
            "content": msg
        }

class SlackWebhookRequest(BaseModel):
    command: str
    text: str
    response_url: str


slack_webhook = config("SLACK_WEBHOOK")
class Slack(Parser):
    async def get_action(self, request: Request):
        req = SlackWebhookRequest(**(await request.form()))

        action = req.command.lstrip("/")
        args = req.text.split(" ")
    
        return action, args

    def reply(self, info: DeployInfo | None, exp_msg: str | None):
        if exp_msg:
            msg = exp_msg
        else:
            assert info is not None
            msg = f"Deploying `{info.repo_uri}` @ `{info.ref}` <https://github.com/{info.repo_uri}/deployments|see here>"

        requests.post(slack_webhook, json={
            "blocks": [
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": msg
                    }
                },
            ]
        })

        return {"text": "ack"}
        
