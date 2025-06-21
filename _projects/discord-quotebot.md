---
layout: project
title: Quotebot (Discord)
caption: For when you need receipts of the group chat.
description: >
  My friends say the darnedest things and I aim to capture them all for eternity.
date: 2024-03-02
image: 
  path: /assets/img/projects/discord-quotebot-cover.png
links:
  - title: Github Repo
    url: https://github.com/dscpsyl/quotebot
---

# Quotebot

1. 
{: toc }

## I like to Hang Out with Friends

I'll admit it now, I'm not much of a gamer as I use to be. [Discord](https://discord.com/) was my home for a time long ago (and maybe it will be soon if their rebrand into the corporate space somehow succeeds), but now I use to remind myself that I need to carve out time for those around me lest I let work consume my waking hours. When I do make time for them, it is a neverending stream of joy, laughter, and the occasional existential crisis. Admist all of this, criminally iconic lines are uttered to the ether, which I find unforgivable. These one-shot lines deserve to be saved reminiscing, a walk down memory lane, or simply future "reference" material. As such, I aimed to create another data-entry front-end for my enjoyment.

Alright alright, I made the basis of this project many many moons ago, but I've only recently pushed it to a point where I can be somewhat okay in letting it run amuck in the wild. So if the dates seem wrong, they're not; I'm just lazy.
{:.note title="On the Timeline of It All"}

## The Idea

Since Discord was the go-to platform, it was only natural that I develop something for the server that I was apart of. I didn't want anything fancy, just something to get the job done. The bot wasn't doing the heavy lifting, only the decorating. It should be able limited to a specific channel in a Discord server, and the bot should manage the format of the channel automatically. That is, when a user submits a quote, the submission should not clutter the channel itself. Rather, it should be a beautiful wall of quotes and only quotes. This way, all the quotes will be in one place, easily searchable, and can be referenced at any time.

### What's a Discord Bot?

Discord bots are nothing more than web applications that can communicate with Discord's API. You can read the full documentation on [Discord's Developer Documentation](https://discord.com/developers/docs/intro). Technically, their official term is called *Discord Apps*. While their feature set is extensive, this bot will only do the basic of basics: listen for messages, parse them, post them, delete them, and store them. There's no need for real-time updates, interactions, or anything fancy. With that being said, this project will only scratch the surface of what Discord bots can do. If you want to learn more about the possibilities, I recommend checking out [Discord.js](https://discord.js.org/#/) or [Discord.py](https://discordpy.readthedocs.io/en/stable/). While many facor using Javascript, this project will use Python and [Discord.py](https://discordpy.readthedocs.io/en/stable/).

### Message Formats

For many reasons, I've chosen the [MLA7 Citation Style](https://owl.purdue.edu/owl/research_and_citation/mla_style/mla_formatting_and_style_guide/mla_formatting_and_style_guide.html). Specifically, I wanted the in-text citation style of __"Quote" (Author, Year)__. This gives me all the information I need to filter for the yearly rewind, the ability to see the magnificent creator of the quote, and the said quote itself. Really anything can be in the `Quote` part of the message, so linting and input validation are a consideration. The `Author` field will be the Discord handle and the `Year` should be automatically generated based on when the quote is submitted to the bot.

For the user input, we want it to be as simple as possible. Thus the user should only need to specify two things: the quote itself and the author of the quote. The bot will then take care of the rest. We need to make sure that the author is a Discord user tag, so the author needs to start with teh `@` symbol. The bot will be looking for this while parsing the message. Otherwise, any other character should be valid in the quote, as long as it is betwen two quotation marks. 

We will be looking for straight quotes, so any curly or styled quotes will not be recognized by the bot. Of course, this is a simple fix, but I have to keep my friends humble.
{.note title="Types of Quotation Marks"}

One final bit on the order of information. Becasue we want to make sure that any type of quote can be submitted, we will enforce the fact that the author is always the last item in the message. This way, any amount of whitespace or other characters can be used, and the entore mesage less the final block of text seperated by a whitespace will be the quote.

## Boring Chores

First things first, you have to get yourself a token for your bot. Login with your Discord account at the [Discord's Developer Portal](https://discord.com/developers/applications) and create a new application. This will give you a bot token that you can use to authenticate your bot with Discord's API. You can also set the bot's name, icon, and description here. Write this down now, as if you loose it, you'll have a world of heacache trying to re-establish the bot.

Also, make sure you have a database instance up and running, ready for your bot to connect to, along with a user for the database, lest you give all your applications admin privileges. For this project, I was really into [MongoDB](https://www.mongodb.com/) at the time, so I used that as my database of choice. You can use any database you want, but you'll have to modify the code a little.

### Settings

For simplicity, we will have a settings file that will hold the configuration for the bot. The main items required here are a predefined bot prefix, the bot token, the channel ID for the quotes, and the database connection, plus the database and collection items (i.e. the database and table) for MongoDB.

```json
{
  "prefix": "",
  "BotToken": "",
  "ChannelID": "",
  "mongoClientID": "",
  "databaseName": "",
  "collectionName": ""
}
```

Later, we'll see that the prefix is not necessary needed given the channelID already sets an exclusive quote zone. In addition, the prefix is simply the starting prefix that can be tuned later.

### Adding the Bot

Back on the [Discord's Developer Portal](https://discord.com/developers/applications), under **Installation**, you can generate an OAuth2 URL to add the bot to your server. Make sure you select the correct permissions for the bot, such as `Send Messages`, `Read Message History`, and `Manage Messages`. Once you have the URL, you can add the bot to your server.

## Main Functions

There are three parts to this bot: the main quote handling functions, the database and quote editing functions, and the general bot configuration functions. However, before any of that, we need to load a bot. For this, we will use the [Discord.py](https://discordpy.readthedocs.io/en/stable/) library to create a bot and manage its functionalities. We already have many of the properties set in the settings file, so we can load those in as well. We will also [pymongo](https://pymongo.readthedocs.io/en/stable/) to connect to the MongoDB database and manage the quotes. To make developnment easier, let's also set up logging to keep track of the bot's activities and have a fallback in case of any async errors.

```python
import json
import logging as log
import sys
from datetime import date
from datetime import datetime
from pathlib import Path

import discord
import pymongo
from discord.ext import commands

# Loads Settings
with open("settings.json", "r") as settingsFile:
    settings: dict = json.load(settingsFile)

# Logging
log.basicConfig(level=log.INFO)

# Format the logs
logFormat = log.Formatter(
    "%(asctime)s - %(levelname)s - %(filename)s::%(funcName)s - %(message)s")
rootLogger = log.getLogger()

# Handle the logs into a file
logFile = f"logs/quotebot-{datetime.now().strftime('%d-%m-%Y-%H-%M-%S')}.log"
Path(logFile).touch(exist_ok=True)
fileLogger = log.FileHandler(logFile)
fileLogger.setFormatter(logFormat)
rootLogger.addHandler(fileLogger)

# Handle the logs into the console
consoleLogger = log.StreamHandler(sys.stdout)
consoleLogger.setFormatter(logFormat)
rootLogger.addHandler(consoleLogger)

# Set the premissions for the bot
intents: discord.Intents = discord.Intents.default()
intents.message_content = True

# Loads Bot
bot = commands.Bot(command_prefix=settings["prefix"],
                   intents=intents,
                   help_command=None)

# Loads db
myclient: pymongo.MongoClient = pymongo.MongoClient(settings["mongoClientID"] + settings["databaseName"])
mydb = myclient.get_default_database()
mycol = mydb[settings["collectionName"]]

# Set the quote number to the last quote number in the database
no: int = 1
for doc in mycol.find({}, {"_id": 1}).sort("_id", -1).limit(1):
    no: int = doc["_id"] + 1
```

To run the bot, we can run `bot.run(settings["BotToken"])` at the end of the file once all functions have been defined. This will initialize the bot to the Discord servers with the token we've been given. If you were to start this now, you should see the bot show as *online* in your server, but it won't do anything. Let's make it do something.

### Quotes

To interact with the bot, we will need to define functions for `events` that the bot will listen for. Thankfully, our defined `bot`  object has a built-in decorator `bot.event` for us to use. For this bot, there are two functions that we will need to overload in this decorator: `on_ready` and `on_message`. The first will be called when the bot is ready to start receiving messages, and the second will be called when a message is sent in the server. For now, let's say that when the bot is up and ready, it'll simply log it. We'll also update the global quote number from ealier.

```python
@bot.event
async def on_ready():
  global no
  log.info(
      f'{bot.user} is connected and has the db of: {str(str(mydb).split(" ")[-1:])[2:-3]} with collection: {str(str(mycol).split(" ")[-1:])[2:-3]}'
  )
  log.info(f"Initalized quote number: {no}")
```

Now for the fun part in `on_message`. This function will be called every time a message is sent to the server. It is our job now to see if there is anything we need to do. As I've mentioned before, the prefix will not be used as long as the channel is defined. That is true, for quotes. For other functionalities, we need to parse the prefix to redirect the command to the right function. We'll save this discussion for later. For now, let's simply use the bot's built in function to parse it like a command if we see the prefix. Because this function will be called for every message, we also need to check if the message is sent to the correct channel (i.e., the quotes channel). Finally, to prevent a positive feedback loop, we will also ignore messages sent by the bot itself, otherwise we will recurs into infinity.

```python
@bot.event
async def on_message(message: discord.Message):

  # Check for command prefixes and process commands
  prefix = settings["prefix"]
  if message.content.startswith(prefix):
    await bot.process_commands(message)
    return

  global no  # global quote number

  # Check of the message is in the channel we are looking for
  channelWatch = settings["ChannelID"]
  if str(message.channel.id) != channelWatch:
    return

  # Check if the message is from the bot
  if message.author == bot.user:
    return
```

Now, let's make sure that there is only one mention in the message; this will be the author of the quote. If there is more or less than one mention, we will ask the user to retry the quote submission. If there is only one mention, we will extract the author of the quote, as well as the submitter of the quote for the database later on.

```python
authorList: list = message.mentions
  if len(authorList) > 1 or len(authorList) == 0:
    await message.delete()
    await message.channel.send(
      f"Error: Please only specify one author for this quote at this time we found {len(authorList)}: {[user.name for user in authorList]} in quote: {message.content}.",
      delete_after=60,
    )
    log.warning(
      f"{message.author} tried to add a quote with {len(authorList)} authors: {[user.name for user in authorList]} and content: {message.content}"
    )
    return
quoteAuthor: discord.Member = authorList[0]
quoteSender: discord.User | discord.Member = message.author

# Get a mentionable string for the author
authorMentionString: str = quoteAuthor.mention
```

With the author sorted, let's turn our attention to the quote itself. As mentioned earlier, the last item in the message itself will be the author. Everything else will be the quote itself. The reason we didn't parse the author out of the message content itself is becasue the content does not have the right Discord user slug format. Without it, any `@`s will have no reference and simply be plain text. Thus, the necessity to extract the author from the `mentions`. Now, we can simply extract the content minus the last item to form the quote.

```python
# Get the content of the message and make sure the citation is at the end of the message
quoteContent: str | list = message.content
quoteContent = quoteContent.split(" ")
quote: str = " ".join(quoteContent[:-1])
if quoteContent[-1] != authorMentionString:
  await message.delete()
  await message.channel.send(
    f"Error: Please make sure to mention the author at the end of the quote For example: {quote} @citation.",
    delete_after=60,
  )
  log.warning(
    f"{message.author} tried to add a quote without mentioning the author at the end of the quote: {quote}"
  )
  return
```

Finally, we will add the year to the quote.

```python
# Get's current year for citationå
today: date = date.today()
time: datetime | str = datetime.now()
time = time.strftime("%H:%M:%S")
year: int = today.year
```

A small side step. Discord has some basic `*` markdown formatting, and we will be utilizing it to format the final quote for the channel. As such, we will need to make sure any quote that already contains `*` is escaped so as to not mess up the formatting.

```python
# Sanitize the quote to prevent * from messing up the formatting
sanitizedQuote = quote.replace("*", "\\*")
```

Now we can construct the full quote message 

```python
# Sends formatted message & cleans up
fullQuote = (str(no) + ": "
            '***"' + sanitizedQuote + '"' + ".*** `(`" +
            authorMentionString + "`, " + str(year) + ")`")
quote_message = await message.channel.send(fullQuote)
jumpURL: str = quote_message.jump_url
await message.delete()
# Invisible character for double spacing
await message.channel.send("\u3164")
```

To wrap everything up, we will take the data we've gathered and store it into the database and increase the global quote number. The database will include the quote number, the quote itself, the author, the submitter, the time, the date, and the jump URL for the quote message (which was retrieved in the code block above). The jump URL is a link to the message itself, which can be used to reference the quote later on.

```python
# Write to Database
mycol.insert_one({
  "_id": no,
  "quote": quote,
  "author": str(quoteAuthor),
  "sender": str(quoteSender),
  "time": str(time),
  "day": str(today),
  "url": str(jumpURL),
})

# print to console
log.info(
  f'Added quote no: {no} to database: "{quote}", {quoteAuthor.name} from {quoteSender.name}. `{str(jumpURL)}`'
)

no += 1
```

While I haven't explicitly mentioned it, you'll notice that for any error or completion of task, the bot will delete the message sent by the user. This is the cleanup management that I mentioned at the beginning. You'll see this throughout the bot, ensuring that the task is completed before clearing the message. This way, no data is lost in case of error, and cleanup is very low on priority.
{.note title="Message Cleanups"}

### Editing

For editing previous quotes, we will define two options: the quote itself, and the author of a quote. The command format will be `<prefix>e author <quote number> <new author>` or `<prefix>e quote <quote number> <new quote>`. Let's define a main edit function to handle the command call. We will check the format and validity of the command and send the result to the correct editing functions.

```python
# ? Args0 will be option of edit | args1 will be quote to edit
@bot.command(name="e", help="Edits previous quotes in database")
async def edit(ctx, *args):
  if len(args) == 0:
    await ctx.message.delete()
    await ctx.send(
        "Error: No arguments supplied. The current available options are: |author|, |quote|.",
        delete_after=5,
    )
    return

  if args[0] == "author":
    await authorEdit(ctx, mycol, *args)
    log.info(f"Author edit: {args[1]}")
  elif args[0] == "quote":
    await quoteEdit(ctx, mycol, *args)
    log.info(f"Quote edit: {args[1]}")
  else:
    await ctx.message.delete()
    await ctx.send("Error: That is not a current valid editing opiton",
                    delete_after=5)
```

#### Helper

For the edit commands, we will need to reach into the database to find the quote jump url we want to edit, so we can update the channel's message. Thus, a simple function to return the quote jump url given the quote number and collection will be useful. *Discord.py* expects only the jump ID and not the full URL, we will only return that part.

```python
#fetches data for the old message to be edited 
def orgMsgFind(mycol,idxNo):
  for entry in mycol.find({"_id":int(idxNo)}):
    return entry['url'].split('/')[-1]
```
#### Author

To edit the author, we retrieve the new author information, update the database and channel, and log it. Gathering the new author information is the same as a new quote. Updating the database is also simple enough. Updating the channel message requires fetching the message using the jump URL, replacing the old author with the new author, and then sending the updated message. Finally, as a curtsey, we will delete the edit message to keep the channel clean.

```python
async def authorEdit(ctx,mycol,*args):
  if len(args) != 3:
    await ctx.message.delete()
    await ctx.send("Error: The arguments are incorrect. The format is: \"e author [Quote Index No.] [New Author Tag]", delete_after=5)
    return
      
  #Gets new Author Information
  newAuthorID = ctx.message.content[ctx.message.content.find('<'):ctx.message.content.find('>')+1]
  newAuthor = ctx.message.mentions[0]
      
  #Updates Database
  result = mycol.update_one({"_id":int(args[1])},{"$set":{"author":str(newAuthor)}})
  if result.acknowledged:
    await ctx.send(f"Updated the author of quote {str(args[1])} to {str(newAuthor)}", delete_after=5)
  else:
    await ctx.send("Error: Failed to update quote.")
      
  #Update Visible Book 
  quoteID = orgMsgFind(mycol,args[1])
  orgMsg = await ctx.channel.fetch_message(quoteID) 
  oldAuthorID = orgMsg.content[orgMsg.content.find('<'):orgMsg.content.find('>')+1]
  newMsg = str(orgMsg.content).replace(oldAuthorID,newAuthorID)
  await orgMsg.edit(content=newMsg)
              
  await ctx.message.delete()
```

#### Quote

Updating the old quote is very similar to updating the author. The databbase update and jump url fetch is the same. To update the channel message, we will take advantage of the fact that the quote is always between two `"` characters. Thus, we simply replace the content between the first and last `"` characters with the new quote.

```python
async def quoteEdit(ctx,mycol,*args):
  if len(args) != 3:
    await ctx.message.delete()
    await ctx.send("Error: The arguments are incorrect. The format is: \"e author [Quote Index No.] \"[New Quote]\"", delete_after=5)
    return    
  
  newQuote = str(args[2])

  result = mycol.update_one({"_id":int(args[1])},{"$set":{"quote":str(newQuote)}})
  if result.acknowledged:
    await ctx.send(f"Updated the quote of quote {str(args[1])} to {str(newQuote)}", delete_after=5)
  else:
    await ctx.send("Error: Failed to update quote.")
  
  quoteID = orgMsgFind(mycol,args[1])
  orgMsg = await ctx.channel.fetch_message(quoteID) 
  quotePOS = [pos for pos, char in enumerate(orgMsg.content) if char == '"']
  oldQuote = orgMsg.content[quotePOS[0]+1:quotePOS[1]]
  newMsg = str(orgMsg.content).replace(oldQuote,newQuote)
  await orgMsg.edit(content=newMsg)   
  
  await ctx.message.delete()
```

### Configuration

There is little configuration for this simple bot. We will define two configurations that can be changed: the prefix, and the channel ID. It should be noted that because these commands use a prefix, they are not bound to a specific channel and can be called anywhere in the server. In fact, they should be called somewhere other than the quotes channel to ensure everything is clean and tidy.

#### Prefix

The prefix can be set to anything. So the command format we will define here is `<prefix>p <new prefix>`. This will change the prefix for the bot to the new prefix. Of course, let's also do some bounds checking here to ensure that the command in given correctly. If the command is sent in the quotes channel, we'll be kind and remove the command message to help with tidyness. Finally, let's save this change to the settings file so that it persists across bot restarts.

```python
@bot.command(name="p", help="Set the prefix of quote")
async def prefixSetting(ctx, *args):
  if len(args) == 0:
    await ctx.message.delete()
    await ctx.send("Error: No arguments supplied.")
    return
  elif len(args) != 1:
    await ctx.message.delete()
    await ctx.send("Error: Please input only one prefix")
    return

  if args[0] == "":
    await ctx.message.delete()
    await ctx.send("Error: Please input a valid prefix")
    return

  # Keep the quote channel clean
  if str(ctx.message.channel.id) == settings["ChannelID"]:
    await ctx.message.delete()

  bot.command_prefix = args[0]
  await ctx.send(f"Updated prefix to {args[0]}!", delete_after=60)
  log.info(f"Updated prefix to {args[0]}!")

  with open("settings.json", "r+") as settingsFile:
    settingsData = json.load(settingsFile)
    settingsData["prefix"] = str(args[0])
    settingsFile.seek(0)
    json.dump(settingsData, settingsFile, indent=4)
    settingsFile.truncate()
```

#### Channel

The channel ID is a little more complex. While the command is still simple, `<prefix>c <channel ID>`, we will need to extract the tagged channel ID to ensure we have the correct reference. However, once the format is identified, we can simply remove any unnecessary characters as all we are looking for is the channel ID itself. We will do the usual bounds checking, setting files update, and the cleanup as necessary.

```python
@bot.command(name="c", help="Change the channel that the quotebot listens in")
async def channelChange(ctx, *args):
  if len(args) != 1:
    await ctx.message.delete()
    await ctx.send(
      "Error: please tag only one channel that will be the quote channel."
    )

  if args[0][0] != ctx.message.channel.mention[0]:
    await ctx.message.delete()
    await ctx.send("Error: Please tag the channel with the # symbol.")
    return

  # Get the channel ID from the arg
  newChannelID = str(args[0][2:-1])
  settings["ChannelID"] = newChannelID

  with open("settings.json", "w") as settingsFile:
    settingsFile.seek(0)
    json.dump(settings, settingsFile, indent=4)
    settingsFile.truncate()

  # Keep the quote channel clean
  if str(ctx.message.channel.id) == newChannelID:
    await ctx.message.delete()

  await ctx.send(f"Updated the listening channel to {args[0]}!",
                  delete_after=60)
  log.info(f"Updated the listening channel to {args[0]}!")
```

## Conclusion

And that's it! A simple record keeper bot for you and your friends! While I've ventured less and less onto Discord itself, I still find myself using this bot to capture IRL moments in a swift fashion. It allows me to give a Spotify-wrapped-esque gift to everyone as my obligatory Christmas White Elephant entry. I hope you found some snippet of this project useful as a takeaway for your time spent reading my ramblings. If nothing else, realize this: 90% of software development industry is simply making a front-end for data, from entry to representation and manipulation. So go, find the data that you call home, and make it pretty.