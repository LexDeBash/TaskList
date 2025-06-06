# TaskList

**TaskList** — iOS-приложение для управления списками задач. Пользователь может создавать списки, добавлять задачи, редактировать их, отмечать как выполненные и сортировать по дате или статусу. Проект построен на базе UIKit и реализует чистую архитектуру с разделением по слоям.


## Возможности

- Создание и удаление списков задач
- Добавление и редактирование задач
- Сортировка задач по дате создания или статусу (выполнено / не выполнено)
- Сохранение данных с помощью Core Data и Realm (взаимозаменяемые реализации)
- Чистая архитектура с использованием MVVM и Coordinator

## Архитектура

Проект реализует принцип разделения ответственности:

- `MVVM`: каждая сцена (TaskLists, Tasks, TaskEditor) имеет свой ViewModel с бизнес-логикой
- `Coordinator`: управление навигацией вынесено в отдельные объекты
- `Storage`: абстракция над слоем хранения данных (Core Data и Realm)
- `DTO`: модель представления изолирована от модели хранения

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

## Контакты

Алексей Ефимов  
[iOS-разработчик на LinkedIn](https://www.linkedin.com/in/алексей-ефимов-965068129)  
[GitHub: LexDeBash](https://github.com/LexDeBash)  
[Telegram: @debash](https://t.me/debash)  
Email: lex.efimov@gmail.com
