
#Использовать logos
#Использовать gitrunner

Перем ВерсияПлагина;
Перем Лог;
Перем КомандыПлагина;

Перем Обработчик;
Перем СчетчикКоммитов;
Перем URLРепозитория;
Перем КоличествоКоммитовДоPush;
Перем ИмяВетки;
Перем ОтправлятьТеги;
Перем ГитРепозиторийСохр;
Перем РабочийКаталогСохр;

Функция Информация() Экспорт
	
	Возврат Новый Структура("Версия, Лог", ВерсияПлагина, Лог)
	
КонецФункции // Информация() Экспорт

Процедура ПриАктивизацииПлагина(СтандартныйОбработчик, КонтекстПлагина) Экспорт
	
	Обработчик = СтандартныйОбработчик;

КонецПроцедуры

Процедура ПриРегистрацииКомандыПриложения(ИмяКоманды, КлассРеализации, Парсер, КонтекстПлагина) Экспорт

	Лог.Отладка("Ищю команду <%1> в списке поддерживаемых", ИмяКоманды);
	Если КомандыПлагина.Найти(ИмяКоманды) = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Лог.Отладка("Устанавливаю дополнительные параметры для команды %1", ИмяКоманды);
	
	ОписаниеКоманды = Парсер.ПолучитьКоманду(ИмяКоманды);
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-push-every-n-commits", "[PLUGIN] [push] <число> количество коммитов до промежуточной отправки на удаленный сервер");
	Парсер.ДобавитьПараметрФлагКоманды		 (ОписаниеКоманды, "-push-tags", "[PLUGIN] [push] Флаг отправки установленных меток");

	Парсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры

Процедура ПриВыполненииКоманды(ПараметрыКоманды, ДополнительныеПараметры, КонтекстПлагина) Экспорт

	КоличествоКоммитовДоPush = ПараметрыКоманды["-push-every-n-commits"];
	ОтправлятьТеги = ПараметрыКоманды["-push-tags"];

	Если КоличествоКоммитовДоPush = Неопределено Тогда
		КоличествоКоммитовДоPush = 0;
	КонецЕсли;

	КоличествоКоммитовДоPush = Число(КоличествоКоммитовДоPush);

	Лог.Отладка("Установлено количество коммитов <%1> после, которых осущевствляется отправка", КоличествоКоммитовДоPush);
	Лог.Отладка("Установлен флаг оправки меток в значение <%1> выгрузки версий", ОтправлятьТеги);
	
КонецПроцедуры



Процедура ПередНачаломВыполнения(ПутьКХранилищу, КаталогРабочейКопии, URLРепозитория, ИмяВетки, КонтекстПлагина) Экспорт

	URLРепозитория = URLРепозитория;
	ИмяВетки = ИмяВетки;
	
КонецПроцедуры

Процедура ПослеОкончанияВыполнения(ПутьКХранилищу, КаталогРабочейКопии, URLРепозитория, ИмяВетки, КонтекстПлагина) Экспорт
	
	ГитРепозиторий = ПолучитьГитРепозиторий(КаталогРабочейКопии);
	ВыполнитьGitPush(ГитРепозиторий, КаталогРабочейКопии, URLРепозитория, ИмяВетки);

КонецПроцедуры


Процедура ПослеКоммита(ГитРепозиторий, КаталогРабочейКопии, КонтекстПлагина) Экспорт
	
	СчетчикКоммитов = СчетчикКоммитов + 1;

	Если СчетчикКоммитов = КоличествоКоммитовДоPush Тогда

		ВыполнитьGitPush(ГитРепозиторий, КаталогРабочейКопии, URLРепозитория, ИмяВетки);
		СчетчикКоммитов = 0;

	КонецЕсли;

КонецПроцедуры


// Cтандартная процедура git push
//
Функция ВыполнитьGitPush(Знач ГитРепозиторий,Знач ЛокальныйРепозиторий, Знач УдаленныйРепозиторий, Знач ИмяВетки = Неопределено, Знач ОтправитьМетки = Ложь) Экспорт
	

	Лог.Информация("Отправляю изменения на удаленный url (push)");
	
	ГитРепозиторий.ВыполнитьКоманду(СтрРазделить("gc --auto", " "));
	Лог.Отладка(СтрШаблон("Вывод команды gc: %1", СокрЛП(ГитРепозиторий.ПолучитьВыводКоманды())));
	
	ПараметрыКомандыPush = Новый Массив;
	ПараметрыКомандыPush.Добавить("push -u");
	ПараметрыКомандыPush.Добавить(СтрЗаменить(УдаленныйРепозиторий, "%", "%%"));
	ПараметрыКомандыPush.Добавить("--all -v");

	ГитРепозиторий.ВыполнитьКоманду(ПараметрыКомандыPush);

	Если ОтправлятьТеги Тогда

		ПараметрыКомандыPush = Новый Массив;
		ПараметрыКомандыPush.Добавить("push -u");
		ПараметрыКомандыPush.Добавить(СтрЗаменить(УдаленныйРепозиторий, "%", "%%"));
		ПараметрыКомандыPush.Добавить("--tags");
	
		ГитРепозиторий.ВыполнитьКоманду(ПараметрыКомандыPush);

	КонецЕсли;

	Лог.Отладка(СтрШаблон("Вывод команды Push: %1", СокрЛП(ГитРепозиторий.ПолучитьВыводКоманды())));
	
КонецФункции

Функция ПолучитьГитРепозиторий(Знач КаталогРабочейКопии)
	
	ФайлКаталога = Новый Файл(ОбъединитьПути(ТекущийКаталог(), КаталогРабочейКопии));
	Если ФайлКаталога.ПолноеИмя = РабочийКаталогСохр Тогда
		ГитРепозиторий = ГитРепозиторийСохр;
	Иначе
		ГитРепозиторий = Новый ГитРепозиторий;
		ГитРепозиторий.УстановитьРабочийКаталог(КаталогРабочейКопии);
		ГитРепозиторий.УстановитьНастройку("core.quotepath", "false", РежимУстановкиНастроекGit.Локально);
		ГитРепозиторий.УстановитьНастройку("merge.ours.driver", "true", РежимУстановкиНастроекGit.Локально);

		РабочийКаталогСохр = ФайлКаталога.ПолноеИмя;
		ГитРепозиторийСохр = ГитРепозиторий;

	КонецЕсли;

	Возврат ГитРепозиторий;
	
КонецФункции // ПолучитьГитРепозиторий()


Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт
	
	Возврат СтрШаблон("[PLUGIN] %1: %2 - %3", ИмяПлагина(), УровниЛога.НаименованиеУровня(Уровень), Сообщение);
	
КонецФункции

Функция ИмяПлагина()
	возврат "push";
КонецФункции // ИмяПлагина()

Процедура Инициализация()

	ВерсияПлагина = "1.0.0";
	Лог = Логирование.ПолучитьЛог("oscript.app.gitsync.plugins."+ ИмяПлагина());
	КомандыПлагина = Новый Массив;
	КомандыПлагина.Добавить("sync");
	КомандыПлагина.Добавить("export");
	
	URLРепозитория = Неопределено;
	ИмяВетки = "master";
	СчетчикКоммитов = 0;

	Лог.УстановитьРаскладку(ЭтотОбъект);

КонецПроцедуры

Инициализация();
