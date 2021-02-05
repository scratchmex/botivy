from __future__ import annotations
from abc import ABC, abstractmethod


class Parser(ABC):
    @abstractmethod
    def get_action(self, msg: str) -> tuple[str, list]:
        pass

    @abstractmethod
    def reply(self, msg: str) -> any:
        pass


class Zulip(Parser):
    def get_action(self, msg: str):
        msg = msg.split()
        if msg[0].startswith("@**"):
            msg = msg[1:]

        action, args = msg[0], msg[1:]

        return action, args

    def reply(self, msg: str):
        return {
            "content": msg
        }