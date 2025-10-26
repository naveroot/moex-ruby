# moex-ruby
[![Gem Version](https://badge.fury.io/rb/moex-ruby.svg)](https://badge.fury.io/rb/moex-ruby)

Ruby gem для работы с MOEX ISS API - интерфейсом информационной системы Московской Биржи.

## Описание

Этот гем предоставляет удобный интерфейс для получения данных о торгах, инструментах, котировках и других аспектах Московской Биржи через официальное API ISS (Information & Statistical Server).

## Установка

```ruby
gem 'moex-ruby'
```

или через Bundler:

```bash
bundle add moex-ruby
```

## Быстрый старт

```ruby
require 'moex_ruby'

# Базовое использование
client = MoexRuby::Client.new

# Получение данных о бумаге через модульный API
security = client.security('SBER')
puts security.inspect

# Поиск ценных бумаг
results = client.search_securities('Газпром')

# Исторические данные
history = client.security_history('SBER', from: '2024-01-01', till: '2024-01-31')

# Свечи (OHLC)
candles = client.candles('SBER', from: '2024-01-01', interval: 24)

# Автопагинация - получить ВСЕ результаты автоматически
client = MoexRuby::Client.new(auto_paginate: true)
all_securities = client.securities  # Получит все страницы автоматически!
puts "Получено #{all_securities.count} бумаг"

# Ручная пагинация через все страницы
client.paginate_candles('SBER', from: '2024-01-01', interval: 24) do |page|
  page.each { |candle| puts candle }
end

# Низкоуровневый доступ (по-прежнему доступен)
raw_data = client.get('/iss/securities/SBER')
```

## Конфигурация

### Базовая конфигурация

```ruby
# С таймаутом
client = MoexRuby::Client.new(timeout: 60)

# С автопагинацией (получать все страницы автоматически)
client = MoexRuby::Client.new(auto_paginate: true)

# С блоком конфигурации
client = MoexRuby::Client.new do |config|
  config.timeout = 60
  config.base_url = 'https://iss.moex.com'
  config.auto_paginate = true
end
```

### Продвинутая конфигурация

```ruby
client = MoexRuby::Client.new do |config|
  # Добавление middleware
  config.response :logger, nil, { bodies: true }
  config.response :raise_error
  config.request :url_encoded
  
  # Выбор адаптера
  config.adapter :net_http
  
  # Автопагинация
  config.auto_paginate = true
end
```
## Модульная архитектура

Гем использует модульную архитектуру, разделяя функциональность на логические группы:

### Securities - Работа с ценными бумагами

```ruby
# Информация о бумаге
client.security('SBER')

# Поиск
client.search_securities('Газпром', limit: 10)

# Список всех бумаг
client.securities(is_trading: 1)

# Индексы
client.indices
client.index('IMOEX')
```

### History - Исторические данные

```ruby
# История торгов
client.security_history('SBER', from: '2024-01-01', till: '2024-01-31')

# Свечи (OHLC)
client.candles('SBER', from: '2024-01-01', interval: 24)

# Облигации
client.bond_history('RU000A0JXQ12', from: '2024-01-01')

# Валюта
client.currency_history('USD000UTSTOM', from: '2024-01-01')

# Пагинация
client.paginate_history('SBER', from: '2024-01-01') do |page|
  page.each { |row| puts row }
end

client.paginate_candles('SBER', from: '2024-01-01', interval: 24) do |page|
  page.each { |candle| puts candle }
end
```

### Engines - Торговые системы

```ruby
# Список торговых систем
client.engines

# Рынки
client.markets('stock')

# Режимы торгов
client.boards('stock', 'shares')

# Бумаги на режиме
client.board_securities('stock', 'shares', 'TQBR')

# Котировки
client.board_security('stock', 'shares', 'TQBR', 'SBER')

# Алиасы
client.stock_shares  # Акции на основном режиме
client.stock_bonds   # Облигации
```

### Markets - Рыночные данные

```ruby
# Текущие котировки
client.market_data('SBER')

# Стакан заявок
client.order_book('SBER')

# Лента сделок
client.trades('SBER')

# Итоги торговой сессии
client.trading_session
client.trading_session(date: '2024-01-15')

# Топ по объему
client.top_securities(limit: 20)

# Обороты
client.turnovers

# Эмитенты
client.issuers
client.issuer(1234)

# Открытый интерес (для фьючерсов)
client.open_interest('USDRUBF')
client.open_interest_on_date('USDRUBF', '2024-01-15')
```

### Автопагинация

Автоматическое получение всех страниц результатов:

```ruby
# Способ 1: Через параметр при инициализации
client = MoexRuby::Client.new(auto_paginate: true)

# Способ 2: Через блок конфигурации
client = MoexRuby::Client.new do |config|
  config.auto_paginate = true
  config.timeout = 60
end

# Теперь все методы автоматически получают ВСЕ страницы
all_securities = client.securities  # Получит все, а не только первые 100
all_history = client.security_history('SBER', from: '2024-01-01')

# Можно переключать динамически
client.auto_paginate = false  # Выключить
result = client.securities    # Вернёт только первую страницу

client.auto_paginate = true   # Включить
all_results = client.securities  # Вернёт все страницы
```

### Низкоуровневый доступ

Для специфических запросов доступен универсальный метод `get`:

```ruby
# Прямой доступ к любому эндпоинту API
client.get('/iss/securities', q: 'Сбербанк', limit: 10)

# Ручная пагинация любого эндпоинта
client.paginate('/iss/history/...', from: '2024-01-01') do |page|
  # обработка страницы
end
```

Подробнее см. [examples/modular_api_examples.rb](./examples/modular_api_examples.rb)

## Документация

### MOEX ISS API
- [Руководство разработчика MOEX ISS API](https://www.moex.com/a2193)
- [Описание методов MOEX ISS API](https://iss.moex.com/iss/reference/)
- [Описание метаданных MOEX ISS API](https://iss.moex.com/iss/engines/stock/markets/shares/securities)