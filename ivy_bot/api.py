from pprint import pprint as print
from fastapi import FastAPI, Request
from pydantic import BaseModel

from . import parser
from .bot import Bot

class WebhookRequest(BaseModel):
    bot_email: str
    data: str
    message: dict
    token: str
    trigger: str

app = FastAPI()

bot = Bot(
    parser=parser.Zulip,
)


@app.get("/")
async def get_root():
    return {"message": "Ivy bot here"}
    

@app.post("/")
async def post_root(request: WebhookRequest):
    print(request.json())

    return bot.dispatch(request.data)