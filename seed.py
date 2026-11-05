import argparse
import random
import sqlite3
from pathlib import Path

from faker import Faker


BASE_DIR = Path(__file__).resolve().parent
DEFAULT_DB = BASE_DIR / "task_manager.db"
STATUSES = ("new", "in progress", "completed")


def seed_database(db_path: Path, user_count: int, task_count: int) -> None:
    fake = Faker("uk_UA")

    with sqlite3.connect(db_path) as connection:
        connection.execute("PRAGMA foreign_keys = ON")
        connection.executescript((BASE_DIR / "schema.sql").read_text(encoding="utf-8"))
        connection.executemany(
            "INSERT OR IGNORE INTO status (name) VALUES (?)",
            ((status,) for status in STATUSES),
        )

        users = [
            (fake.name()[:100], fake.unique.email()[:100])
            for _ in range(user_count)
        ]
        connection.executemany(
            "INSERT INTO users (fullname, email) VALUES (?, ?)",
            users,
        )

        user_ids = [
            row[0]
            for row in connection.execute("SELECT id FROM users").fetchall()
        ]
        status_ids = [
            row[0]
            for row in connection.execute("SELECT id FROM status").fetchall()
        ]

        if task_count and not user_ids:
            raise ValueError("Cannot create tasks without users.")

        tasks = [
            (
                fake.sentence(nb_words=6)[:100],
                fake.paragraph() if random.choice((True, False)) else None,
                random.choice(status_ids),
                random.choice(user_ids),
            )
            for _ in range(task_count)
        ]
        connection.executemany(
            """
            INSERT INTO tasks (title, description, status_id, user_id)
            VALUES (?, ?, ?, ?)
            """,
            tasks,
        )


def main() -> None:
    parser = argparse.ArgumentParser(description="Seed the task manager database.")
    parser.add_argument("--db", type=Path, default=DEFAULT_DB, help="SQLite database path")
    parser.add_argument("--users", type=int, default=10, help="Number of users to add")
    parser.add_argument("--tasks", type=int, default=30, help="Number of tasks to add")
    args = parser.parse_args()

    if args.users < 0 or args.tasks < 0:
        parser.error("--users and --tasks must be non-negative")

    seed_database(args.db, args.users, args.tasks)


if __name__ == "__main__":
    main()
