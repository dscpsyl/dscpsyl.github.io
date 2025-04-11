
As things become virtual, we find ourselves using email and online meeting platforms to communicate with each other. While using BCC to try and send mass emails to your participants is easy, it still takes times and doesn’t look professional at all. You can shell out $50 for plugins that can do it for you, but why waste that money when you can use it for more useful things such as buying parts for your home server (\*wink\* \*wink\*). Here is a simple Python script for you to use in assisting you with mailing lists without using services such as MailChimp. We will be focusing on Google’s API for Gmail using Python.

Please read Google’s Terms of Service about using their API. They have limitations for how many drafts you can create and messages you can send per day (the limit for a regular account is about 100). We are not responsible for any damages caused by misuse of this code. This posts is for educational purposes and written in good faith to inform the public. Click [here](https://developers.google.com/apps-script/guides/services/quotas#note1) and [here](https://support.google.com/a/answer/166852) for more information. Click [here](https://developers.google.com/workspace/gmail/api/guides) for the Google’s API page.
{.note title="DISCLAIMER:"}

## Goals:

We will be setting up a script that will cycle through an excel sheet and send a predefined email with subject line and body. This script will also be able to switch users and emails. We will also be creating this script with the idea that we can use it as a module in the future. Of course, this will not be the most efficient nor does it solve everything. But is makes sending emails much more convenient and hassle free in the long run.

## Prerequisites

- Basic Knowledge of Json Files & APIs
- Google Account
- IDE (Visual Code Studio will be used in this post)
- Good Understanding of the Python Language
- Python3 Installed

## Let’s Start Coding!

Before we begin, click [here](https://console.developers.google.com/) to accept Google’s API terms of service and enable it for your account. After that, setup and download *credentials.json* onto your local machine and into the directory of your script. This file should be secret and never shown or shared with anyone. You should never have to open it or look inside it either.

With all the formalities out of the way, it’s time to finally start writing some code!

## Module Requirements

Google’s API uses .pickle files to store tokens and validations for sessions so we will need the pickle module. We will also need base64 encoding for the API to send the information and mimetypes for creating the messages.

~~~python
import pickle
import base64
import mimetypes
~~~

datetime is a module we will need for recording our sending times. From there, we will specifically import datetime to avoid repetition later down the line. To open and use our excel files, openpyxl is needed, and json will be used to store our sender information. The errors function from the apiclient module will help us understand errors and debug our code. Speaking of logging, let’s import the logging module as well.

~~~python
import datetime as dt
import openpyxl as xl
import json as js
import logging as lg 
from apiclient import errors
from datetime import datetime as dt
~~~

Now for modules specific to emails and Google’s API. We need the build in googleapiclient, InstalledAppFlow in Google’s oauth module module, and Request in the google module. From there, we will need a few MIME specific resources to encode our emails. They should all be self explanatory so we won’t bother explaining them. You can read more about it here.

~~~python
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from email.mime.audio import MIMEAudio
from email.mime.base import MIMEBase
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
~~~

We will need some miscellaneous modules to make our lives easier and not spam Google’s servers. You can search up what each one does if you need more information. And that is all the modules. Let’s get started with the fun stuff.

~~~python
import time
import sys
import os
~~~


## Logging In

First things’ first, we have to login to our account to access anything. Because we are going to create drafts and modify messages, let us define our SCOPES with the .compose ending. Google’s API has different scopes with varying levels of access for developers to ensure their program does not get abused. In our case, we will need the compose access level. **If you ever need to modify the scope, be sure to delete the token.pickle file.**

~~~python
SCOPES = ['https://www.googleapis.com/auth/gmail.compose']
~~~

As we are going to make this a useable module in the future, let’s define a function called login and initialize the creds variable.

~~~python
def login():
  creds = None
~~~

Let’s then try and find the token.pickle file and if we do, open it and load it into the creds variable.
~~~python
if os.path.exists('token.pickle'):
    with open('token.pickle', 'rb') as token:
        creds = pickle.load(token)
~~~

If we cannot find token or it’s not valid, let’s try to refresh it. If refreshing doesn’t work, we will ask for a new token and then dump it into the creds variable.

~~~python
if not creds or not creds.valid:
    if creds and creds.expired and creds.refresh_token:
      creds.refresh(Request())
    else:
        flow = InstalledAppFlow.from_client_secrets_file(
            'credentials.json', SCOPES)
        creds = flow.run_local_server(port=0)
    with open('token.pickle', 'wb') as token:
      pickle.dump(creds, token)
~~~

Lastly, we will create the service variable with the creds variable and return from the function. This service defines what account the API is interacting with and allows us to authenticate and make modify the account with new drafts and to send messages.

~~~python
service = build('gmail', 'v1', credentials=creds)
return service 
~~~

## Create Message

For this we will need to pass a few parameters. We will need the sender, the message, the recipient, and the subject. We will create a MIME object with the message. Then we will fill in the other attributes.

~~~python
def create_message(sender, to, subject, message_text):
  message = MIMEText(message_text)
  message['to'] = to
  message['from'] = sender
  message['subject'] = subject
~~~

Here, it get’s a bit weird. We will need to encode it into base64 as bytes, but then decode it again. What seems to happen is that while the API does not accept base64, the actual Gmail servers need it. So by converting it to base64 and decoding it, it allows it to be passed to the server and encoded again. Of course, this is just speculation and if you know what is actually going on, do let us know! Anyways, after that, we will return it into the raw object.

~~~python
  message = base64.urlsafe_b64encode(message.as_bytes())
  message = message.decode()
  return {'raw': message }
~~~

## Creating a Draft

While you can imminently send this raw message data, it’d be safer to create a draft incase the script goes wrong. That way you still have everything and no one gets half written emails.

As we will be communicating with the API now, we will wrap our code in a try, except statement. We will pass into this function the service, our user ID, and message_body. We will set the message variable to the message object of the message_body variable. Then we will call the API and try to create a draft.

~~~python
def create_draft(service, user_id, message_body):
  try:
    message = {'message': message_body}
    draft = service.users().drafts().create(userId=user_id, body=message).execute()
    return draft["id"]
~~~

If it works, we will return the draft_id. If not, the API will return a http error and we will return nothing. If we are running this as a script and not a module, we will quit with an error.

~~~python
  except errors.HttpError as error:
    if __name__ == "__main__":
      sys.exit(1)
    else:
      return None
~~~

## Sending the Draft

This will work similar to [Creating a Draft](#creating-a-draft). Again, we will be communicating with the API, passing the service, draft ID, and user ID. And We will return True if it succeeds and False if it fails and will quit if running as a script.

~~~python
def send_draft(service, user_Id, draftId):
    try:
        service.users().drafts().send(userId=user_Id, body={ 'id': draftId }).execute()
        return True
    except errors.HttpError as error:
        if __name__ == "__main__":
          sys.exit(1)
        else:
          return False
~~~

And that is everything for the modules we need to create. You can stop here if you’d like and use these for your other coding projects. But for the rest of you, let’s continue to completing the full script of your mailing program.

## Opening Excel File

Here’s where the fun begins. Let’s create a function called main and in here we will call the login() function first to connect to the API.

~~~python
def main(workbook):
    service = login()
~~~

Then let’s try and open the excel file. If it doesn’t work we’ll quit.

~~~python
  try:
    wbname = "/path/to/excel/file"
    wb = xl.load_workbook(filename=wbname)
  except:
    sys.exit(1)
~~~

Once we succeed, we’ll set the active sheet as our working sheet. Here, this is my personal preference, we’ll create a new function to pass everything to. This way, editing the code late on is much easier. You can just keep the rest of the code in the same function in you want to.

~~~python
  ws = wb.active
  process(ws, service, wb, wbname)
~~~

## Using Json File

First and foremost here is an example of a json file that we will be using here.

~~~json
{
    "name": "John Dohn",
    "sender": "foo@example.com",
    "subject": "This is a Reminder!",
}
~~~

Now, this will be the first part of our process function. This function will be the main place to tweak depending on your excel setup and API configuration. Before we begin, let’s set the userId variable to “me” so that the API won’t return an error later. There are times you’ll want to change this variable so we decided to put it here. Right after, let’s define the json file.

~~~python
def process(ws, service, wb, wbname):
  userId = "me" 
  jsFile = "/path/to/json/file"
~~~

Now we will try to open the file. If it doesn’t work, let us quit.

~~~python
  try:
    with open(jsFile):
      jsonData = js.load(jsFile)
  except Exception as e:
    sys.exit(1)
~~~

## Data and Variables

For our excel sheet, we will be using column A as the name of the recipient and column B as the recipient email address. Row one is just labels for us humans to read.

Continuing on in the same function, let’s get starting with filling out the data. The sender need the name and the sender field of the json file. This way, Gmail knows the sending email address and the name to show to the recipient. The email must be inclosed with “<>” signs to indicate that it is the address and not part of the name. The subject is just the subject field.

~~~python
sender =  jsonData["name"] + "<" + jsonData["sender"] + ">"
subject = jsonData["subject"]
~~~

Here, we will also define the max column and rows of our excel sheet.
~~~python
  maxRow = ws.max_row
  maxCol = ws.max_column
~~~

Now we will loop between the rows of the excel sheet. We will ignore row one as it is just labels with no useful data.
~~~python
  for rows in range(maxRow):
    if rows == 0 or rows == 1:
      continue
~~~

We will get the recipient name from column A and their email address from column B.

~~~python
recieptName = ws["A" + str(rows)].value
to = ws["B" + str(rows)].value
~~~

The body of our message will contain some sample text. We will use the receiptName variable to personalize the message. Then we will pass it to the final function that will send our message.

~~~python
body = "Dear" + recieptName + ",\n\nHello! This is your reminder that we have a meeting next week!\n\nSee you there!"
email(to, recieptName, body, service, userId, sender, subject)
~~~

We will get to that in just a bit. Let us add the ability to fill the rows that we’ve sent a message to with green. We will, as always, create another function that we will cover later. Let’s write and save this modified sheet to a new file.

~~~python
greenfill = xl.styles.PatternFill(start_color='00FF00', end_color='000000', fill_type='solid')
recordSentMail(rows, ws, greenfill, maxCol)
row += 1

wb.save(wbname + ".new")
~~~

And that is all the data we need. Let us continue to using the previous functions to create a draft and send our message!

## Sending The Message

Again, I will be creating another function because I like functions. This one will be simple. We will set a few variables to our functions from earlier and call our sending function.

~~~python
def email(to, recieptName, body, service, userId, sender, subject):
  message = create_message(sender, to, subject, body)
  draftId = create_draft(service, userId, message)
  send_draft(service, userId, draftId, to, recieptName)
~~~

## Recording

Remember that recording function that we created earlier? Let’s get back to that now. We will use the previous max column value and change that to its letter equivalent. We will then get the current time and put that into the column right next to the last column in the row. Finally we will set all other columns with a green fill as defined before.

~~~python
def recordSentMail(row, ws, color, maxCol):
  maxColMax = maxCol + 1
  colLttrMax = xl.utils.get_column_letter(maxColMax)
  now = dt.now()
  now_string = now.strftime("%d/%m/%Y-%H:%M:%S")
  for col in range(maxCol+1):
    if col == 0:
      continue
    colLttr = xl.utils.get_column_letter(col)
    ws[colLttr + str(row)].fill = color
  ws[colLttrMax + str(row)].value = now_string
~~~

## Conclusion

ANNNNDDD that’s everything! You should have your very own working script to send emails to all your followers. Again, please check Google’s TOS to make sure you are using their API correctly. Of course, this code isn’t perfect nor is it the most efficient. But it gets the job done and logically easy to follow. Because we have implemented as json file, you have room for expandability. You can make recording optional, set logging to the script, and change where the body is inputed. You can also make it more interactive with the user defining where the excel and json files are. It’s up to you how developed you want this script to be. Here is just the basics to get you started. Don’t spam!