import subprocess
from functools import wraps
from bot import LOGGER, dispatcher
from bot import OWNER_ID
from bot import AUTHORIZED_CHATS
from telegram import ParseMode, Update
from telegram.ext import CallbackContext, CommandHandler
from telegram.ext.dispatcher import run_async
AUTHORIZED_CHATS.add(OWNER_ID)

def dev_plus(func):

    @wraps(func)
    def is_dev_plus_func(update: Update, context: CallbackContext, *args,
                         **kwargs):
        bot = context.bot
        user = update.effective_user

        for i in AUTHORIZED_CHATS:
            if(i == user.id) :
                return func(update, context, *args, **kwargs)
        else:
            update.effective_message.reply_text(
            "This is a developer restricted command."
            " Ping the owner of the bot if you need to use this feature!")

    return is_dev_plus_func

@dev_plus
@run_async
def pdump(update: Update, context: CallbackContext):
    message = update.effective_message
    cmd = message.text.split(' ', 1)
    if len(cmd) == 1:
        message.reply_text('Please Provide a Direct Link to an Android Firmware to be Dumped On Private Github Repo')
        return
    cmd = cmd[1]
    process = subprocess.Popen(
        "bash pdump.sh " + cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    stdout, stderr = process.communicate()
    reply = ''
    stderr = stderr.decode()
    stdout = stdout.decode()
    if stdout:
        reply += f"*Dumping Your Given Firmware, Please wait, Dump will be availaible on \n\n@boxdumps\n\nSince its a private dump, You may not have access to the dump, Ping the bot owner if you need access*\n\n`{stdout}`\n"
        LOGGER.info(f"Shell - bash pdump.sh {cmd} - {stdout}")
    if stderr:
        reply += f"*Stderr*\n`{stderr}`\n"
        LOGGER.error(f"Shell - bash pdump.sh {cmd} - {stderr}")
    if len(reply) > 3000:
        with open('shell_output.txt', 'w') as file:
            file.write(reply)
        with open('shell_output.txt', 'rb') as doc:
            context.bot.send_document(
                document=doc,
                filename=doc.name,
                reply_to_message_id=message.message_id,
                chat_id=message.chat_id)
    else:
        message.reply_text(reply, parse_mode=ParseMode.MARKDOWN)


PDUMP_HANDLER = CommandHandler(['pdmp', 'pdump'], pdump)
dispatcher.add_handler(PDUMP_HANDLER)
