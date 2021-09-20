import subprocess
from functools import wraps
from bot import LOGGER, dispatcher
from bot import OWNER_ID
from bot import AUTHORIZED_CHATS
from bot.helper.telegram_helper.message_utils import sendMessage, editMessage
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
def reply(update: Update, context: CallbackContext):
    return sendMessage('PRE PROCESSING', context.bot, update)

@run_async
def dump(update: Update, context: CallbackContext):
    message = update.effective_message
    cmd = message.text.split(' ', 1)
    rpl = reply(update, context)
    msg_id=rpl.message_id
    ch_id=rpl.chat_id
    if len(cmd) == 1:
        message.reply_text('Please Provide a Direct Link to an Android Firmware')
        return
    cmd = cmd[1]
    process = subprocess.Popen(
        "bash dump.sh " + cmd + " " + msg_id + " " + ch_id, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    stdout, stderr = process.communicate()
    reply = ''
    stderr = stderr.decode()
    stdout = stdout.decode()
    if stdout:
        reply += f"*Dumping Your Given Firmware, Please wait, Dump will be availaible on \n\n@boxdumps*\n\n`{stdout}`\n"
        LOGGER.info(f"Shell - bash dump.sh {cmd} - {stdout}")
    if stderr:
        reply += f"*Stderr*\n`{stderr}`\n"
        LOGGER.error(f"Shell - bash dump.sh {cmd} - {stderr}")
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


DUMP_HANDLER = CommandHandler(['dmp', 'dump'], dump)
dispatcher.add_handler(DUMP_HANDLER)
