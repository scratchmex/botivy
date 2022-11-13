from decouple import config
from traceback import format_exc

from fastapi import Request

from . import actions
from .parser import Parser


class Bot:
    def __init__(self, *, parser: Parser, **kwargs):
        self.parser = parser
        self.conf = kwargs

    async def dispatch(self, request: Request):
        action, args = await self.parser.get_action(request)

        action_callback = getattr(self, action)

        if not action_callback:
            print(f"{action} callback not implemented")

            return
        try:
            info = action_callback(args)
            exp_msg = None
        except Exception:
            info = None
            exp_msg = f"Failure! \n\n```\n{format_exc()}```"

        return self.parser.reply(info=info, exp_msg=exp_msg)

    def deploy(self, args: list):
        """
        @ivy deploy main
        """
        repo = config("GITHUB_REPO", None)

        if not repo:
            if not len(args) == 2:
                return "I should receive `<repo> <ref>` as argument without spaces on the params."

            repo, ref = args
        else:
            if not len(args) == 1:
                return "I should only receive the `<ref>` as argument without spaces"
            
            ref, = args
        
        return actions.deploy(
                repo_uri=repo,
                ref=ref
            )
        