Let me paint a picture for you. It’s 7:00 AM on a Monday morning. Your head kind of hurts from partying all night. Oh no, you have to check your emails. But it’s so tedious to open up your browser and click on the buttons and wait for the pages to load. What do you do? You make your computer do it for you.

We will not be going over how to do this for Windows or Linux in this post as they are much more straight forward than Mac.
{.note title="Note"}

## Prerequisites

- Mac (Duh)
- Automator
- Applescript
- Calendar
- Default Browser

## Let’s Get Coding

Because MacOS has Automator as it’s dedicated automation program, we will be using that. While it is possible to connect it with Python or external scripts for running, I find that containing everything within Automator gives the best experience and prevents many bugs and crashes.

## Quick Background

As stated above, Automator is the dedicated application for MacOS to create and automate tasks on your Mac. It has tons of functions and variables beyond the scope of this post. While there is no way to create custom actions, it is very likely you can achieve the exact results with the ones given. If nothing else you can record your actions and Automator will remember it.

AppleScript is similar in purpose to Bash Shell on Linux or Batch Script on windows. However it has a more human readable syntax which can be off-putting to users who are more familiar with more traditional programming languages.

## Actions

Open up Automator and choose Workflow. We will be converting this to a Calendar Alarm later but this will allow us to keep a copy in case we want to edit it in the future.

We will be using two actions: Get Specified URL’s and Run AppleScript respectively. Both of these can be found with a quick search on the left hand side. Just grab them over to the right where your workflow is.

### Get Specified URL’s

This action is straightforward. Insert the url’s of each website you want the workflow to open and in what order. Below is a quick example of a few websites:

~~~
https://google.com
https://en.wikipedia.com
https://mail.google.com/u/0
https://example.com
https://github.com
~~~

### Run Apple Script

Tutorials and guides for AppleScript are everywhere so we will not be going over the basics. We recommend checking out [Apple’s Developer Guide of AppleScript](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/introduction/ASLR_intro.html) to get started.

We will create three functions: main (or run), FileExist, and CleanUp. Let’s leave the main function alone and work on FileExist.

This method will use the shell command touch to create a random file with the current date. This is how we will keep track of when the script has been ran. The file type does not matter, only the name. You can even create your own file extension name if you want. This function will simply return a true if the file is there or false if it’s not. We will use System Events to check for the file and the main function will pass it the path of the file which we will store in the variable “theFile”.

~~~applescript
to FileExists(theFile)
	
    tell application "System Events"
		
        if exists file theFile then
            return true 
        else
 
            return false
 
        end if
 
    end tell 
end FileExists
~~~

The function CleanUp is so that our disk doesn’t get overrun with the amount of different files. While we could write the history in one file, AppleScript is designed to command other applications, not preform actions itself. Thus this is the workaround we have ended up using. Our main function will pass it the working path and we will count the amount of file in it. If it is at seven or over, we will remove all the files in the folder in the main function. Thus, make sure to not add anything to the folder and, better yet, side this folder so no one can access it. For this, we will use the Finder application.

~~~applescript
to cleanUp(workingPath)
    tell application "Finder"
		
        set amount to count items in folder workingPath
        return amount
	
    end tell

end cleanUp
~~~

Now let’s finally put everything together in our main function. To start off, we need to pass it the Urls and parameters from our Get Specified URLs action. Then we will set the working path to a hidden folder.

~~~applescript
on run {input, parameters}
	
     set workingPath to "Macintosh HD:Users:testuser:appleScripts:.URL_Calendar_Workflow"
~~~

Next, we will use our CleanUp function to count and see if we need to remove our previous records.

~~~applescript
if cleanUp(workingPath) ≥ 7 then
		
    tell application "Finder"
			
        delete (every item of folder (workingPath))
    end tell
	
end if
~~~

Then let us get the current date and set the name of our new record file to that plus any file extension we want.

~~~applescript
set myDate to date string of (current date)
	
set filePath to workingPath & ":." & myDate & ".day"
	set thisFile to "'" & myDate & ".day'"
set shellFilePath to "/Users/testuser/appleScripts/.URL_Calendar_Workflow"
~~~

Finally we will test to see if the current date file already exists. If it does, we know the script has already ran today and we won’t need to run it again. If not, we will create a record using touch and open the URL’s in our browser. For our case, we will be using Google Chrome. The function requires a return to end so we will just return the input.

~~~applescript
if FileExists(filePath) then
		
    return false
	
else
		
    do shell script shellFilePath & thisFile

    repeat with theURL in input
			
        tell application "Google Chrome" to open location theURL
		
    end repeat
		
    return input
	
end if
~~~

Finally, as if we had to say this but we will fo our one clueless reader, end the main function.

~~~applescript
end run
~~~

## Add to Calendar

The hard part is done so let’s add it to our workflow. Open a new workflow file but this time, select the Calendar Alarm option. Highlight the two actions in your workflow and copy/paste it into the calendar alarm workflow. You should see that everything has been migrated successfully. Click on the play button to test it out. If you’re happy. Save it and it’ll automatically be added to your calendar.

Now, Apple Calendar should open and you should see it under your date with the Automator label. Configure it however you want. For me, I’ve set it to run everyday at 6:00 AM so my sites will be ready when I get to my computer.

## Conclusion

That’s it! You’ve automated a little bit of your workflow and removed a tedious aspect of your life. It should now be more efficient and less stressful, at least during your mornings. If you ever need to add or delete URL’s, you’re gonna have to recreate the calendar alarm and delete the last one. But since you have everything set up, it’s just a matter of copying the archive workflow, changing the URL’s, and saving it again to your calendar. With that, may your 2021 be more fruitful than yesterday!