import requests
import datetime
from pprint import pprint
from config import open_weather_token
import telebot

def get_weather(city, open_weather_token):

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
        r = requests.get(f'http://api.openweathermap.org/data/2.5/weather?q={city}&appid={open_weather_token}&units=metric&lang=ru')
        data = r.json()
        pprint(data)

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

        print(f'Дата и время: {datetime.datetime.now().strftime("%d.%m.%Y %H:%M")}\n'
              f'Погода в городе: {city}\nОписание: {desc}\nТемпература: {temperature}°C\nОщущается как: {feels_like}°C\n'
              f'Влажность: {humidity} %\nДавление: {pressure} мм.рт.ст.\nВетер: {wind} м/с\n'
              f'Рассвет: {sunrise}\nЗакат: {sunset}'
             )
    except Exception as ex:
        print(ex)
        print('Проверьте название города')

def main():
    city = input('Введите ваш город: ')
    get_weather(city, open_weather_token)



# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    main()

# See PyCharm help at https://www.jetbrains.com/help/pycharm/
