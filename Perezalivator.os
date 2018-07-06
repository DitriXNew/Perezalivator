///////////////////////////////////////////////////////////////////////
// ПРОГРАММА ДЛЯ "ПЕРЕЗАЛИВКИ" БАЗ
// Автор: Онянов Виталий (Tavalik.ru)
// Версия от 15.08.2017
//

#Использовать json
#Использовать gui
#Использовать TLog
#Использовать "lib\\TRun1CMod"
#Использовать TMSSQL
#Использовать TMail 

Перем Логирование, УправлениеЭП;
Перем УправляемыйИнтерфейс, ФормаВыбораНастроек;
Перем ТаблицаБазаИсточник, ТаблицаБазаПриемник, ТаблицаПользователи, ТаблицаРасширений, ТаблицаРасширенийВБазе;
Перем КонтрольАктивныхСеансовПройден, ИндексБазыИсточник, ИндексБазыПриемник;
Перем РежимОтладки, РежимТестирования;

//******************************************************************
Процедура Инициализация()
	
	////////////////////////////////////////
	// Обнулим глобальные перменные
	КонтрольАктивныхСеансовПройден = Ложь;
	ИндексБазыИсточник = 0;
	ИндексБазыПриемник = 0;
	РежимОтладки = Ложь;
	РежимТестирования = Ложь;
	
	
	////////////////////////////////////////
	// Каталог для хранения логов
	ИдентификаторЗадания = "Perezalivator";
	КаталогХраненияЛогов = ".\_Logs\";
	Логирование = Новый ТУправлениеЛогированием(); //TLog
	Логирование.ДатаВремяВКаждойСтроке = Истина;
	Логирование.ВыводитьСообщенияПриЗаписи = Истина;	
	Логирование.СоздатьФайлЛога(ИдентификаторЗадания,КаталогХраненияЛогов);
	
	
	////////////////////////////////////////
	// Настройка электорнной почты
	УправлениеЭП = Новый ТУправлениеЭлектроннойПочтой();
	
	
	////////////////////////////////////////
	// Прочитаем параметры
	
	// Заполняем источники
	ТаблицаБазаИсточник = Новый ТаблицаЗначений;
	ТаблицаБазаИсточник.Колонки.Добавить("Имя");
	ТаблицаБазаИсточник.Колонки.Добавить("ПутьКПлатформе1С");
	ТаблицаБазаИсточник.Колонки.Добавить("ТипБазы");
	ТаблицаБазаИсточник.Колонки.Добавить("ВерсияCOMConnector");
	ТаблицаБазаИсточник.Колонки.Добавить("ИмяБазы");
	ТаблицаБазаИсточник.Колонки.Добавить("АдресКластера");
	ТаблицаБазаИсточник.Колонки.Добавить("ПортКластера");
	ТаблицаБазаИсточник.Колонки.Добавить("ПортАгента");
	ТаблицаБазаИсточник.Колонки.Добавить("ИмяПользователя");
	ТаблицаБазаИсточник.Колонки.Добавить("ПарольПользователя");
	ТаблицаБазаИсточник.Колонки.Добавить("АдресСервераSQL");
	ТаблицаБазаИсточник.Колонки.Добавить("ИмяПользователяSQL");
	ТаблицаБазаИсточник.Колонки.Добавить("ПарольПользователяSQL");
	ТаблицаБазаИсточник.Колонки.Добавить("ИмяБазыДанныхSQL");
	
	// Заполняем приемники
	ТаблицаБазаПриемник = Новый ТаблицаЗначений;
	ТаблицаБазаПриемник.Колонки.Добавить("Имя");
	ТаблицаБазаПриемник.Колонки.Добавить("ПутьКПлатформе1С");
	ТаблицаБазаПриемник.Колонки.Добавить("ТипБазы");
	ТаблицаБазаПриемник.Колонки.Добавить("ВерсияCOMConnector");
	ТаблицаБазаПриемник.Колонки.Добавить("ИмяБазы");
	ТаблицаБазаПриемник.Колонки.Добавить("АдресКластера");
	ТаблицаБазаПриемник.Колонки.Добавить("ПортКластера");
	ТаблицаБазаПриемник.Колонки.Добавить("ПортАгента");
	ТаблицаБазаПриемник.Колонки.Добавить("ИмяПользователяАдминистратораКластера");
	ТаблицаБазаПриемник.Колонки.Добавить("ПарольПользователяАдминистратораКластера");
	ТаблицаБазаПриемник.Колонки.Добавить("ИмяПользователя");
	ТаблицаБазаПриемник.Колонки.Добавить("ПарольПользователя");
	ТаблицаБазаПриемник.Колонки.Добавить("АдресХранилища");
	ТаблицаБазаПриемник.Колонки.Добавить("ИмяПользователяХранилища");
	ТаблицаБазаПриемник.Колонки.Добавить("ПарольПользователяХранилища");	
	ТаблицаБазаПриемник.Колонки.Добавить("АдресСервераSQL");
	ТаблицаБазаПриемник.Колонки.Добавить("ИмяПользователяSQL");
	ТаблицаБазаПриемник.Колонки.Добавить("ПарольПользователяSQL");
	ТаблицаБазаПриемник.Колонки.Добавить("ИмяБазыДанныхSQL");
	
	ТаблицаРасширений = Новый ТаблицаЗначений;
	ТаблицаРасширений.Колонки.Добавить("ИндексБазыПриемник");
	ТаблицаРасширений.Колонки.Добавить("Имя");
	ТаблицаРасширений.Колонки.Добавить("УникальныйИдентификатор");
	ТаблицаРасширений.Колонки.Добавить("Версия");
	ТаблицаРасширений.Колонки.Добавить("ХешСумма");
	ТаблицаРасширений.Колонки.Добавить("АдресХранилища");
	ТаблицаРасширений.Колонки.Добавить("ИмяПользователяХранилища");
	ТаблицаРасширений.Колонки.Добавить("ПарольПользователяХранилища");
	
	// Прочитаем путь к файлу настроек из командной строки
	МассивФайловНастроек = Новый Массив;
	Для Сч = 0 По АргументыКоманднойСтроки.Количество()-1 Цикл
		Аргумент = АргументыКоманднойСтроки.Получить(Сч);
		Если Лев(Аргумент,1) = "-" Тогда
			// Специальные параметры
			Если СокрЛП(Аргумент) = "-debug" Тогда
				РежимОтладки = Истина;
				Сообщить("--------------------------------------------");
				Сообщить("ЗАПУСК В РЕЖИМЕ ОТЛАДКИ");
				Сообщить("--------------------------------------------");
			КонецЕсли;
			Если СокрЛП(Аргумент) = "-test" Тогда
				РежимТестирования = Истина;
				Сообщить("--------------------------------------------");
				Сообщить("ЗАПУСК В РЕЖИМЕ ТЕСТИРОВАНИЯ НАСТРОЕК");
				Сообщить("--------------------------------------------");
			КонецЕсли;
		Иначе
			// Файл с настройками
			МассивФайловНастроек.Добавить(СокрЛП(Аргумент));
		КонецЕсли;
	КонецЦикла;
	
	// Обработаем файлы настроек
	Сч = 0;
	Пока Истина Цикл
		
		ПутьКФайлуНастроек = МассивФайловНастроек.Получить(Сч);
		Файл = Новый Файл(ПутьКФайлуНастроек);
		Если файл.Существует() Тогда
			
			// Получим текст файла
			ЧтениеТекста = Новый ЧтениеТекста(ПутьКФайлуНастроек, КодировкаТекста.UTF8);
			ТекстФайлаНастроек = ЧтениеТекста.Прочитать();
			ЧтениеТекста.Закрыть();
			Сообщить("Прочитан файл настроек: " + Файл.ПолноеИмя);
			
			Попытка
				ЧтениеJSON = Новый ПарсерJSON;
				ПараметрыИзФайла = ЧтениеJSON.ПрочитатьJSON(ТекстФайлаНастроек,,,Истина);
				ПрочитатьПараметрыРекурсивно(ПараметрыИзФайла);
			Исключение
				Сообщить(ОписаниеОшибки());
				ЗавершитьРаботу(1);
			КонецПопытки;
			
			Сч = Сч + 1;			
		Иначе
			Сообщить("Не найден файл настроек по пути: " + ПутьКФайлуНастроек);
			МассивФайловНастроек.Удалить(Сч);
		КонецЕсли;
		
		Если Сч = МассивФайловНастроек.Количество() Тогда
			Прервать;
		КонецЕсли;		
		
	КонецЦикла;
	
	// Если файл не бы передан в параметрах, найдем его в каталоге
	Если МассивФайловНастроек.Количество() = 0 Тогда
		// Попробуем найти файл настроек в текущем каталоге
		ПутьКФайлуНастроек = ОбъединитьПути(ТекущийСценарий().Каталог,"Perezalivator_Params.json");
		Файл = Новый Файл(ПутьКФайлуНастроек);
		Если Не файл.Существует() Тогда
			Если СоздатьШаблонФайлаНастроек(ПутьКФайлуНастроек) Тогда
				МассивФайловНастроек.Добавить(ПутьКФайлуНастроек);
				Сообщить("Создан шаблон файла настроек. Заполните файл и перезапустите программу.");
				ЗавершитьРаботуСПаузой();
			Иначе
				ЗавершитьРаботу(1);
			КонецЕсли;
		КонецЕсли;
		МассивФайловНастроек.Добавить(ПутьКФайлуНастроек);
	КонецЕсли;
	
	Если РежимТестирования Тогда
		ВыполнитьТестНастроек();
		Возврат;
	КонецЕсли;
	
	////////////////////////////////////////
	// Загружаем внешнюю компоненту oscript-gui.dll
	УправляемыйИнтерфейс = Новый УправляемыйИнтерфейс();
	ФормаВыбораНастроек = УправляемыйИнтерфейс.СоздатьФорму();
	ФормаВыбораНастроек.УстановитьДействие(ЭтотОбъект, "ПриОткрытии", "ПриОткрытииФормы");
	ФормаВыбораНастроек.Показать();	
	
КонецПроцедуры

//******************************************************************
Процедура ЗавершитьРаботуСПаузой()
	
	Сообщить("Для продолжения нажмите любую клавишу...");
	Консоль = Новый Консоль();
	ОбщееОжидание = 0;
	Пока Не Консоль.НажатаКлавиша И ОбщееОжидание < 60000 Цикл
		Приостановить(100);
		ОбщееОжидание = ОбщееОжидание + 100;
	КонецЦикла;
	ЗавершитьРаботу(1);
	
КонецПроцедуры

//******************************************************************
Процедура ПрочитатьПараметрыРекурсивно(Параметры, СтруктураЗначений = "")
	
	Для Каждого Параметр Из Параметры Цикл
		
		//Сообщить("- " + ТипЗнч(Параметр.Значение) + ", " + Строка(Параметр.Ключ) + ", " + Строка(Параметр.Значение));
		
		Если ТипЗнч(Параметр.Значение) = Тип("Структура")
			ИЛИ ТипЗнч(Параметр.Значение) = Тип("Соответствие") Тогда
			
			Если Параметр.Ключ = "НастройкиSMTP" Тогда
				СтруктураЗначений = УправлениеЭП.УчетнаяЗаписьЭП;
			ИначеЕсли Параметр.Ключ = "ПолучателиСообщений" Тогда
				СтруктураЗначений = УправлениеЭП.СтруктураСообщения;
			КонецЕсли;
			ПрочитатьПараметрыРекурсивно(Параметр.Значение, СтруктураЗначений);
			
		ИначеЕсли ТипЗнч(Параметр.Значение) = Тип("Массив") Тогда
			
			Для Каждого ЭлементМассива Из Параметр.Значение Цикл
				Если Параметр.Ключ = "Источники" Тогда
					СтруктураЗначений = ТаблицаБазаИсточник.Добавить();
				ИначеЕсли Параметр.Ключ = "Приемники" Тогда
					СтруктураЗначений = ТаблицаБазаПриемник.Добавить();
				ИначеЕсли Параметр.Ключ = "Расширения" Тогда
					СтруктураЗначений = ТаблицаРасширений.Добавить();
					СтруктураЗначений.ИндексБазыПриемник = ТаблицаБазаПриемник.Количество() - 1;
				КонецЕсли;
				ПрочитатьПараметрыРекурсивно(ЭлементМассива, СтруктураЗначений)
			КонецЦикла;
			
		Иначе
			СтруктураЗначений[Параметр.Ключ] = Параметр.Значение;			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

//******************************************************************
Функция СоздатьШаблонФайлаНастроек(ПутьКФайлуНастроек)
	
	Попытка
		ЗаписьТекста = Новый ЗаписьТекста();
		ЗаписьТекста.Открыть(ПутьКФайлуНастроек,КодировкаТекста.UTF8);
		ЗаписьТекста.ЗаписатьСтроку(
		"{
		|	""Источники"":
		|	[
		|		{
		|			""Имя"" : 								""Пример_База_Источник"",
		|			""АдресСервераSQL"" : 					"""",
		|			""ИмяПользователяSQL"" :				"""",
		|			""ПарольПользователяSQL"" :				"""",
		|			""ИмяБазыДанныхSQL"" : 					""""
		|		}
		|	],
		|	""Приемники"": 
		|	[
		|		{
		|			""Имя"" : 								""Пример_База_Применик1"",
		|			""ПутьКПлатформе1С"" : 					""C:\\Program Files (x86)\\1cv8\\8.3.х.хххх\\bin\\1cv8.exe"",
		|			""ТипБазы"" : 							""S"",
		|			""ВерсияCOMConnector"" :				""83"",
		|			""ИмяБазы"" : 							"""",
		|			""АдресКластера"" : 					"""",
		|			""ПортКластера"" : 						""1541"",
		|			""ПортАгента"" :						""1540"",
		|			""ИмяПользователя"" : 					"""",
		|			""ПарольПользователя"" :				"""",
		|			""АдресХранилища"" :					"""",
		|			""ИмяПользователяХранилища"" : 			"""",
		|			""ПарольПользователяХранилища"" : 		"""",	
		|			""АдресСервераSQL"" : 					"""",
		|			""ИмяПользователяSQL"" : 				"""",
		|			""ПарольПользователяSQL"" : 			"""",
		|			""ИмяБазыДанныхSQL"" : 					""""
		|		},
		|		{
		|			""Имя"" : 								""Пример_База_Применик2"",
		|			""ПутьКПлатформе1С"" : 					""C:\\Program Files (x86)\\1cv8\\8.3.х.хххх\\bin\\1cv8.exe"",
		|			""ТипБазы"" : 							""S"",
		|			""ВерсияCOMConnector"" :				""83"",
		|			""ИмяБазы"" : 							"""",
		|			""АдресКластера"" : 					"""",
		|			""ПортКластера"" : 						""1541"",
		|			""ПортАгента"" :						""1540"",
		|			""ИмяПользователя"" : 					"""",
		|			""ПарольПользователя"" :				"""",
		|			""АдресХранилища"" :					"""",
		|			""ИмяПользователяХранилища"" : 			"""",
		|			""ПарольПользователяХранилища"" : 		"""",	
		|			""АдресСервераSQL"" : 					"""",
		|			""ИмяПользователяSQL"" : 				"""",
		|			""ПарольПользователяSQL"" : 			"""",
		|			""ИмяБазыДанныхSQL"" : 					""""
		|		}
		|	],
		|	""ЭлектроннаяПочта"": 
		|	{
		|		""НастройкиSMTP"":
		|		{
		|			""АдресSMTP"" : 						"""",
		|			""ПортSMTP"" : 							465,
		|			""ПользовательSMTP"" : 					"""",
		|			""ПарольSMTP"" : 						"""",
		|			""ИспользоватьSSL"" : 					true
		|		},
		|		""ПолучателиСообщений"":
		|		{
		|			""АдресЭлектроннойПочтыПолучателя"" : 	""myname@domen.ru;""
		|		}
		|	}
		|}");
		ЗаписьТекста.Закрыть();
	Исключение
		Возврат Ложь;
		Сообщить(ОписаниеОшибки());
	КонецПопытки;
	
	Возврат Истина;
	
КонецФункции

//******************************************************************
Процедура ПриОткрытииФормы() Экспорт
	
	ФормаВыбораНастроек.Заголовок = "ПЕРЕЗАЛИВАТОР v1.0";
	ФормаВыбораНастроек.Высота = 480;
	ФормаВыбораНастроек.Ширина = 680;
	
	// ПолеСоСпискомИсточник
	Данные = Новый Соответствие; Сч = 0;
	Для Каждого СтрокаТаблицы Из ТаблицаБазаИсточник Цикл
		Данные.Вставить(СтрокаТаблицы.Имя, Сч); Сч = Сч + 1;
	КонецЦикла;
	ПолеФормы = ФормаВыбораНастроек.Элементы.Добавить("ПолеСоСпискомИсточник", "ПолеФормы", Неопределено);
	ПолеФормы.Заголовок = "База источник:    ";
	ПолеФормы.Вид = ФормаВыбораНастроек.ВидПоляФормы.ПолеСоСписком;
	ПолеФормы.СписокВыбора = Данные;
	ПолеФормы.Значение = 0;
	ПолеФормы.УстановитьДействие(ЭтотОбъект, "ПриИзменении", "ПриИзменииПолеСоСпискомИсточник");
	
	// ПолеСоСпискомПриемник
	Данные = Новый Соответствие; Сч = 0;
	Для Каждого СтрокаТаблицы Из ТаблицаБазаПриемник Цикл
		Данные.Вставить(СтрокаТаблицы.Имя, Сч); Сч = Сч + 1;
	КонецЦикла;
	ПолеФормы = ФормаВыбораНастроек.Элементы.Добавить("ПолеСоСпискомПриемник", "ПолеФормы", Неопределено);
	ПолеФормы.Заголовок = "База назначения:";
	ПолеФормы.Вид = ФормаВыбораНастроек.ВидПоляФормы.ПолеСоСписком;
	ПолеФормы.СписокВыбора = Данные;
	ПолеФормы.Значение = 0;
	ПолеФормы.УстановитьДействие(ЭтотОбъект, "ПриИзменении", "ПриИзменииПолеСоСпискомПриемник");
	
	// Дата
	ПолеФормы = ФормаВыбораНастроек.Элементы.Добавить("Дата", "ПолеФормы", Неопределено);
	ПолеФормы.Заголовок = "Перезаливать на дату:";
	ПолеФормы.Вид = ФормаВыбораНастроек.ВидПоляФормы.ПолеКалендаря;
	ПолеФормы.Значение = ТекущаяДата();
	
	Группа = ФормаВыбораНастроек.Элементы.Добавить("ГруппаКнопкиРасширений", "ГруппаФормы", Неопределено);
	Группа.Вид = УправляемыйИнтерфейс.ВидГруппыФормы.ОбычнаяГруппа;
	Группа.Закрепление = УправляемыйИнтерфейс.СтильЗакрепления.Верх;
	
	Кнопка = ФормаВыбораНастроек.Элементы.Добавить("КнопкаОбновитьСписокРасширений", "КнопкаФормы", Группа);
	Кнопка.Заголовок = "Обновить список расширений";
	Кнопка.УстановитьДействие(ЭтотОбъект, "Нажатие", "ПриНажатииНаКнопкуОбновитьСписокРасширений");
	
	// ПолеРасширений
	ПолеФормы = ФормаВыбораНастроек.Элементы.Добавить("ПолеРасширений", "ТаблицаФормы", Неопределено);
	ПолеФормы.Заголовок = "Списки используемых расширений:";
	ПолеФормы.ПоложениеЗаголовка = УправляемыйИнтерфейс.ПоложениеЗаголовка.Верх;
	ПолеФормы.Закрепление = УправляемыйИнтерфейс.СтильЗакрепления.Верх;
	ПолеФормы.Высота = 220;
	
	// ПолеЛог
	ПолеФормы = ФормаВыбораНастроек.Элементы.Добавить("ПолеЛог", "ПолеФормы", Неопределено);
	ПолеФормы.Вид  = ФормаВыбораНастроек.ВидПоляФормы.ПолеНадписи;
	ПолеФормы.Заголовок = "Лог выполнения обработки:";
	ПолеФормы.ПоложениеЗаголовка = УправляемыйИнтерфейс.ПоложениеЗаголовка.Верх;	
	ПолеФормы.Высота = 220;
	ПолеФормы.Закрепление = УправляемыйИнтерфейс.СтильЗакрепления.Верх;
	
	// ПолеПользователи
	ПолеФормы = ФормаВыбораНастроек.Элементы.Добавить("ПолеПользователи", "ТаблицаФормы", Неопределено);
	ПолеФормы.Заголовок = "ВНИМАНИЕ! Имеются активые соединения с базой приемником:";
	ПолеФормы.ПоложениеЗаголовка = УправляемыйИнтерфейс.ПоложениеЗаголовка.Верх;
	ПолеФормы.Закрепление = УправляемыйИнтерфейс.СтильЗакрепления.Заполнение;
	
	Группа = ФормаВыбораНастроек.Элементы.Добавить("ГруппаКнопки", "ГруппаФормы", Неопределено);
	Группа.Вид = УправляемыйИнтерфейс.ВидГруппыФормы.ОбычнаяГруппа;
	Группа.Закрепление = УправляемыйИнтерфейс.СтильЗакрепления.Низ;
	
	Кнопка = ФормаВыбораНастроек.Элементы.Добавить("КнопкаВыполнить", "КнопкаФормы", Группа);
	Кнопка.Заголовок = "Перезалить базу";
	Кнопка.УстановитьДействие(ЭтотОбъект, "Нажатие", "ПриНажатииНаКнопкуВыполнить");
	
	Кнопка = ФормаВыбораНастроек.Элементы.Добавить("КнопкаОбновить", "КнопкаФормы", Группа);
	Кнопка.Заголовок = "Обновить";
	Кнопка.УстановитьДействие(ЭтотОбъект, "Нажатие", "ПриНажатииНаКнопкуОбновить");
	
	Кнопка = ФормаВыбораНастроек.Элементы.Добавить("КнопкаЗакрыть", "КнопкаФормы", Группа);
	Кнопка.Заголовок = "Закрыть";
	Кнопка.УстановитьДействие(ЭтотОбъект, "Нажатие", "ПриНажатииНаКнопкуЗакрыть");
	
	УправлениеДиалогом(0);
	
КонецПроцедуры

//******************************************************************
Процедура УправлениеДиалогом(Этап = 0)
	
	Если Этап = 0 Тогда
		ТекстКнопкиВыполнить = "Перезалить базу";
		ДоступностьНастроек = Истина;
		ДоступностьОбновитьОтмена = Ложь;
		ВидимостьПолеПользователи = Ложь;
	ИначеЕсли Этап = 1 Тогда
		Если ТаблицаПользователи <> Неопределено И ТаблицаПользователи.Количество() = 0 Тогда
			ТекстКнопкиВыполнить = "Перезалить базу";
		Иначе
			ТекстКнопкиВыполнить = "ЗАВЕРШИТЬ ВСЕ СЕАНСЫ И ПРОДОЛЖИТЬ";
		КонецЕсли;
		ДоступностьНастроек = Ложь;
		ДоступностьОбновитьОтмена = Истина;
		ВидимостьПолеПользователи = Истина;
	Иначе
		ТекстКнопкиВыполнить = "Перезалить базу";
		ДоступностьНастроек = Истина;
		ДоступностьОбновитьОтмена = Ложь;
		ВидимостьПолеПользователи = Ложь;		
	КонецЕсли;
	
	ФормаВыбораНастроек.Элементы.Найти("ПолеСоСпискомИсточник").Доступность = ДоступностьНастроек;
	ФормаВыбораНастроек.Элементы.Найти("ПолеСоСпискомПриемник").Доступность = ДоступностьНастроек;
	ФормаВыбораНастроек.Элементы.Найти("Дата").Доступность = ДоступностьНастроек;
	
	ПолеПользователи = ФормаВыбораНастроек.Элементы.Найти("ПолеПользователи");
	ПолеЛог = ФормаВыбораНастроек.Элементы.Найти("ПолеЛог");
	Если ВидимостьПолеПользователи Тогда
		Если ТаблицаПользователи <> Неопределено Тогда
			ПровайдерТЗ = Новый Провайдер;
			ПровайдерТЗ.Источник = ТаблицаПользователи;
			ПолеПользователи.ПутьКДанным = ПровайдерТЗ;
		КонецЕсли;
		ПолеЛог.Видимость = Ложь;
		ПолеПользователи.Видимость = Истина;
	Иначе
		ПолеПользователи.Видимость = Ложь;
		ПолеЛог.Видимость = Истина;
	КонецЕсли;
	
	ГруппаКнопки = ФормаВыбораНастроек.Элементы.Найти("ГруппаКнопки");		
	ГруппаКнопки.Элементы.Найти("КнопкаВыполнить").Заголовок = ТекстКнопкиВыполнить;
	ГруппаКнопки.Элементы.Найти("КнопкаОбновить").Доступность = ДоступностьОбновитьОтмена;	
	
КонецПроцедуры

//******************************************************************
Процедура ПриИзменииПолеСоСпискомИсточник() Экспорт
	
	ИндексБазыИсточник = ФормаВыбораНастроек.Элементы.Найти("ПолеСоСпискомИсточник").Значение;
	
КонецПроцедуры

//******************************************************************
Процедура ПриИзменииПолеСоСпискомПриемник() Экспорт
	
	ИндексБазыПриемник = ФормаВыбораНастроек.Элементы.Найти("ПолеСоСпискомПриемник").Значение;
	
КонецПроцедуры

//******************************************************************
Процедура ПриНажатииНаКнопкуЗакрыть() Экспорт
	
	ФормаВыбораНастроек.Закрыть();
	
КонецПроцедуры

//******************************************************************
Процедура ПриНажатииНаКнопкуОбновить() Экспорт
	
	Если Не ПолучитьСписокАктивныхСеансов() Тогда
		УправляемыйИнтерфейс.СтандартныеДиалоги.Предупреждение("Не удалось проверить список активных пользователей базы приемника!",,"Ошибка!");
		Возврат;
	КонецЕсли;
	УправлениеДиалогом(1);
	
КонецПроцедуры

//******************************************************************
Процедура ПриНажатииНаКнопкуВыполнить() Экспорт
	
	// Проверим, что все поля заполнены
	Если ИндексБазыИсточник = -1 Тогда
		УправляемыйИнтерфейс.СтандартныеДиалоги.Предупреждение("Не выбрана база источник!",,"Внимание!");
		Возврат;
	КонецЕсли;
	Если ИндексБазыПриемник = -1 Тогда
		УправляемыйИнтерфейс.СтандартныеДиалоги.Предупреждение("Не выбрана база приемник!",,"Внимание!");
		Возврат;
	КонецЕсли;	
	
	// Проверим, есть ли активные сеансты с базой приемником
	ВыполнитьОбработку = Ложь;
	НетДоступаККонсолиКластера = Ложь;
	Если Не КонтрольАктивныхСеансовПройден Тогда
		
		Если Не ПолучитьСписокАктивныхСеансов() Тогда
			Ответ = УправляемыйИнтерфейс.СтандартныеДиалоги.Вопрос("Не удалось проверить список активных пользователей базы приемника! Продолжить?",РежимДиалогаВопрос.ДаНет,,,"Все равно продолжить операцию?");
			Если Ответ = КодВозвратаДиалога.Да Тогда	
				НетДоступаККонсолиКластера = Истина;
				ВыполнитьОбработку = Истина;
			Иначе
				Возврат;
			КонецЕсли;
		КонецЕсли;
		
		Если Не НетДоступаККонсолиКластера Тогда
			
			Если ТаблицаПользователи = Неопределено Тогда
				Возврат;
			КонецЕсли;
			
			// Если есть активные соединения, покажим их
			Если ТаблицаПользователи.Количество() = 0 Тогда
				ВыполнитьОбработку = Истина;
			Иначе
				УправлениеДиалогом(1);
				КонтрольАктивныхСеансовПройден = Истина;			
			КонецЕсли;
			
		КонецЕсли;
		
	Иначе
		ВыполнитьОбработку = Истина;
	КонецЕсли;
	
	// Можно выполнить обработку
	Если ВыполнитьОбработку Тогда
		
		Ответ = УправляемыйИнтерфейс.СтандартныеДиалоги.Вопрос("Вы уверены что хотите перезалить базу?",РежимДиалогаВопрос.ДаНет,,,"Последнее предупреждение!");
		Если Ответ = КодВозвратаДиалога.Да Тогда
			
			УправлениеДиалогом(0);
			Если ВыполнитьОбработку(НетДоступаККонсолиКластера) Тогда
				УправляемыйИнтерфейс.СтандартныеДиалоги.Предупреждение("Обработка выполнена успешно!",,"Успех!");
			Иначе
				УправляемыйИнтерфейс.СтандартныеДиалоги.Предупреждение("ОБРАБОТКА НЕ ВЫПОЛНЕНА!",,"ОШИБКА!");
			КонецЕсли;		
			
		КонецЕсли;
	КонецЕсли;	
	
КонецПроцедуры

//******************************************************************
Процедура ПриНажатииНаКнопкуОбновитьСписокРасширений() Экспорт
	// База источник из таблицы
	БазаИсточник = ТаблицаБазаИсточник.Получить(ИндексБазыИсточник);
	
	Запуск1С = Новый ТУправлениеЗапуском1С();
	ЗаполнитьЗначенияСвойств(Запуск1С.ПараметрыЗапуска,БазаИсточник);
	ТаблицаРасширенийВБазе = Запуск1С.ПолучитьСписокРасширений();
	Если ТаблицаРасширенийВБазе = Неопределено Тогда
		//тогда произошла ошибка
	Иначе
		
		Для Каждого Расширение Из ТаблицаРасширенийВБазе Цикл
			Строки = ТаблицаРасширений.НайтиСтроки(Новый Структура("ИндексБазыПриемник, Имя",ИндексБазыПриемник, Расширение.Имя));
			Если Строки.Количество() = 0 Тогда Продолжить КонецЕсли;
				ЗаполнитьЗначенияСвойств(Расширение, Строки[0], , "УникальныйИдентификатор, Версия, ХешСумма");
			КонецЦикла;
			
			ПолеРасширений = ФормаВыбораНастроек.Элементы.Найти("ПолеРасширений");
			
			ПровайдерТЗ = Новый Провайдер;
			ПровайдерТЗ.Источник = ТаблицаРасширенийВБазе;
			ПолеРасширений.ПутьКДанным = ПровайдерТЗ;
			
		КонецЕсли;
		
	КонецПроцедуры
	
	//******************************************************************
	Функция ПолучитьСписокАктивныхСеансов()
		
		// База применик из таблицы
		БазаПриемник = ТаблицаБазаПриемник.Получить(ИндексБазыПриемник);
		
		// Получаем список сеансов
		Запуск1С = Новый ТУправлениеЗапуском1С();
		ЗаполнитьЗначенияСвойств(Запуск1С.ПараметрыЗапуска,БазаПриемник);
		ТаблицаПользователи = Запуск1С.ПолучитьСписокСеансов();
		
		Если ТаблицаПользователи = Неопределено Тогда
			Возврат Ложь;
		КонецЕсли;
		
		Возврат Истина;
		
	КонецФункции
	
	//******************************************************************
	Функция ВыполнитьТестНастроек()
		
		//
		БылиОшибки = Ложь;
		
		// Начало выполнения обработки
		СтрокаДействие  = "Начало выполнения тестирвоания настроек:";
		Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
		Логирование.УвеличитьУровень();
		
		// Создадим объекты
		УправлениеMSSQL = Новый УправлениеMSSQL();
		Запуск1С = Новый ТУправлениеЗапуском1С();
		
		// Цикл по всем базам источникам
		Для Каждого БазаИсточник ИЗ ТаблицаБазаИсточник Цикл
			
			Логирование.ЗаписатьСтрокуЛога();
			Логирование.ЗаписатьСтрокуЛога("Тест БД Источника: " + БазаИсточник.Имя);
			
			УправлениеMSSQL.ОчиститьПараметры();
			ЗаполнитьЗначенияСвойств(УправлениеMSSQL.ПараметрыПодключения,БазаИсточник);
			
			// Получим структуру файлов БД Источника
			// Если структура файлов получена, считаем, что параметры подключения заданы корректно
			ТаблицаФайловБД = УправлениеMSSQL.ПолучитьСтруктуруФайловБД();
			Если ТаблицаФайловБД = Неопределено Тогда
				СтрокаДействие = "Получить структуру файлов БД Источинка - ОШИБКА: " + УправлениеMSSQL.ТекстОшибки;
				БылиОшибки = Истина;
			ИначеЕсли ТаблицаФайловБД.Количество() = 0 Тогда
				СтрокаДействие = "Получить структуру файлов БД Источинка - ОШИБКА: Список файлов пуст!";
				БылиОшибки = Истина;
			Иначе
				СтрокаДействие = "Получить структуру файлов БД Источинка - УСПЕШНО";
			КонецЕсли;
			Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
			
		КонецЦикла;
		
		// Цикл по всем базам приемникам
		Для Каждого БазаПриемник ИЗ ТаблицаБазаПриемник Цикл
			
			Логирование.ЗаписатьСтрокуЛога();
			Логирование.ЗаписатьСтрокуЛога("Тест БД Приемника: " + БазаПриемник.Имя);
			
			УправлениеMSSQL.ОчиститьПараметры();
			ЗаполнитьЗначенияСвойств(УправлениеMSSQL.ПараметрыПодключения,БазаПриемник);
			
			// Получим структуру файлов БД Приемника
			// Если структура файлов получена, считаем, что параметры подключения заданы корректно
			ТаблицаФайловБД = УправлениеMSSQL.ПолучитьСтруктуруФайловБД();
			Если ТаблицаФайловБД = Неопределено Тогда
				СтрокаДействие = "Получить структуру файлов БД Приемника - ОШИБКА: " + УправлениеMSSQL.ТекстОшибки;
				БылиОшибки = Истина;
			ИначеЕсли ТаблицаФайловБД.Количество() = 0 Тогда
				СтрокаДействие = "Получить структуру файлов БД Приемника - ОШИБКА: Список файлов пуст!";
				БылиОшибки = Истина;
			Иначе
				СтрокаДействие = "Получить структуру файлов БД Приемника - УСПЕШНО";
			КонецЕсли;
			Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
			
			Запуск1С.ОчиститьПараметры();
			ЗаполнитьЗначенияСвойств(Запуск1С.ПараметрыЗапуска,БазаПриемник);
			
			// Получим список активных соединений БД Приемника
			// Если список сеансов получен, считаем, что настройки базы заданы корректно
			ТаблицаСеансов = Запуск1С.ПолучитьСписокСеансов();
			Если ТаблицаСеансов = Неопределено Тогда
				СтрокаДействие = "Получить список сеансов БД Приемника - ОШИБКА: " + Запуск1С.ТекстОшибки;
				БылиОшибки = Истина;
			Иначе
				СтрокаДействие = "Получить список сеансов БД Приемника - УСПЕШНО";
			КонецЕсли;
			Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
			
			// Выполним очистку локального кэша хранилища конфигурации
			// Если получилось очистить, считаем, что настройки хранилища и настройки 1С:Предприятие заданы корректно
			Если ЗначениеЗаполнено(Запуск1С.ПараметрыЗапуска.АдресХранилища) Тогда
				Если Запуск1С.ВыполнитьОчисткуЛокальногоКешаХранилища() Тогда
					СтрокаДействие = "Очистить локальный кэш хранилища конфигурации - УСПЕШНО";
				Иначе
					СтрокаДействие = "Очистить локальный кэш хранилища конфигурации - ОШИБКА: " + Запуск1С.ТекстОшибки;
					БылиОшибки = Истина;
				КонецЕсли;
				Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
			КонецЕсли;
			
		КонецЦикла;
		
		СтрокаДействие  = "Завершение выполнения обработки.";
		Логирование.ЗаписатьСтрокуЛога();
		Логирование.УменьшитьУровень();
		Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
		
		Сообщить("--------------------------------------------");
		Сообщить("Рзультат тестирования: " + ?(БылиОшибки,"БЫЛИ ОШИБКИ!","УСПЕШНО!"));
		Сообщить("--------------------------------------------");
		
		Возврат Не БылиОшибки;
		
	КонецФункции
	
	//******************************************************************
	Функция ВыполнитьОбработку(НетДоступаККонсолиКластера=Ложь)
		
		//
		БылиОшибки = Ложь;
		БазаВосстановлена = Ложь;
		ПолеЛог = ФормаВыбораНастроек.Элементы.Найти("ПолеЛог");
		ПолеЛог.Видимость = Истина;
		
		// Начало выполнения обработки
		СтрокаДействие  = "Начало выполнения обработки.";
		Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
		Логирование.УвеличитьУровень();
		ПолеЛог.Значение = СтрокаДействие;
		
		// База применик из таблицы
		БазаПриемник = ТаблицаБазаПриемник.Получить(ИндексБазыПриемник);
		Запуск1С = Новый ТУправлениеЗапуском1С();
		ЗаполнитьЗначенияСвойств(Запуск1С.ПараметрыЗапуска,БазаПриемник);
		
		// Завершим соединения, если необходимо
		Если Не НетДоступаККонсолиКластера Тогда
			Если ТаблицаПользователи.Количество() > 0 Тогда
				Если Запуск1С.ЗавершитьРаботуПользователей() Тогда
					СтрокаДействие = "Завершить работу пользователей - УСПЕШНО";
				Иначе
					СтрокаДействие = "Завершить работу пользователей - ОШИБКА: " + Запуск1С.ТекстОшибки;
					БылиОшибки = Истина;
				КонецЕсли;
				Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
				ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;
			КонецЕсли;
		КонецЕсли;
		
		// Установим блокировку начала сеансов
		Если Не НетДоступаККонсолиКластера Тогда
			Если Не БылиОшибки Тогда
				Если Запуск1С.УстановитьБлокировкуНачалаСеансов() Тогда
					СтрокаДействие = "Установить блокировку начала сеансов - УСПЕШНО";
				Иначе
					СтрокаДействие = "Установить блокировку начала сеансов - ОШИБКА: " + Запуск1С.ТекстОшибки;
					БылиОшибки = Истина;
				КонецЕсли;
				Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
				ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;
			КонецЕсли;
		КонецЕсли;
		ВыполнитьСборкуМусора();
		
		// База источник из таблицы
		Если Не БылиОшибки Тогда
			БазаИсточник = ТаблицаБазаИсточник.Получить(ИндексБазыИсточник);
			УправлениеMSSQL = Новый УправлениеMSSQL();
			ЗаполнитьЗначенияСвойств(УправлениеMSSQL.ПараметрыПодключения,БазаИсточник);
		КонецЕсли;
		
		// Получим список файлов для восстановления
		Если Не БылиОшибки Тогда
			ТекДата = ФормаВыбораНастроек.Элементы.Найти("Дата").Значение;
			МассивФайлов = УправлениеMSSQL.ПолучитьСписокФайловДляВосстановленияБД(КонецДня(ТекДата)); 
			Если МассивФайлов <> Неопределено Тогда
				СтрокаДействие = "Получить список файлов для восстановления БД - УСПЕШНО";
				Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
				ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;
				Для Сч = 0 По МассивФайлов.Количество()-1 Цикл
					СтрокаДействие = "    Файл: " + МассивФайлов.Получить(Сч);
					Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
					ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;
				КонецЦикла;
			Иначе
				СтрокаДействие = "Получить список файлов для восстановления БД - ОШИБКА: " + УправлениеMSSQL.ТекстОшибки;
				Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
				ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;
				БылиОшибки = Истина;
			КонецЕсли;
		КонецЕсли;
		
		// Получим структуру файлов БД Источника
		Если Не БылиОшибки Тогда
			ТаблицаФайловБДИсточника = УправлениеMSSQL.ПолучитьСтруктуруФайловБД();
			Если ТаблицаФайловБДИсточника = Неопределено Тогда
				СтрокаДействие = "Получить структуру файлов БД Источинка - ОШИБКА: " + УправлениеMSSQL.ТекстОшибки;
				БылиОшибки = Истина;
			ИначеЕсли ТаблицаФайловБДИсточника.Количество() = 0 Тогда
				СтрокаДействие = "Получить структуру файлов БД Источинка - ОШИБКА: Список файлов пуст!";
				БылиОшибки = Истина;
			Иначе
				СтрокаДействие = "Получить структуру файлов БД Источинка - УСПЕШНО";
			КонецЕсли;
			Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
			ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;
		КонецЕсли;
		
		// База применик из таблицы
		Если Не БылиОшибки Тогда
			УправлениеMSSQL = Новый УправлениеMSSQL();
			ЗаполнитьЗначенияСвойств(УправлениеMSSQL.ПараметрыПодключения,БазаПриемник);
		КонецЕсли;	
		
		// Восстановим базу
		Если Не БылиОшибки Тогда
			Если УправлениеMSSQL.ВосстановитьИзРезервнойКопииБД(МассивФайлов,ТаблицаФайловБДИсточника) Тогда
				СтрокаДействие = "Восстановить из резервной копии БД - УСПЕШНО";
				БазаВосстановлена = Истина;
			Иначе
				СтрокаДействие = "Восстановить из резервной копии БД - ОШИБКА: " + УправлениеMSSQL.ТекстОшибки;
				БылиОшибки = Истина;
			КонецЕсли;
			Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
			ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;		
		КонецЕсли;
		
		// Переведем в простую модель восстановления
		Если Не БылиОшибки Тогда
			Если УправлениеMSSQL.ИзменитьМодельВосстановленияБД("SIMPLE") Тогда
				СтрокаДействие = "Перевести в простую модель восстановления - УСПЕШНО";
			Иначе
				СтрокаДействие = "Перевести в простую модель восстановления - ОШИБКА: " + УправлениеMSSQL.ТекстОшибки;
				БылиОшибки = Истина;
			КонецЕсли;
			Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
			ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;		
		КонецЕсли;
		
		// Запустим сжатие лог-файла
		Если Не БылиОшибки Тогда
			Если УправлениеMSSQL.СжатьФайлыБД("LOG") Тогда
				СтрокаДействие = "Сжать файл логов - УСПЕШНО";
			Иначе
				СтрокаДействие = "Сжать файл логов - ОШИБКА: " + УправлениеMSSQL.ТекстОшибки;
				БылиОшибки = Истина;
			КонецЕсли;
			Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
			ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;		
		КонецЕсли;
		
		// Если база была подключена к хранилищу, необходимо переподключится
		Если ЗначениеЗаполнено(БазаПриемник.АдресХранилища) Тогда
			
			// Отключимся от хранилища базы источника
			Если Не БылиОшибки Тогда
				Если Запуск1С.ОтключитьКонфигурациюОтХранилища() Тогда
					СтрокаДействие = "Отключиться от хранилища - УСПЕШНО";
				Иначе
					СтрокаДействие = "Отключиться от хранилища  - ОШИБКА: " + УправлениеMSSQL.ТекстОшибки;
					БылиОшибки = Истина;
				КонецЕсли;
				Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
				ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;		
			КонецЕсли;
			
			// Подключимся к старому хранилищу
			Если Не БылиОшибки Тогда
				Если Запуск1С.ПодключитьКонфигурациюКХранилищу() Тогда
					СтрокаДействие = "Подключиться к хранилищу - УСПЕШНО";
				Иначе
					СтрокаДействие = "Подключиться к хранилищу  - ОШИБКА: " + УправлениеMSSQL.ТекстОшибки;
					БылиОшибки = Истина;
				КонецЕсли;
				Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
				ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;		
			КонецЕсли;
			
			// Обновим конфигурацию из хранилища
			Если Не БылиОшибки Тогда
				Если Запуск1С.ОбновитьКонфигурациюИзХранилища() Тогда
					СтрокаДействие = "Обновить конфигурацию из хранилища - УСПЕШНО";
				Иначе
					СтрокаДействие = "Обновить конфигурацию из хранилища  - ОШИБКА: " + УправлениеMSSQL.ТекстОшибки;
					БылиОшибки = Истина;
				КонецЕсли;
				Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
				ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;		
			КонецЕсли;
			
			// Обновить конфигурацию базы данных
			Если Не БылиОшибки Тогда
				Если Запуск1С.ОбновитьКонфигурациюБазыДанных() Тогда
					СтрокаДействие = "Обновить конфигурацию базы данных - УСПЕШНО";
				Иначе
					СтрокаДействие = "Обновить конфигурацию базы данных  - ОШИБКА: " + УправлениеMSSQL.ТекстОшибки;
					БылиОшибки = Истина;
				КонецЕсли;
				Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
				ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;		
			КонецЕсли;
			
		КонецЕсли;
		
		// Подключим к хранилищу расширения
		Если НЕ ТаблицаРасширенийВБазе = Неопределено Тогда
			Для Каждого Расширение Из ТаблицаРасширенийВБазе Цикл
				
				Если ЗначениеЗаполнено(Расширение.АдресХранилища) Тогда
					
					ЗаполнитьЗначенияСвойств(Запуск1С.ПараметрыЗапуска,Расширение,"АдресХранилища, ИмяПользователяХранилища, ПарольПользователяХранилища");
					Запуск1С.ПараметрыЗапуска.ИмяРасширения = Расширение.Имя;
					
					// Отключимся от хранилища базы источника
					Если Не БылиОшибки Тогда
						Если Запуск1С.ОтключитьКонфигурациюОтХранилища() Тогда
							СтрокаДействие = "Расширение: " + Расширение.Имя + " - " + "Отключиться от хранилища - УСПЕШНО";
						Иначе
							СтрокаДействие = "Расширение: " + Расширение.Имя + " - " + "Отключиться от хранилища  - ОШИБКА: " + УправлениеMSSQL.ТекстОшибки;
							БылиОшибки = Истина;
						КонецЕсли;
						Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
						ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;		
					КонецЕсли;
					
					// Подключимся к старому хранилищу
					Если Не БылиОшибки Тогда
						Если Запуск1С.ПодключитьКонфигурациюКХранилищу() Тогда
							СтрокаДействие = "Расширение: " + Расширение.Имя + " - " + "Подключиться к хранилищу - УСПЕШНО";
						Иначе
							СтрокаДействие = "Расширение: " + Расширение.Имя + " - " + "Подключиться к хранилищу  - ОШИБКА: " + УправлениеMSSQL.ТекстОшибки;
							БылиОшибки = Истина;
						КонецЕсли;
						Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
						ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;		
					КонецЕсли;
					
					// Обновим конфигурацию из хранилища
					Если Не БылиОшибки Тогда
						Если Запуск1С.ОбновитьКонфигурациюИзХранилища() Тогда
							СтрокаДействие = "Расширение: " + Расширение.Имя + " - " + "Обновить конфигурацию из хранилища - УСПЕШНО";
						Иначе
							СтрокаДействие = "Расширение: " + Расширение.Имя + " - " + "Обновить конфигурацию из хранилища  - ОШИБКА: " + УправлениеMSSQL.ТекстОшибки;
							БылиОшибки = Истина;
						КонецЕсли;
						Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
						ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;		
					КонецЕсли;
					
					// Обновить конфигурацию базы данных
					Если Не БылиОшибки Тогда
						Если Запуск1С.ОбновитьКонфигурациюБазыДанных() Тогда
							СтрокаДействие = "Расширение: " + Расширение.Имя + " - " + "Обновить конфигурацию базы данных - УСПЕШНО";
						Иначе
							СтрокаДействие = "Расширение: " + Расширение.Имя + " - " + "Обновить конфигурацию базы данных  - ОШИБКА: " + УправлениеMSSQL.ТекстОшибки;
							БылиОшибки = Истина;
						КонецЕсли;
						Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
						ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;		
					КонецЕсли;
					
				КонецЕсли;
			КонецЦИкла;
		КонецЕсли;
		// Снимем блокировку начала сеансов
		Если Не НетДоступаККонсолиКластера Тогда
			Если Запуск1С.СнятьБлокировкуНачалаСеансов(Ложь) Тогда
				СтрокаДействие = "Снять блокировку начала сеансов - УСПЕШНО";
			Иначе
				СтрокаДействие = "Снять блокировку начала сеансов - ОШИБКА: " + Запуск1С.ТекстОшибки;
				БылиОшибки = Истина;
			КонецЕсли;
			Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
			ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;
		КонецЕсли;
		ВыполнитьСборкуМусора();
		
		// Отправляем эклектронное сообщение с файлом лога во вложении
		Если БазаВосстановлена И ЗначениеЗаполнено(УправлениеЭП.УчетнаяЗаписьЭП.АдресSMTP) Тогда
			
			СтруктураСообщения = УправлениеЭП.СтруктураСообщения;
			СтруктураСообщения.ТемаСообщения = "### Перезалита база данных. Источник - """ + БазаИсточник.Имя + """, Назначение - """ + БазаПриемник.Имя + """";
			Если БылиОшибки Тогда
				СтруктураСообщения.ТекстСообщения = "ВНИМАНИЕ! " + Символы.ПС + 
				СтруктураСообщения.ТемаСообщения + Символы.ПС +
				"Но не все операции были выполнены. Смотрите лог-файл во вложении.";
			Иначе
				СтруктураСообщения.ТекстСообщения = СтруктураСообщения.ТемаСообщения + Символы.ПС + 
				"Все операции были выполнены успешно.";
			КонецЕсли;
			
			// Часть имеющегося лога добавим в письмо
			ИмяВременногоФайла = ПолучитьИмяВременногоФайла("txt");
			КопироватьФайл(Логирование.ИмяФайлаЛога,ИмяВременногоФайла);
			СтруктураСообщения.Вложения = ИмяВременногоФайла;
			
			// Отправим сообщение
			Если УправлениеЭП.ОтправитьСообщение() Тогда
				СтрокаДействие = "Отправить электорнное сообщение - УСПЕШНО. Адреса: " + СтруктураСообщения.АдресЭлектроннойПочтыПолучателя;
			Иначе
				СтрокаДействие = "Отправить электорнное сообщение - ОШИБКА: " + УправлениеЭП.ТекстОшибки;
				БылиОшибки = Истина;
			КонецЕсли;
			Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
			ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;
			
			УдалитьФайлы(ИмяВременногоФайла);
			
		КонецЕсли;
		
		СтрокаДействие  = "Завершение выполнения обработки.";
		Логирование.УменьшитьУровень();
		Логирование.ЗаписатьСтрокуЛога(СтрокаДействие);
		ПолеЛог.Значение = ПолеЛог.Значение + Символы.ПС + СтрокаДействие;
		
		Возврат Не БылиОшибки;
		
	КонецФункции
	
	//******************************************************************
	Инициализация();
	