/// DAY 7: Unit Tests for Habit Tracker
///
/// Today you will:
/// 1. Learn how to write tests in Move
/// 2. Write tests for your habit tracker
/// 3. Use assert! macro
///
/// Note: You can copy code from day_06/sources/solution.move if needed

module challenge::day_07 {
    use std::string::{Self, String};

    // Copy from day_06: Habit struct with String
    public struct Habit has copy, drop {
        name: String,
        completed: bool,
    }

    public struct HabitList has drop {
        habits: vector<Habit>,
    }

    public fun new_habit(name: String): Habit {
        Habit {
            name,
            completed: false,
        }
    }

    public fun make_habit(name_bytes: vector<u8>): Habit {
        let name = string::utf8(name_bytes);
        new_habit(name)
    }

    public fun empty_list(): HabitList {
        HabitList {
            habits: vector::empty(),
        }
    }

    public fun add_habit(list: &mut HabitList, habit: Habit) {
        vector::push_back(&mut list.habits, habit);
    }

    public fun complete_habit(list: &mut HabitList, index: u64) {
        let len = vector::length(&list.habits);
        if (index < len) {
            let habit = vector::borrow_mut(&mut list.habits, index);
            habit.completed = true;
        }
    }

    // Note: assert! is a built-in macro in Move 2024 - no import needed!

    // TODO: Write a test 'test_add_habits' that:
    // - Creates an empty list
    // - Adds 1-2 habits
    // - Checks that the list length is correct
    // #[test]
    // fun test_add_habits() {
    //     // Your code here
    //     // Use b"Exercise".to_string() to create a String
    // }
	#[test]
	fun	test_add_habits()
	{
		let	mut habit_list = empty_list();
		let	habit1 = new_habit(b"habit1".to_string());
		let	habit2  = new_habit(b"habit2".to_string());

		add_habit(&mut habit_list, habit1);
		add_habit(&mut habit_list, habit2);
		let	len	= vector::length(&habit_list.habits);
		assert!(len == 2, 0);
	}

    // TODO: Write a test 'test_complete_habit' that:
    // - Creates a list and adds a habit
    // - Completes the habit
    // - Checks that completed == true
    // #[test]
    // fun test_complete_habit() {
    //     // Your code here
    // }
	#[test]
	fun	test_complete_habit()
	{
		let	mut habit_list = empty_list();
		let	habit1 = new_habit(b"habit1".to_string());

		add_habit(&mut habit_list, habit1);
		complete_habit(&mut habit_list, 0);
		let	complete_habit = vector::borrow(&habit_list.habits, 0);
		assert!(complete_habit.completed == true, 0);
	}
}

