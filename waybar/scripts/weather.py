#!/usr/bin/env python3
import json
import requests
from datetime import datetime

weather = requests.get("https://wttr.in/?format=j1&u").json()  # Celsius

# Nord palette
NORD = {
    'snow': '#88C0D0',
    'cloud': '#81A1C1',
    'clear': '#EBCB8B',
    'rain': '#88C0D0',
    'storm': '#BF616A',
    'fog': '#D8DEE9',
}

def colored(icon, color, size=12):
    return f'<span foreground="{color}" size="{1000*size}">{icon}</span>'

WEATHER_CODES = {
    '113': colored('☀️', NORD['clear']),
    '116': colored('⛅️', NORD['cloud']),
    '119': colored('☁️', NORD['cloud']),
    '122': colored('☁️', NORD['cloud']),
    '143': colored('🌫', NORD['fog']),
    '176': colored('🌦', NORD['rain']),
    '179': colored('🌧', NORD['rain']),
    '182': colored('🌧', NORD['rain']),
    '185': colored('🌧', NORD['rain']),
    '200': colored('⛈', NORD['storm']),
    '227': colored('🌨', NORD['snow']),
    '230': colored('❄️', NORD['snow']),
    '248': colored('🌫', NORD['fog']),
    '260': colored('🌫', NORD['fog']),
    '263': colored('🌦', NORD['rain']),
    '266': colored('🌦', NORD['rain']),
    '281': colored('🌧', NORD['rain']),
    '284': colored('🌧', NORD['rain']),
    '293': colored('🌦', NORD['rain']),
    '296': colored('🌦', NORD['rain']),
    '299': colored('🌧', NORD['rain']),
    '302': colored('🌧', NORD['rain']),
    '305': colored('🌧', NORD['rain']),
    '308': colored('🌧', NORD['rain']),
    '311': colored('🌧', NORD['rain']),
    '314': colored('🌧', NORD['rain']),
    '317': colored('🌧', NORD['rain']),
    '320': colored('🌨', NORD['snow']),
    '323': colored('🌨', NORD['snow']),
    '326': colored('🌨', NORD['snow']),
    '329': colored('❄️', NORD['snow']),
    '332': colored('❄️', NORD['snow']),
    '335': colored('❄️', NORD['snow']),
    '338': colored('❄️', NORD['snow']),
    '350': colored('🌧', NORD['rain']),
    '353': colored('🌦', NORD['rain']),
    '356': colored('🌧', NORD['rain']),
    '359': colored('🌧', NORD['rain']),
    '362': colored('🌧', NORD['rain']),
    '365': colored('🌧', NORD['rain']),
    '368': colored('🌨', NORD['snow']),
    '371': colored('❄️', NORD['snow']),
    '374': colored('🌧', NORD['rain']),
    '377': colored('🌧', NORD['rain']),
    '386': colored('⛈', NORD['storm']),
    '389': colored('🌩', NORD['storm']),
    '392': colored('⛈', NORD['storm']),
    '395': colored('❄️', NORD['snow']),
}

def format_time(time):
    return time.replace("00", "").zfill(2)

def format_temp(tempC):
    return (tempC + "°C").ljust(4)

def format_chances(hour):
    chances = {
        "chanceoffog": "Fog",
        "chanceofrain": "Rain",
        "chanceofsnow": "Snow",
        "chanceofsunshine": "Sun",
        "chanceofthunder": "Thunder"
    }
    return ", ".join(f"{label} {hour[key]}%" for key, label in chances.items() if int(hour[key]) > 0)

current = weather['current_condition'][0]
icon = WEATHER_CODES.get(current['weatherCode'], '❓')
feels = current['FeelsLikeC']
wind = current['windspeedKmph']
humidity = current['humidity']
desc = current['weatherDesc'][0]['value']
temp = current['temp_C']

data = {
    "text": f"{icon} {feels}°C",
    "tooltip": f"<b>{desc} ({temp}°C)</b>\nFeels like: {feels}°C\nWind: {wind} Km/h\nHumidity: {humidity}%\n"
}

for i, day in enumerate(weather['weather']):
    if i > 2:
        break
    label = ["Today", "Tomorrow", "Day After"][i]
    maxtemp = day['maxtempC']
    mintemp = day['mintempC']
    sunrise = day['astronomy'][0]['sunrise']
    sunset = day['astronomy'][0]['sunset']
    data['tooltip'] += f"\n<b>{label} ({day['date']})</b>\n⬆️ {maxtemp}° ⬇️ {mintemp}° 🌅 {sunrise} 🌇 {sunset}\n"
    for hour in day['hourly']:
        if i == 0 and int(format_time(hour['time'])) < datetime.now().hour - 2:
            continue
        time_str = format_time(hour['time'])
        h_icon = WEATHER_CODES.get(hour['weatherCode'], '❓')
        h_temp = format_temp(hour['FeelsLikeC'])
        desc = hour['weatherDesc'][0]['value']
        chance = format_chances(hour)
        data['tooltip'] += f"{time_str} {h_icon} {h_temp} {desc}, {chance}\n"

print(json.dumps(data))
