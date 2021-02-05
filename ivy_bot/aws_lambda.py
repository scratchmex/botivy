import sys
import json

from . import parser
from .bot import Bot


bot = Bot(
    parser=parser.Zulip,
)


def handler(event, context):
    method = event.get("requestContext", {}).get("http", {}).get("method")

    if method == "GET":
        return {
            "message": f'Hello! Ivy bot here from AWS Lambda using Python {sys.version} !',
            "event": event,
        }

    if method == "POST":
        body = event.get("body")

        if not body:
            return {
                "error": "no body found",
                "event": event
            }
        
        body = json.loads(body)
        data = body["data"]

        return bot.dispatch(data)

    return {
        "error": "No method found.",
        "event": event,
    }