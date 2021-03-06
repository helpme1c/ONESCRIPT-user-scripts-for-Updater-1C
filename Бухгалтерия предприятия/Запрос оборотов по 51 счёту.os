#use "updater1c"

// ****************************************************************************
// Переменные модуля
// ****************************************************************************

Перем errors;		// Признак того, что при выполнении скрипта были ошибки.
Перем updater;		// Обновлятор, через который мы получаем информацию о базе,
					// а также вызываем различные функции обновлятора.
Перем connector;	// Коннектор для подключения к базе.
Перем v8;			// Само подключение к базе через коннектор.

// ****************************************************************************
// Ваш код для выполнения обновлятором
// ****************************************************************************

Процедура Главная()

	// Обязательно прочтите статью про COM-объекты
	// http://helpme1c.ru/ispolzovanie-com-obektov-v-onescript

	Запрос = v8.NewObject("Запрос");
	 
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	ХозрасчетныйОбороты.СуммаОборотДт КАК Приход,
	|	ХозрасчетныйОбороты.СуммаОборотКт КАК Расход
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.Обороты(
	|		ДАТАВРЕМЯ(2013, 01, 01), ДАТАВРЕМЯ(2013, 12, 31),
	|		Год, Счет.Код = ""51"", , , , 
	|	) КАК ХозрасчетныйОбороты";
	 
	Результат = Запрос.Выполнить();
	 
	Выборка = Результат.Выбрать();
	 
	ПутьКФайлу = "C:\Аудит.txt";
	 
	Файл = Новый Файл(ПутьКФайлу);
	Если НЕ Файл.Существует() Тогда
		Документ = Новый ТекстовыйДокумент;
		Документ.Записать(ПутьКФайлу, КодировкаТекста.ANSI);
	КонецЕсли;
	 
	Если Выборка.Следующий() Тогда
	 
		Документ = Новый ТекстовыйДокумент;
		Документ.Прочитать(ПутьКФайлу, КодировкаТекста.ANSI);	
	 
		Сообщение = "пришло " + Строка(Выборка.Приход) + " рублей";
		Сообщение = Сообщение + ", ушло " + Строка(Выборка.Расход) + " рублей";
	 
		Документ.ДобавитьСтроку("Обороты по 51 счёту в " + updater.BaseName + " за 2013 год: " + Сообщение);
		Документ.Записать(ПутьКФайлу, КодировкаТекста.ANSI);
	 
	КонецЕсли;

КонецПроцедуры

// ****************************************************************************
// Служебные процедуры
// ****************************************************************************

Процедура ПриНачалеРаботы()

	errors = Ложь;

	updater = Новый Updater1C;

	// Если в скрипте не планируется использовать
	// подключение к базе - просто закомментируйте
	// две нижние строки.
	connector = Новый COMОбъект("V" + updater.PlatformRelease + ".COMConnector");
	v8 = updater.BaseConnect(connector);
	
КонецПроцедуры

Процедура ПриОкончанииРаботы()

	Если v8 <> Неопределено Тогда
		Попытка
			ОсвободитьОбъект(v8);
			v8 = Неопределено;
		Исключение
		КонецПопытки;
	КонецЕсли;
	
	Если connector <> Неопределено Тогда
		Попытка
			ОсвободитьОбъект(connector);
			connector = Неопределено;
		Исключение
		КонецПопытки;
	КонецЕсли;
	
	Если updater <> Неопределено Тогда
		Попытка
			ОсвободитьОбъект(updater);
			updater = Неопределено;
		Исключение
		КонецПопытки;
	КонецЕсли;
	
	// Ожидание в конце выполнения программы
	// магическим образом помогает избежать
	// проблем с освобождением ресурсов, если
	// мы использовали внешнее подключение к
	// базе. Могут быть случаи, когда недостаточно
	// 1 секунды.
	Приостановить(1000);

	Если errors Тогда
		ЗавершитьРаботу(1);
	КонецЕсли;

КонецПроцедуры

// ****************************************************************************
// Инициализация и запуск скрипта
// ****************************************************************************

ПриНачалеРаботы();

Попытка	
	Главная();	
Исключение
	errors = Истина;
	Сообщить("<span class='red'><b>" + ОписаниеОшибки() + "</b></span>");
КонецПопытки;

ПриОкончанииРаботы();