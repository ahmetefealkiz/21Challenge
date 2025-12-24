/// DAY 4: Vector + Ownership Basics
/// 
/// Today you will:
/// 1. Learn about vectors
/// 2. Create a list of habits
/// 3. Understand basic ownership concepts

module challenge::day_04 {
    use std::ascii::String;

    // Copy the Habit struct from day_03
    public struct	Habit has copy, drop
	{
        name:		String,
        completed:	bool,
    }

    public fun	new_habit(name: String): Habit
	{
        Habit {
            name,
            completed: false,
        }
    }

    // TODO: Create a struct called 'HabitList' with:
    // - habits: vector<Habit>
    // Add 'drop' ability (not copy, because vectors can't be copied)
    // public struct HabitList has drop {
    //     // Your field here
    // }
	public struct	HabitList has drop
	{
		habits:	vector<Habit>
	}


    // TODO: Write a function 'empty_list' that returns an empty HabitList
    // public fun empty_list(): HabitList {
    //     // Use vector::empty() to create an empty vector
    // }
	public fun empty_list(): HabitList
	{
		HabitList { habits: vector::empty() }
	}

    // TODO: Write a function 'add_habit' that takes:
    // - list: &mut HabitList (mutable reference)
    // - habit: Habit (by value, transfers ownership)
    // Use vector::push_back to add the habit
    // public fun add_habit(list: &mut HabitList, habit: Habit) {
    //     // Your code here
    // }
	public fun	add_habit(list: &mut HabitList, habit: Habit)
	{
		vector::push_back(&mut list.habits, habit)
	}
}

