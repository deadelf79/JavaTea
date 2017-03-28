# JavaTea
## Что это? ##

**JavaTea** - это генератор кода классов для Java (и Processing) с упрощенным синтаксисом, цель которого - минимумом текста в одном текстовом файле создавать набор классов, чтобы вы могли пить чай вместо рутинного написания множества классов и файлов.

**Генератор еще в разработке и многое еще не готово. Все работающее стабильно вынесено в раздел "Синтаксис" и не будет меняться в дальнейшем.**

## Синтаксис ##
### Импорт пакетов ###

Перечисляем все импортируемые пакеты через запятую или построчно. Или сразу через запятую и построчно, как в примере:

    * java.some.Thing, java.some.Else
    * java.yes.this.Too

Получаем:

	import java.some.Thing;
	import java.some.Else;
	import java.yes.this.Too;

### Название пакета ###

Чтобы указать название собственного пакета, в который войдут все классы после обработки, укажите `&` и название пакета, например, так:

	& myPackage

Получим:

	package myPackage;

### Создание класса ###

Указываем слово `class` в самом начале строки (отступы недопустимы!), вводим его название:

	class Foo

Получаем:

	class Foo {
		// constructor
		public Foo() {
		}

	}

Если класс является потомком (расширяет родительский класс), добавляем слово `by` после имени класса и пишем имя родителя:

	class Foo by Bar

Получаем:

	class Foo extends Bar {
		// constructor
		public Foo() {
		}
	
	}

### Переменные ###

Есть четыре вида переменных:

- публичные (public)
- защищенные (protected)
- приватные (private)
- приватные, работа с которыми осуществляется через методы, имена которых начинается с `get` и `set`

Объявление разных виов переменных:

	+ int fooBar 	// <- публичная
	_ int foo		// <- защищенная
	- int bar		// <- приватная
	~ int baz		// <- приватная, getset

Получим в результате:

	public int fooBar;
	protected int foo;
	private int bar;
	int baz; // методы get и set записываются в последний объявленный класс

Если перед переменной нет табуляции или пробелов, то она становится глобальной (вне классов, инициализируется в начале файла), например:

	+ int fooBar
	class Foo by Bar

Дает результат:

	public int fooBar;

	class Foo extends Bar {
		// constructor
		public Foo() {
		}
	
	}

Чтобы создать переменную класса, нужно добавить в начало строку табуляцию или пробел после объявления класса, например:

	class Foo by Bar
		+ int fooBar;

Получим:

	class Foo extends Bar {
		// variables
		public int fooBar;
		
		// constructor
		public Foo() {
			
		}
		
	}

Переменные `getset` объявляются после объявления класса:

	class Foo by Bar
		~ int fooBar;

Получаем:

	class Foo extends Bar {
		// variables
		int fooBar;
		
		// constructor
		public Foo() {
		}
		
		// getters
		public int getFooBar() {
			return fooBar;
		}
		
		// setters
		public int setFooBar(int newValue) {
			fooBar = newValue;
		}
		
	}

Вы можете назначить переменной значение по умолчанию, которое будет задаваться в конструкторе класса:

	class Foo
		+ int some 0

Получим:

	class Foo {
		// variables
		public int some;
		
		
		// constructor
		public Foo() {
			some = 0;
			
		}
		
	}

### Массивы и списки ###

Вы можете объявить переменную для хранения массива определенного размера. Сделать это можно в теле класса:

	class Foo
		+ String[] line 10

Получим:

	class Foo {
		// variables
		public String[] line;
		
		
		// constructor
		public Foo() {
			String[] line = new String[10];
			
		}
		
	}

При указании списка `ArrayList` последним параметром будет не количество элементов списка, а класс, который будет хранить в себе список:

	class Foo
		+ ArrayList some SomeClass

Дает результат:

	class Foo {
		// variables
		public ArrayList some;
		
		
		// constructor
		public Foo() {
			ArrayList<SomeClass> some = new ArrayList<>();
			
		}
		
	}

### Функции ###
пока в разработке