
# TaskCLI — Simple Command-Line Task Manager 📝

A lightweight command-line task manager written in **Elixir**.  
Create, list, complete, and save your tasks — all from your terminal!

---

## ✨ Features

- Add new tasks
- List all pending tasks
- Mark tasks as completed
- Save and load tasks from a file
- (Stretch) Periodically remind about pending tasks (using concurrency)

---

## 🚀 Getting Started

### Prerequisites

- [Elixir](https://elixir-lang.org/install.html) installed (version 1.14 or later recommended)

### Installation

Clone the repository:

```bash
git clone https://github.com/LolsonX/task_cli
cd task_cli

Fetch dependencies:

`mix deps.get`

Run application:
`mix run`


## 🛠️ Usage
Example commands you can implement:
```bash
> add "Buy groceries"
> list
> done 1
> save
> load
```


## Run tests
`mix test`

## 🧠 What I Learned
- Pattern matching and recursion
- Handling IO in Elixir
- Working with processes (optional reminders)
- Basic file reading and writing
- Structuring small Elixir apps

## 📦 Stretch Goals (Optional)

- Add a background reminder process (Task + Process.send_after)
- Support task priorities (high, medium, low)
- Colorize terminal output (using IO.ANSI)

## 📄 License

This project is licensed under the MIT License.
Feel free to use it, modify it, and make it better! 🚀
## 🙌 Acknowledgments

- Elixir School
- Programming Elixir Book
