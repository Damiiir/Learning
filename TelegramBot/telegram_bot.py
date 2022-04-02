import requests
import datetime
from config import open_weather_token, bot_token
from aiogram import Bot, types
from aiogram.dispatcher import Dispatcher
from aiogram.utils import executor

bot = Bot(token = bot_token)
dp = Dispatcher(bot)

@dp.message_handler(commands =["start"])
async def start_command(message: types.Message):
    await message.reply("Привет! Введи название города и я пришлю сводку погоды")


@dp.message_handler()
async def get_weather(message: types.Message):
    code_to_smile = {
        'Clear': "Ясно \U00002600",
        'Clouds': "Облачно \U00002601",
        'Rain': "Дождь \U00002614",
        'Drizzle': "Дождь \U00002614",
        'Thunderstorm': "Гроза \U000026A1",
        'Snow': "Cнег \U0001F328",
        'Mist': "Туман \U0001F32B"
    }
    try:
        r = requests.get(f'http://api.openweathermap.org/data/2.5/weather?q={message.text}&appid={open_weather_token}&units=metric&lang=ru')
        data = r.json()


        city = data['name']
        temperature = data['main']['temp']
        description = data['weather'][0]['main']
        if description in code_to_smile:
            desc = code_to_smile[description]
        else:
            desc = 'Посмотри в окно'
        feels_like = data['main']['feels_like']
        humidity = data['main']['humidity']
        pressure = data['main']['pressure']
        wind = data['wind']['speed']
        sunrise = datetime.datetime.fromtimestamp(data['sys']['sunrise'])
        sunset = datetime.datetime.fromtimestamp(data['sys']['sunset'])

        await message.reply(f'Дата и время: {datetime.datetime.now().strftime("%d.%m.%Y %H:%M")}\n'
              f'Погода в городе: {city}\nОписание: {desc}\nТемпература: {temperature}°C\nОщущается как: {feels_like}°C\n'
              f'Влажность: {humidity} %\nДавление: {pressure} мм.рт.ст.\nВетер: {wind} м/с\n'
              f'Рассвет: {sunrise}\nЗакат: {sunset}'
             )
    except:
        await message.reply('U\00002620 Проверьте название города U\00002620')

if __name__ == "__main__":
    executor.start_polling(dp)