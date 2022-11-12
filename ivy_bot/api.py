from pprint import pprint

from fastapi import FastAPI, Request

from . import parser
from .bot import Bot


app = FastAPI()

bot = Bot(
    parser=parser.Slack(),
)

@app.get("/")
async def get_root():
    return {"message": "Ivy bot here"}
    

@app.post("/")
async def post_root(request: Request):
    pprint(await request.body())

    return await bot.dispatch(request)
