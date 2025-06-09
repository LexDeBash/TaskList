# TaskList

**TaskList** — iOS-приложение для управления списками задач. Пользователь может создавать списки, добавлять задачи, редактировать их, отмечать как выполненные и сортировать по дате или статусу. Проект построен на базе UIKit по архитектуре MVVM с инверсией зависимостей и поддержкой двух типов хранилища: **Core Data** и **Realm**.


## Возможности

- Создание и удаление списков задач
- Добавление и редактирование задач
- Сортировка задач по дате создания или статусу (выполнено / не выполнено)
- Две взаимозаменяемые реализации: `CoreDataStorage`, `RealmStorage`
- Чистая архитектура с использованием MVVM и Coordinator
- Абстрактный слой хранения через протокол `Storage`
- DTO-модели без зависимости от инфраструктур
- Реактивный биндинг через замыкания (`onTasksChanged`, `onError`, и т.д.)
- Модульный редактор задач (`TaskEditorViewController`)
- Поддержка пустых состояний через `UIContentUnavailableConfiguration`
- Упрощённый Auto Layout через `applyConstraints(...)`

## Архитектура

Проект реализует принцип разделения ответственности:

- `MVVM`: каждая сцена (TaskLists, Tasks, TaskEditor) имеет свою модель представления ViewModel с бизнес-логикой
- `Coordinator`: управление навигацией вынесено в отдельные объекты
- `Storage`: абстракция над слоем хранения данных (Core Data и Realm)
- `DTO`: модель представления изолирована от модели хранения

## Модули

- `TaskListsViewController` — список списков задач
- `TasksViewController` — список задач внутри списка
- `TaskEditorViewController` — создание и редактирование задачи
- `Storage.swift` — абстракция для слоя данных
- `CoreDataStorage.swift` / `RealmStorage.swift` — реализации хранилища
- `TaskInput.swift` — DTO для передачи данных от пользователя

Структура проекта:

```plaintext
TaskList
│
├── App                  // AppDelegate, SceneDelegate, стартовая точка
├── Coordinators         // Навигация
├── Models               // Модели предметной области
├── Services             // Реализация Storage (CoreDataStorage, RealmStorage)
├── TaskLists            // View + ViewModel для экранов со списками
├── Tasks                // View + ViewModel для задач внутри списка
├── TaskEditor           // View + ViewModel для формы редактирования
├── Extensions           // Вспомогательные расширения
├── Factories            // DI-компоненты
└── Resources            // Локализация, ассеты и т.д.
```

## Технологии

- **Язык:** Swift 5.9+
- **UI:** UIKit (без SwiftUI)
- **Архитектура:** MVVM + Coordinator
- **Хранение данных:** 
  - `Core Data` с `NSPersistentCloudKitContainer`
  - `Realm` через SPM
- **Поиск:** `UISearchController`
- **Сортировка:** встроенная по дате и статусу
- **Локализация:** английская (Base.lproj)
- **Тестирование:** частичная поддержка через `XCTest`
- **SPM-зависимости:** только Realm, остальное — чистый Xcode-проект

## Установка

1. Склонируйте репозиторий:
   git clone https://github.com/ваш-аккаунт/TaskList.git

2. Откройте `.xcodeproj`:
   open TaskList/TaskList.xcodeproj

3. Убедитесь, что выбран target `TaskList` и сборка производится на симуляторе с iOS 17+.

4. Соберите и запустите проект (Cmd + R).

## Заметки

- Хранилище можно переключить, подставив нужную реализацию `Storage` при запуске.
- Данные и модели хранения (`TaskListEntity`, `TaskListObject`) не пересекаются с UI.
- UI не зависит от фреймворка хранения и может быть расширен без модификации контроллеров.

## Автор

Алексей Ефимов  
[GitHub](https://github.com/LexDeBash)  
[LinkedIn](https://www.linkedin.com/in/алексей-ефимов-965068129)  
[Telegram](https://t.me/debash)
Email: lex.efimov@gmail.com
