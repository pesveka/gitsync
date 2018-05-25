#Использовать fs
#Использовать json
#Использовать logos
#Использовать "./internal"

Перем ИндексПлагинов;
Перем КаталогПлагинов;
Перем ПутьКФайлуВключенныхПлагинов;
Перем КаталогЗависимостей;

Функция ПолучитьИндексПлагинов() Экспорт
	Возврат ИндексПлагинов;
КонецФункции

Процедура ЗагрузитьПлагины() Экспорт

	ТекущийЗагрузчикПлагинов = Новый ЗагрузчикПлагинов(КаталогПлагинов);
	ТекущийЗагрузчикПлагинов.ЗагрузитьПлагины();
	ИндексПлагинов = ТекущийЗагрузчикПлагинов.ИндексПлагинов();

	ВключенныеПлагины = ПрочитатьВключенныеПлагины();
	ВключитьПлагины(ВключенныеПлагины);

КонецПроцедуры

Функция НовыйМенеджерПодписок() Экспорт
	
	Возврат Новый МенеджерПодписок(ИндексПлагинов);

КонецФункции

Процедура ОтключитьПлагины(МассивПлагинов) Экспорт
	
	Для каждого ОтключаемыйПлагин Из МассивПлагинов Цикл
		
		Плагин = ИндексПлагинов[ОтключаемыйПлагин];

		Если Плагин = Неопределено Тогда
			Продолжить;
		КонецЕсли;

		Плагин.Отключить();

	КонецЦикла;

КонецПроцедуры

Процедура ВключитьПлагины(МассивПлагинов) Экспорт
	
	Для каждого ВключаемыеПлагин Из МассивПлагинов Цикл
		
		Если ТипЗнч(ВключаемыеПлагин) = Тип("Строка") Тогда
			ВключитьПлагин(ВключаемыеПлагин);
		Иначе
			ВключитьПлагин(ВключаемыеПлагин.Ключ);
		КонецЕсли;
		
	КонецЦикла;

КонецПроцедуры

Процедура ВключитьПлагин(Знач ИмяПлагина) Экспорт

	Плагин = ИндексПлагинов[ИмяПлагина];

	Если Плагин = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Плагин.Включить();

КонецПроцедуры

Процедура УстановитьКаталогПлагинов(Знач ПутьККаталогу) Экспорт
	КаталогПлагинов = ПутьККаталогу;
КонецПроцедуры

Процедура УстановитьКаталогЗависимостей(Знач НовыйКаталогЗависимостей) Экспорт
	КаталогЗависимостей = НовыйКаталогЗависимостей;
КонецПроцедуры

Процедура УстановитьФайлПлагин(Знач ПутьКФайлуПакета) Экспорт
	
	Установщик = Новый УстановщикПлагинов();
	Установщик.УстановитьКаталогПлагинов(КаталогПлагинов);
	Установщик.УстановитьКаталогЗависимостей(КаталогЗависимостей);

	Установщик.УстановитьФайлПлагина(ПутьКФайлуПакета);

КонецПроцедуры

Процедура УстановитьПлагинПоИмени(Знач ИмяПлагина) Экспорт
	
	Установщик = Новый УстановщикПлагинов();
	Установщик.УстановитьКаталогПлагинов(КаталогПлагинов);
	Установщик.УстановитьКаталогЗависимостей(КаталогЗависимостей);

	Установщик.УстановитьПлагинПоИмени(ИмяПлагина);

КонецПроцедуры

Процедура УстановитьРежимОтладки() Экспорт
	
	Для каждого КлючЗначение Из ИндексПлагинов Цикл
		
		Плагин = КлючЗначение.Значение;
		Плагин.ВключитьОтладку();

	КонецЦикла;

КонецПроцедуры

Процедура УстановитьФайлВключенныхПлагинов(Знач ПутьКФайлу) Экспорт
	ПутьКФайлуВключенныхПлагинов = ПутьКФайлу;
КонецПроцедуры

Функция ПрочитатьВключенныеПлагины() Экспорт

	ВключенныеПлагины = Новый Соответствие;

	ПутьКФайлу = ПолучитьПутьКФайлуВключенныхПлагинов();
	ФайлАктивныхПлагинов= Новый Файл(ПутьКФайлу);

	Если Не ФайлАктивныхПлагинов.Существует() Тогда
		Возврат ВключенныеПлагины;
	КонецЕсли;

	JsonСтрока = ПрочитатьФайл(ПутьКФайлу);

	Если ПустаяСтрока(JsonСтрока) Тогда
		Возврат ВключенныеПлагины;
	КонецЕсли;

	ПарсерJSON  = Новый ПарсерJSON();
	ДанныеФайла = ПарсерJSON.ПрочитатьJSON(JsonСтрока);

	Для каждого ДанныеПлагинаИзФайла Из ДанныеФайла Цикл
		
		Если Булево(ДанныеПлагинаИзФайла.Значение) Тогда
			ВключенныеПлагины.Вставить(ДанныеПлагинаИзФайла.Ключ, ДанныеПлагинаИзФайла.Значение);
		КонецЕсли;

	КонецЦикла;

	Возврат ВключенныеПлагины;

КонецФункции

Функция ПолучитьПутьКФайлуВключенныхПлагинов()
	
	ФайлАктивныхПлагинов= Новый Файл(ПутьКФайлуВключенныхПлагинов);

	Если Не ФайлАктивныхПлагинов.Существует() Тогда
		Возврат ОбъединитьПути(КаталогПлагинов, ИмяФайлаВключенныхПлагинов());
	КонецЕсли;

	Возврат ФайлАктивныхПлагинов.ПолноеИмя;

КонецФункции

Функция ИмяФайлаВключенныхПлагинов() Экспорт
	
	Возврат "gitsync-plugins.json";

КонецФункции

Процедура ЗаписатьВключенныеПлагины() Экспорт

	ИмяФайла = ПолучитьПутьКФайлуВключенныхПлагинов();

	КаталогФайла = Новый Файл(ИмяФайла).Путь;
	ФС.ОбеспечитьКаталог(КаталогФайла);

	ПарсерJSON  = Новый ПарсерJSON();
	ДанныеДляЗаписи = Новый Соответствие;

	Для каждого КлючЗначение Из ИндексПлагинов Цикл
		
		Плагин = КлючЗначение.Значение;
		ДанныеДляЗаписи.Вставить(Плагин.Имя(), Плагин.Включен());
	
	КонецЦикла;
	
	ТекстФайла = ПарсерJSON.ЗаписатьJson(ДанныеДляЗаписи);

	ЗаписатьФайл(ИмяФайла, ТекстФайла);

КонецПроцедуры

Функция ПрочитатьФайл(Знач ИмяФайла)
	
	Чтение = Новый ЧтениеТекста(ИмяФайла, КодировкаТекста.UTF8);
	Рез  = Чтение.Прочитать();
	Чтение.Закрыть();
	
	Возврат Рез;

КонецФункции

Процедура ЗаписатьФайл(Знач ИмяФайла, ТекстФайла)

	Запись = Новый ЗаписьТекста(ИмяФайла);
	Запись.ЗаписатьСтроку(ТекстФайла);
	Запись.Закрыть();

КонецПроцедуры

Процедура ПриСозданииОбъекта(Знач ЗначениеКаталогПлагинов = Неопределено)
	
	ИндексПлагинов = Новый Соответствие;

	Если ЗначениеЗаполнено(ЗначениеКаталогПлагинов) Тогда
		КаталогПлагинов = ЗначениеКаталогПлагинов;
	КонецЕсли;
	
	ДополнительныйКаталогБиблиотек = ПолучитьЗначениеСистемнойНастройки("lib.additional");

	Если ЗначениеЗаполнено(ДополнительныйКаталогБиблиотек) Тогда
		КаталогЗависимостей = ДополнительныйКаталогБиблиотек;
	Иначе
		КаталогЗависимостей = ПолучитьЗначениеСистемнойНастройки("lib.system");
	КонецЕсли;

КонецПроцедуры

