/// DAY 14: Tests for Bounty Board
/// 
/// Today you will:
/// 1. Write comprehensive tests
/// 2. Test all the functions you've created
/// 3. Practice test organization
///
/// Note: You can copy code from day_13/sources/solution.move if needed

module challenge::day_14 {
    use std::string::String;

    #[test_only]
    use std::unit_test::assert_eq;
    use std::string;

    // Copy from day_13: All structs and functions
    public enum TaskStatus has copy, drop {
        Open,
        Completed,
    }

    public struct Task has copy, drop {
        title: String,
        reward: u64,
        status: TaskStatus,
    }

    public struct TaskBoard has drop {
        owner: address,
        tasks: vector<Task>,
    }

    public fun new_task(title: String, reward: u64): Task {
        Task {
            title,
            reward,
            status: TaskStatus::Open,
        }
    }

    public fun new_board(owner: address): TaskBoard {
        TaskBoard {
            owner,
            tasks: vector::empty(),
        }
    }

    public fun add_task(board: &mut TaskBoard, task: Task) {
        vector::push_back(&mut board.tasks, task);
    }

    public fun complete_task(task: &mut Task) {
        task.status = TaskStatus::Completed;
    }

    public fun total_reward(board: &TaskBoard): u64 {
        let len = vector::length(&board.tasks);
        let mut total = 0;
        let mut i = 0;
        while (i < len) {
            let task = vector::borrow(&board.tasks, i);
            total = total + task.reward;
            i = i + 1;
        };
        total
    }

    public fun completed_count(board: &TaskBoard): u64 {
        let len = vector::length(&board.tasks);
        let mut count = 0;
        let mut i = 0;
        while (i < len) {
            let task = vector::borrow(&board.tasks, i);
            if (task.status == TaskStatus::Completed) {
                count = count + 1;
            };
            i = i + 1;
        };
        count
    }

    // Note: assert! is a built-in macro in Move 2024 - no import needed!

    // TODO: Write at least 3 tests:
    // 
    // Test 1: test_create_board_and_add_task
    // - Create a board with an owner
    // - Add a task
    // - Verify the task was added
    // 
    // Test 2: test_complete_task
    // - Create board, add tasks
    // - Complete a task
    // - Verify completed_count is correct
    // 
    // Test 3: test_total_reward
    // - Create board, add multiple tasks with different rewards
    // - Verify total_reward is correct
    // 
    // #[test]
    // fun test_create_board_and_add_task() {
    //     // Your code here
    // }
	#[test]
	fun test_create_board_and_add_task() {
		let mut board;
		let task;

		task = new_task(string::utf8(b"task"), 100);
		board = new_board(@0x1);

		add_task(&mut board, task);

		assert_eq!(vector::length(&board.tasks), 1);
	}

	#[test]
	fun test_complete_task() {
		let mut board;
		let task1;
		let task2;
		let task_to_complete;

		board = new_board(@0x1);
		task1 = new_task(string::utf8(b"task_1"), 100);
		task2 = new_task(string::utf8(b"task_2"), 100);

		add_task(&mut board, task1);
		add_task(&mut board, task2);

		task_to_complete = vector::borrow_mut(&mut board.tasks, 0);
		complete_task(task_to_complete);

		assert_eq!(completed_count(&board), 1);
	}

	#[test]
	fun test_total_reward() {
		let mut board;
		let task1;
		let task2;
		let task3;

		board = new_board(@0x1);
		task1 = new_task(string::utf8(b"task_1"), 50);
		task2 = new_task(string::utf8(b"task_2"), 100);
		task3 = new_task(string::utf8(b"task_3"), 150);

		add_task(&mut board, task1);
		add_task(&mut board, task2);
		add_task(&mut board, task3);

		assert_eq!(total_reward(&board), 300);
	}
}

