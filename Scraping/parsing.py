import random
from time import sleep
import requests
from bs4 import BeautifulSoup
import json
import csv

headers = {
    'Accept': '*/*',
    'User-Agent': '***'
    }
# url = 'https://health-diet.ru/table_calorie/'
#
# req = requests.get(url, headers=headers)
# src = req.text
# # print(src)
#
# with open('index3.html', 'w', encoding='utf-8') as file:
#     file.write(src)
#
# with open('index3.html', encoding='utf-8') as file:
#     src = file.read()
#
# soup = BeautifulSoup(src, 'lxml')
# find_all = soup.find_all(class_='mzr-tc-group-item-href')
#
# all_categories = {}
# for item in find_all:
#     item_text = item.text
#     item_href = 'https://health-diet.ru' + item.get('href')
#     all_categories[item_text] = item_href
#
# with open('all_categories.json', 'w', encoding='utf-8') as file:
#     json.dump(all_categories, file, indent=4, ensure_ascii=False)


with open('all_categories.json', encoding='utf-8') as file:
    all_categ = json.load(file)

iteration_count = int(len(all_categ)) - 1
count = 0
print(f'Всего итераций: {iteration_count}')

for category_name, category_href in all_categ.items():
    rep = [',', '-', ' ']
    for i in rep:
        if i in category_name:
            category_name = category_name.replace(i, '_')

    req = requests.get(url=category_href, headers=headers)
    src = req.text

    with open(f'data/{count}_{category_name}.html', 'w', encoding='utf-8') as file:
        file.write(src)

    with open(f'data/{count}_{category_name}.html', encoding='utf-8') as file:
        src = file.read()
    soup = BeautifulSoup(src, 'lxml')

    # проверка страницы на наличие продуктов
    alert_block = soup.find(class_='uk-alert-danger')
    if alert_block is not None:
        continue

    # собираем заголовки таблицы
    table_header = soup.find(class_='mzr-tc-group-table').find('tr').find_all('th')
    product = table_header[0].text
    calories = table_header[1].text
    proteins = table_header[2].text
    fats = table_header[3].text
    carbohydrates = table_header[4].text

    with open(f'data/{count}_{category_name}.csv', 'w', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(
            (
                product,
                calories,
                proteins,
                fats,
                carbohydrates
            )
        )
    # собираем данные продуктов
    products = soup.find(class_='mzr-tc-group-table').find('tbody').find_all('tr')

    product_info = []
    for item in products:
        products_tds = item.find_all('td')
        title = products_tds[0].find('a').text
        calories = products_tds[1].text
        proteins = products_tds[2].text
        fats = products_tds[3].text
        carbohydrates = products_tds[4].text

        product_info.append(
            {
                'Title': title,
                'Calories': calories,
                'Proteins': proteins,
                'Fats': fats,
                'Carbohydrates': carbohydrates
            }
        )

        with open(f'data/{count}_{category_name}.csv', 'a', encoding='utf-8') as file:
            writer = csv.writer(file)
            writer.writerow(
                (
                    title,
                    calories,
                    proteins,
                    fats,
                    carbohydrates
                )
            )

    with open(f'data/{count}_{category_name}.json', 'a', encoding='utf-8') as file:
        json.dump(product_info, file, indent=4, ensure_ascii=False)

    count += 1
    print(f'# Итерация {count}. {category_name} записан...')
    iteration_count = iteration_count - 1
    if iteration_count == 0:
        print('Работа завершена')
        break
    print(f'Осталось итераций: {iteration_count}')
    sleep(random.randrange(2,4))

