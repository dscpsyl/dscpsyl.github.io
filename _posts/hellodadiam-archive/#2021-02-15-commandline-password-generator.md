Now, more than ever, passwords and 2FA are important to keep your online presence safe. Yet password cracking and account hacking is still rampant. Assuming the organization you have an account with is competent, how do you make sure you protect your account? Well, it’s back to basics. Having a strong password is the foundation to a secure and unbreakable account. But that brings up the problem of remembering all these passwords and trying to create them all. The former can be solved with password managers, both paid and free are great, but the latter is a bit harder to tackle. Some managers do have a random string generator, but what if you don’t want a manager.

Never use the same password for two different accounts!
{.note title="Note"}

There are many different methods that people have used to tackle this problem. However, a popular, and more important secure, method is Diceware Passphrase.

## History

[Diceware](https://theworld.com/~reinhold/diceware.html) is a passphrase generator that uses 5 dice and a list of words as its foundation. Each time you roll, you use the words associate with the 5 digit number. Since and repeat as many times as you want and you have yourself a secure, random, and tough-to-crack passphrase that is easier to remember than a random string.

However, who even has time to go through this process with every new account. That’s what computers are for. So today we will be making a simple bash script that can use this method. And, if you do want a random string, we will be adding that on top of the base usage.

## Word List

The two worse list, named Diceware and Beale, can be found on the Diceware website or [here](https://theworld.com/%7Ereinhold/diceware.wordlist.asc) and [here](https://theworld.com/%7Ereinhold/beale.wordlist.asc) respectively. Copy the page and paste it into a text file and we’re good to go.

This tutorial assumes you know how to program in bash already.
{.note title="Note"}

## Help Menu

How would you know what to do if there was no help menu? SO let’s get that done first. We will have three options: the help menu itself, passphrase, and password. The help menu is…you know…the help menu. The passphrase is the usage of Diceware and printing out the words. The password option adds an extra layer where the passphrase is put through an md5 has to generate a random string for usage.

~~~bash
Help Menu
help() {
echo "-h | --help          Brings up this menu"
echo "-s | --rand {number} Uses diceware and md5 to return random string, set number of words"
echo "-d | --dice {number} Uses diceware, set nummber of words"
}
~~~

## Diceware

Let’s create a function and define where our two files are. The ${HOME} allows us to not have to specify a path for every user who uses this. you can also use a relative path if you want. We will also create a counter variable and a variable to choose the file that we will use.

~~~bash
diceware() {
wordFile="/${HOME}/Path/to/diceware.txt"
altFile="/${HOME}/Path/to/beale.txt"
i=0
listNum=0
~~~

We will now create a while;do loop with the counter being less than the number inputed by the user.

~~~bash
Main Loop
while [[ i -lt "$wordNum" ]]; do
(( i++ ))
done
~~~
Next, lets initialize a variable called “number” and another counter for the number of dice rolled. Then, because we can’t roll 5 dice at the same time, we’ll roll it 5 times and append the new number to the end of the last in the “number” variable.

~~~bash
number=
x=0
while [[ x -lt "5" ]]; do 
	number+=$(( ( RANDOM % 6 )  + 1 ))
	(( x++ ))
done
~~~

Now, to make thing extra secure, we’ll randomize which list we use.

~~~bash
listNum=$(( ( RANDOM % 2 )  + 1 ))
if [[ $listNum == "1" ]]; then
	theFile=$wordFile
else 
	theFile=$altFile
fi
~~~

Finally we will use the global “word_List” variable, which will be created in the main menu, and attach the selected word to the end of whatever string is in there. To do this, let’s use the grep function and awk only the word part of the output.

~~~bash
word_List+=$(grep $number $theFile | awk '{print $2}' ) 
~~~

And the Diceware function is done!

## Random String

We will just be adding on top of the original Diceware function with a md5 command. Then we’ll pipe it into an awk command so it only prints out the string and nothing else.

~~~bash
string_input() {
	md5 -s $word_List | awk '{print $4}'
}
~~~

## Main Menu

Let’s finally put everything together in the main menu. We will create a main while;do loop that will check if the first argument if empty. If not, we will use a case statement to list out the options available.

~~~bash
while [[ $1 != "" ]]; do
	case $1 in 
	esac 
done  
~~~

In the case statement, let’s list out the 4 options: -h for help, -d for just passphrase, -s for the password hash, and * for any other invalid options. Under -h, we will just call our help function and exit. Under * we will echo a please try again message, display the help message, and exit.

~~~bash
-h | --help ) 
	help
	exit
	;;

* ) echo "Sorry your input: $1, is not a valid option."
	help 
	exit 
~~~

For -d, we will first set the first argument to be the “wordnumber” variable by shifting the pointer to the next argument so that becomes the first. We will then create an empty “word_List” string so it is global. Finally, we’ll call our Diceware function, echo “word_List”, and exit. For -s, it is the same thing but we take out the echo and activate the string function instead, which will automatically output the hash.

~~~bash
-s | --word ) shift
	wordNum=$1 
	word_List=""
	diceware
	string_input 
	exit
	;;
-d | --dice) shift
	wordNum=$1
	word_List=""
	diceware
	echo $word_List
	exit
	;;
~~~

## Conclusion

And that is it! You have your personal password generator. You can modify this with different word lists or use sha256 instead of md5 if you would like. You can also add an alias in your bashc file to have a shortcut in your Commandline so you don’t have to reference the file every time. This can also easily be ported to window’s batch as well with the same concept applied. Happy account making!