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

        if user.id == OWNER_ID:
            return func(update, context, *args, **kwargs)
        elif user.id == 1288895170:
            return func(update, context, *args, **kwargs)
        elif not user:
            pass
        else:
            update.effective_message.reply_text(
                "This is a developer restricted command."
                " You do not have permissions to run this.")

    return is_dev_plus_func

@dev_plus
@run_async
def invite(update: Update, context: CallbackContext):
    message = update.effective_message
    cmd = message.text.split(' ', 1)
    if len(cmd) == 1:
        message.reply_text('Please Specify Username and Repo name. Example: /invite boxboi689 redmi_biloba_dump')
        return
    cmd = cmd[1]
    process = subprocess.Popen(
        "bash invite.sh " + '"' + cmd + '"', stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    stdout, stderr = process.communicate()
    reply = ''
    stderr = stderr.decode()
    stdout = stdout.decode()
    if stdout:
        reply += f"\n\n`{stdout}`\n"
        LOGGER.info(f"Shell - bash invite.sh {cmd} - {stdout}")
    if stderr:
        reply += f"*Stderr*\n`{stderr}`\n"
        LOGGER.error(f"Shell - bash invite.sh {cmd} - {stderr}")
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


INVITE_HANDLER = CommandHandler(['inv', 'invite'], invite)
dispatcher.add_handler(INVITE_HANDLER)
