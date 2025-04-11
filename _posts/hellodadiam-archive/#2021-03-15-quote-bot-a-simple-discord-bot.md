We’ve all had that problem. Your friend says something iconic during a session in Discord and you need to have that in record. But it’s so hard to scroll up later on. Or if you need to quote it over a voice channel and the conversion is moving so fast.

No need to worry. Quote Bot is here! It’s a simple bot to get you into the world of discord bots and can help you record the most precious moment with your friend. Best of all, it saves everything to a Mongo database so you can quickly sweep through different filters.

## Prerequisites

- Python3
- Discord.py
- Dedicated computer
- Discord account
- MongoDB

## Setup and Installation

This guide will assume you have installed [MongoDB](https://www.mongodb.com/docs/manual/installation/) and know how to use it. It will also assume you have a discord bot token ready to go and have [Discord.py](https://discordpy.readthedocs.io/en/latest/) installed. There are many great tutorials out there and there’s no point in rewriting one here. One last thing, like many great projects, it’s important to have setup a virtual environment for this project. With that said, if you have everything ready, let’s get started.

## Settings

We’ll create a settings.json file to store a few variables to make it easier to expand later on. We’ll first store our prefix and our bot token.

~~~json
{
    "prefix": "&",
    "BotToken": "REPLACE WITH TOKEN"
}
~~~

## Connecting and Turning On

Let’s start by importing a few modules. Don’t worry you’ll understand what each of these do as we go on.

~~~python
import discord 
import json
import pymongo
from discord.ext import commands
from datetime import date, datetime 
~~~

Let’s create a async event to tell us when the bot has connected. And then, let’s tell the bot to run at the end of the file. This line should be the last thing your program executes.

~~~python
botPrefix = settings["prefix"]
bot = commands.Bot(command_prefix=botPrefix)
TOKEN = settings["BotToken"]

bot.run(TOKEN)
~~~

## Load Bot Settings and DB

You might have noticed that we called a few parameters from our json file. Let’s load the file before we call anything from it first.

~~~python
with open("settings.json", "r") as settingsFile:
    settings = json.load(settingsFile)
~~~

Next, let’s load our mongoDB in as well. We will be numbering our quotes based on the previous ones so it will process between restarts. Don’t worry, we’ll have an index column when we store our quotes later so this will be called. You can call your database and collection anything you want.

~~~python
myclient = pymongo.MongoClient("mongodb://localhost:27017/")
mydb = myclient["QuoteBot"]
mycol = mydb["quotesArchive"] 
for doc in mycol.find({}, {"_id":1}).sort("_id", -1).limit(1):
    no = doc["_id"] + 1
~~~

## Quoting Command

Here’s the meat of our command. We will have to parse through the given message, find the quote, find the author, create an entry, and return the formatted quote. No time to waste, let’s go!

### Find the Quote

First thing’s first. When we get the trigger for our command to run, we need to find the quote. For that, let’s use a simple char finder and get the position of the ” char. We will also ignore the first 4 characters as they are the command. Oh and let’s also define our function and get the “no” variable in here. We will also return an error message if we can’t find it.

~~~python
@bot.command(name="q")
async def quote(ctx):
    global no
    quote = ctx.message.content[3:]
    quotePOS = [pos for pos, char in enumerate(quote) if char == '"']
    if len(quotePOS) != 2:
        await ctx.send("Error: Can't Find Quote. Please surround your quote with quotation marks.")
        await ctx.message.delete()
        return

    quoteReturn = quote[quotePOS[0]+1:quotePOS[1]]
~~~

## Find the Author

Discord contains all the mentions in a nice place in context so we’ll use that. Because discord tags people not with the @username (that’s just to make it look pretty on the surface, we will need to get the user’s ID. This ID is surrounded with “<>” so again, we’ll parse for these characters. While we’re here, let’s also get the senders ID and the URL for our database entry later.

~~~python
    authorList = ctx.message.mentions
    if len(authorList) > 1:
        await ctx.send("Error: Please only specify one author at this time.")
        await ctx.message.delete()
        return
    elif len(authorList) == 0:
        await ctx.send("Error: Please only specify an author.")
        await ctx.message.delete()
        return
    author = authorList[0]
    sender = ctx.message.author
    jumpURL = ctx.message.jump_url
    authorID = quote[quote.find("<"):quote.find(">")+1]
~~~

## Date Citation

For any good citation, we will need to get the time. We’ll also use this to help sort our database. For our return message, we will only be using the year though.

~~~python
    today = date.today() 
    time = datetime.now()
    time = time.strftime("%H:%M:%S")
    year = today.year
~~~

## Return Message

So, with everything done, let’s format it to look neat and tidy. We’ll also “double space” things to keep it looking sleek. This will be achieved by the Unicode character “3164”. After we send the formatted message, we’ll delete the original message as well. You might’ve seen this command throughout the script. Deleting the original message helps keep the channel clean. The return message might seem complicated, but it’s just a lot of connected strings plus discord markdown formatting. You can change this formatting however you like. Just read up a bit on discord’s markdown.

~~~python
return message
    await ctx.send(str(no) + ": "'***"'+str(quoteReturn)+'"'+".*** `(`"+str(authorID)+"`, "+str(year)+")`")
    await ctx.message.delete()
    await ctx.send("\u3164")
~~~

## Add to DB

Finally when things are all sent, we can ad the new entry to the database. We will be using mongo’s built in “_id” value to store our quote number. And so we don’t weight on our database, we will just add to our “no” variable for the next quote while the bot is active.

~~~python
    mycol.insert_one({"_id" : no, "quote" : quoteReturn, "author" : str(author), "sender" : str(sender), "time" : str(time), "day" : str(today), "url" : str(jumpURL)})
    no += 1
~~~

## Conclusion

Tada! You have just made your very own Discord bot! This is just an introduction to what a bot can do. Because Discord.py is a robust wrapper, you can code basically anything you want with the original API. Give yourself the server experience you and your friends deserve